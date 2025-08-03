# GNU Makefile for building generated C files in parallel
# Usage:
#   make generate   # generate C and H files using Python
#   make all        # build all object files
#   make clean      # remove build artifacts

NUM_FILES := 50
BASE_DIR := generated
PYTHON := python

# List of folders
FOLDERS := $(addprefix $(BASE_DIR)/mod_,$(shell seq -w 1 $(NUM_FILES)))
# List of C and H files
CFILES := $(foreach i,$(shell seq -w 1 $(NUM_FILES)),$(BASE_DIR)/mod_$(i)/mod_$(i).c)
HFILES := $(foreach i,$(shell seq -w 1 $(NUM_FILES)),$(BASE_DIR)/mod_$(i)/mod_$(i).h)
# List of object files
OBJS := $(CFILES:.c=.o)

.PHONY: all generate clean test

# Add main.c and executable
MAIN := main.c
EXEC := test_app.exe

# Include parent directory for header files
CFLAGS += -Igenerated

# Add all subfolders to the include path
INCLUDE_DIRS := $(addprefix -I$(BASE_DIR)/mod_,$(shell seq -w 1 $(NUM_FILES)))
CFLAGS += -I$(BASE_DIR) $(INCLUDE_DIRS)

all: generate $(OBJS) $(EXEC)
	@echo "Build complete."

$(EXEC): $(OBJS) $(MAIN)
	$(CC) $(CFLAGS) $(OBJS) $(MAIN) -o $(EXEC)

generate:
	$(PYTHON) gen_c_files.py

$(BASE_DIR)/mod_%/mod_%.o: $(BASE_DIR)/mod_%/mod_%.c $(BASE_DIR)/mod_%/mod_%.h
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -rf $(BASE_DIR)
	rm -f *.o
	rm -f *.exe

# test target runs the executable
test: $(EXEC)
	./$(EXEC)
