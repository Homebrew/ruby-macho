CC = clang

HELLO_SRC = hello.c
LIBHELLO_SRC = libhello.c

MACHOS = hello.o hello.bin libhello.dylib libextrahello.dylib hellobundle.so
FATS = fathello.o fathello.bin libfathello.dylib libfatextrahello.dylib fathellobundle.so
EXPECTEDS =

RPATH_FLAGS = -rpath made_up_path
FAT_ARCH_FLAGS = -arch i386 -arch x86_64

UNAME_S := $(shell uname -s)

ifneq ($(UNAME_S),Darwin)
$(error This makefile can only be run on OS X)
endif

all: machos fats expecteds

machos: $(MACHOS)

fats: $(FATS)

expecteds: $(EXPECTEDS)

hello.o:
	$(CC) -c $(HELLO_SRC) -o $@

hello.bin:
	$(CC) $(RPATH_FLAGS) $(HELLO_SRC) -o $@

libhello.dylib:
	$(CC) -dynamiclib $(LIBHELLO_SRC) -o $@

libextrahello.dylib:
	$(CC) -dynamiclib $(LIBHELLO_SRC) -Wl,-upward_library,/usr/lib/libm.dylib -Wl,-lazy-lpthread -o $@

hellobundle.so:
	$(CC) -bundle $(LIBHELLO_SRC) -o $@

fathello.o:
	$(CC) $(FAT_ARCH_FLAGS) -c $(HELLO_SRC) -o $@

fathello.bin:
	$(CC) $(RPATH_FLAGS) $(FAT_ARCH_FLAGS) $(HELLO_SRC) -o $@

libfathello.dylib:
	$(CC) $(FAT_ARCH_FLAGS) -dynamiclib $(LIBHELLO_SRC) -o $@

libfatextrahello.dylib:
	$(CC) $(FAT_ARCH_FLAGS) -dynamiclib $(LIBHELLO_SRC) -Wl,-upward_library,/usr/lib/libm.dylib -Wl,-lazy-lpthread -o $@

fathellobundle.so:
	$(CC) $(FAT_ARCH_FLAGS) -bundle $(LIBHELLO_SRC) -o $@

clean:
	rm -f $(MACHOS) $(FATS)

.PHONY: all clean
