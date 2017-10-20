
if (EXISTS "${CURRENT_INSTALLED_DIR}/include/mysql/mysql.h")
	message(FATAL_ERROR "FATAL ERROR: libmysql and libmariadb are incompatible.")
endif()

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/mariadb-connector-c-3.0.2)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/MariaDB/mariadb-connector-c/archive/v3.0.2.tar.gz"
    FILENAME "mariadb-connector-c-3.0.2.tar.gz"
    SHA512 a5086ff149b1ca0e1b652013475c5f3793824416a60ec35018b6dcd502bd38b50fa040271ff8d308520dadecc9601671fccf67046fcda2425f1d7c59e1c6c52f
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
	OPTIONS
        -DWITH_UNITTEST=OFF
)

vcpkg_install_cmake()

# remove debug header
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# fix libmariadb lib & dll directory.
if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
	file(RENAME
		${CURRENT_PACKAGES_DIR}/lib/mariadb/mariadbclient.lib
		${CURRENT_PACKAGES_DIR}/lib/mariadbclient.lib)		
	file(RENAME
		${CURRENT_PACKAGES_DIR}/debug/lib/mariadb/mariadbclient.lib
		${CURRENT_PACKAGES_DIR}/debug/lib/mariadbclient.lib)
else()
	file(MAKE_DIRECTORY
		${CURRENT_PACKAGES_DIR}/bin
		${CURRENT_PACKAGES_DIR}/debug/bin)
	file(RENAME
		${CURRENT_PACKAGES_DIR}/lib/mariadb/libmariadb.dll
		${CURRENT_PACKAGES_DIR}/bin/libmariadb.dll)
	file(RENAME
		${CURRENT_PACKAGES_DIR}/debug/lib/mariadb/libmariadb.dll
		${CURRENT_PACKAGES_DIR}/debug/bin/libmariadb.dll)
	file(RENAME
		${CURRENT_PACKAGES_DIR}/lib/mariadb/libmariadb.lib
		${CURRENT_PACKAGES_DIR}/lib/libmariadb.lib)
	file(RENAME
		${CURRENT_PACKAGES_DIR}/debug/lib/mariadb/libmariadb.lib
		${CURRENT_PACKAGES_DIR}/debug/lib/libmariadb.lib)
endif()

# remove plugin folder
file(REMOVE_RECURSE
	${CURRENT_PACKAGES_DIR}/lib/plugin
	${CURRENT_PACKAGES_DIR}/debug/lib/plugin
	${CURRENT_PACKAGES_DIR}/lib/mariadb
	${CURRENT_PACKAGES_DIR}/debug/lib/mariadb)

# copy & remove header files
file(GLOB HEADER_FILES ${CURRENT_PACKAGES_DIR}/include/mariadb/*)
file(REMOVE
	${CURRENT_PACKAGES_DIR}/include/mariadb/my_config.h.in
	${CURRENT_PACKAGES_DIR}/include/mariadb/mysql_version.h.in
	${CURRENT_PACKAGES_DIR}/include/mariadb/CMakeLists.txt
	${CURRENT_PACKAGES_DIR}/include/mariadb/Makefile.am)
file(RENAME
	${CURRENT_PACKAGES_DIR}/include/mariadb
	${CURRENT_PACKAGES_DIR}/include/mysql)

# copy license file
file(COPY ${SOURCE_PATH}/COPYING.LIB DESTINATION ${CURRENT_PACKAGES_DIR}/share/libmariadb)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libmariadb/COPYING.LIB ${CURRENT_PACKAGES_DIR}/share/libmariadb/copyright)
