CC = clang

HELLO_SRC = hello.c
LIBHELLO_SRC = libhello.c

MACHOS = hello.o hello.bin libhello.dylib hellobundle.so
FATS = fathello.o fathello.bin libfathello.dylib fathellobundle.so

FAT_ARCH_FLAGS = -arch i386 -arch x86_64

UNAME_S := $(shell uname -s)

ifneq ($(UNAME_S),Darwin)
$(error This makefile can only be run on OS X)
endif

all: machos fats

machos: $(MACHOS)

fats: $(FATS)

hello.o:
	$(CC) -c $(HELLO_SRC) -o $@

hello.bin:
	$(CC) $(HELLO_SRC) -o $@

libhello.dylib:
	$(CC) -dynamiclib $(HELLO_SRC) -o $@

hellobundle.so:
	$(CC) -bundle $(HELLO_SRC) -o $@

fathello.o:
	$(CC) $(FAT_ARCH_FLAGS) -c $(HELLO_SRC) -o $@

fathello.bin:
	$(CC) $(FAT_ARCH_FLAGS) $(HELLO_SRC) -o $@

libfathello.dylib:
	$(CC) $(FAT_ARCH_FLAGS) -dynamiclib $(HELLO_SRC) -o $@

fathellobundle.so:
	$(CC) $(FAT_ARCH_FLAGS) -bundle $(HELLO_SRC) -o $@

install: all
	mkdir ../bin
	mv $(MACHOS) $(FATS) ../bin

clean:
	rm -f $(MACHOS) $(FATS)

.PHONY: all clean
