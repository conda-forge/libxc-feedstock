set SITEP="Lib\site-packages"
IF "%PY_VER%"=="3.15" (
  set SITEP="lib\python\site-packages"
)

cmake %CMAKE_ARGS% ^
      -G"Ninja" ^
      -S"%SRC_DIR%\pylibxc" ^
      -Bbuild_py ^
      -DCMAKE_BUILD_TYPE=Release ^
      -DCMAKE_INSTALL_PREFIX="%PREFIX%" ^
      -DPYLIBXC_INSTALL_PYMODDIR="%SITEP%"
if errorlevel 1 exit 1

cmake --build build_py ^
      --config Release ^
      -v ^
      --target install
if errorlevel 1 exit 1

