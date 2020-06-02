THEOS_DEVICE_IP = 127.0.0.1
THEOS_DEVICE_PORT = 2222

ARCHS = arm64
DEBUG = 0
FINALPACKAGE = 1

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = XGesture13

XGesture13_FILES = Tweak.xm
XGesture13_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
