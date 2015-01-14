# ========================================
# Generic Makefile for C/C++ Program
#
# Author: Edward Chen
#
# Date:	  2015.1.13 (version 0.1)
# ========================================


# .obj file
OBJDIR=./build

# The directory of project
SRCDIRS=

#The valid type of file
SRCTYPE:=.c .cpp

INCLUDEDIR=
# -MD 生成.d来引入方便之后对.h的依赖
CFLAGS:= -O2 -Wall -MD $(foreach dir, $(INCLUDEDIR), -I$(dir))

ifeq "$(DEST_SOURCE)" ""
	SRCS= %.cpp %.c
else
	SRCS=$(DEST_SOURCE)
endif


CC=g++

INSTALL_PATH=

VPATH= 

OBJS=$(patsubst %.cpp, $(OBJDIR)/%.o, $(SRCS))

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

all:$(OBJS)
ifeq "FILE_TYPE" "BIN"
	$(CC) $(OBJS) -shared -o $(TARGET) $(CFLAGS)	
endif

ifeq "FILE_TYPE" "LIB"

endif

ifeq "FILE_TYPE" "APP"

endif
	$(CC)	



$(OBJECTDIR)%.o: $(SRCDIR)%.c
	@[ ! -d $(OBJDIR) ] & mkdir -p $(OBJDIR)
	$(CC) $(CPPFLAGS) $(CFLAGS) -o $@ -c $<

install:
	all
ifeq "$(INSTALL_PATH)" ""
	mv $(TARGET) $(INSTALL_PATH)$(TARGET)
endif

clean:
	@find $(OBJDIR) -name "*.o" -or -name "*.d"|xargs rm -f
	@rm -f $(TARGET)

help:
	@echo '========================================'
	@echo '      Generic Makefile for C/C++        '
	@echo '========================================'
	@echo 'PROGRAM:     ' $(PROGRAM)
	@echo 'CC:          ' $(CC)
	@echo ''
	
	@echo 'all:     compile and link'
	@echo 'clean:   clean objects and executable fule'
	@echo 'install: make and install the file to where you want'
	@echo 'help:    show make info of the project'






