@echo off

set adb-tools=.\source\platform-tools
set boot_origin=.\boot_origin
set boot_Magiskpatched=.\boot_Magiskpatched

:start
CLS
title 全自动刷入magisk delta ---by badnng
echo.
echo.          全自动刷入magisk delta
echo.                               by badnng
echo.按A键开始进行老机型的boot的全自动刷入~
echo.按B键开始进行新机型init_boot的全自动刷入~


%检查文件是否完整%
if exist .\Magisk.zip (
    choice /C AB /N /M "请选择 A 或 B："
    if errorlevel 2 goto flash_b
    goto flash_a
) else (
    goto error-noMagisk.zip
)


:error-noMagisk.zip
CLS
echo.
echo.  Magisk.zip不存在，请检查是否放入Magisk文件
pause>null
del null
exit

:flash_a
CLS
choice /C AB /N /M "请选择要刷入的Magisk分支：Magisk_Delta(A) 或 Magisk_topjohnwu(B)"
if errorlevel 2 (
    rem 选择 B，执行 flash_b
    goto flash_a_top
) else (
    rem 选择 A，执行 flash_a
    bin\busybox unzip Magisk.zip -d tmp -n |bin\busybox grep -E "arm|util_functions" |bin\busybox sed "s/ //g"
echo.
if not exist tmp/META-INF (echo.文件错误！&rd /s /q tmp 1>nul 2>nul&pause&exit)

if exist tmp\assets\util_functions.sh bin\busybox bash -c "echo 面具版本将更新为： $(cat tmp/assets/util_functions.sh |grep MAGISK_VER_CODE |cut -d = -f 2)"
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
echo.更新完成！
rd /s /q tmp

.\source\payload\payload-dumper-go.exe -p boot -o %boot_origin% .\payload.bin
if not exist %boot_origin%\boot.img (echo.当前目录没有 boot.img 文件！& pause & exit /b)
if exist %boot_Magiskpatched%\boot_Magiskpatched.img (del /s /q %boot_Magiskpatched%\boot_Magiskpatched.img 1>nul 2>nul)
echo.
bin\busybox bash bin/boot_patch.sh %boot_origin%\boot.img
echo.
if exist new-boot.img (move new-boot.img %boot_Magiskpatched%\boot_Magiskpatched.img 1>nul 2>nul&echo.成功修补 boot.img) else (echo.无法修补 boot.img)

%adb-tools%\adb devices | findstr /r /c:"^[ \t]*[0-9a-zA-Z]+[ \t]*device$"

echo 设备已连接，继续执行其他操作...

%adb-tools%\adb reboot bootloader

echo 正在等待 10 秒...以便设备能进入fastboot
timeout /t 10 >nul

echo 设备已连接，继续执行其他操作...
%adb-tools%\fastboot flash boot %boot_Magiskpatched%\boot_Magiskpatched.img

echo 设备将重启进入系统，祝您使用愉快~
%adb-tools%\fastboot reboot
goto end
)



:flash_b
CLS
choice /C AB /N /M "请选择要刷入的Magisk分支：Magisk_Delta(A) 或 Magisk_topjohnwu(B)"
if errorlevel 2 (
    rem 选择 B，执行 flash_b_top
    goto flash_b_top
) else (
    rem 选择 A，执行 flash_b
    bin\busybox unzip Magisk.zip -d tmp -n |bin\busybox grep -E "arm|util_functions" |bin\busybox sed "s/ //g"
echo.
if not exist tmp/META-INF (echo.文件错误！&rd /s /q tmp 1>nul 2>nul&pause&exit)

if exist tmp\assets\util_functions.sh bin\busybox bash -c "echo 面具版本将更新为： $(cat tmp/assets/util_functions.sh |grep MAGISK_VER_CODE |cut -d = -f 2)"
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
echo.更新完成!
rd /s /q tmp

.\source\payload\payload-dumper-go.exe -p init_boot -o %boot_origin% .\payload.bin
if not exist %boot_origin%\init_boot.img (echo.当前目录没有 init_boot.img 文件！& pause & exit /b)
if exist %boot_Magiskpatched%\boot_Magiskpatched.img (del /s /q %boot_Magiskpatched%\boot_Magiskpatched.img 1>nul 2>nul)
echo.
bin\busybox bash bin/boot_patch.sh %boot_origin%\init_boot.img
echo.
if exist new-boot.img (move new-boot.img %boot_Magiskpatched%\boot_Magiskpatched.img 1>nul 2>nul&echo.成功修补 boot.img) else (echo.无法修补 boot.img)

%adb-tools%\adb devices | findstr /r /c:"^[ \t]*[0-9a-zA-Z]+[ \t]*device$"

echo 设备已连接，继续执行其他操作...

%adb-tools%\adb reboot bootloader

echo 正在等待 10 秒...以便设备能进入fastboot
timeout /t 10 >nul

echo 设备已连接，继续执行其他操作...
%adb-tools%\fastboot flash init_boot %boot_Magiskpatched%\boot_Magiskpatched.img

echo 设备将在3秒后重启进入系统，祝您使用愉快~
timeout /t 3 >nul
%adb-tools%\fastboot reboot
goto end
)



