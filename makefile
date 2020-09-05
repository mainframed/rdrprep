#
# Makefile for Linux version of rdrprep
#

DESTDIR  = $(PREFIX)/usr/local/bin

# Standard flags for all architectures
CFLAGS	 = -O2 -Wall -fPIC 
CFL_370  = -O2 -Wall -fPIC 
LFLAGS	 = -lpthread

# Add default flags for Pentium compilations
ifndef HOST_ARCH
CFLAGS	 += -malign-double -march=pentiumpro
CFL_370  += -malign-double -march=pentiumpro
endif

# Handle host architecture if specified
ifeq ($(HOST_ARCH),i386)
CFLAGS	 += -malign-double
CFL_370	 += -malign-double
endif
ifeq ($(HOST_ARCH),i586)
CFLAGS	 += -malign-double -march=pentium
CFL_370  += -malign-double -march=pentium
endif
ifeq ($(HOST_ARCH),i686)
CFLAGS	 += -malign-double -march=pentiumpro
CFL_370  += -malign-double -march=pentiumpro
endif

EXEFILES = rdrprep

RECV_OBJS = rdrprep.o

all:	   $(EXEFILES)

rdrprep: $(RECV_OBJS)
	$(CC) -o rdrprep $(RECV_OBJS)

install:  $(EXEFILES)
	cp $(EXEFILES) $(DESTDIR)

