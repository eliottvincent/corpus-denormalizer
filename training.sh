# @Author: eliottvincent
# @Date:   2019-01-09T10:55:22+01:00
# @Email:  evincent@enssat.fr
# @Last modified by:   eliottvincent
# @Last modified time: 2019-01-09T15:21:04+01:00
# @License: MIT
# @Copyright: © 2018 Productmates. All rights reserved.


#!/bin/bash

echo hello

export MOSES_PATH=/home/moses/mosesdecoder
export HOME_PATH=/home
LINES=1000

mkdir "$HOME_PATH/lm/europarl-v7-fr-normdenorm"

# the language model (LM) is used to ensure fluent output
# so it is built with the target language
$MOSES_PATH/bin/lmplz -o 3 \
  < "$HOME_PATH/corpus/europarl-v7-fr-normdenorm/europarl-v7-fr-$LINES.denorm" \
  > "$HOME_PATH/lm/europarl-v7-fr-normdenorm/europarl-v7-fr-$LINES.arpa.denorm"

# binarise (for faster loading) the *.arpa.txt file using KenLM
$MOSES_PATH/bin/build_binary \
  "$HOME_PATH/lm/europarl-v7-fr-normdenorm/europarl-v7-fr-$LINES.arpa.denorm" \
  "$HOME_PATH/lm/europarl-v7-fr-normdenorm/europarl-v7-fr-$LINES.blm.denorm"

# check the language model by querying it
echo "reprise de la session" \
  | $MOSES_PATH/bin/query "$HOME_PATH/lm/europarl-v7-fr-normdenorm/europarl-v7-fr-$LINES.blm.denorm"

# training model
# 1. Prepare data
# 2. Run GIZA++
# 3. Align words
# 4. Get lexical translation table
# 5. Extract phrases
# 6. Score phrases
# 7. Build reordering model
# 8. Build generation models
# 9. Create configuration file
echo "------TRAINING------"
nohup nice $MOSES_PATH/scripts/training/train-model.perl \
  --parallel \
  -root-dir train \
  --first-step 1 \
  -corpus "$HOME_PATH/corpus/europarl-v7-fr-normdenorm/europarl-v7-fr-$LINES" \
  --f denorm --e norm \
  -lm 0:3:$HOME_PATH/lm/europarl-v7-fr-normdenorm/europarl-v7-fr-${LINES}.blm.denorm:8 \
  -external-bin-dir $MOSES_PATH/tools >& "$HOME_PATH/working/training.out" &
tail -f "$HOME_PATH/working/training.out"
echo "------TRAINING------"
