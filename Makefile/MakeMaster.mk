# make the project in the subdir file

.PHONY: all clean install 

all:
ifneq "$(SUBDIRS)" ""
	(for target in ${SUBDIRS}; do (cd $$target; pwd; ${MAKE} $@); done)
endif

clean:
ifneq "$(SUBDIRS)" ""
	(for target in ${SUBDIRS}; do (cd $$target; pwd; ${MAKE} $@); done)
endif	

install:
ifneq "$(SUBDIRS)" ""
	(for target in ${SUBDIRS}; do (cd $(target; pwd; ${MAKE} $@); done)
endif


