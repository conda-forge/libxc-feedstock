
if [ "$(uname)" == "Darwin" ]; then
    ENABLE_FORTRAN=ON
fi
if [ "$(uname)" == "Linux" ]; then
    ENABLE_FORTRAN=ON
fi


# disable -fno-plt due to https://bugs.llvm.org/show_bug.cgi?id=51863 due to some GCC bug
if [[ "$target_platform" == "linux-ppc64le" ]]; then
  CFLAGS="$(echo $CFLAGS | sed 's/-fno-plt //g')"
  CXXFLAGS="$(echo $CXXFLAGS | sed 's/-fno-plt //g')"
fi

if [ ${target_platform} == "linux-ppc64le" ]; then
  ${BUILD_PREFIX}/bin/cmake ${CMAKE_ARGS} \
    -H${SRC_DIR} \
    -Bbuild \
    -G"Ninja" \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_C_COMPILER=${CC} \
    -DCMAKE_C_FLAGS="${CFLAGS}" \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DNAMESPACE_INSTALL_INCLUDEDIR="/" \
    -DBUILD_SHARED_LIBS=ON \
    -DENABLE_PYTHON=OFF \
    -DENABLE_FORTRAN=${ENABLE_FORTRAN} \
    -DENABLE_XHOST=OFF \
    -DBUILD_TESTING=ON
else
  ${BUILD_PREFIX}/bin/cmake ${CMAKE_ARGS} \
    -H${SRC_DIR} \
    -Bbuild \
    -G"Ninja" \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_C_COMPILER=${CC} \
    -DCMAKE_C_FLAGS="${CFLAGS}" \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DNAMESPACE_INSTALL_INCLUDEDIR="/" \
    -DBUILD_SHARED_LIBS=ON \
    -DENABLE_PYTHON=OFF \
    -DENABLE_FORTRAN=${ENABLE_FORTRAN} \
    -DENABLE_XHOST=OFF \
    -DBUILD_TESTING=ON \
    -DLIBXC_ENABLE_DERIV=4e
fi

cmake --build build --target install -j${CPU_COUNT}

# If building with ENABLE_PYTHON=ON, relocate python scripts to expected location:
# (Avoiding setup.py which runs cmake again, separately)
#mkdir -p ${SP_DIR}
#mv ${PREFIX}/lib/pylibxc ${SP_DIR}/

ctest --repeat until-pass:5
