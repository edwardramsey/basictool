#读取产品工程名称
ifeq "$(PRODUCT)" ""
        include $(OB_REL)/etc/openboss.def
else
        include $(OB_REL)/etc/$(PRODUCT).def
endif

INCPATHS=
EXCPATHS=
INCOBDPATHS=
LDPATHS=
SYS_LIBS=
LDLIBNAMES=$(SYS_LIBS) $(PRODLIBS)
DEFS=
OPTS=
BUILDTYPE=
SVRVIDL=

CCFLAGS=
CXXFLAGS=
INCFLAGS=
EXCFLAGS=
PICFLAGS=
LDFLAGS=
LDOPTS=
SHLDFLAGS=
DMFLAGS=
THRFLAGS=
THRDEFS=
PURIFYOPTS=
QUANTIFYOPTS=
IDLTYPE=
DL_LIB=dl
CONFLIST=$(CONF_OBD_LIST)

ORBCC=idl2cpp
OBDCC=$(OB_REL)/bin/obd2cpp
ORBTYPEOPT=-type_code_info
VBSHLDFLAGS=
VBLDFLAGS=

TIER_KERNEL=_db
TIER_MGR=_mgr
TIER_PMGR=_pmgr
TIER_APP=_app

OBDCCOPTS = -namingchk



#为不同的产品定义不同的选项  lixp added, 2007-06-11
ifeq "$(PRODUCT_NAME)" "OPENBOSS"
        DEFS += -DOBD_SELECTED_API
        ifdef PROJECT_NAME
                OBDCCOPTS += -prj:$(PROJECT_NAME)
        else
                ifdef MODULE_NAME
                        OBDCCOPTS += -prj:$(MODULE_NAME)
                endif
        endif
endif

#确定数据库名称及版本
ifeq "$(DB)" "1"
        ifeq "$(DB_TYPE)" "ORACLE"
                ifeq "$(DB_VER)" "8I"
                        ORA8I=1
                endif
                ifeq "$(DB_VER)" "9I"
                        ORA9I=1
                endif
        endif
        ifeq "$(DB_TYPE)" "SYBASE"
                SYB=1
        endif
endif

#确定编译32位还是64位
ifeq "$(BIT_TYPE)" "32"
        BIT32=1
        BITTYPE :=
        COMBIT :=32
        DEFS+=-DBIT32
endif
ifeq "$(BIT_TYPE)" "64"
        BIT64=1
        BITTYPE :=
        COMBIT :=64
        DEFS+=-DBIT64
endif


#确定操作系统
ifeq "$(OS_TYPE)" "SunOS"
        SOLARIS=1
        DLLEXT =so
        DEFS+=-DSOLARIS -D$(PRODUCT_NAME) -D$(PRODUCT_VER) -D$(PROJECT_ADDR)
        DL_LIB=dl
        SYS_LIBS+= Cstd mtmalloc
        ifdef SOCKET
                LDLIBNAMES+=socket
                LDLIBNAMES+=nsl
        endif

        #MKDEP=CC -xM1
        MKDEP=fastdepend
        CXX=$(CXX_TYPE)
        CXXTMPOBJ=ir.out SunWS_cache
        CC=$(CC_TYPE)
        CCTMPOBJ=

        DEBUGFLAGS=-g
        LDDEBUGFLAGS=
        DMFLAGS=-xM1
        PICFLAGS=-PIC
        THRFLAGS=-mt
        THRDEFS=-D_REENTRANT

        LD=CC
        LDTMPOBJ=

        SHLD=CC
        SHLDFLAGS=-G
        SHLDTMPOBJ=

        ifeq "$(BIT64)" "1"
                PICFLAGS=-KPIC
                LDPATHS+=/usr/lib/64
                CCFLAGS+= -xtarget=ultra -xarch=v9
                LDFLAGS+= -xtarget=ultra -xarch=v9
                SHLDFLAGS+= -xtarget=ultra -xarch=v9
        endif
endif



