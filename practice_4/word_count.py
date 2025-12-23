import sys
import subprocess
import os

def run_mapreduce(input_file, output_file):
    if not os.path.exists(input_file):
        print(f"Error: Input file '{input_file}' not found.")
        return
    
    mapper_path = os.path.join(os.path.dirname(__file__), "mapper.py")
    reducer_path = os.path.join(os.path.dirname(__file__), "reducer.py")
    
    with open(input_file, 'r', encoding='utf-8') as input_f:
        mapper_process = subprocess.Popen(
            [sys.executable, mapper_path],
            stdin=input_f,
            stdout=subprocess.PIPE,
            text=True
        )
        
        reducer_process = subprocess.Popen(
            [sys.executable, reducer_path],
            stdin=mapper_process.stdout,
            stdout=subprocess.PIPE,
            text=True
        )
        
        mapper_process.stdout.close()
        
        output_data = reducer_process.communicate()[0]
        
        with open(output_file, 'w', encoding='utf-8') as output_f:
            output_f.write(output_data)
        
        print(f"Word count completed. Results saved to '{output_file}'")

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python word_count.py <input_file> <output_file>")
        sys.exit(1)
    
    input_file = sys.argv[1]
    output_file = sys.argv[2]
    run_mapreduce(input_file, output_file)

