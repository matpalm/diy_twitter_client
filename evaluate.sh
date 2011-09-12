#!/usr/bin/env bash

function evaluate_once {
 shuf read.vw | ../split_training_test.py 0.1 train.vw test.vw
 cat train.vw | vw -f model -q am -q ah -q au -q at -q mh -q mu -q mt -q hu -q ht -q ut --thread_bits 2 --audit > train.vw.audit.stdout 2>train.vw.audit.stderr
 cat test.vw | vw -t -i model -p predictions --quiet
 cat test.vw | cut -d' ' -f1 > labels.actual
 cat predictions | cut -d' ' -f1 > labels.predicted
 perf -ACC -files labels.actual labels.predicted -t 0.5 | awk '{print $2}' >> accuracy
}

rm -rf eval_working
mkdir eval_working
cd eval_working
../read_articles_to_vw.py > read.vw
:> accuracy
for i in {1..50}; do evaluate_once; done

R --vanilla --slave <<EOF
 runs = read.delim('accuracy',header=F)\$V1
 summary(runs)
 sd(runs)
EOF