:flash_a_top
CLS
bin\busybox unzip Magisk-v26.1.zip -d tmp -n |bin\busybox grep -E "arm|util_functions" |bin\busybox sed "s/ //g"
echo.
if not exist tmp/META-INF (echo.文件错误！&rd /s /q tmp 1>nul 2>nul&pause&exit)

if exist tmp\assets\util_functions.sh bin\busybox bash -c "echo 面具版本将更新为： $(cat tmp/assets/util_functions.sh |grep MAGISK_VER_CODE |cut -d = -f 2)"
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
echo.更新完成！
rd /s /q tmp

.\source\payload\payload-dumper-go.exe -p boot -o %boot_origin% .\payload.bin
if not exist %boot_origin%\boot.img (echo.当前目录没有 boot.img 文件！& pause & exit /b)
if exist %boot_Magiskpatched%\boot_Magiskpatched.img (del /s /q %boot_Magiskpatched%\boot_Magiskpatched.img 1>nul 2>nul)
echo.
bin\busybox bash bin/boot_patch.sh %boot_origin%\boot.img
echo.
if exist new-boot.img (move new-boot.img %boot_Magiskpatched%\boot_Magiskpatched.img 1>nul 2>nul&echo.成功修补 boot.img) else (echo.无法修补 boot.img)

%adb-tools%\adb devices | findstr /r /c:"^[ \t]*[0-9a-zA-Z]+[ \t]*device$"

echo 设备已连接，继续执行其他操作...

%adb-tools%\adb reboot bootloader

echo 正在等待 10 秒...以便设备能进入fastboot
timeout /t 10 >nul

echo 设备已连接，继续执行其他操作...
%adb-tools%\fastboot flash boot %boot_Magiskpatched%\boot_Magiskpatched.img

echo 设备将重启进入系统，祝您使用愉快~
%adb-tools%\fastboot reboot
goto end


:flash_b_top
CLS
bin\busybox unzip Magisk-V26.1.zip -d tmp -n |bin\busybox grep -E "arm|util_functions" |bin\busybox sed "s/ //g"
echo.
if not exist tmp/META-INF (echo.文件错误！&rd /s /q tmp 1>nul 2>nul&pause&exit)

if exist tmp\assets\util_functions.sh bin\busybox bash -c "echo 面具版本将更新为： $(cat tmp/assets/util_functions.sh |grep MAGISK_VER_CODE |cut -d = -f 2)"
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
echo.更新完成！
rd /s /q tmp

.\source\payload\payload-dumper-go.exe -p init_boot -o %boot_origin% .\payload.bin
if not exist %boot_origin%\init_boot.img (echo.当前目录没有 init_boot.img 文件！& pause & exit /b)
if exist %boot_Magiskpatched%\boot_Magiskpatched.img (del /s /q %boot_Magiskpatched%\boot_Magiskpatched.img 1>nul 2>nul)
echo.
bin\busybox bash bin/boot_patch.sh %boot_origin%\init_boot.img
echo.
if exist new-boot.img (move new-boot.img %boot_Magiskpatched%\boot_Magiskpatched.img 1>nul 2>nul&echo.成功修补 boot.img) else (echo.无法修补 boot.img)

%adb-tools%\adb devices | findstr /r /c:"^[ \t]*[0-9a-zA-Z]+[ \t]*device$"

echo 设备已连接，继续执行其他操作...

%adb-tools%\adb reboot bootloader

echo 正在等待 10 秒...以便设备能进入fastboot
timeout /t 10 >nul

echo 设备已连接，继续执行其他操作...
%adb-tools%\fastboot flash init_boot %boot_Magiskpatched%\boot_Magiskpatched.img

echo 设备将在3秒后重启进入系统，祝您使用愉快~
timeout /t 3 >nul
%adb-tools%\fastboot reboot
goto end


:end
echo.    是否删除payload.bin文件？(Y删除/N不删)
choice /c YN

if errorlevel 2 (
    echo 正在删除残留文件
	del /s /q %boot_Magiskpatched%\boot_Magiskpatched.img
	del /s /q %boot_origin%\boot.img
	del /s /q %boot_origin%\init_boot.img
) else (
    echo 删除文件
    del /s /q .\payload.bin
	del /s /q %boot_Magiskpatched%\boot_Magiskpatched.img
	del /s /q %boot_origin%\boot.img
	del /s /q %boot_origin%\init_boot.img
)
endlocal

echo.    执行完毕，希望大大用的开心呀
echo.    有能力的话关注一下我的b站呗，或者去酷安搜索badnng关注我，如果大佬能请我喝瓶矿泉水的话，我会加倍感谢你的！
start .\source\QRCode\cd85617e1d34b8ebe63db88c22abd09.jpg
echo.    本窗口将在6秒钟关闭~
timeout /t 6 >nul
explorer "https://space.bilibili.com/355631279?spm_id_from=333.1007.0.0"