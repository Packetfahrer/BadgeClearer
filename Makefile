#Link_Theos := $(shell if [[ ! -h theos ]]; then ln -s $(THEOS); fi)

#TARGET = iphone:clang:6.1
export ARCHS = armv7 arm64
export SDKVERSION = 7.0
export THEOS_BUILD_DIR = packages

include ./theos/makefiles/common.mk

TWEAK_NAME = BadgeClearer
BadgeClearer_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"

SUBPROJECTS += badgeclearerpreferences
include $(THEOS_MAKE_PATH)/aggregate.mk
