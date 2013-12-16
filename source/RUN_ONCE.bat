::@ECHO OFF
echo off

REM - Set root directory

IF "%VISION_SDK%"=="" ( 
ECHO ERROR!!! %%VISION_SDK%% environment variable is NOT defined. This environment variable must point to the root of your install directory of the 
SDK
pause
exit
)

set CURR_DIR=%~dp0
set ROOT_DIR=%~dp0
echo Files will be copied from:
echo %VISION_SDK%
echo to:
echo %CURR_DIR%

REM - Start copy (Base data)

set SRC_DIR=%VISION_SDK%\Data\Vision\Base
md Data\Vision\Base
xcopy "%SRC_DIR%" /S "%ROOT_DIR%\Data\Vision\Base" /Y

REM - Start copy (Icons for various platforms)

set SRC_DIR=%VISION_SDK%\Data\Common
md Data\Common
IF EXIST "%SRC_DIR%" xcopy "%SRC_DIR%" /S "%ROOT_DIR%\Data\Common" /Y 