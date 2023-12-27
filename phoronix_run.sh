#! /bin/bash


export IR2VEC_PATH="/home/nishu/nishant/ir2vec_llvm/build-llvm/lib/LLVMHelloIR2Vec.so" \
export VOCAB_PATH="/home/nishu/nishant/ir2vec_llvm/ml-llvm-project/IR2Vec/vocabulary/seedEmbeddingVocab-300-llvm10.txt" \
export CPP=/home/nishu/nishant/ir2vec_llvm/install/bin/clang-cpp \
export CC=/home/nishu/nishant/ir2vec_llvm/install/bin/clang-10 \
export CFLAGS="-ftime-report -Xclang -load -Xclang $IR2VEC_PATH -mllvm -vocab=$VOCAB_PATH" \
export CXXFLAGS="-ftime-report -Xclang -load -Xclang $IR2VEC_PATH -mllvm -vocab=$VOCAB_PATH"

# clang_path="/home/nishu/nishant/ir2vec_llvm/install/bin/clang-10"

# command="$clang_path -Xclang -load -Xclang $ir2vec_pass_path -mllvm -vocab=$vocab_path -O3 "$@""