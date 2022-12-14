#!/usr/bin/env sh

# Extracts a semantic version number from the given string.
semver() { echo "$1" | sed -nre 's/^[^0-9]*(([0-9]+\.)*[0-9]+).*/\1/p'; }

# Strip all excess whitespace, leading, trailing, and between characters.
strip() { echo "$1" | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//' | sed 's/  */ /g'; }

# All directories with public headers.
nginx_include_dirs="$CORE_INCS $NGX_OBJS $HTTP_INCS $MAIL_INCS"

# Required libraries.
nginx_libs="$(echo "$CORE_LIBS" | sed 's/-l//g')"

# All the source files.
nginx_sources="objs/ngx_modules.c $CORE_SRCS $HTTP_SRCS $MAIL_SRCS $NGX_MISC_SRCS $NGX_ADDON_SRCS $NGX_SHARED_SRCS"

# Extract the nginx version from the sources.
nginx_version="$(semver "$(grep "#define NGINX_VERSION" src/core/nginx.h)")"

# Generate the CMakeLists.txt file from the *.in template.
cmake -DNGINX_INCLUDE_DIRS="$(strip "$nginx_include_dirs")" \
      -DNGINX_LIBS="$(strip "$nginx_libs")" \
      -DNGINX_SOURCES="$(strip "$nginx_sources")" \
      -DNGINX_VERSION="$(strip "$nginx_version")" \
      -P "auto/cmake/CMakeLists.cmake"
