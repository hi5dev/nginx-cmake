# Break and indent the space-separated file/directory listings.
string(REPLACE " " "\n  " NGINX_SOURCES ${NGINX_SOURCES})
string(REPLACE " " "\n  " NGINX_INCLUDE_DIRS ${NGINX_INCLUDE_DIRS})

# Generate the CMakeLists.txt from the .in template.
configure_file(auto/cmake/CMakeLists.txt.in CMakeLists.txt @ONLY)
