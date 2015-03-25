# this is common Makefile for subfile in src
# -----
#     |---src -> src1/.. src2/.. ...
#	  |---include
#     |---build

.PHONY: all clean

TARGET=test

CC=g++
CFLAGS= -Wall -pedantic -O3 -std=c++11 -fpermissive
LDFLAGS=  

SRCDIR=src
HEADDIR=include
LIBDIR=build

SRC=$(shell find . -name '*.cpp')
TMP=$(subst $(SRCDIR),$(LIBDIR), $(SRC))
OBJ=$(patsubst %.cpp,%.o,$(TMP))

all:$(OBJ)
	$(CC) -o $@ $^ $(LDFLAGS)

$(LIBDIR)/%.o: $(SRCDIR)/%.cpp 
	@[ ! -d $(dir $@) ] & mkdir -p $(dir $@)
	$(CC) -o $@ -c $< $(CFLAGS)

clean:
	rm -rf $(LIBDIR)
