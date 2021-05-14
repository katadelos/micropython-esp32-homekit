# micropython-esp32-homekit
micropython-esp32-homekit allows the user to create HomeKit compatible devices using the Micropython programming language.

This repository consists of the `homekit` Micropython module created by [@remibert](https://github.com/remibert) for the [pycameresp](https://github.com/remibert/pycameresp) project (with minor changes that allow the module to be built as an [external C module](https://docs.micropython.org/en/latest/develop/cmodules.html)) and patches required to integrate the module into Micropython.

## Compatibility
micropython-esp32-homekit is only compatible with the ESP32 series of development boards. 

Although the underlying `esp-homekit-sdk` provides limited support for ESP8266 based development boards, it requires the use of the `ESP8266-RTOS-SDK` and is not compatible with the `esp-open-sdk` used by the ESP8266 port of Micropython.

## Building
To build micropython-esp32-homekit, use:
```
make
```
This will download and patch the required components and build a Micropython firmware binary with the `homekit` module included. The firmware binary can be found within the `firmware` directory.

To build for a specific board, specify the board target as an environment variable:
```
make BOARD=GENERIC_OTA
```

To clean the Micropython workspace or delete all downloaded components, use:
```
make clean
make clean-all
```