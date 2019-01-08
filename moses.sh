# @Author: eliottvincent
# @Date:   2019-01-08T14:44:38+01:00
# @Email:  evincent@enssat.fr
# @Last modified by:   eliottvincent
# @Last modified time: 2019-01-08T15:24:20+01:00
# @License: MIT
# @Copyright: © 2019 ENSSAT. All rights reserved.


#!/bin/bash

echo hello
cd /home/moses/

# The tokenisation can be run as follows
mosesdecoder/scripts/tokenizer/tokenizer.perl -l en \
  < corpus/training/news-commentary-v8.fr-en.en    \
  > corpus/news-commentary-v8.fr-en.tok.en
mosesdecoder/scripts/tokenizer/tokenizer.perl -l fr \
  < corpus/training/news-commentary-v8.fr-en.fr    \
  > corpus/news-commentary-v8.fr-en.tok.fr


# The truecaser first requires training, in order to extract some statistics about the text
mosesdecoder/scripts/recaser/train-truecaser.perl \
  --model corpus/truecase-model.en --corpus     \
  corpus/news-commentary-v8.fr-en.tok.en
mosesdecoder/scripts/recaser/train-truecaser.perl \
  --model corpus/truecase-model.fr --corpus     \
  corpus/news-commentary-v8.fr-en.tok.fr

# Truecasing uses another script from the Moses distribution
mosesdecoder/scripts/recaser/truecase.perl \
  --model corpus/truecase-model.en         \
  < corpus/news-commentary-v8.fr-en.tok.en \
  > corpus/news-commentary-v8.fr-en.true.en
mosesdecoder/scripts/recaser/truecase.perl \
  --model corpus/truecase-model.fr         \
  < corpus/news-commentary-v8.fr-en.tok.fr \
  > corpus/news-commentary-v8.fr-en.true.fr

# Finally we clean, limiting sentence length to 80
mosesdecoder/scripts/training/clean-corpus-n.perl \
  corpus/news-commentary-v8.fr-en.true fr en \
  corpus/news-commentary-v8.fr-en.clean 1 80
