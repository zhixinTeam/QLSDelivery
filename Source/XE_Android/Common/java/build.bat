@echo off

setlocal

rem if x%ANDROID% == x set ANDROID=C:\Android\android-sdk-windows
rem if x%ANDROID% == x set ANDROID=C:\Users\Public\Documents\Studio\15.0\PlatformSDKs\adt-bundle-windows-x86-20130522\sdk
rem if x%ANDROID% == x set ANDROID=C:\PlatformSDKs\adt-bundle-windows-x86-20131030\sdk
if x%ANDROID% == x set ANDROID=C:\Android\adt-bundle-windows-x86-20131030\sdk
set ANDROID_PLATFORM=%ANDROID%\platforms\android-19

set EMBO_LIB="C:\Program Files (x86)\Embarcadero\Studio\15.0\lib\android\debug"
set PROJ_DIR="%CD%"
set VERBOSE=0

echo.
echo Compiling the Java activity source file
echo.
mkdir output 2> nul
mkdir output\classes 2> nul
if x%VERBOSE% == x1 SET VERBOSE_FLAG=-verbose
javac %VERBOSE_FLAG% -source 1.6 -target 1.6 -Xlint:deprecation -cp %ANDROID_PLATFORM%\android.jar;%EMBO_LIB%\fmx.jar -d output\classes src\com\blong\nfc\NativeActivitySubclass.java

echo.
echo Creating jar containing the new classes
echo.
mkdir output\jar 2> nul
if x%VERBOSE% == x1 SET VERBOSE_FLAG=v
jar c%VERBOSE_FLAG%f output\jar\NativeActivitySubclass.jar -C output\classes com

echo Tidying up
echo.
del output\classes\com\blong\nfc\NativeActivitySubclass*.class
rmdir output\classes\com\blong\nfc
rmdir output\classes\com\blong
rmdir output\classes\com
rmdir output\classes

echo.
echo Now we have the end result, which is output\jar\NativeActivitySubclass.jar

:Exit

endlocal
