
cmake ${CMAKE_ARGS} ^
      -G"Ninja" ^
      -S"%SRC_DIR%\pylibxc" ^
      -Bbuild_py ^
      -DCMAKE_BUILD_TYPE=Release ^
      -DCMAKE_INSTALL_PREFIX="%PREFIX%" ^
      -DPYLIBXC_INSTALL_PYMODDIR="\Lib\site-packages"
if errorlevel 1 exit 1

cmake --build build_py ^
      --config Release ^
      --target install
if errorlevel 1 exit 1

