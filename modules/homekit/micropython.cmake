add_library(usermod_homekit_ INTERFACE)

target_sources(usermod_homekit_ INTERFACE
    ${CMAKE_CURRENT_LIST_DIR}/modhomekit.c
    ${CMAKE_CURRENT_LIST_DIR}/modhomekit_accessory.c
    ${CMAKE_CURRENT_LIST_DIR}/modhomekit_charact.c
    ${CMAKE_CURRENT_LIST_DIR}/modhomekit_service.c
)

target_include_directories(usermod_homekit_ INTERFACE
    ${CMAKE_CURRENT_LIST_DIR}
    ${CMAKE_CURRENT_LIST_DIR}/../../components/esp-homekit-sdk/components/homekit/esp_hap_core/include
    ${CMAKE_CURRENT_LIST_DIR}/../../components/esp-homekit-sdk/components/homekit/esp_hap_apple_profiles/include
)

target_link_libraries(usermod INTERFACE usermod_homekit_)