ifeq "$(OS_TYPE)" "AIX"
        IBM=1
        DLLEXT =so
        #MKDEP=$(CXX_TYPE) -M -qsyntaxonly
        MKDEP=fastdepend
        CXX=$(CXX_TYPE)
        CXXFLAGS=-brtl -bexpall -qlanglvl=oldfriend -q$(COMBIT)
        CXXTMPOBJ=
        CC=$(CC_TYPE)

        ifeq "$(DEBUG)" "1"
                #CCFLAGS=-brtl -bexpall -qlonglong -qlongdouble -q$(COMBIT) -qalign=full -qstaticinline -qkeyword=typename
                CCFLAGS=-brtl -bexpall -qlongdouble -q$(COMBIT) -qalign=full -qstaticinline -qkeyword=typename
                DEBUGFLAGS=-g
        else
        #       CCFLAGS=-brtl -bexpall -qlonglong -qlongdouble -q$(COMBIT) -qalign=full -qinline -qkeyword=typename -O3
                #CCFLAGS=-brtl -bexpall -qlonglong -qlongdouble -q$(COMBIT) -qalign=full -qstaticinline -qkeyword=typename
                CCFLAGS=-brtl -bexpall -qlongdouble -q$(COMBIT) -qalign=full -qstaticinline -qkeyword=typename
                DEBUGFLAGS=
        endif

        CCTMPOBJ=
        DMFLAGS=-xM1
        PICFLAGS=
        THRFLAGS=
        THRDEFS=-D_REENTRANT -D_THREAD_SAFE -DPTHREADS -DTHREAD

        LD=xlC_r
        LDFLAGS=-brtl -bexpall -bnoipath -q$(COMBIT) -qstaticinline -bhalt:5
        LDTMPOBJ=

        SHLD=xlC_r -brtl -G -qmkshrobj -bdynamic -bnoipath -berok
        SHLDFLAGS=-brtl -lpthreads -qstaticinline -bhalt:5
        SHLDTMPOBJ=

        ifeq "$(BIT64)" "1"
                LDFLAGS+= -b maxdata:0x8000000000
                SHLDFLAGS+= -q64
        else
                LDFLAGS+= -b maxdata:0x80000000
        endif
endif






ifeq "$(OS_TYPE)" "HP-UX"
        HP=1
        DLLEXT =sl
        DEFS+=-DHPUX -D$(PRODUCT_NAME) -D$(PRODUCT_VER) -D$(PROJECT_ADDR)
        DL_LIB=dld

        #MKDEP=$(CXX_TYPE) +maked -E
        MKDEP=fastdepend
        CXX=$(CXX_TYPE)
        CXXFLAGS=
        CXXTMPOBJ=
        CC=$(CC_TYPE)
        ifeq "$(CPU_TYPE)" "IA64"
                CCFLAGS=+Z -Wl,+s +u4 -ext -mt -AA -DORBNEWTHROW= -D_KERNEL_THREADS -D_RWSTD_MULTI_THREAD
                THRDEFS=-D_REENTRANT -D_THREAD_SAFE -DPTHREADS -DTHREAD -D_RWSTD_MULTI_THREAD
#               LDFLAGS=-Wl,+s -AA -lpthread
                LDFLAGS=-Wl,+s -AA -mt
#               SHLDFLAGS=-b -bdynamic -Wl,+s -AA -D_RWSTD_MULTI_THREAD -lpthread
                SHLDFLAGS=-b -bdynamic -Wl,+s -AA -D_RWSTD_MULTI_THREAD -mt
        else
                HP_DA_FLAG=+DA1.1
ifeq "$(OBMW_TYPE)" "VisiBroker"
ifeq "$(OBMW_VER)" "6.5"
                HP_DA_FLAG=+DAportable
                DEFS+=-D_VIS_STD -DHPUX_11 -DINCLUDE_FSTREAM -D_VIS_LONG_LONG -D_VIS_LONG_DOUBLE \
                        -D_VIS_UNICODE -D_VIS_STREAM_WCHAR -D_VIS_NO_IOSTREAM_WCHAR -D_VIS_NO_IOSTREAM_LONGDOUBLE +W1039
