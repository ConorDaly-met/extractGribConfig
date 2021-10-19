################################################################################

cmake_minimum_required( VERSION 3.12 FATAL_ERROR )

################################################################################

## If user has defined environment var EXP (your harmonie experiment) the install 
## will default to $HOME/extractGribConfig/$EXP
## This is overridden by commandline -DCMAKE_INSTALL_PREFIX

if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  if(NOT DEFINED ENV{EXP})
      message(FATAL_ERROR "Please define either CMAKE_INSTALL_PREFIX or environment variable EXP")
      exit(1)
  endif()
  if(DEFINED ENV{HOME})
    string(CONCAT MYPREFIX $ENV{HOME} "/extractGribConfig/" $ENV{EXP})
  endif()
  message(STATUS "MYPREFIX: ${MYPREFIX}") 
  set(CMAKE_INSTALL_PREFIX "${MYPREFIX}" CACHE PATH "..." FORCE)
endif()

################################################################################

project( extractGribConfig LANGUAGES NONE )

################################################################################

add_subdirectory (bin)
add_subdirectory (share)
