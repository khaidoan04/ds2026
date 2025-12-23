import sys
import re

def tokenize(line):
    line = line.strip().lower()
    words = re.findall(r'\b[a-z]+\b', line)
    return words

for line in sys.stdin:
    words = tokenize(line)
    for word in words:
        print(f"{word}\t1")

