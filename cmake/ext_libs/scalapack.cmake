# Finds Scalapack, tests, and if not found or broken, autobuild scalapack
include(ExternalProject)

if(NOT scalapack_external)
  if(autobuild)
    find_package(SCALAPACK)
  else()
    find_package(SCALAPACK REQUIRED)
  endif()
endif()

if(SCALAPACK_FOUND OR TARGET SCALAPACK::SCALAPACK)
  return()
endif()

set(scalapack_external true CACHE BOOL "build ScaLapack")

if(NOT TARGET LAPACK)
  # acquired by find_package instead of ExternalProject, so make dummy target
  add_custom_target(LAPACK)
endif()

if(NOT SCALAPACK_ROOT)
  set(SCALAPACK_ROOT ${CMAKE_INSTALL_PREFIX})
endif()

set(SCALAPACK_LIBRARIES
${SCALAPACK_ROOT}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}scalapack${CMAKE_STATIC_LIBRARY_SUFFIX}
${SCALAPACK_ROOT}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}blacs${CMAKE_STATIC_LIBRARY_SUFFIX})


ExternalProject_Add(SCALAPACK
GIT_REPOSITORY ${scalapack_git}
GIT_TAG ${scalapack_tag}
CMAKE_ARGS -DCMAKE_INSTALL_PREFIX:PATH=${SCALAPACK_ROOT} -DLAPACK_ROOT:PATH=${LAPACK_ROOT} -DBUILD_SHARED_LIBS:BOOL=false -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING:BOOL=false
CMAKE_CACHE_ARGS -Darith:STRING=${arith}
BUILD_BYPRODUCTS ${SCALAPACK_LIBRARIES}
INACTIVITY_TIMEOUT 15
CONFIGURE_HANDLED_BY_BUILD ON
DEPENDS LAPACK
)

ExternalProject_Get_property(SCALAPACK SOURCE_DIR)

# FIXME: patch with FindMPI.cmake
# (remove when updated with new FindMPI.cmaake)
ExternalProject_Add_Step(SCALAPACK patch_find_mpi DEPENDEES patch
COMMAND ${CMAKE_COMMAND} -E copy_if_different ${CMAKE_CURRENT_LIST_DIR}/../Modules/FindMPI.cmake ${SOURCE_DIR}/cmake/Modules/)


add_library(SCALAPACK::SCALAPACK INTERFACE IMPORTED)
target_link_libraries(SCALAPACK::SCALAPACK INTERFACE "${SCALAPACK_LIBRARIES}")

# race condition for linking without this
add_dependencies(SCALAPACK::SCALAPACK SCALAPACK)
