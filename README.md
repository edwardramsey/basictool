# basictool
I want to write somebasic tool for myself. I want to it can make me do some work more easier.
List:
  1. generic makefile
  2. readfileinfo tool
  3. 


-------------
####Makefile Use Example
Example File Architecture:

(include these two files)
|--MakeMaster.mk
|--MakeBasic.mk

|--Makefile
|--
`--subdir1
	|--Makefile
	|--xx.h
	|--xx.cpp
`--subdir2
	|--Makefile
	|--xx.h
	|--xx.cpp

Example Makefile in project root path	
```
SUBDIRS=subdir1\
		subdir2

include $(YOUR_MAKE_PATH)/MakeMaster.mk
```

Example Makefile in Subdir
```
DEST_TYPE=BIN
DEST = YOURNAME
DEST_SOURCE=xx.cpp\
			xxx.cpp ...

include $(YOUR_MAKE_PATH)/MakeBasic.mk
```
