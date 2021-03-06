# --- generate constants
configure_file(constants/phys_consts.in.f90 phys_consts.f90 @ONLY)
add_library(const OBJECT ${CMAKE_CURRENT_BINARY_DIR}/phys_consts.f90)

# --- interpolation
add_subdirectory(interpolation)

# --- grid
add_subdirectory(grid)

add_subdirectory(calculus)

add_subdirectory(diffusion)

add_library(advec OBJECT advection/advec_mpi.f90)
target_link_libraries(advec PRIVATE const mpimod grid meshobj)

add_subdirectory(potential)

add_subdirectory(coord)

set_targ_props(advec const diffusion grid interp mumps_interface PDEelliptic PDEparabolic potential)
