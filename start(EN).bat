@echo off

set adb-tools=.\source\platform-tools
set boot_origin=.\boot_origin
set boot_Magiskpatched=.\boot_Magiskpatched

:start
CLS
title Automatic Magisk Delta Flashing ---by badnng
echo.
echo. Automatic Magisk Delta Flashing
echo. by badnng
echo.Press A to start the fully automated flashing of boot for older models~
echo.Press B to start the fully automated flashing of init_boot for newer models~


%检查文件是否完整%
if exist .\Magisk.zip (
    choice /C AB /N /M "Please select A or B:"
    if errorlevel 2 goto flash_b
    goto flash_a
) else (
    goto error-noMagisk.zip
)


:error-noMagisk.zip
CLS
echo.
echo.  Magisk.zip does not exist. Please check if Magisk file is placed.
pause>null
del null
exit

:flash_a
CLS
choice /C AB /N /M "Please select the Magisk branch to flash into: Magisk_Delta(A) or Magisk_topjohnwu(B)"
if errorlevel 2 (
    rem 选择 B，执行 flash_a_top
    goto flash_a_top
) else (
    rem 选择 A，执行 flash_a
	ren ".\Magisk.zip" "Magisk.apk"
	adb install .\Magisk.apk
	ren ".\Magisk.apk" "Magisk.zip"

    bin\busybox unzip Magisk.zip -d tmp -n |bin\busybox grep -E "arm|util_functions" |bin\busybox sed "s/ //g"
echo.
if not exist tmp/META-INF (echo.File error! &rd /s /q tmp 1>nul 2>nul&pause&exit)

if exist tmp\assets\util_functions.sh bin\busybox bash -c "echo Magisk version will be updated to: $(cat tmp/assets/util_functions.sh |grep MAGISK_VER_CODE |cut -d = -f 2)"
if exist tmp\lib\arm64-v8a (
	del bin\magisk64 1>nul 2>nul
	del bin\magiskinit 1>nul 2>nul
	copy tmp\lib\arm64-v8a\libmagisk64.so bin\magisk64 1>nul 2>nul
	copy tmp\lib\arm64-v8a\libmagiskinit.so bin\magiskinit 1>nul 2>nul
)
if exist tmp\lib\armeabi-v7a (
	del bin\magisk32 1>nul 2>nul
	copy tmp\lib\armeabi-v7a\libmagisk32.so bin\magisk32 1>nul 2>nul
	if exist tmp\lib\armeabi-v7a\libmagisk64.so (
		copy tmp\lib\armeabi-v7a\libmagisk64.so bin\magisk64 1>nul 2>nul
	)
	if not exist tmp\lib\arm64-v8a\libmagiskinit.so (
		copy tmp\lib\armeabi-v7a\libmagiskinit.so bin\magiskinit 1>nul 2>nul
	)
)
echo.Update completed!
rd /s /q tmp

.\source\payload\payload-dumper-go.exe -p boot -o %boot_origin% .\payload.bin
if not exist %boot_origin%\boot.img (echo.Current directory does not have boot.img file!& pause & exit /b)
if exist %boot_Magiskpatched%\boot_Magiskpatched.img (del /s /q %boot_Magiskpatched%\boot_Magiskpatched.img 1>nul 2>nul)
echo.
bin\busybox bash bin/boot_patch.sh %boot_origin%\boot.img
echo.
if exist new-boot.img (move new-boot.img %boot_Magiskpatched%\boot_Magiskpatched.img 1>nul 2>nul&echo.Successfully patched boot.img) else (echo.Unable to patch boot.img)

%adb-tools%\adb devices | findstr /r /c:"^[ \t]*[0-9a-zA-Z]+[ \t]*device$"

echo Device connected, proceeding with further operations...

%adb-tools%\adb reboot bootloader

echo Waiting for 10 seconds... for the device to enter fastboot
timeout /t 10 >nul

%adb-tools%\fastboot devices

if errorlevel 1 (
    echo Device not detected in Fastboot!
    pause
    exit /b
)

echo Device connected, proceeding with further operations...
%adb-tools%\fastboot flash boot %boot_Magiskpatched%\boot_Magiskpatched.img

echo Device will restart and enter the system. Enjoy!
%adb-tools%\fastboot reboot
goto end
)



