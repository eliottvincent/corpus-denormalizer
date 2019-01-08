# @Author: eliottvincent
# @Date:   2019-01-08T14:44:38+01:00
# @Email:  evincent@enssat.fr
# @Last modified by:   eliottvincent
# @Last modified time: 2019-01-08T15:09:02+01:00
# @License: MIT
# @Copyright: © 2018 Productmates. All rights reserved.


#!/bin/bash

echo hello

# The tokenisation can be run as follows
/home/moses/mosesdecoder/scripts/tokenizer/tokenizer.perl -l fr \
  < /home/moses/corpus/training/news-commentary-v8.fr-en.fr \
  > /home/moses/corpus/news-commentary-v8.fr-en.tok.fr

# The truecaser first requires training, in order to extract some statistics about the text
/home/moses/mosesdecoder/scripts/recaser/train-truecaser.perl \
  --model /home/moses/corpus/truecase-model.fr --corpus     \
  /home/moses/corpus/news-commentary-v8.fr-en.tok.fr

# Truecasing uses another script from the Moses distribution
/home/moses/mosesdecoder/scripts/recaser/truecase.perl \
  --model /home/moses/corpus/truecase-model.fr         \
  < /home/moses/corpus/news-commentary-v8.fr-en.tok.fr \
  > /home/moses/corpus/news-commentary-v8.fr-en.true.fr

# Finally we clean, limiting sentence length to 80
/home/moses/mosesdecoder/scripts/training/clean-corpus-n.perl \
  /home/moses/corpus/news-commentary-v8.fr-en.true fr en \
  /home/moses/corpus/news-commentary-v8.fr-en.clean 1 80
