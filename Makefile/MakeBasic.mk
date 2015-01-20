# ========================================
# Generic Makefile for C/C++ Program
#
# Author: Edward Chen
#
# Date:	  2015.1.13 (version 0.1)
# ========================================

# .obj file
OBJDIR=./build

CFLAGS:= -O2 -Wall -MD $(foreach dir, $(INCLUDEDIR), -I$(dir)) 

# default cpp
ifeq "$(DEST_SOURCE)" ""
	SRCS= $(wildcard *.cpp) 
else
	SRCS=$(DEST_SOURCE)
endif

OBJS=$(patsubst %.cpp, $(OBJDIR)/%.o, $(SRCS))


CC = gcc
CXX = g++

###################################################
# User Own Defination 

# add user own CFLAGS
USER_CFLAGS= #-g

# output file path
INSTALL_PATH=

# add include file
INCLUDEDIR=

# add
VPATH=

# add use of ld
LDFLAGS=

# -MD 生成.d来引入方便之后对.h的依赖
# CFLAGS_DEP:= -MD $(foreach dir, $(INCLUDEDIR), -I$(dir))

# this will adjust the order of .a
ifneq "$(LDFLAGS)" ""
	XLDFLAGS = -Xlinker "-(" $(LDFLAGS) -Xlinker "-)"
else
	XLDFLAGS=
endif

####################################################
# deal output file name 

LIBEND=.a
BINPRE=lib
BINEND=.so

FILE_TYPE=$(strip $(DEST_TYPE))

ifeq "$(FILE_TYPE)" "BIN"
	TARGET := $(addprefix $(BINPRE), $(DEST)$(BINEND))
endif

ifeq "$(FILE_TYPE)" "LIB"
	TARGET := $(addsuffix $(LIBEND), $(DEST))
endif

ifeq "$(FILE_TYPE)" "APP"
	TARGET := $(DEST)
endif

######################################################

.PHONY: all install clean help

all : $(OBJS)
ifeq "$(FILE_TYPE)" "BIN"
	$(CXX) $(OBJS) -shared -fPIC -o $(TARGET) $(CFLAGS) $(XLDFLAGS) 
endif

ifeq "$(FILE_TYPE)" "LIB"
	ar rc $(TARGET) $(OBJS)
endif

ifeq "$(FILE_TYPE)" "APP"
	$(CXX) $(OBJS) -o $(TARGET) $(CFLAGS) $(XLDFLAGS)
endif


$(OBJDIR)/%.o : %.cpp
	@[ ! -d $(OBJDIR) ] & mkdir -p $(OBJDIR)
	$(CXX) $(CPPFLAGS) $(CFLAGS) -o $@ -c $<

$(OBJDIR)/%.o: %.c
	@[ ! -d $(OBJDIR) ] & mkdir -p $(OBJDIR)
	$(CC) $(CPPFLAGS) $(CFLAGS) -o $@ -c $<


install:
	all
ifeq "$(INSTALL_PATH)" ""
	cp -rf $(TARGET) $(INSTALL_PATH)$(TARGET)
endif

clean:
	@find $(OBJDIR) -name "*.o" -or -name "*.d"|xargs rm -f
	@rm -f $(TARGET)

help:
	@echo '========================================'
	@echo '      Generic Makefile for C/C++        '
	@echo '========================================'
	@echo 'CC & CXX:          ' $(CC) $(CXX)
	@echo 'link '				$(CXX) $(CPPFLAGS) $(CFLAGS)
	
	@echo 'all:     compile and link'
	@echo 'clean:   clean objects and executable fule'
	@echo 'install: make and install the file to where you want'
	@echo 'help:    show make info of the project'






