# make the project in the subdir file

.PHONY: all clean install 
all:
ifneq "$(SUBDIRS)" ""
	(for target in $(SUBDIRS); do (cd $$(i); pwd; ${MAKE} $@); done)
endif

clean:
ifneq "$(SUBDIRS)" ""
	(for i in ${SUBDIRS}; do (cd $$i; pwd; ${MAKE} $@); done)
endif	

install:
ifneq "$(SUBDIRS)" ""
	(for i in ${SUBDIRS}; do (cd $$i; pwd; ${MAKE} $@); done)
endif


