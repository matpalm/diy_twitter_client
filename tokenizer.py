#!/usr/bin/env python
import sys, codecs, locale
from nltk.tokenize import WordPunctTokenizer, PunktWordTokenizer, PunktSentenceTokenizer

sent_tokenizer = PunktSentenceTokenizer()
token_tokenizer = WordPunctTokenizer()

sys.stdin = codecs.getreader(locale.getpreferredencoding())(sys.stdin)
sys.stdout = codecs.getwriter(locale.getpreferredencoding())(sys.stdout)
sys.stderr = codecs.getwriter(locale.getpreferredencoding())(sys.stderr)

def not_single_char(token): return len(token) > 1

for line in sys.stdin.readlines():
    print "line ", line.strip()
    for sentence in sent_tokenizer.tokenize(line):
        tokens = token_tokenizer.tokenize(sentence)
        print "tokens ", tokens



