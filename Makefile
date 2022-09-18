SHELL=/bin/bash
ROOT=$(PWD)/components

BOARD=GENERIC

MPY_DIR=$(ROOT)/micropython
MPY_MOD_DIR=$(PWD)/modules/
ESPIDF_DIR=$(ROOT)/esp-idf
ESPHK_DIR=$(ROOT)/esp-homekit-sdk
PATCH_DIR=$(PWD)/patch

MPY_VERSION=v1.15
ESPIDF_VERSION=v4.2.1
ESPHK_VERSION=389189abd7c1965d70eb3ddc7a19a8f0313f1fc8

ifneq ($(LOCAL_GIT_DIR),)
MPY_URL=file://$(LOCAL_GIT_DIR)/micropython
ESPIDF_URL=file://$(LOCAL_GIT_DIR)/esp-idf
ESPHK_URL=file://$(LOCAL_GIT_DIR)/esp-homekit-sdk
else
MPY_URL=https://github.com/micropython/micropython/
ESPIDF_URL=http://github.com/espressif/esp-idf
ESPHK_URL=https://github.com/espressif/esp-homekit-sdk
endif

default: all

define sl_hk
	ln -sf $(ESPHK_DIR)/components/homekit/$1 $(ESPIDF_DIR)/components/$1
endef

setup-dirs:
ifeq ($(wildcard .stamp_setup_dirs),)
	mkdir $(ROOT)
	mkdir firmware
	touch .stamp_setup_dirs
endif

get-micropython:
ifeq ($(wildcard .stamp_mpy_dl),)
	git -C $(ROOT) clone $(MPY_URL)
	git -C $(MPY_DIR) checkout $(MPY_VERSION)
	touch .stamp_mpy_dl
endif

get-esp_idf:
ifeq ($(wildcard .stamp_espidf_dl),)
	git -C $(ROOT) clone $(ESPIDF_URL)
	git -C $(ESPIDF_DIR) checkout $(ESPIDF_VERSION)
ifneq ($(LOCAL_GIT_DIR),)
	scripts/localtool espidf-submodules $(LOCAL_GIT_DIR)
endif
	git -C $(ESPIDF_DIR) submodule update --init \
		components/bt/controller/lib \
		components/bt/host/nimble/nimble \
		components/esp_wifi \
		components/esptool_py/esptool \
		components/lwip/lwip \
		components/mbedtls/mbedtls \
		components/asio \
		components/cbor \
		components/coap \
		components/nghttp \
		components/expat \
		components/mqtt \
		components/spiffs \
		components/unity \
		components/protobuf-c \
		components/json \
		components/bootloader
	cd $(ESPIDF_DIR) && ./install.sh
	touch .stamp_espidf_dl
endif

get-esp_homekit_sdk:
ifeq ($(wildcard .stamp_esphk_dl),)
	git -C $(ROOT) clone $(ESPHK_URL)
	git -C $(ESPHK_DIR) checkout $(ESPHK_VERSION)
ifneq ($(LOCAL_GIT_DIR),)
	scripts/localtool esphk-submodules $(LOCAL_GIT_DIR)
endif
	git -C $(ESPHK_DIR) submodule update --init --recursive -- components/homekit/json_parser/
	git -C $(ESPHK_DIR) submodule update --init -- components/homekit/json_generator
	$(call sl_hk,esp_hap_apple_profiles)
	$(call sl_hk,esp_hap_core)
	$(call sl_hk,esp_hap_extras)
	$(call sl_hk,esp_hap_platform)
	$(call sl_hk,hkdf-sha)
	$(call sl_hk,json_generator)
	$(call sl_hk,json_parser)
	$(call sl_hk,mu_srp)
	touch .stamp_esphk_dl
endif

get-dependencies: setup-dirs get-micropython get-esp_idf get-esp_homekit_sdk

patch-components:
ifeq ($(wildcard .stamp_patched),)
	git -C $(ESPHK_DIR) apply $(PATCH_DIR)/esp-homekit-sdk/*.patch
	git -C $(ESPIDF_DIR) apply $(PATCH_DIR)/esp-idf/*.patch
	git -C $(MPY_DIR) apply $(PATCH_DIR)/micropython/*.patch
	cp -frvp modules/homekit/py $(MPY_DIR)/ports/esp32/modules/homekit
	touch .stamp_patched
endif

build-micropython:
	make -C $(MPY_DIR)/mpy-cross
	source $(ESPIDF_DIR)/export.sh; \
	make -C $(MPY_DIR)/ports/esp32 submodules; \
	make USER_C_MODULES=$(MPY_MOD_DIR)/micropython.cmake -C $(MPY_DIR)/ports/esp32 BOARD=$(BOARD)

retrieve-firmware:
	cp $(MPY_DIR)/ports/esp32/build-$(BOARD)/firmware.bin \
	$(PWD)/firmware/micropython-esp32-homekit-$(BOARD).bin

clean:
	source $(ESPIDF_DIR)/export.sh; \
	make -C $(MPY_DIR)/ports/esp32 clean

clean-all:
	rm -rf components
	rm -rf firmware
	rm .stamp_*

all: get-dependencies patch-components build-micropython retrieve-firmware
