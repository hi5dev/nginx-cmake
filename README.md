# nginx for CMake

Easily add [nginx](https://nginx.org/) to a CMake project.

## Synopsis

```cmake
include(FetchContent)

# Declare this repository as a dependency.
FetchContent_Declare(nginx
  GIT_REPOSITORY https://github.com/hi5dev/nginx-cmake
  GIT_TAG main)

# Append your auto/configure options to nginx_CONFIGURE_OPTS.
# For example, if you're building an nginx module, you might want to add something like this:
list(APPEND nginx_CONFIGURE_OPTS "--add-module=${CMAKE_CURRENT_SOURCE_DIR}/src")

# Optionally override the URL to the Git repository. This is the default:
set(nginx_URL https://github.com/nginx/nginx.git)

# Use the repository's git tags to specify which version of nginx to use. This is the current default:
set(nginx_TAG release-1.23.2)

# Install rules are enabled by default.
set(nginx_INSTALL ON)

# By default all these components are installed. Setting nginx_INSTALL to OFF disables all of these as well.
set(nginx_INSTALL_CONFIG_FILES ON)
set(nginx_INSTALL_EXE ON)
set(nginx_INSTALL_MANPAGE ON)

# Clones this repository and nginx, then patches it for CMake, runs auto/configure, and adds it to your project.
FetchContent_MakeAvailable(nginx)
```

## How it Works

This project includes nginx as a dependency using [FetchContent]. After cloning the repository, it adds a script to
the [auto] directory that generates a `CMakeLists.txt` file at the same time the `Makefile` is generated. The file is
generated by CMake using `configure_file`. The template can be found in this repository at
[auto/cmake/CMakeLists.txt.in].

<!-- External Links -->
[FetchContent]: https://cmake.org/cmake/help/latest/module/FetchContent.html
[auto]: https://github.com/nginx/nginx/tree/master/auto
[auto/configure]: https://github.com/nginx/nginx/blob/master/auto/configure

<!-- Project Links -->
[auto/cmake/CMakeLists.txt.in]: https://github.com/hi5dev/nginx-cmake/blob/main/auto/cmake/CMakeLists.txt.in