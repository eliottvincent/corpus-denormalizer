# @Author: eliottvincent
# @Date:   2019-01-08T14:44:38+01:00
# @Email:  evincent@enssat.fr
# @Last modified by:   eliottvincent
# @Last modified time: 2019-01-09T10:50:19+01:00
# @License: MIT
# @Copyright: © 2019 ENSSAT. All rights reserved.



#!/bin/bash

echo hello
cd /home/moses/

mosesdecoder/bin/lmplz -o 3 \
  < corpus/europarl-v7-fr-10000-normdenorm/europarl-v7-fr-10000.denormalized.txt \
  > corpus/europarl-v7-fr-10000-normdenorm/europarl-v7-fr-10000.denormalized.arpa.txt

mosesdecoder/bin/build_binary \
  corpus/europarl-v7-fr-10000-normdenorm/europarl-v7-fr-10000.denormalized.arpa.txt \
  corpus/europarl-v7-fr-10000-normdenorm/europarl-v7-fr-10000.denormalized.blm.txt

echo "reprise de la session" \
  | mosesdecoder/bin/query corpus/europarl-v7-fr-10000-normdenorm/europarl-v7-fr-10000.denormalized.blm.txt



# cat corpus/europarl-v7-fr-10000-normdenorm/europarl-v7-fr-10000.denormalized.txt
