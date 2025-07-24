#!/usr/bin/env bash

set -ex

if [[ ! -z "${cuda_compiler_version+x}" && "${cuda_compiler_version}" != "None" ]]; then
    NVCC="$(command -v nvcc)"
    NVCFLAGS=""
    for arch in 60 70 80; do
        NVCFLAGS+=" --generate-code=arch=compute_${arch},code=[compute_${arch},sm_${arch}]"
    done
    NVCFLAGS+=" -O3 -std=c++17 --compiler-options ${CXXFLAGS// /,}"
    ENABLE_CUDA=ON
    DERIV=2
elif [[ "$target_platform" == "linux-aarch64" ]]; then
    ENABLE_CUDA=OFF
    DERIV=3
else
    ENABLE_CUDA=OFF
    DERIV=4e
fi

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
    -DCMAKE_CUDA_COMPILER="${NVCC}" \
    -DCMAKE_CUDA_FLAGS="${NVCFLAGS}" \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DNAMESPACE_INSTALL_INCLUDEDIR="/" \
    -DBUILD_SHARED_LIBS=ON \
    -DENABLE_PYTHON=OFF \
    -DENABLE_FORTRAN=${ENABLE_FORTRAN} \
    -DENABLE_CUDA=${ENABLE_CUDA} \
    -DENABLE_XHOST=OFF \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.10 \
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
    -DCMAKE_CUDA_COMPILER="${NVCC}" \
    -DCMAKE_CUDA_FLAGS="${NVCFLAGS}" \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DNAMESPACE_INSTALL_INCLUDEDIR="/" \
    -DBUILD_SHARED_LIBS=ON \
    -DENABLE_PYTHON=OFF \
    -DENABLE_FORTRAN=${ENABLE_FORTRAN} \
    -DENABLE_CUDA=${ENABLE_CUDA} \
    -DENABLE_XHOST=OFF \
    -DBUILD_TESTING=ON \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.10 \
    -DLIBXC_ENABLE_DERIV=${DERIV}
fi

cmake --build build --target install -j${CPU_COUNT}

# If building with ENABLE_PYTHON=ON, relocate python scripts to expected location:
# (Avoiding setup.py which runs cmake again, separately)
#mkdir -p ${SP_DIR}
#mv ${PREFIX}/lib/pylibxc ${SP_DIR}/

if [[ -z "${cuda_compiler_version+x}" || "${cuda_compiler_version}" == "None" ]]; then
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "" ]]; then
    ctest --repeat until-pass:5
fi
fi
