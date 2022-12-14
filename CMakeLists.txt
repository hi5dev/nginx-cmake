# Minimum version of CMake required for this file.
cmake_minimum_required(VERSION 3.24)

# Patch is used to install the cmake generator script in auto/configure.
find_package(Patch REQUIRED)

# This project's name and its semantic version number.
project(nginx-cmake VERSION 1.0.0 LANGUAGES C)

# Project options.
option(nginx_INSTALL "Include installation targets" ON)

# The official nginx repository is hosted with Mercurial, but there's also a mirror that's updated hourly on Github.
set(nginx_URL "https://github.com/nginx/nginx.git" CACHE STRING "URL to the nginx git repository")

# The Git tag to checkout after cloning the repository.
set(nginx_TAG "release-1.23.2" CACHE STRING "Git tag to checkout after cloning the repository")

# Configure nginx to build to the CMake binary directory using the same compiler as CMake.
list(APPEND nginx_CONFIGURE_OPTS --prefix=${CMAKE_INSTALL_PREFIX} --with-cc=${CMAKE_C_COMPILER})

# Enables populating content at configure time via any method supported by the ExternalProject module.
include(FetchContent)

# Don't check for changes after cloning the repository since it's locked to a specific tag.
set(FETCHCONTENT_UPDATES_DISCONNECTED_NGINX ON)

# Definition for cloning the nginx git repository.
fetchcontent_declare(nginx GIT_REPOSITORY ${nginx_URL} GIT_TAG ${nginx_TAG} GIT_SHALLOW 1)

# Check if this is the first time the repository is being cloned.
if(NOT EXISTS "${FETCHCONTENT_BASE_DIR}/nginx-src/CMakeLists.txt")
  # FetchContent silences the output from git. It can be turned on, but it's too noisy.
  message(CHECK_START "Cloning nginx Git repository")

  # Clone the repository and populate the nginx_* CMake variables, but don't make it available yet.
  fetchcontent_populate(nginx)

  # Done cloning the repository.
  message(CHECK_PASS "done")

  # Patching involves copying the auto files and applying the configure.patch file.
  message(CHECK_START "Patching nginx auto/configure")

  # Patch has been applied if the cmake auto files have been copied over.
  if(NOT EXISTS "${nginx_SOURCE_DIR}/auto/cmake")
    # Copy the generator scripts.
    file(COPY "auto/" DESTINATION "${nginx_SOURCE_DIR}/auto/")

    # Patch auto/configure to include the cmake generator script.
    execute_process(COMMAND_ERROR_IS_FATAL ANY
      COMMAND "${Patch_EXECUTABLE}" "${nginx_SOURCE_DIR}/auto/configure" "${nginx_SOURCE_DIR}/auto/configure.patch"
      OUTPUT_FILE "${nginx_BINARY_DIR}/configure.log"
      WORKING_DIRECTORY "${nginx_SOURCE_DIR}")

    # No fatal errors means the patch was successfully applied.
    message(CHECK_PASS "done")
  else()
    # Patch was applied in a previous run.
    message(CHECK_PASS "patched")
  endif()

  # The configure commands are logged instead of written to STDOUT to keep the CMake log noise down.
  message(CHECK_START "Configuring nginx")

  # Run auto/configure with the user-configurable options.
  execute_process(COMMAND_ERROR_IS_FATAL ANY
    COMMAND "auto/configure" ${nginx_CONFIGURE_OPTS}
    OUTPUT_FILE "${nginx_BINARY_DIR}/configure.log"
    WORKING_DIRECTORY "${nginx_SOURCE_DIR}")

  # Done configuring nginx.
  message(CHECK_PASS "done")

  # nginx has to be manually added the first time since a CMakeLists.txt file didn't exist when it was populated.
  add_subdirectory("${nginx_SOURCE_DIR}" "${nginx_BINARY_DIR}")
endif()

# Ensure nginx is made available to the project.
fetchcontent_makeavailable(nginx)