endif
endif
                CCFLAGS=+Z -Wl,+s +u1 -ext -mt -w $(HP_DA_FLAG) -DORBNEWTHROW= -D_KERNEL_THREADS -D_RWSTD_MULTI_THREAD
                THRDEFS=-D_REENTRANT -D_THREAD_SAFE -DPTHREADS -DTHREAD -D_RWSTD_MULTI_THREAD
                LDFLAGS=-Wl,+s -lpthread
                SHLDFLAGS=-b -bdynamic -Wl,+s -D_RWSTD_MULTI_THREAD -lpthread
                ifeq "$(STL_TYPE)" "HP_STL_1.2.1"
                        CCFLAGS+= -Aa  -DOB_NO_STD
                        LDFLAGS+= -Aa
                        SHLDFLAGS+= -Aa
                        THRDEFS+= -DOB_NO_STD
                endif
                ifeq "$(STL_TYPE)" "HP_STL_2.0"
                        CCFLAGS+=-AA
						LDFLAGS+=-AA
                        SHLDFLAGS+=-AA
                endif
        endif

        CCTMPOBJ=
        DEBUGFLAGS=-g0 +d
        DMFLAGS=-xM1
        PICFLAGS=
        THRFLAGS=

        LD=$(CXX)
        LDTMPOBJ=

        SHLD=$(CXX)
        SHLDTMPOBJ=

        ifeq "$(BIT64)" "1"
                CCFLAGS+=+DD64
                LDFLAGS+=+DD64
                SHLDFLAGS+=+DD64
        endif
endif



ifeq "$(OS_TYPE)" "Linux"
        DLLEXT =so
        DEFS+=-DLINUX -DLINUX_X86 -D$(PRODUCT_NAME) -D$(PRODUCT_VER) -D$(PROJECT_ADDR)
        DL_LIB=dl
# lixp added
        MKDEP=$(CXX_TYPE) -MMD -E
# added end
        CXX=$(CXX_TYPE)
        CXXFLAGS=
        CXXTMPOBJ=
        CC=$(CC_TYPE)

# x86 CPU
        CCFLAGS=-fpic -ftemplate-depth-64
        THRDEFS=-D_REENTRANT -D_THREAD_SAFE -DPTHREADS -DTHREAD -D_RWSTD_MULTI_THREAD -D_GNU_SOUORCE
        LDFLAGS=-lpthread
        SHLDFLAGS=-shared -lpthread
        CCTMPOBJ=

        DEBUGFLAGS=-g
        DMFLAGS=-MM
        PICFLAGS=
        THRFLAGS=

        LD=$(CXX)
        LDTMPOBJ=

        SHLD=$(CXX)
        SHLDTMPOBJ=
endif



ifeq "$(PURIFY)" "1"
        CC := purify $(PURIFYOPTS) $(CC) -g
        CXX := purify $(PURIFYOPTS) $(CXX) -g
endif
ifeq "$(QUANTIFY)" "1"
        CC := quantify $(QUANTIFYOPTS) $(CC)
        CXX := quantify $(QUANTIFYOPTS) $(CXX)
endif

ifeq "$(IDLTYPE)" "1"
        ORBCCOPTS += $(ORBTYPEOPT)
endif

ifeq "$(DEBUG)" "1"
        BUILDTYPE=$(BITTYPE)D
        DEFS+=-DDEBUG $(PRODDEBUGDEFS)
        OBD_CCFLAGS:=$(CCFLAGS)
        OBD_CXXFLAGS=$(OBD_CCFLAGS) $(PICFLAGS) $(THRFLAGS) $(THRDEFS) $(OPTS)
        CCFLAGS+=$(DEBUGFLAGS) $(PICFLAGS) $(THRFLAGS) $(THRDEFS) $(OPTS)
        LDFLAGS+=$(LDDEBUGFLAGS)
        SHLDFLAGS+=$(LDDEBUGFLAGS)
else
        BUILDTYPE=$(BITTYPE)
        OBD_CCFLAGS=$(PICFLAGS) $(THRFLAGS) $(THRDEFS) $(OPTS)
        OBD_CXXFLAGS=$(OBD_FLAGS)
        CCFLAGS+=$(PICFLAGS) $(THRFLAGS) $(THRDEFS) $(OPTS)
