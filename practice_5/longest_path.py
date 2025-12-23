import sys
import subprocess
import os

def run_mapreduce(input_files, output_file):
    mapper_path = os.path.join(os.path.dirname(__file__), "mapper.py")
    reducer_path = os.path.join(os.path.dirname(__file__), "reducer.py")
    
    all_inputs_exist = True
    for input_file in input_files:
        if not os.path.exists(input_file):
            print(f"Warning: Input file '{input_file}' not found.")
            all_inputs_exist = False
    
    if not all_inputs_exist:
        print("Some input files are missing. Continuing with available files...")
    
    mapper_processes = []
    for input_file in input_files:
        if os.path.exists(input_file):
            input_f = open(input_file, 'r', encoding='utf-8')
            mapper_process = subprocess.Popen(
                [sys.executable, mapper_path],
                stdin=input_f,
                stdout=subprocess.PIPE,
                text=True
            )
            mapper_processes.append(mapper_process)
            input_f.close()
    
    if not mapper_processes:
        print("Error: No valid input files found.")
        return
    
    import tempfile
    temp_file = tempfile.NamedTemporaryFile(mode='w+', delete=False, encoding='utf-8')
    temp_filename = temp_file.name
    
    for proc in mapper_processes:
        output = proc.communicate()[0]
        temp_file.write(output)
    temp_file.close()
    
    sorted_temp_file = tempfile.NamedTemporaryFile(mode='w+', delete=False, encoding='utf-8')
    sorted_temp_filename = sorted_temp_file.name
    sorted_temp_file.close()
    
    with open(temp_filename, 'r', encoding='utf-8') as input_f:
        lines = input_f.readlines()
        lines.sort(key=lambda x: int(x.split('\t')[0]) if '\t' in x else 0, reverse=True)
        with open(sorted_temp_filename, 'w', encoding='utf-8') as sorted_f:
            sorted_f.writelines(lines)
    
    if os.path.exists(temp_filename):
        os.unlink(temp_filename)
    
    with open(sorted_temp_filename, 'r', encoding='utf-8') as reducer_input:
        reducer_process = subprocess.Popen(
            [sys.executable, reducer_path],
            stdin=reducer_input,
            stdout=subprocess.PIPE,
            text=True
        )
        output_data = reducer_process.communicate()[0]
    
    with open(output_file, 'w', encoding='utf-8') as output_f:
        output_f.write(output_data)
    
    if os.path.exists(sorted_temp_filename):
        os.unlink(sorted_temp_filename)
    
    print(f"Longest path analysis completed. Results saved to '{output_file}'")

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python longest_path.py <input_file1> [input_file2 ...] <output_file>")
        print("Example: python longest_path.py laptop1_paths.txt laptop2_paths.txt output.txt")
        sys.exit(1)
    
    input_files = sys.argv[1:-1]
    output_file = sys.argv[-1]
    run_mapreduce(input_files, output_file)

