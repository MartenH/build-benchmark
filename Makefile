# GNU Makefile for building generated C files in parallel
# Usage:
#   make generate   # generate C and H files using Python
#   make all        # build all object files
#   make clean      # remove build artifacts

# Use ITER for number of modules, default to 50
ITER ?= 50
NUM_FILES = $(ITER)
BASE_DIR = generated
PYTHON = python

# List of folders
FOLDERS = $(addprefix $(BASE_DIR)/mod_,$(shell seq -w 001 $(ITER)))
# List of C and H files
CFILES = $(foreach i,$(shell seq -w 001 $(ITER)),$(BASE_DIR)/mod_$(i)/mod_$(i).c)
HFILES = $(foreach i,$(shell seq -w 001 $(ITER)),$(BASE_DIR)/mod_$(i)/mod_$(i).h)
# List of object files
OBJS = $(CFILES:.c=.o)

.PHONY: all generate clean test

# Add main.c and executable
MAIN = main.c
EXEC = test_app.exe

# Include parent directory for header files
CFLAGS += -Igenerated

# Add all subfolders to the include path
INCLUDE_DIRS = $(addprefix -I$(BASE_DIR)/mod_,$(shell seq -w 001 $(ITER)))
CFLAGS += -I$(BASE_DIR) $(INCLUDE_DIRS)

all: generate
	@start=$$(date +%s%3N); \
	$(MAKE) build_only; \
	end=$$(date +%s%3N); \
	delta=$$(awk "BEGIN {print ($$end-$$start)/1000}"); \
	echo "Build complete."; \
	echo "Command: make all $(MAKEFLAGS)"; \
	echo "Build time: $$delta seconds"; \
	(echo "System info:" && (uname -a 2>/dev/null || ver))

.PHONY: build_only
build_only: generate $(OBJS) $(EXEC)

$(EXEC): $(OBJS) $(MAIN)
	$(CC) $(CFLAGS) $(OBJS) $(MAIN) -o $(EXEC)

generate:
	ITER=$(ITER) $(PYTHON) gen_c_files.py

$(BASE_DIR)/mod_%/mod_%.o: $(BASE_DIR)/mod_%/mod_%.c $(BASE_DIR)/mod_%/mod_%.h
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -rf $(BASE_DIR)
	rm -f *.o
	rm -f *.exe

# test target runs the executable
test: $(EXEC)
	./$(EXEC)
