# GNU Makefile for building generated C files in parallel
# Usage:
#   make generate   # generate C and H files using Python
#   make all        # build all object files
#   make clean      # remove build artifacts

# Use ITER for number of modules, default to 50
ITER ?= 500
NUM_FILES = $(ITER)
BASE_DIR = generated

uname:=$(shell uname)

ifeq ($(uname),Linux)
	OS := linux
else ifeq ($(findstring CYGWIN,$(uname)),CYGWIN)
	OS := cygwin
else ifeq ($(findstring MINGW,$(uname)),MINGW)
	OS := mingw
else ifeq ($(findstring MSYS,$(uname)),MSYS)
	OS := msys
else
	OS := windows
endif

ifeq ($(OS),cygwin)
	ROOT=/cygdrive/c
else ifeq ($(OS),mingw)
	ROOT=C:
else ifeq ($(OS),windows)
	ROOT=C:
endif

PYTHON3=$(ROOT)/T2P_Tools/Python/3.13.2-01/python.exe
CC = $(ROOT)/ems2/T2P_Tools/ti-arm-clang/3.2.0/bin/tiarmclang.exe


# List of folders
FOLDERS = $(addprefix $(BASE_DIR)/mod_,$(shell seq -w 001 $(ITER)))
# List of C and H files
CFILES = $(foreach i,$(shell seq -w 001 $(ITER)),$(BASE_DIR)/mod_$(i)/mod_$(i).c)
HFILES = $(foreach i,$(shell seq -w 001 $(ITER)),$(BASE_DIR)/mod_$(i)/mod_$(i).h)
# List of object files
OBJS = $(CFILES:.c=.o)
# List of dependency files
DEPFILES = $(OBJS:.o=.o.d)

.PHONY: all generate clean test

# Add main.c and executable
MAIN = main.c
EXEC = test_app.exe

# Include parent directory for header files
CFLAGS += -Igenerated

# Add all subfolders to the include path
INCLUDE_DIRS = $(addprefix -I$(BASE_DIR)/mod_,$(shell seq -w 001 $(ITER)))
CFLAGS += -I$(BASE_DIR) $(INCLUDE_DIRS)

# TI ARM Clang specific flags for bare-metal target
CFLAGS += -mcpu=cortex-m4 -mthumb

# Add dependency generation flags (like CMake does)
CFLAGS += -MD -MT $@ -MF $@.d

LDFLAGS += -Xlinker --output_file=$(EXEC:.exe=.out) -Xlinker --map_file=$(EXEC:.exe=.map) -Xlinker --rom_model

all: generate
ifeq ($(OS),windows)
	REM Windows cmd timing (no millisecond precision)
	for /f %%t in ('echo %time%') do set START=%%t
	$(MAKE) build_only
	for /f %%t in ('echo %time%') do set END=%%t
	echo Build complete.
	echo Command: make all $(MAKEFLAGS)
	echo Build time: (timing not implemented for cmd)
	ver
else
	start=$$(date +%s%3N); \
	$(MAKE) build_only; \
	end=$$(date +%s%3N); \
	delta=$$(awk "BEGIN {print ($$end-$$start)/1000}"); \
	echo "Build complete."; \
	echo "Command: make all $(MAKEFLAGS)"; \
	echo "Build time: $$delta seconds"; \
	(echo "System info:" && (uname -a 2>/dev/null || ver))
endif

.PHONY: build_only
build_only: generate $(OBJS) $(EXEC)

$(EXEC): $(OBJS) $(MAIN)
	$(CC) $(CFLAGS) $(LDFLAGS) $(OBJS) $(MAIN) -o $(EXEC)

generate:
ifeq ($(OS),windows)
	set ITER=$(ITER) && $(PYTHON3) gen_c_files.py
else
	ITER=$(ITER) $(PYTHON3) gen_c_files.py
endif

$(BASE_DIR)/mod_%/mod_%.o: $(BASE_DIR)/mod_%/mod_%.c $(BASE_DIR)/mod_%/mod_%.h
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -rf $(BASE_DIR)
	rm -f *.o
	rm -f *.exe
	rm -f *.out
	rm -f *.map

# test target runs the executable
test: $(EXEC)
	./$(EXEC)

# Include dependency files (if they exist)
-include $(DEPFILES)
