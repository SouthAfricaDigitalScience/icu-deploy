#!/bin/bash -e
# this should be run after check-build finishes.
. /etc/profile.d/modules.sh
module add deploy
module add gcc/${GCC_VERSION}
whoami
echo ${SOFT_DIR}
module add deploy
echo ${SOFT_DIR}
cd ${WORKSPACE}/${NAME}/source/build-${BUILD_NUMBER}
echo "All tests have passed, will now build into ${SOFT_DIR}"
make distclean
CFLAGS="-std=c++11"  ../configure \
--with-library-bits=64 \
--enable-shared=yes \
--enable-static=yes \
--with-data-packaging=library \
--enable-rpath \
--prefix=${SOFT_DIR}-gcc-${GCC_VERSION}
make
echo "installing"
make install
echo "Creating the modules file directory ${LIBRARIES}"
mkdir -p ${LIBRARIES}/${NAME}
(
cat <<MODULE_FILE
#%Module1.0
## $NAME modulefile
##
proc ModulesHelp { } {
    puts stderr "       This module does nothing but alert the user"
    puts stderr "       that the [module-info name] module is not available"
}

module-whatis   "$NAME $VERSION : See https://github.com/SouthAfricaDigitalScience/ICU-deploy"
setenv ICU_VERSION       $VERSION
setenv ICU_DIR           $::env(CVMFS_DIR)/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION-gcc-${GCC_VERSION}
prepend-path PATH                            $::env(ICU_DIR)/bin
prepend-path LD_LIBRARY_PATH   $::env(ICU_DIR)/lib
prepend-path GCC_INCLUDE_DIR   $::env(ICU_DIR)/include
prepend-path CFLAGS            "-I$::env(ICU_DIR)/include"
prepend-path LDFLAGS           "-L$::env(ICU_DIR)/lib"
MODULE_FILE
) > ${LIBRARIES}/${NAME}/${VERSION}-gcc-${GCC_VERSION}

echo "testing module"
module avail ${NAME}
module add ${NAME}/${VERSION}-gcc-${GCC_VERSION}
