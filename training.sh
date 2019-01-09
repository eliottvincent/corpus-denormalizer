# @Author: eliottvincent
# @Date:   2019-01-09T10:55:22+01:00
# @Email:  evincent@enssat.fr
# @Last modified by:   eliottvincent
# @Last modified time: 2019-01-09T12:05:52+01:00
# @License: MIT
# @Copyright: © 2018 Productmates. All rights reserved.


#!/bin/bash

echo hello

export MOSES_PATH=/home/moses/mosesdecoder
export HOME_PATH=/home

mkdir "$HOME_PATH/lm/europarl-v7-fr-10000-normdenorm"

# the language model (LM) is used to ensure fluent output
# so it is built with the target language
$MOSES_PATH/bin/lmplz -o 3 \
  < "$HOME_PATH/corpus/europarl-v7-fr-10000-normdenorm/europarl-v7-fr-10000.denormalized.txt" \
  > "$HOME_PATH/lm/europarl-v7-fr-10000-normdenorm/europarl-v7-fr-10000.denormalized.arpa.txt"

# binarise (for faster loading) the *.arpa.txt file using KenLM
$MOSES_PATH/bin/build_binary \
  "$HOME_PATH/lm/europarl-v7-fr-10000-normdenorm/europarl-v7-fr-10000.denormalized.arpa.txt" \
  "$HOME_PATH/lm/europarl-v7-fr-10000-normdenorm/europarl-v7-fr-10000.denormalized.blm.txt"

# check the language model by querying it
echo "reprise de la session" \
  | $MOSES_PATH/bin/query "$HOME_PATH/lm/europarl-v7-fr-10000-normdenorm/europarl-v7-fr-10000.denormalized.blm.txt"

# training model
echo "------TRAINING------"
nohup nice $MOSES_PATH/scripts/training/train-model.perl --verbose \
  -root-dir train \
  -corpus "$HOME_PATH/corpus/europarl-v7-fr-10000-normdenorm/europarl-v7-fr-10000.denormalized.txt" \
  -lm 0:3:$HOME_PATH/lm/europarl-v7-fr-10000-normdenorm/europarl-v7-fr-10000.denormalized.blm.txt:8 \
  -external-bin-dir $MOSES_PATH/tools >& "$HOME_PATH/working/training.out" &
tail -f working/training.out
echo "------TRAINING------"
