cmake_minimum_required(VERSION 3.22)
project(AmetrineLauncher LANGUAGES CXX OBJCXX)

# Opciones de compilación
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Configuración específica de iOS
if(IOS)
    set(MACOSX_BUNDLE ON)
    set(CMAKE_XCODE_ATTRIBUTE_TARGETED_DEVICE_FAMILY "2") # 2 es para iPad only
    set(CMAKE_XCODE_ATTRIBUTE_IPHONEOS_DEPLOYMENT_TARGET "15.0")
    set(CMAKE_XCODE_ATTRIBUTE_CODE_SIGNING_ALLOWED NO) # SideStore/TrollStore no requieren firma de Xcode
    set(CMAKE_XCODE_ATTRIBUTE_INFOPLIST_FILE "${CMAKE_CURRENT_SOURCE_DIR}/src/Info.plist")
endif()

# Buscar Qt 6
find_package(Qt6 COMPONENTS Core Gui Widgets REQUIRED)

# Archivos fuente del proyecto
set(SOURCES
    src/main.mm
    src/glfw_bypass.cpp
)

# Definir el ejecutable (Bundle de la App)
add_executable(AmetrineLauncher ${SOURCES})

# Vincular módulos de Qt
target_link_libraries(AmetrineLauncher PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Widgets
)

# Vincular frameworks nativos de Apple en iOS
if(IOS)
    target_link_libraries(AmetrineLauncher PRIVATE
        "-framework Foundation"
        "-framework UIKit"
        "-framework GameController"
        "-framework Metal"
        "-framework QuartzCore"
    )
    
    # Propiedades del bundle de iOS
    set_target_properties(AmetrineLauncher PROPERTIES
        MACOSX_BUNDLE_BUNDLE_NAME "Ametrine Launcher"
        MACOSX_BUNDLE_GUI_IDENTIFIER "org.ametrinelauncher.launcher"
        MACOSX_BUNDLE_BUNDLE_VERSION "1.0.0"
        MACOSX_BUNDLE_SHORT_VERSION_STRING "1.0"
    )
endif()
