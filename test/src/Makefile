# Usage:
#   make USE=10.6-xcode3.2.6
#   make USE=10.11-xcode7.3

HELLO_SRC    = hello.c
LIBHELLO_SRC = libhello.c
RPATH_FLAGS  = -Wl,-rpath,made_up_path
TARGET_FILES = \
	hello.o \
	hello.bin \
	hello_expected.bin \
	hello_rpath_expected.bin \
	libhello.dylib \
	libhello_expected.dylib \
	libextrahello.dylib \
	hellobundle.so

# Architecture-specific flags that are set by pattern matching the targets.
ARCH_FLAGS   =
i386/%            : ARCH_FLAGS = -arch i386
x86_64/%          : ARCH_FLAGS = -arch x86_64
ppc/%             : ARCH_FLAGS = -arch ppc
ppc64/%           : ARCH_FLAGS = -arch ppc64
fat-i386-x86_64/% : ARCH_FLAGS = -arch i386 -arch x86_64
fat-i386-ppc/%    : ARCH_FLAGS = -arch i386 -arch ppc
fat-ppc-ppc64/%   : ARCH_FLAGS = -arch ppc -arch ppc64

# Make sure we're on OS X.
UNAME_S := $(shell uname -s)
ifneq ($(UNAME_S),Darwin)
  $(error This makefile can only be run on OS X, but detected $(UNAME_S))
endif

# Select one of the pre-defined subsets (depends on host OS X and Xcode).
ALL_DIRS := i386 x86_64 ppc ppc64 fat-i386-x86_64 fat-i386-ppc fat-ppc-ppc64
ifneq ($(USE_DIRS),)
  # Trust the user to get this right, if explicitly specified.
else ifeq ($(USE),all)
  $(warning USE - Using 'all' is unlikely to work on a single host.)
  USE_DIRS := $(ALL_DIRS)
else ifeq ($(USE),10.6-xcode3.2.6)
  USE_DIRS := i386 x86_64 ppc fat-i386-x86_64 fat-i386-ppc
  NO_UPWARD := 1
  NO_LAZY := 1
else ifeq ($(USE),10.11-xcode7.3)
  USE_DIRS := i386 x86_64 fat-i386-x86_64
else
  # Warn about unspecified subset, but effectively fall back to 10.11-xcode7.3.
  $(warning USE - Option either unset or invalid. Using a safe fallback.)
  $(warning USE - Valid choices: all, 10.6-xcode3.2.6, 10.11-xcode7.3.)
  USE_DIRS := i386 x86_64 fat-i386-x86_64
endif

# Setup target names from all/used architecture directories.
ALL_TARGETS := $(addprefix all-,$(ALL_DIRS))
USE_TARGETS := $(addprefix all-,$(USE_DIRS))

# Tweak flags according to toolchain support.
LIBEXTRA_LDADD = -L$(@D)
ifeq ($(NO_UPWARD),1)
  # Xcode 3.2.6: `ld` doesn't support `-upward_library`.
  LIBEXTRA_LDADD += -Wl,-weak_library,/usr/lib/libz.dylib
else
  LIBEXTRA_LDADD += -Wl,-upward_library,/usr/lib/libz.dylib
endif
ifeq ($(NO_LAZY), 1)
  # Xcode 3.2.6: `ld` theoretically supports `-lazy-l`, but gets confused.
  LIBEXTRA_LDADD += -Wl,-reexport-lhello
else
  LIBEXTRA_LDADD += -Wl,-lazy-lhello
endif

# Setup default target (used subset).
.PHONY: all
all: $(USE_TARGETS) inconsistent

# Setup targets that build all files for a given architecture (`all-<arch>`).
.PHONY: $(ALL_TARGETS)
$(ALL_TARGETS): all-%: $(addprefix %/,$(TARGET_FILES))

# Setup targets for creating architecture-specific output directories.
$(ALL_DIRS):
	mkdir -p $@

# Setup architecture-specific per-file targets (`<arch>/<file>`).
%/hello.o: $(HELLO_SRC) %
	$(CC) $(ARCH_FLAGS) -o $@ -c $<

%/hello.bin: $(HELLO_SRC) %
	$(CC) $(ARCH_FLAGS) -o $@ $(RPATH_FLAGS) $<

%/hello_expected.bin: %/hello.bin
	cp $< $@
	install_name_tool -change /usr/lib/libSystem.B.dylib test $@

%/hello_rpath_expected.bin: %/hello.bin
	cp $< $@
	install_name_tool -rpath made_up_path /usr/lib $@

%/libhello.dylib: $(LIBHELLO_SRC) %
	$(CC) $(ARCH_FLAGS) -o $@ -dynamiclib $<

%/libhello_expected.dylib: %/libhello.dylib
	cp $< $@
	install_name_tool -id test $@

%/libextrahello.dylib: $(LIBHELLO_SRC) % %/libhello.dylib
	$(CC) $(ARCH_FLAGS) -o $@ -dynamiclib $< $(LIBEXTRA_LDADD)

%/hellobundle.so: $(LIBHELLO_SRC) %
	$(CC) $(ARCH_FLAGS) -bundle $< -o $@

# build inconsistent binaries
.PHONY: inconsistent
inconsistent: $(USE_TARGETS)
	./make-inconsistent.sh $(USE_DIRS)

# Remove all build products, even those not selected in the current run.
.PHONY: clean
clean:
	rm -rf $(ALL_DIRS)

# Copy all selected build products to their final destination.
.PHONY: install
install: all
	cp -rf $(USE_DIRS) ../bin/
