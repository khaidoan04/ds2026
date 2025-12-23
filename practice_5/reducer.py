import sys

max_length = -1
longest_paths = []

for line in sys.stdin:
    line = line.strip()
    if not line:
        continue
    
    parts = line.split('\t', 1)
    if len(parts) != 2:
        continue
    
    try:
        path_length = int(parts[0])
        path = parts[1]
    except ValueError:
        continue
    
    if path_length > max_length:
        max_length = path_length
        longest_paths = [path]
    elif path_length == max_length:
        longest_paths.append(path)

for path in longest_paths:
    print(f"{max_length}\t{path}")

