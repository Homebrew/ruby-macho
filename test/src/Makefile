CC = clang

HELLO_SRC = hello.c
LIBHELLO_SRC = libhello.c

BINDIRS = x86_64 fat-i386-x86_64

RPATH_FLAGS = -rpath made_up_path
FAT_I386_X86_64_FLAGS = -arch i386 -arch x86_64
LDFLAGS = -L.

UNAME_S := $(shell uname -s)

ifneq ($(UNAME_S),Darwin)
$(error This makefile can only be run on OS X)
endif

# all: machos fats expecteds
all: $(BINDIRS)

x86_64:
	mkdir $@
	$(CC) -c $(HELLO_SRC) -o $@/hello.o
	$(CC) $(RPATH_FLAGS) $(HELLO_SRC) -o $@/hello.bin
	$(CC) -dynamiclib $(LIBHELLO_SRC) -o $@/libhello.dylib
	$(CC) $(LDFLAGS) -dynamiclib $(LIBHELLO_SRC) -Wl,-upward_library,/usr/lib/libm.dylib -Wl,-lazy-lhello -o $@/libextrahello.dylib
	$(CC) -bundle $(LIBHELLO_SRC) -o $@/hellobundle.so

fat-i386-x86_64:
	mkdir $@
	$(CC) $(FAT_I386_X86_64_FLAGS) -c $(HELLO_SRC) -o $@/hello.o
	$(CC) $(RPATH_FLAGS) $(FAT_I386_X86_64_FLAGS) $(HELLO_SRC) -o $@/hello.bin
	$(CC) $(FAT_I386_X86_64_FLAGS) -dynamiclib $(LIBHELLO_SRC) -o $@/libhello.dylib
	$(CC) $(LDFLAGS) $(FAT_I386_X86_64_FLAGS) -dynamiclib $(LIBHELLO_SRC) -Wl,-upward_library,/usr/lib/libm.dylib -Wl,-lazy-lfathello -o $@/libextrahello.dylib
	$(CC) $(FAT_I386_X86_64_FLAGS) -bundle $(LIBHELLO_SRC) -o $@/hellobundle.so

install: all
	mv -f $(BINDIRS) ../bin/

clean:
	rm -rf $(BINDIRS)

.PHONY: all clean
