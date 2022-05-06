.POSIX:
.SUFFIXES: .el .elc

EMACS 	 = emacs -Q -q --batch
COMPILE  = xeft.elc

# Additional emacs load-path and autoload
LOAD_PATH := -L .
LOAD_AUTOLOAD := -l autoload

# AUTOLOAD related variables
AUTOLOAD_DIR  := "${PWD}"
AUTOLOAD_FILE := "${PWD}/xeft-autoloads.el"
AUTOLOAD_EVAL := --eval '(make-directory-autoloads ${AUTOLOAD_DIR} ${AUTOLOAD_FILE})'

PREFIX ?= /usr/local
CXX ?= g++
CXXFLAGS = -fPIC -I$(PREFIX)/include -std=c++11
LDFLAGS = -L$(PREFIX)/lib
LDLIBS = -lxapian

# Dylib extensions.
ifeq ($(OS),Windows_NT)
	SOEXT = dll
else ifeq ($(shell uname),Darwin)
	SOEXT = dylib
else
	SOEXT = so
endif

all: xapian-lite.$(SOEXT) compile autoload

xapian-lite.$(SOEXT): xapian-lite.cc
	$(CXX) $< -o $@ -shared $(CXXFLAGS) $(LDFLAGS) $(LDLIBS)

.el.elc:
	$(EMACS) $(LOAD_PATH) -f batch-byte-compile $^

.PHONY: compile
compile: $(COMPILE)

.PHONY: autoload
autoload:
	${EMACS} ${LOAD_AUTOLOAD} ${AUTOLOAD_EVAL}

.PHONY: clean
clean:
	rm -f *.so *.o *.dylib *.dll *.elc
