YAMLS := $(wildcard *.yaml)
MACHOS := $(YAMLS:.yaml=.macho)

.PHONY: all
all: $(MACHOS)

%.macho: %.yaml
	yaml2obj $< -o $@
