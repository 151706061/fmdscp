SET TYPE=Release
SET TYPE=Debug

REM a top level directory for all PACS related code
SET DEVSPACE="%CD%"

cd %DEVSPACE%\boost
call bootstrap
IF "%TYPE%" == "Release" b2 toolset=msvc-11.0 runtime-link=static define=_BIND_TO_CURRENT_VCLIBS_VERSION=1 -j 4 stage release
IF "%TYPE%" == "Debug"   b2 toolset=msvc-11.0 runtime-link=static define=_BIND_TO_CURRENT_VCLIBS_VERSION=1 -j 4 stage debug
cd ..

cd %DEVSPACE%\zlib
mkdir build-%TYPE%
cd build-%TYPE%
cmake.exe .. -G "Visual Studio 11" -DCMAKE_C_FLAGS_RELEASE="/MT /O2 /D NDEBUG" -DCMAKE_C_FLAGS_DEBUG="/D_DEBUG /MTd /Od" -DCMAKE_INSTALL_PREFIX=%DEVSPACE%\zlib\%TYPE%
msbuild /P:Configuration=%TYPE% INSTALL.vcxproj
cd ..\..
IF "%TYPE%" == "Release" copy /Y %DEVSPACE%\zlib\Release\lib\zlibstatic.lib %DEVSPACE%\zlib\Release\lib\zlib_o.lib
IF "%TYPE%" == "Debug"   copy /Y %DEVSPACE%\zlib\Debug\lib\zlibstaticd.lib %DEVSPACE%\zlib\Debug\lib\zlib_d.lib

cd %DEVSPACE%\dcmtk
mkdir build-%TYPE%
cd build-%TYPE%
cmake .. -G "Visual Studio 11" -DDCMTK_WIDE_CHAR_FILE_IO_FUNCTIONS=1 -DDCMTK_WITH_ZLIB=1 -DWITH_ZLIBINC=%DEVSPACE%\zlib\%TYPE% -DCMAKE_INSTALL_PREFIX=%DEVSPACE%\dcmtk\%TYPE%
msbuild /P:Configuration=%TYPE% INSTALL.vcxproj
cd ..\..

cd %DEVSPACE%\openjpeg
mkdir build-%TYPE%
cd build-%TYPE%
cmake .. -G "Visual Studio 11" -DBUILD_THIRDPARTY=1 -DBUILD_SHARED_LIBS=0 -DCMAKE_C_FLAGS_RELEASE="/MT /O2 /D NDEBUG" -DCMAKE_C_FLAGS_DEBUG="/D_DEBUG /MTd /Od" -DCMAKE_INSTALL_PREFIX=%DEVSPACE%\openjpeg\%TYPE%
msbuild /P:Configuration=%TYPE% INSTALL.vcxproj

cd %DEVSPACE%\fmjpeg2koj
mkdir build-%TYPE%
cd build-%TYPE%
cmake .. -G "Visual Studio 11" -DOPENJPEG=%DEVSPACE%\openjpeg\%TYPE% -DDCMTK_DIR=%DEVSPACE%\dcmtk\build-%TYPE% -DCMAKE_INSTALL_PREFIX=%DEVSPACE%\fmjpeg2koj\%TYPE%
msbuild /P:Configuration=%TYPE% INSTALL.vcxproj
cd ..\..

cd %DEVSPACE%\poco
mkdir build-%TYPE%
cd build-%TYPE%
cmake .. -G "Visual Studio 11" -DPOCO_STATIC=ON -DCMAKE_CXX_FLAGS_RELEASE="/MT /O2 /D NDEBUG" -DCMAKE_CXX_FLAGS_DEBUG="/D_DEBUG /MTd /Od" -DCMAKE_INSTALL_PREFIX=%DEVSPACE%\poco\%TYPE%
msbuild /P:Configuration=%TYPE% INSTALL.vcxproj
cd ..\..

cd %DEVSPACE%
mkdir build-%TYPE%
cd build-%TYPE%
cmake .. -G "Visual Studio 11" -DBOOST_ROOT=%DEVSPACE%\boost -DDCMTK_DIR=%DEVSPACE%\dcmtk\build-%TYPE% -DZLIB_ROOT=%DEVSPACE%\zlib\%TYPE% -DFMJPEG2K=%DEVSPACE%\fmjpeg2koj\%TYPE% -DOPENJPEG=%DEVSPACE%\openjpeg\%TYPE% -DPOCO=%DEVSPACE%\poco\%TYPE%
msbuild /P:Configuration=%TYPE% ALL_BUILD.vcxproj
cd ..

cd %DEVSPACE%