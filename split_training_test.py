#!/usr/bin/env python
import sys
from random import random

if not len(sys.argv)==4:
    raise "expected TEST_PERC TRAINING_FILE TEST_FILE"
test_perc, training_file, test_file = sys.argv[1:]
test_perc = float(test_perc)

train = open(training_file, 'w')
test  = open(test_file, 'w')

for line in sys.stdin:
    if random() < test_perc:
        test.write(line)
    else:
        train.write(line)

train.close()
test.close()