endif



DLLTAIL=$(BUILDTYPE).$(DLLEXT)

ifeq "$(SYB)" "1"
        INCPATHS+= $(SYBASE)/include
        EXCPATHS+= $(SYBASE)/include
        LDPATHS+=$(SYBASE)/lib
        LDLIBNAMES+=ct_r cs_r comn_r blk_r tcl_r
        DEFS+=-DDB_TYPE_SYB
endif

ifeq "$(ORA8I)" "1"
        INCPATHS+= $(ORACLE_HOME)/rdbms/demo $(ORACLE_HOME)/rdbms/public \
                $(ORACLE_HOME)/plsql/public $(ORACLE_HOME)/network/public
        EXCPATHS+= $(ORACLE_HOME)/rdbms/demo $(ORACLE_HOME)/rdbms/public \
                $(ORACLE_HOME)/plsql/public $(ORACLE_HOME)/network/public
        DEFS += -DOTL_ORA8I -DDB_TYPE_ORA

        ifeq "$(BIT64)" "1"
                LDPATHS+=$(ORACLE_HOME)/lib64
        else
                LDPATHS+=$(ORACLE_HOME)/lib
        endif

        LDLIBNAMES+=clntsh
endif


ifeq "$(ORA9I)" "1"
        INCPATHS+= $(ORACLE_HOME)/rdbms/demo $(ORACLE_HOME)/rdbms/public \
                $(ORACLE_HOME)/plsql/public $(ORACLE_HOME)/network/public
        EXCPATHS+= $(ORACLE_HOME)/rdbms/demo $(ORACLE_HOME)/rdbms/public \
                $(ORACLE_HOME)/plsql/public $(ORACLE_HOME)/network/public
        DEFS += -DOTL_ORA9I -DDB_TYPE_ORA
        #DEFS += -DDB_TYPE_ORA

        ifeq "$(BIT64)" "1"
                LDPATHS+=$(ORACLE_HOME)/lib
        else
                ifeq "$(OS_TYPE)" "Linux"
                        LDPATHS+=$(ORACLE_HOME)/lib
                else
                        LDPATHS+=$(ORACLE_HOME)/lib32
                endif
        endif

        LDLIBNAMES+=clntsh
endif

MAKEDEST=$(PRODDEST)



INCPATHS+= $(PRODINCS)
LDPATHS+=$(PRODLIBPATH)
OPTS+=$(DEFS) $(PRODOPTS) $(SUBSYSTEM_DEFS)

LDOPTS+=$(THRFLAGS)
LDLIBS+=$(addprefix -L,$(LDPATHS)) $(addprefix -l,$(LDLIBNAMES))
LDFLAGS+=$(THRFLAGS) $(LDLIBS)
SHLDFLAGS+=$(LDLIBS)
CXXFLAGS=$(CCFLAGS)
CFLAGS=$(CCFLAGS)
INCOBDPATHS=$(PRODIDLPATH)

INCFLAGS+=$(addprefix -I,$(INCPATHS))
INCOBDFLAGS+=$(addprefix -I,$(INCOBDPATHS))

#中间件增加版本信息
OB_VER_NAME=__aiob_dll_version

# for dependances but delete files from ORACLE_HOME and obsystem, lixp added
MAKEDEP_FILE=Makefile.depend

#add by tzl for fastdepend 2007/06/05
EXCPATHS+= $(OB_REL)/include  \
    $(OB_REL)/include/common \
    $(OB_SRC)/obsystem/include  \
    $(OB_SRC)/obsystem/include/common

EXCFLAGS=$(addprefix -E,$(EXCPATHS))
#end add

# modify end



##### for OPENBOSS begin,analyze current work's subsystem dir name
CURDIR=$(shell pwd)
TEMP1=$(OB_SRC)/
TEMP2=$(subst $(TEMP1),,$(CURDIR))
TEMP3=$(subst /, ,$(TEMP2))
SUBSYSTEM=$(word 1, $(TEMP3))
MODULE_N=$(word 2, $(TEMP3))
##### for OPENBOSS end

