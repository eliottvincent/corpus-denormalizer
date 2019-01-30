# @Author: eliottvincent
# @Date:   2019-01-09T10:55:22+01:00
# @Email:  evincent@enssat.fr
# @Last modified by:   eliottvincent
# @Last modified time: 2019-01-30T15:20:34+01:00
# @License: MIT
# @Copyright: © 2018 Productmates. All rights reserved.


#!/bin/bash

# Variables
#
HOME_PATH=/home
MOSES_PATH=/home/moses/mosesdecoder
NORMALIZER_PATH=/home/irisa-text-normalizer
LINES_COUNT=1000


prepare_corpus() {
  {
    # Keep only first n lines
    echo "$(head -$LINES_COUNT "$HOME_PATH/corpus/europarl-v7.fr-en.fr")" > "$HOME_PATH/corpus/europarl-v7.fr-en.fr" &&

    echo '✅ prepare_corpus succeeded'
    } || {
    echo '❌ prepare_corpus failed'
    return 1
  }
}


# clean_corpus_moses() {
#   {
#     # Clean corpus (using Moses script) - OLD
#     #
#     # example: 'clean-corpus-n.perl CORPUS L1 L2 OUT MIN MAX'
#     #   takes the corpus files CORPUS.L1 and CORPUS.L2...
#     #   ...deletes lines longer than MAX...
#     #   ...and creates the output files clean.L1 and clean.L2
#     $MOSES_PATH/scripts/training/clean-corpus-n.perl \
  #       "$HOME_PATH/corpus/europarl-v7.fr-en" fr en \
  #       "$HOME_PATH/corpus/europarl-v7.fr-en.clean" 1 80
#
#     echo 'clean_corpus_moses succeeded'
#     } || {
#     echo 'clean_corpus_moses failed'
#     return 1
#   }
# }


# Clean corpus
#
clean_corpus_homemade() {
  {
    # - create working copy
    cp "$HOME_PATH/corpus/europarl-v7.fr-en.fr" "$HOME_PATH/corpus/europarl-v7.fr-en.wip.fr" &&
    wc -l "$HOME_PATH/corpus/europarl-v7.fr-en.wip.fr" &&


    # - remove empty lines
    sed -i '/^$/d' "$HOME_PATH/corpus/europarl-v7.fr-en.wip.fr" &&
    echo "- removed empty lines" &&
    wc -l "$HOME_PATH/corpus/europarl-v7.fr-en.wip.fr" &&

    # - remove lines w/ one character
    sed -i '/^.$/d' "$HOME_PATH/corpus/europarl-v7.fr-en.wip.fr" &&
    echo "- removed lines w/ one character" &&
    wc -l "$HOME_PATH/corpus/europarl-v7.fr-en.wip.fr" &&

    # - remove lines w/ more words than necessary (80 by default)
    awk '{
    if (NF < 80)
           print $0 > "'"$HOME_PATH"'/corpus/europarl-v7.fr-en.wip.awk.fr";
    }' "$HOME_PATH/corpus/europarl-v7.fr-en.wip.fr" &&
    cp "$HOME_PATH/corpus/europarl-v7.fr-en.wip.awk.fr" "$HOME_PATH/corpus/europarl-v7.fr-en.wip.fr" &&
    # rename back to '.wip.fr' (we need to use a tmp output file with awk)
    echo "- removed lines w/ more than 80 words" &&
    wc -l "$HOME_PATH/corpus/europarl-v7.fr-en.wip.fr" &&

    # - remplacer les “ - “ par “-”. Dans le cas contraire, on obtient des retours à la ligne dans le corpus normalisé (en sortie du module de Mr Lecorvé) à chaque fois que cette expression apparaît.
    sed -i "s/ - /-/g" "$HOME_PATH/corpus/europarl-v7.fr-en.wip.fr" &&
    echo "- replaced ' - ' with '-'" &&
    wc -l "$HOME_PATH/corpus/europarl-v7.fr-en.wip.fr" &&

    # remove all square brackets
    sed -i "s/[][]//g" "$HOME_PATH/corpus/europarl-v7.fr-en.wip.fr" &&
    echo "- removed '[' & ']'" &&
    wc -l "$HOME_PATH/corpus/europarl-v7.fr-en.wip.fr" &&


    # create final cleaned files
    cp "$HOME_PATH/corpus/europarl-v7.fr-en.wip.fr" "$HOME_PATH/corpus/europarl-v7.fr-en.clean.fr" &&
    cp "$HOME_PATH/corpus/europarl-v7.fr-en.clean.fr" "$HOME_PATH/corpus/europarl-v7.fr-en.fr.denorm" &&
    echo "- created final cleaned files" &&

    echo '✅ clean_corpus_homemade succeeded'
    } || {
    echo '❌ clean_corpus_homemade failed'
    return 1
  }
}


