import os

NUM_FILES = 50
BASE_DIR = "generated"

os.makedirs(BASE_DIR, exist_ok=True)

for i in range(1, NUM_FILES + 1):
    folder = os.path.join(BASE_DIR, f"mod_{i:02d}")
    os.makedirs(folder, exist_ok=True)
    h_path = os.path.join(folder, f"mod_{i:02d}.h")
    c_path = os.path.join(folder, f"mod_{i:02d}.c")
    with open(h_path, "w") as hf:
        hf.write(f"#ifndef MOD_{i:02d}_H\n#define MOD_{i:02d}_H\n\nvoid mod_{i:02d}_func(void);\n\n#endif\n")
    with open(c_path, "w") as cf:
        cf.write(f'#include "all.h"\n#include "mod_{i:02d}.h"\n#include <stdio.h>\n\nvoid mod_{i:02d}_func(void) {{\n    printf("Hello from mod_{i:02d}!\\n");\n}}\n')

# Generate all.h in BASE_DIR, using only #include "mod_xx.h"
all_h_path = os.path.join(BASE_DIR, "all.h")
with open(all_h_path, "w") as ah:
    ah.write("/* Auto-generated all.h: includes all generated headers */\n")
    for i in range(1, NUM_FILES + 1):
        ah.write(f'#include "mod_{i:02d}.h"\n')

# Generate main.c
def generate_main_c(num_files):
    with open("main.c", "w") as mf:
        mf.write("/* Auto-generated main.c for testing all generated modules */\n")
        mf.write("#include <stdio.h>\n")
        mf.write("#include \"generated/all.h\"\n\n")
        mf.write("int main(void) {\n")
        mf.write("    // Call all generated functions\n")
        for i in range(1, num_files + 1):
            mf.write(f"    mod_{i:02d}_func();\n")
        mf.write("    printf(\"All module functions called.\\n\");\n")
        mf.write("    return 0;\n}\n")

generate_main_c(NUM_FILES)
