
#
# hxinotify
#
# For debug build set: debug=true
#

OS = Linux
NDLL_FLAGS =
HXCPP_FLAGS =

SRC = sys/io/Inotify*.hx
SRC_DEMO = $(SRC) sys/io/Inotify*.hx demo/InotifyDemo.hx

uname_M := $(shell sh -c 'uname -m 2>/dev/null || echo not')
ifeq (${uname_M},x86_64)
OS = Linux64
NDLL_FLAGS += -DHXCPP_M64 -Ddebug
HXCPP_FLAGS += -D HXCPP_M64
else ifeq (${uname_M},armv6l)
OS = RPi
else ifeq (${uname_M},armv7l)
OS = ARM7
endif

NDLL = ndll/$(OS)/inotify.ndll
HX_DEMO = haxe  -main InotifyDemo -cp ../ $(HXCPP_FLAGS)

ifeq (${debug},true)
HX_DEMO += -debug
else
HX_DEMO += --no-traces -dce full
endif

$(NDLL): src/*.cpp
	@echo "Building ndll for : $(OS)"
	@(cd src;haxelib run hxcpp build.xml $(NDLL_FLAGS);)

ndll: $(NDLL)

demo-neko: $(NDLL) $(SRC_DEMO)
	@mkdir -p demo
	@(cd demo;$(HX_DEMO) -neko inotify-demo.n)
	cp $(NDLL) demo/

demo-cpp: $(NDLL) $(SRC_DEMO)
	@mkdir -p demo
	@(cd demo;$(HX_DEMO) -neko inotify-demo.n)
	@(cd demo;$(HX_DEMO) -cpp bin)
	mv demo/bin/InotifyDemo* demo
	cp $(NDLL) demo/

demo: demo-neko demo-cpp

haxelib:
	zip -r hxinotify.zip ndll src/*.cpp src/build.xml sys haxelib.json

install: haxelib
	haxelib local hxinotify.zip

uninstall:
	haxelib remove hxinotify

all: ndll demo

clean:
	rm -rf ndll/
	rm -rf src/obj
	rm -f src/all_objs
	rm -rf demo/bin
	rm -f demo/inotify-demo demo/inotify-demo.n demo/inotify.ndll
	rm -f hxinotify.zip

.PHONY: ndll demo clean
