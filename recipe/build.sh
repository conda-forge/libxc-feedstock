
if [ "$(uname)" == "Darwin" ]; then
    ENABLE_FORTRAN=OFF
fi
if [ "$(uname)" == "Linux" ]; then
    ENABLE_FORTRAN=ON
fi


${BUILD_PREFIX}/bin/cmake \
    -H${SRC_DIR} \
    -Bbuild \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_C_COMPILER=${CC} \
    -DCMAKE_C_FLAGS="${CFLAGS}" \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DNAMESPACE_INSTALL_INCLUDEDIR="/" \
    -DBUILD_SHARED_LIBS=ON \
    -DENABLE_PYTHON=ON \
    -DENABLE_FORTRAN=${ENABLE_FORTRAN} \
    -DENABLE_XHOST=OFF \
    -DBUILD_TESTING=ON \
    -DDISABLE_KXC=OFF

cd build
make -j${CPU_COUNT}

make install

# Relocate python scripts to expected location:
# (Avoiding setup.py which runs cmake again, separately)
mkdir -p ${SP_DIR}
mv ${PREFIX}/lib/pylibxc ${SP_DIR}/

ctest
