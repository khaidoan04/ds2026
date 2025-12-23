import sys

for line in sys.stdin:
    path = line.strip()
    if not path:
        continue
    
    path_length = len(path)
    print(f"{path_length}\t{path}")

