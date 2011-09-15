#!/usr/bin/env python
import sys
from math import *
from collections import *

MIN_BIGRAM_SUPPORT = 1#2
MIN_UNIGRAM_SUPPORT = 1#5

unigram_count = 0
bigram_count = 0
unigram_freq = defaultdict(int)
bigram_freq = defaultdict(int)

# extract frequencies
for line in sys.stdin:
    tokens = line.strip().split()
    tokens.pop(0) # drop id

    if len(tokens)==0:
        continue

    t1 = tokens.pop(0)
    unigram_freq[t1] += 1
    unigram_count += 1

    while len(tokens)>0:
        t2 = tokens.pop(0)
        unigram_freq[t2] += 1
        unigram_count += 1
        bigram = (t1,t2)
        bigram_freq[bigram] += 1
        bigram_count += 1
        t1 = t2

#print "unigram_count", unigram_count
#print "bigram_count", bigram_count

# emit mutual info
for bigram in bigram_freq:
    bigram_f = bigram_freq[bigram]
    if bigram_f < MIN_BIGRAM_SUPPORT:
        continue

    t1, t2 = bigram
    t1_f = unigram_freq[t1]
    t2_f = unigram_freq[t2]
    if t1_f < MIN_UNIGRAM_SUPPORT or t2_f < MIN_UNIGRAM_SUPPORT:
        continue

    p_bigram = float(bigram_f) / bigram_count
    p_t1 = float(t1_f) / unigram_count
    p_t2 = float(t2_f) / unigram_count

    mutual_info = p_bigram / (p_t1 * p_t2)

    print mutual_info, bigram_f, p_bigram, t1_f, p_t1, t2_f, p_t2, t1, t2

        
