cmake_minimum_required(VERSION 3.25)

project(CaesarPadUITestHarness LANGUAGES Swift)

set(CMAKE_XCODE_ATTRIBUTE_IPHONEOS_DEPLOYMENT_TARGET "15.0")
set(CMAKE_XCODE_ATTRIBUTE_ONLY_ACTIVE_ARCH "YES")
set(CMAKE_XCODE_ATTRIBUTE_SUPPORTED_PLATFORMS "iphonesimulator")
set(CMAKE_XCODE_ATTRIBUTE_TARGETED_DEVICE_FAMILY "2")

add_executable(CaesarPadTestHost MACOSX_BUNDLE HostApp.swift)
set_target_properties(CaesarPadTestHost PROPERTIES
    XCODE_ATTRIBUTE_CODE_SIGNING_ALLOWED "NO"
    XCODE_ATTRIBUTE_GENERATE_INFOPLIST_FILE "YES"
    XCODE_ATTRIBUTE_PRODUCT_BUNDLE_IDENTIFIER "dev.caesarpad.testhost"
    XCODE_ATTRIBUTE_UIRequiresFullScreen "YES"
    XCODE_GENERATE_SCHEME TRUE
)

add_library(CaesarPadUITests MODULE CaesarPadUITests.swift)
target_link_libraries(CaesarPadUITests PRIVATE "-framework XCTest")
add_dependencies(CaesarPadUITests CaesarPadTestHost)
set_target_properties(CaesarPadUITests PROPERTIES
    BUNDLE TRUE
    BUNDLE_EXTENSION "xctest"
    XCTEST TRUE
    XCTEST_TESTEE CaesarPadTestHost
    XCODE_ATTRIBUTE_CODE_SIGNING_ALLOWED "NO"
    XCODE_ATTRIBUTE_GENERATE_INFOPLIST_FILE "YES"
    XCODE_ATTRIBUTE_PRODUCT_BUNDLE_IDENTIFIER "dev.caesarpad.uitests"
    XCODE_ATTRIBUTE_TEST_TARGET_NAME "CaesarPadTestHost"
    XCODE_GENERATE_SCHEME TRUE
    XCODE_PRODUCT_TYPE "com.apple.product-type.bundle.ui-testing"
)
