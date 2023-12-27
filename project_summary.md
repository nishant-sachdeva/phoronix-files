# Summary

* Adding a summary here, so as to quickly be able to get a run through of what the project is about

* The target of the project is to run phoronix-test-suite benchmarks, with IR2Vec.
* We need to record time, performance etc when doing the same.

## Prerequisites

* Having a working knowledge of how to compile and run the IR2Vec source code.
* Having a precursor knowledge of LLVM.

* Following is a description of the various components of this project
    * Phoronix test Suite [link](https://github.com/phoronix-test-suite/phoronix-test-suite)
        * Downloading, installing and running a test/test-suite
            * Instructions are available on the [repository](https://github.com/phoronix-test-suite/phoronix-test-suite/blob/master/documentation/phoronix-test-suite.md#installation-instructions)
        * Virtual Test Suites
            * phoronix-test-suite has a virtual suite, `pts/compiler`.
                * Learn more about Virtual Test Suite [here](https://github.com/phoronix-test-suite/phoronix-test-suite/blob/master/documentation/phoronix-test-suite.md#virtual-test-suites)
            * For local testing purposes, we don't use the virtual suite, we use a regular testbench called `pts/polybench-c`
        * Compiler Masking
            * To test out various compilation options, flags etc, we use `compiler masking` with Phoronix Test Suite.
            * Learn more about Compiler Masking [here](https://github.com/phoronix-test-suite/phoronix-test-suite/blob/master/documentation/phoronix-test-suite.md#compiler-testing--masking)
            * Here's how we use compiler masking with Phoronix Test Suite
                * We find out the exact clang command that we need to execute the test-bench/suite compilation with
                    * We want to generate IR2Vec embeddings during the test bench installation. So we need to compile with clang, whilst executing the IR2Vec pass.
                    * Normally, the pipeline for running a custom pass goes as follows
                        * Compile , using clang, into .ll files
                        * Compile the .ll files with the IR2Vec pass ( or any other pass of your choice ) , using `opt`
                    * However, with compiler masking, we can only replace the CC/CXX flags. So, we have to figure out how to do the entire compilation with the custom pass using a single command.
                    * We figured out the command
                        * `install/bin/clang-10 -ftime-report -Xclang -load -Xclang /home/nishu/nishant/ir2vec_llvm/build-llvm/lib/LLVMHelloIR2Vec.so -mllvm -vocab=ml-llvm-project/IR2Vec/vocabulary/seedEmbeddingVocab-300-llvm10.txt -O3 test.c`
                        * Here, `/install/bin/clang-10` is the location of the installed clang binary.
                        * We use the t `-ftime-repor,` `-Xclang`, `-mllvm` flags to provide further options for running our compilation. The other values specified here are as required by the `Hello-IR2Vec` pass.
                        * This compilation produces the executable along with the IR2Vec bindings, and a full time report detailing out all compilation passes.
                * So, once we find out the exact command as required for a single-step end to end compilation, we create an executable file, which contains the CC, CXX, CFLAGS, CXXFLAGS enviroment variables.
                * 
                ```bash
                export IR2VEC_PATH="/home/nishu/nishant/ir2vec_llvm/build-llvm/lib/LLVMHelloIR2Vec.so" \
                export VOCAB_PATH="/home/nishu/nishant/ir2vec_llvm/ml-llvm-project/IR2Vec/vocabulary/seedEmbeddingVocab-300-llvm10.txt" \
                export CPP=/home/nishu/nishant/ir2vec_llvm/install/bin/clang-cpp \
                export CC=/home/nishu/nishant/ir2vec_llvm/install/bin/clang-10 \
                export CFLAGS="-ftime-report -Xclang -load -Xclang $IR2VEC_PATH -mllvm -vocab=$VOCAB_PATH" \
                export CXXFLAGS="-ftime-report -Xclang -load -Xclang $IR2VEC_PATH -mllvm -vocab=$VOCAB_PATH"
                ```
                * We then source this file, into our runtime environment, using `source phoronix_variables.sh` command, where `phoronix_variables.sh` is the file that contains these environment variables.
                * Once sourced, we run the appropriate phoronix command to install our testbench/test-suite.

    * ml-llvm project
        * Taking a little detour here to understand the ml-llvm tools installation.
        * The compilation instructions for the ml-llvm project as as follows
            * Git pull. Use the `--recursive` option that's mentioned in the Readme.
            * The script we used to compile the ml-llvm project tools is 
                * 
                ```bash
                build_llvm=`pwd`/build-llvm
                installprefix=`pwd`/install
                llvm=`pwd`/ml-llvm-project
                mkdir -p $build_llvm
                mkdir -p $installprefix

                cmake -G Ninja -S $llvm/llvm -B $build_llvm \
                    -DLLVM_INSTALL_UTILS=ON \
                    -DCMAKE_INSTALL_PREFIX=$installprefix \
                    -DCMAKE_BUILD_TYPE=Release \
                    -DLLVM_TARGETS_TO_BUILD=host \
                    -DLT_LLVM_INSTALL_DIR="/usr/bin/llvm-config-10" \
                    -DEigen3_DIR="/home/nishu/nishant/ir2vec_llvm/eigen-build/" \
                    -DLLVM_ENABLE_PROJECTS="IR2Vec;clang;"

                ninja -C $build_llvm install
                ```
                * Note here that we are differing from the project readme.
                * The Readme has instructions to compile the entire project including the relevant ml tools.
                * We don't need that. So, we instead compile `IR2Vec;clang`
                    * ( We also ended up removing the `demoGrpcPass`, but that may not be required here since we've already removed the ml-llvm-tools from the compilation. )
                * The IR2Vec pass is located in the `llvm/lib/Transforms/Hello_IR2Vec` path.

    * Recording the installation results
        - Changed Ir2Vec pass to print output to a third file. We can now see what embeddings are generated.
        - We can have the time taken by the pass, using the `-ftime-report` option in clang.
        - phoronix-test-suite has a flag `-force-install` that forces installation of test every time.
            - So we don't have to run the full benchmark just to see the impact of IR2Vec pass.
        - phoronix-test-suite has a user option `SaveInstallationLogs`, that's located in the file `~/.phoronix-test.suite/user-config.xml`. If set to TRUE, it records compilation output in an `install.log` file in the `installed-tests` folder under your particular test.
        - These steps let us track the time taken for compilation. And specifically, the share of time taken by the IR2Vec pass.

Yet to see if this full option is available for an entire suite, or just the tests.