:flash_b
CLS
choice /C AB /N /M "Please select the Magisk branch to flash into: Magisk_Delta(A) or Magisk_topjohnwu(B)"
if errorlevel 2 (
    rem 选择 B，执行 flash_b_top
    goto flash_b_top
) else (
    rem 选择 A，执行 flash_b
	ren ".\Magisk.zip" "Magisk.apk"
	adb install .\Magisk.apk
	ren ".\Magisk.apk" "Magisk.zip"

    bin\busybox unzip Magisk.zip -d tmp -n |bin\busybox grep -E "arm|util_functions" |bin\busybox sed "s/ //g"
echo.
if not exist tmp/META-INF (echo.File error! &rd /s /q tmp 1>nul 2>nul&pause&exit)

if exist tmp\assets\util_functions.sh bin\busybox bash -c "echo Magisk version will be updated to: $(cat tmp/assets/util_functions.sh |grep MAGISK_VER_CODE |cut -d = -f 2)"
if exist tmp\lib\arm64-v8a (
	del bin\magisk64 1>nul 2>nul
	del bin\magiskinit 1>nul 2>nul
	copy tmp\lib\arm64-v8a\libmagisk64.so bin\magisk64 1>nul 2>nul
	copy tmp\lib\arm64-v8a\libmagiskinit.so bin\magiskinit 1>nul 2>nul
)
if exist tmp\lib\armeabi-v7a (
	del bin\magisk32 1>nul 2>nul
	copy tmp\lib\armeabi-v7a\libmagisk32.so bin\magisk32 1>nul 2>nul
	if exist tmp\lib\armeabi-v7a\libmagisk64.so (
		copy tmp\lib\armeabi-v7a\libmagisk64.so bin\magisk64 1>nul 2>nul
	)
	if not exist tmp\lib\arm64-v8a\libmagiskinit.so (
		copy tmp\lib\armeabi-v7a\libmagiskinit.so bin\magiskinit 1>nul 2>nul
	)
)
echo.Update completed!
rd /s /q tmp

.\source\payload\payload-dumper-go.exe -p init_boot -o %boot_origin% .\payload.bin
if not exist %boot_origin%\init_boot.img (echo.Current directory does not have init_boot.img file!& pause & exit /b)
if exist %boot_Magiskpatched%\boot_Magiskpatched.img (del /s /q %boot_Magiskpatched%\boot_Magiskpatched.img 1>nul 2>nul)
echo.
bin\busybox bash bin/boot_patch.sh %boot_origin%\init_boot.img
echo.
if exist new-boot.img (move new-boot.img %boot_Magiskpatched%\boot_Magiskpatched.img 1>nul 2>nul&echo.Successfully patched boot.img) else (echo.Unable to patch boot.img)

%adb-tools%\adb devices | findstr /r /c:"^[ \t]*[0-9a-zA-Z]+[ \t]*device$"

echo Device connected, proceeding with further operations...

%adb-tools%\adb reboot fastboot

echo Waiting for 10 seconds... for the device to enter fastboot
timeout /t 10 >nul

%adb-tools%\fastboot bootloader

if errorlevel 1 (
    echo Device not detected in Fastboot!
    pause
    exit /b
)

echo Device connected, proceeding with further operations...
%adb-tools%\fastboot flash init_boot %boot_Magiskpatched%\boot_Magiskpatched.img

echo Device will restart and enter the system. Enjoy!
timeout /t 3 >nul
%adb-tools%\fastboot reboot
goto end
)



:flash_a_top
CLS
ren ".\Magisk-v26.1.zip" "Magisk-v26.1.apk"
adb install .\Magisk-v26.1.apk
ren ".\Magisk-v26.1.apk" "Magisk-v26.1.zip"

bin\busybox unzip Magisk-v26.1.zip -d tmp -n |bin\busybox grep -E "arm|util_functions" |bin\busybox sed "s/ //g"
echo.
if not exist tmp/META-INF (echo.File error!&rd /s /q tmp 1>nul 2>nul&pause&exit)

if exist tmp\assets\util_functions.sh bin\busybox bash -c "echo Magisk version will be updated to: $(cat tmp/assets/util_functions.sh |grep MAGISK_VER_CODE |cut -d = -f 2)"
if exist tmp\lib\arm64-v8a (
	del bin\magisk64 1>nul 2>nul
	del bin\magiskinit 1>nul 2>nul
	copy tmp\lib\arm64-v8a\libmagisk64.so bin\magisk64 1>nul 2>nul
	copy tmp\lib\arm64-v8a\libmagiskinit.so bin\magiskinit 1>nul 2>nul
)
if exist tmp\lib\armeabi-v7a (
	del bin\magisk32 1>nul 2>nul
	copy tmp\lib\armeabi-v7a\libmagisk32.so bin\magisk32 1>nul 2>nul
	if exist tmp\lib\armeabi-v7a\libmagisk64.so (
		copy tmp\lib\armeabi-v7a\libmagisk64.so bin\magisk64 1>nul 2>nul
	)
	if not exist tmp\lib\arm64-v8a\libmagiskinit.so (
		copy tmp\lib\armeabi-v7a\libmagiskinit.so bin\magiskinit 1>nul 2>nul
	)
)
echo.Update completed!
rd /s /q tmp

.\source\payload\payload-dumper-go.exe -p boot -o %boot_origin% .\payload.bin
if not exist %boot_origin%\boot.img (echo.Current directory does not have boot.img file!& pause & exit /b)
if exist %boot_Magiskpatched%\boot_Magiskpatched.img (del /s /q %boot_Magiskpatched%\boot_Magiskpatched.img 1>nul 2>nul)
echo.
bin\busybox bash bin/boot_patch.sh %boot_origin%\boot.img
echo.
if exist new-boot.img (move new-boot.img %boot_Magiskpatched%\boot_Magiskpatched.img 1>nul 2>nul&echo.Successfully patched boot.img) else (echo.Unable to patch boot.img)

