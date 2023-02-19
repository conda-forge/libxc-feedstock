
${BUILD_PREFIX}/bin/cmake ${CMAKE_ARGS} \
    -G"Ninja" \
    -S${SRC_DIR}/pylibxc \
    -Bbuild_py \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DPYLIBXC_INSTALL_PYMODDIR="/lib/python${PY_VER}/site-packages"

${BUILD_PREFIX}/bin/cmake --build build_py --target install

