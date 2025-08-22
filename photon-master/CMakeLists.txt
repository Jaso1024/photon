cmake_minimum_required(VERSION 3.16)
project(PhotonMaster VERSION 1.0.0)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

# Find required Qt components
find_package(Qt6 REQUIRED COMPONENTS Core Widgets Network)

# Source files
set(SOURCES
    src/main.cpp
    src/MainWindow.cpp
    src/MoonlightManager.cpp
    src/RemotePC.cpp
)

set(HEADERS
    src/MainWindow.h
    src/MoonlightManager.h
    src/RemotePC.h
)

# Create executable
add_executable(photon-master ${SOURCES} ${HEADERS})

# Link Qt libraries
target_link_libraries(photon-master
    Qt6::Core
    Qt6::Widgets
    Qt6::Network
)

# Set properties
set_target_properties(photon-master PROPERTIES
    WIN32_EXECUTABLE TRUE
    MACOSX_BUNDLE TRUE
)