%adb-tools%\adb devices | findstr /r /c:"^[ \t]*[0-9a-zA-Z]+[ \t]*device$"

echo Device connected, proceeding with further operations...

%adb-tools%\adb reboot bootloader

echo Waiting for 10 seconds... for the device to enter fastboot
timeout /t 10 >nul

%adb-tools%\fastboot devices

if errorlevel 1 (
    echo Device not detected in Fastboot!
    pause
    exit /b
)

echo Device connected, proceeding with further operations...
%adb-tools%\fastboot flash boot %boot_Magiskpatched%\boot_Magiskpatched.img

echo Device will restart and enter the system. Enjoy!
%adb-tools%\fastboot reboot
goto end


:flash_b_top
CLS
ren ".\Magisk-v26.1.zip" "Magisk-v26.1.apk"
adb install .\Magisk-v26.1.apk
ren ".\Magisk-v26.1.apk" "Magisk-v26.1.zip"

bin\busybox unzip Magisk-V26.1.zip -d tmp -n |bin\busybox grep -E "arm|util_functions" |bin\busybox sed "s/ //g"
echo.
if not exist tmp/META-INF (echo.flies is error！&rd /s /q tmp 1>nul 2>nul&pause&exit)

if exist tmp\assets\util_functions.sh bin\busybox bash -c "echo The magisk version will be updated to： $(cat tmp/assets/util_functions.sh |grep MAGISK_VER_CODE |cut -d = -f 2)"
if exist tmp\lib\arm64-v8a (
	del bin\magisk64 1>nul 2>nul
	del bin\magiskinit 1>nul 2>nul
	copy tmp\lib\arm64-v8a\libmagisk64.so bin\magisk64 1>nul 2>nul
	copy tmp\lib\arm64-v8a\libmagiskinit.so bin\magiskinit 1>nul 2>nul
)
if exist tmp\lib\armeabi-v7a (
	del bin\magisk32 1>nul 2>nul
	copy tmp\lib\armeabi-v7a\libmagisk32.so bin\magisk32 1>nul 2>nul
	if exist tmp\lib\armeabi-v7a\libmagisk64.so (
		copy tmp\lib\armeabi-v7a\libmagisk64.so bin\magisk64 1>nul 2>nul
	)
	if not exist tmp\lib\arm64-v8a\libmagiskinit.so (
		copy tmp\lib\armeabi-v7a\libmagiskinit.so bin\magiskinit 1>nul 2>nul
	)
)
echo.update completed!
rd /s /q tmp

.\source\payload\payload-dumper-go.exe -p init_boot -o %boot_origin% .\payload.bin
if not exist %boot_origin%\init_boot.img (echo.There is no init_boot.img file in the current directory！& pause & exit /b)
if exist %boot_Magiskpatched%\boot_Magiskpatched.img (del /s /q %boot_Magiskpatched%\boot_Magiskpatched.img 1>nul 2>nul)
echo.
bin\busybox bash bin/boot_patch.sh %boot_origin%\init_boot.img
echo.
if exist new-boot.img (move new-boot.img %boot_Magiskpatched%\boot_Magiskpatched.img 1>nul 2>nul&echo.Successfully patched boot.img) else (echo.cannot be patched boot.img)

%adb-tools%\adb devices | findstr /r /c:"^[ \t]*[0-9a-zA-Z]+[ \t]*device$"

echo The device is connected, continue to do other operations...

%adb-tools%\adb reboot fastboot

echo Waiting 10 seconds... for device to enter fastboot
timeout /t 10 >nul

%adb-tools%\fastboot bootloader

if errorlevel 1 (
    echo Fastboot not detecting the device!
    pause
    exit /b
)

echo The device is connected, continue to do other operations...
%adb-tools%\fastboot flash init_boot %boot_Magiskpatched%\boot_Magiskpatched.img

echo The device will restart into the system after 3 seconds, I wish you a happy use~
timeout /t 3 >nul
%adb-tools%\fastboot reboot
goto end


:end
echo.    Do you want to delete the payload.bin file? (Y to delete/N not to delete)
choice /c YN

if errorlevel 2 (
    echo Delete the flies for No
	del /s /q %boot_Magiskpatched%\boot_Magiskpatched.img
	del /s /q %boot_origin%\boot.img
	del /s /q %boot_origin%\init_boot.img
) else (
    echo Delete the flies for Yes
    del /s /q .\payload.bin
	del /s /q %boot_Magiskpatched%\boot_Magiskpatched.img
	del /s /q %boot_origin%\boot.img
	del /s /q %boot_origin%\init_boot.img
)
endlocal

echo.Execution complete. Have a great day!
echo.If you have the ability, please consider following me on Bilibili.(Bilibili space will open before the window was closed!) And if have something questions welecome email to wsj316@outlook.com!
echo.This window will close in 6 seconds~
timeout /t 6 >nul
explorer "https://space.bilibili.com/355631279?spm_id_from=333.1007.0.0"