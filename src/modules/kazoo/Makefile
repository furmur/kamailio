#
# WARNING: do not run this directly, it should be run by the main Makefile

include ../../Makefile.defs
auto_gen=
NAME=kazoo.so
JLIB=json

BUILDER = $(shell which pkg-config)
ifeq ($(BUILDER),)
	JSONC=$(shell ls $(SYSBASE)/include/lib/libjson*.so $(LOCALBASE)/lib/libjson*.so 2>/dev/null | grep json-c)
else
	JSONC=$(shell pkg-config --libs json-c 2>/dev/null | grep json-c)

	ifeq ($(shell pkg-config --atleast-version=0.13.0 librabbitmq; echo $$?),0)
		DEFS += -DRABBITMQ_DEPRECATION
	endif
endif

ifneq ($(JSONC),)
	JLIB=json-c
endif

ifeq ($(BUILDER),)
	DEFS+=-I$(LOCALBASE)/include -I$(SYSBASE)/include \
		-I$(SYSBASE)/include/$(JLIB)
	LIBS=-L$(LOCALBASE)/lib -I$(SYSBASE)/lib -lrabbitmq -l$(JLIB) -luuid -levent
else
	DEFS += $(shell $(BUILDER) --cflags $(JLIB))
	LIBS += $(shell $(BUILDER) --libs $(JLIB))
	DEFS += $(shell $(BUILDER) --cflags uuid)
	LIBS += $(shell $(BUILDER) --libs uuid)
	DEFS += $(shell $(BUILDER) --cflags librabbitmq)
	LIBS += $(shell $(BUILDER) --libs librabbitmq)
	DEFS += $(shell $(BUILDER) --cflags libevent)
	LIBS += $(shell $(BUILDER) --libs libevent)
endif

include ../../Makefile.modules