#####################################
# below is dependence define
#####################################
.SUFFIXES: .cpp .cxx .CC .c .d .vidl
.PHONY: all clean rebuild

%_obd_c.o: %_obd_c.cpp
        $(CXX) $(OBD_CXXFLAGS) $(INCFLAGS) -c $< -o $@
%_imp.o: %_imp.cpp
        $(CXX) $(OBD_CXXFLAGS) $(INCFLAGS) -c $< -o $@
%.o: %.cpp
        $(CXX) $(CXXFLAGS) $(INCFLAGS) -c $< -o $@
%.o: %.cxx
        $(CXX) $(CXXFLAGS) $(INCFLAGS) -c $< -o $@
%.o: %.cc
        $(CXX) $(CXXFLAGS) $(INCFLAGS) -c $< -o $@
%.o: %.CC
        $(CXX) $(CXXFLAGS) $(INCFLAGS) -c $< -o $@
%.o: %.c
        $(CXX) $(CFLAGS) $(INCFLAGS) -c $< -o $@
%.d: %.cpp
        @$(CXX) $(DMFLAGS) $(CXXFLAGS) $^ \
        | sed 's/\($*\)\.o[ :]*/\1.o $@ : /g' > $@; \
        [ -s $@ ] || rm -f $@
%.d: %.c
        @$(CC) $(DMFLAGS) $(CCFLAGS) $^ \
        | sed 's/\($*\)\.o[ :]*/\1.o $@ : /g' > $@; \
        [ -s $@ ] || rm -f $@



# define VPATH
HEADER_VPATH=$(OB_REL)/include/$(SUBSYSTEM):../include
OBD_VPATH=.:../kernel:$(PRODIDLPATH)
VPATH=$(OBD_VPATH):$(HEADER_VPATH)

# the first make rule
all:$(MAKEDEST)

checkenv:
        @echo Build for ${OS_TYPE}
        @echo
        @echo Using C++ compiler $(CXX)
        @echo
        @echo Using C compiler $(CC)
        @echo
        @echo BUILDTYPE= $(BUILDTYPE)
        @echo
        @echo CXXFLAGS= $(CXXFLAGS)
        @echo
        @echo LDPATHS= $(LDPATHS)
        @echo
        @echo LDFLAGS= $(LDFLAGS)
        @echo
        @echo SYSTEMOBJ= $(SYSTEMTMPOBJS)
        @echo
        @echo ORBCCOPTS= $(ORBCCOPTS)
        @echo
        @echo OBDCCOPTS= $(OBDCCOPTS)
        @echo
        @echo CONFLIST= $(CONFLIST)
        @echo
        @echo INCOBDFLAGS= $(INCOBDFLAGS)
        @echo
        @echo PRODDEST= $(PRODDEST)
        @echo

checkobj:
        @echo $(PRODDEST)

SYSOBJ=$(CXXTMPOBJ) $(CCTMPOBJ) $(LDTMPOBJ) $(SHLDTMPOBJ)
SYSTEMTMPDIRS=.
SYSTEMTMPDIRS+=$(foreach OBJ,$(filter %.o,$(PRODTMPOBJ)),\
        $(shell dirname "$(OBJ)"))
SYSTEMTMPOBJS=$(foreach dir,$(SYSTEMTMPDIRS),\
        $(foreach TMPOBJ,$(SYSOBJ),$(dir)/$(TMPOBJ)))
cleansysobj:
        @rm -rf $(SYSTEMTMPOBJS)
cleanprodobj:
        @rm -rf $(PRODTMPOBJ)
        @rm -rf $(PRODOBJS)

clean: cleansysobj cleanprodobj
        rm -rf *_[cs].hh *_[cs].cc
        rm -rf *_msg.cpp *_msg.h
        rm -rf *.o
        rm -rf *.mk *.vidl
        rm -rf $(PRODDEST) core

cleandep:
        rm -rf $(MAKEDEP_FILE)

clean_all: clean cleandep

make_install_all:
        ${MAKE} all install install_headers install_idl
