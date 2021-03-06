# arch-tag: Main Makefile
# Copyright (C) 2004 - 2005 John Goerzen <jgoerzen@complete.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

.PHONY: all
all: setup
	./setup configure
	./setup build

PYTHON ?= python
setup: Setup.hs MissingPy.cabal
	ghc -package Cabal Setup.hs -o setup

doc: setup
	./setup haddock

clean:
	-./setup clean
	-rm -rf html `find . -name "*.o"` `find . -name "*.hi"` \
		`find . -name "*~"` *.a setup dist testsrc/runtests \
		 local-pkg *.buildinfo
	-cd doc && $(MAKE) clean

.PHONY: local-pkg
local-pkg: all
	echo "[" > local-pkg
	cat .installed-pkg-config >> local-pkg
	echo "]" >> local-pkg

testsrc/runtests: $(shell find . -name "*.hs") \
			$(shell find . -name "*.hsc")
	ghc6 -O2 -o testsrc/runtests -Iglue -Ldist/build -odir dist/build \
	   -hidir dist/build -package mtl -fffi -idist/build -itestsrc \
	   -L/usr/lib -L/usr/lib/python2.5/site-packages \
	   -fglasgow-exts \
	   -I/usr/include/python2.5 \
		-package HUnit --make testsrc/runtests.hs \
		dist/build/glue/glue.o dist/build/glue/excglue.o -lpython2.5

# dist/build/libHSMissingPy-*
test-ghc6: testsrc/runtests
	testsrc/runtests 

test-hugs:
	runhugs -98 +o -P$(PWD)/libsrc:$(PWD)/testsrc: testsrc/runtests.hs

interact-hugs:
	hugs -98 +o -P$(PWD)/libsrc:

interact-ghci: all
	ghci -fallow-overlapping-instances -fallow-undecidable-instances -fglasgow-exts -ilibsrc

interact: interact-hugs

test: test-ghc6

genexceptions:
	runhugs genexceptions.hs

