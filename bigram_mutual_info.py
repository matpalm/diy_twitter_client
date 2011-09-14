#!/usr/bin/env python
import sys
from math import *
from collections import *

MIN_BIGRAM_SUPPORT = 2
MIN_UNIGRAM_SUPPORT = 5

total_unigrams = 0
unigram_freq = defaultdict(int)
bigram_freq = defaultdict(int)

for line in sys.stdin:
    tokens = line.strip().split()
    tokens.pop(0) # drop id

    if len(tokens)==0:
        continue

    t1 = tokens.pop(0)
    unigram_freq[t1] += 1
    total_unigrams += 1

    while len(tokens)>0:
        t2 = tokens.pop(0)
        unigram_freq[t2] += 1
        total_unigrams += 1
        bigram = (t1,t2)
        bigram_freq[bigram] += 1
        t1 = t2

for bigram in bigram_freq:
    bigram_f = bigram_freq[bigram]
    if bigram_f < MIN_BIGRAM_SUPPORT:
        continue

    t1, t2 = bigram
    t1_f = unigram_freq[t1]
    t2_f = unigram_freq[t2]
    if t1_f < MIN_UNIGRAM_SUPPORT or t2_f < MIN_UNIGRAM_SUPPORT:
        continue

    p_bigram = float(bigram_f) / total_unigrams
    p_t1 = float(t1_f) / total_unigrams
    p_t2 = float(t2_f) / total_unigrams

    mutual_info = log(p_bigram,2) - log(p_t1,2) + log(p_t2,2)

    print mutual_info, t1, t2

        