# Normalize corpus
#
normalize_corpus() {
  {
    # - apply tokenisation
    perl "$NORMALIZER_PATH/bin/fr/basic-tokenizer.pl" -v \
      "$HOME_PATH/corpus/europarl-v7.fr-en.clean.fr" > "$HOME_PATH/corpus/europarl-v7.fr-en.fr.norm" &&
    # - apply generic normalization
    perl "$NORMALIZER_PATH/bin/fr/start-generic-normalisation.pl" -v \
      "$HOME_PATH/corpus/europarl-v7.fr-en.fr.norm" > "$HOME_PATH/corpus/europarl-v7.fr-en.fr.norm.step1" &&
    perl "$NORMALIZER_PATH/bin/fr/end-generic-normalisation.pl" -v \
      "$HOME_PATH/corpus/europarl-v7.fr-en.fr.norm.step1" > "$HOME_PATH/corpus/europarl-v7.fr-en.fr.norm.step2" &&
    # - apply specific normalization (with nlp config)
    perl "$NORMALIZER_PATH/bin/fr/specific-normalisation.pl" -v \
      "$NORMALIZER_PATH/cfg/nlp.cfg" "$HOME_PATH/corpus/europarl-v7.fr-en.fr.norm.step2" > "$HOME_PATH/corpus/europarl-v7.fr-en.fr.norm.nlp" &&


    # create final cleaned file
    cp "$HOME_PATH/corpus/europarl-v7.fr-en.fr.norm.nlp" "$HOME_PATH/corpus/europarl-v7.fr-en.fr.norm" &&

    echo '✅ normalize_corpus succeeded'
    } || {
    echo '❌ normalize_corpus failed'
    return 1
  }
}


# Clean corpus again (after normalization)
#
clean_corpus_again() {
  {
    # - remove empty lines
    sed -i '/^$/d' "$HOME_PATH/corpus/europarl-v7.fr-en.fr.norm" &&
    # - remove line w/ one character
    sed -i '/^.$/d' "$HOME_PATH/corpus/europarl-v7.fr-en.fr.norm" &&

    echo '✅ clean_corpus_again succeeded'
    } || {
    echo '❌ clean_corpus_again failed'
    return 1
  }
}

# Prepare moses
#
prepare_moses() {
  {
    # the language model (LM) is used to ensure fluent output
    # so it is built with the target language
    $MOSES_PATH/bin/lmplz -o 3 \
      < "$HOME_PATH/corpus/europarl-v7.fr-en.fr.denorm" \
      > "$HOME_PATH/lm/europarl-v7.fr-en.fr.arpa.denorm" &&

    # binarise (for faster loading) the *.arpa.denorm file using KenLM
    $MOSES_PATH/bin/build_binary \
      "$HOME_PATH/lm/europarl-v7.fr-en.fr.arpa.denorm" \
      "$HOME_PATH/lm/europarl-v7.fr-en.fr.blm.denorm" &&

    # check the language model by querying it
    echo "reprise de la session" \
      | $MOSES_PATH/bin/query "$HOME_PATH/lm/europarl-v7.fr-en.fr.arpa.denorm" &&

    echo '✅ prepare_moses succeeded'
    } || {
    echo '❌ prepare_moses failed'
    return 1
  }
}

# Launch moses training
#
launch_training() {
  {
    # 1. Prepare data
    # 2. Run GIZA++
    # 3. Align words
    # 4. Get lexical translation table
    # 5. Extract phrases
    # 6. Score phrases
    # 7. Build reordering model
    # 8. Build generation models
    # 9. Create configuration file
    $MOSES_PATH/scripts/training/train-model.perl \
      --verbose \
      --parallel \
      --root-dir training \
      --first-step 1 \
      --corpus "$HOME_PATH/corpus/europarl-v7.fr-en.fr" \
      --f norm --e denorm \
      -lm 0:3:$HOME_PATH/lm/europarl-v7.fr-en.fr.blm.denorm:8 \
      -external-bin-dir $MOSES_PATH/tools &&
    # -external-bin-dir $MOSES_PATH/tools >& "$HOME_PATH/working/training.out" &
    # tail -f "$HOME_PATH/working/training.out"
    du -hs "$HOME_PATH/training" &&
    cat "$HOME_PATH/training/model/moses.ini" &&

    echo '✅ launch_training succeeded'
    } || {
    echo '❌ launch_training failed'
    return 1
  }
}


# Post training (wip)
#
post_training() {
  {
    echo "$(tail -10 "$HOME_PATH/corpus/europarl-v7.fr-en.fr.norm")" > "$HOME_PATH/corpus/europarl-v7.fr-en.fr.norm.test" &&
    echo "$(tail -10 "$HOME_PATH/corpus/europarl-v7.fr-en.fr.denorm")" > "$HOME_PATH/corpus/europarl-v7.fr-en.fr.denorm.true" &&

    nohup nice $MOSES_PATH/bin/moses \
      --verbose \
      -f $HOME_PATH/training/model/moses.ini \
      < $HOME_PATH/corpus/europarl-v7.fr-en.fr.norm.test \
      > $HOME_PATH/training/model/europarl-v7.fr-en.fr.denorm.test &&

    cp "$HOME_PATH/corpus/europarl-v7.fr-en.fr.norm.test" "$HOME_PATH/training/model/europarl-v7.fr-en.fr.norm.test" &&

    echo '✅ post_training succeeded'
    } || {
    echo '❌ post_training failed'
    return 1
  }
}

keep_docker_alive() {
  tail -f /dev/null
}


launch_pipeline() {

  # Prepare directories
  mkdir "$HOME_PATH/lm/europarl-v7-fr-normdenorm"

  echo "------START PRE-TRAINING------" &&
  prepare_corpus &&
  clean_corpus_homemade &&
  normalize_corpus &&
  clean_corpus_again &&
  echo "------END PRE-TRAINING------" &&

  echo "------START TRAINING------" &&
  prepare_moses &&
  launch_training &&
  echo "------END TRAINING------" &&

  echo "------START POST-TRAINING------" &&
  post_training &&
  echo "------END POST-TRAINING------" &&

  keep_docker_alive
}


(launch_pipeline && echo '✅ SUCCESS launch_pipeline') || echo '❌ FAILURE launch_pipeline'
