
${BUILD_PREFIX}/bin/cmake ${CMAKE_ARGS} \
    -G"Ninja" \
    -S${SRC_DIR}/pylibxc \
    -Bbuild_py \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_BUILD_TYPE=Release

${BUILD_PREFIX}/bin/cmake --build build_py --target install

