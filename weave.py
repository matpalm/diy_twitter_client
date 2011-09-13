#!/usr/bin/env python
import sys
if not len(sys.argv)==3:
    raise "expected FILE1 FILE2"
f1 = open(sys.argv[1],'r')
for l2 in open(sys.argv[2],'r'):
    sys.stdout.write(f1.readline().strip() + " " + l2)

