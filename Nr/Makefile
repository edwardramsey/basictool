########################################################
# 后台动态库 Makefile 的写法
#
#########################################################
#
# 包含基本的系统参数定义【不能更改】
include $(OB_REL)/etc/NGbasedefine.mk
#
########################################################
# 目标名称，最终的程序文件名是 lib$(DEST)$(DLLTAIL)【必须修改】
DEST = main

# 目标的类型，必须是 DLL
DEST_TYPE = DLL

# 编译目标程序需要的源代码文件，可以带路径（但必须是绝对路径）【必须修改】
DEST_SOURCES = \
			nr_info.cpp\

# 目标的头文件安装路径，最终目录将是 $OB_REL/include/$(SUBSYSTEM)/$(HEADER_PATH)/ 【可选】
HEADER_PATH =

# 需要安装的头文件，文件名需带路径【可选】
OD_HEADERS = 

OD_HEADERS_PATH = $(OB_REL)/include/public/odframe

ADDTIONAL_INSTALL_HEADER_CMD = mkdir -p $(OD_HEADERS_PATH) && cp -rf $(OD_HEADERS) $(OD_HEADERS_PATH)

# 其它选项【可选】
#IS_OPENBROKER_SOURCE = 1
NEED_DATABASE = 0
NEED_MIDDLE_WARE = 0
NEED_OPENBROKER = 0
NEED_MAKE_DEPEND = 1

########################################################
# 用户的宏定义，为编译器添加其它的 -D 参数，注意不要自行添加 -D 【可选】
# USER_DEFS =
USER_CXXFLAGS =
ifeq "$(OS_TYPE)" "AIX"
	USER_CXXFLAGS+= -qrtti
endif

# 用户定义的 include 路径，即除了 public 外的其它 include 路径【可选】
USER_INC_PATH = . \
	$(OB_REL)/include/public/common \
	$(OB_REL)/include/public/common/base \

# 非 $(OB_REL)/lib/ 下库文件的连接路径【可选】
USER_LD_PATH = \

# 需要连接的其它库文件，应使用 $(BUILDTYPE) 作为后缀【可选】
USER_LIBRARIES = \
	pthread \
 
################################################## 

# 包含基本的 Makefile 规则文件【不能更改】
include $(OB_REL)/etc/NGCmake
