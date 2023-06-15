@echo off

set adb-tools=.\source\platform-tools
set boot_origin=.\boot_origin
set boot_Magiskpatched=.\boot_Magiskpatched

:start
CLS
title ȫ�Զ�ˢ��magisk delta ---by badnng
echo.
echo.          ȫ�Զ�ˢ��magisk delta
echo.                               by badnng
echo.��A����ʼ�����ϻ��͵�boot��ȫ�Զ�ˢ��~
echo.��B����ʼ�����»���init_boot��ȫ�Զ�ˢ��~


%����ļ��Ƿ�����%
if exist .\Magisk.zip (
    choice /C AB /N /M "��ѡ�� A �� B��"
    if errorlevel 2 goto flash_b
    goto flash_a
) else (
    goto error-noMagisk.zip
)


:error-noMagisk.zip
CLS
echo.
echo.  Magisk.zip�����ڣ������Ƿ����Magisk�ļ�
pause>null
del null
exit

:flash_a
CLS
choice /C AB /N /M "��ѡ��Ҫˢ���Magisk��֧��Magisk_Delta(A) �� Magisk_topjohnwu(B)"
if errorlevel 2 (
    rem ѡ�� B��ִ�� flash_b
    goto flash_a_top
) else (
    rem ѡ�� A��ִ�� flash_a
    bin\busybox unzip Magisk.zip -d tmp -n |bin\busybox grep -E "arm|util_functions" |bin\busybox sed "s/ //g"
echo.
if not exist tmp/META-INF (echo.�ļ�����&rd /s /q tmp 1>nul 2>nul&pause&exit)

if exist tmp\assets\util_functions.sh bin\busybox bash -c "echo ��߰汾������Ϊ�� $(cat tmp/assets/util_functions.sh |grep MAGISK_VER_CODE |cut -d = -f 2)"
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
echo.������ɣ�
rd /s /q tmp

.\source\payload\payload-dumper-go.exe -p boot -o %boot_origin% .\payload.bin
if not exist %boot_origin%\boot.img (echo.��ǰĿ¼û�� boot.img �ļ���& pause & exit /b)
if exist %boot_Magiskpatched%\boot_Magiskpatched.img (del /s /q %boot_Magiskpatched%\boot_Magiskpatched.img 1>nul 2>nul)
echo.
bin\busybox bash bin/boot_patch.sh %boot_origin%\boot.img
echo.
if exist new-boot.img (move new-boot.img %boot_Magiskpatched%\boot_Magiskpatched.img 1>nul 2>nul&echo.�ɹ��޲� boot.img) else (echo.�޷��޲� boot.img)

%adb-tools%\adb devices | findstr /r /c:"^[ \t]*[0-9a-zA-Z]+[ \t]*device$"

echo �豸�����ӣ�����ִ����������...

%adb-tools%\adb reboot bootloader

echo ���ڵȴ� 10 ��...�Ա��豸�ܽ���fastboot
timeout /t 10 >nul

echo �豸�����ӣ�����ִ����������...
%adb-tools%\fastboot flash boot %boot_Magiskpatched%\boot_Magiskpatched.img

echo �豸����������ϵͳ��ף��ʹ�����~
%adb-tools%\fastboot reboot
goto end
)



:flash_b
CLS
choice /C AB /N /M "��ѡ��Ҫˢ���Magisk��֧��Magisk_Delta(A) �� Magisk_topjohnwu(B)"
if errorlevel 2 (
    rem ѡ�� B��ִ�� flash_b_top
    goto flash_b_top
) else (
    rem ѡ�� A��ִ�� flash_b
    bin\busybox unzip Magisk.zip -d tmp -n |bin\busybox grep -E "arm|util_functions" |bin\busybox sed "s/ //g"
echo.
if not exist tmp/META-INF (echo.�ļ�����&rd /s /q tmp 1>nul 2>nul&pause&exit)

if exist tmp\assets\util_functions.sh bin\busybox bash -c "echo ��߰汾������Ϊ�� $(cat tmp/assets/util_functions.sh |grep MAGISK_VER_CODE |cut -d = -f 2)"
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
echo.�������!
rd /s /q tmp

.\source\payload\payload-dumper-go.exe -p init_boot -o %boot_origin% .\payload.bin
if not exist %boot_origin%\init_boot.img (echo.��ǰĿ¼û�� init_boot.img �ļ���& pause & exit /b)
if exist %boot_Magiskpatched%\boot_Magiskpatched.img (del /s /q %boot_Magiskpatched%\boot_Magiskpatched.img 1>nul 2>nul)
echo.
bin\busybox bash bin/boot_patch.sh %boot_origin%\init_boot.img
echo.
if exist new-boot.img (move new-boot.img %boot_Magiskpatched%\boot_Magiskpatched.img 1>nul 2>nul&echo.�ɹ��޲� boot.img) else (echo.�޷��޲� boot.img)

%adb-tools%\adb devices | findstr /r /c:"^[ \t]*[0-9a-zA-Z]+[ \t]*device$"

echo �豸�����ӣ�����ִ����������...

%adb-tools%\adb reboot bootloader

echo ���ڵȴ� 10 ��...�Ա��豸�ܽ���fastboot
timeout /t 10 >nul

echo �豸�����ӣ�����ִ����������...
%adb-tools%\fastboot flash init_boot %boot_Magiskpatched%\boot_Magiskpatched.img

echo �豸����3�����������ϵͳ��ף��ʹ�����~
timeout /t 3 >nul
%adb-tools%\fastboot reboot
goto end
)



:flash_a_top
CLS
bin\busybox unzip Magisk-v26.1.zip -d tmp -n |bin\busybox grep -E "arm|util_functions" |bin\busybox sed "s/ //g"
echo.
if not exist tmp/META-INF (echo.�ļ�����&rd /s /q tmp 1>nul 2>nul&pause&exit)

if exist tmp\assets\util_functions.sh bin\busybox bash -c "echo ��߰汾������Ϊ�� $(cat tmp/assets/util_functions.sh |grep MAGISK_VER_CODE |cut -d = -f 2)"
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
echo.������ɣ�
rd /s /q tmp

.\source\payload\payload-dumper-go.exe -p boot -o %boot_origin% .\payload.bin
if not exist %boot_origin%\boot.img (echo.��ǰĿ¼û�� boot.img �ļ���& pause & exit /b)
if exist %boot_Magiskpatched%\boot_Magiskpatched.img (del /s /q %boot_Magiskpatched%\boot_Magiskpatched.img 1>nul 2>nul)
echo.
bin\busybox bash bin/boot_patch.sh %boot_origin%\boot.img
echo.
if exist new-boot.img (move new-boot.img %boot_Magiskpatched%\boot_Magiskpatched.img 1>nul 2>nul&echo.�ɹ��޲� boot.img) else (echo.�޷��޲� boot.img)

%adb-tools%\adb devices | findstr /r /c:"^[ \t]*[0-9a-zA-Z]+[ \t]*device$"

echo �豸�����ӣ�����ִ����������...

%adb-tools%\adb reboot bootloader

echo ���ڵȴ� 10 ��...�Ա��豸�ܽ���fastboot
timeout /t 10 >nul

echo �豸�����ӣ�����ִ����������...
%adb-tools%\fastboot flash boot %boot_Magiskpatched%\boot_Magiskpatched.img

echo �豸����������ϵͳ��ף��ʹ�����~
%adb-tools%\fastboot reboot
goto end


:flash_b_top
CLS
bin\busybox unzip Magisk-V26.1.zip -d tmp -n |bin\busybox grep -E "arm|util_functions" |bin\busybox sed "s/ //g"
echo.
if not exist tmp/META-INF (echo.�ļ�����&rd /s /q tmp 1>nul 2>nul&pause&exit)

if exist tmp\assets\util_functions.sh bin\busybox bash -c "echo ��߰汾������Ϊ�� $(cat tmp/assets/util_functions.sh |grep MAGISK_VER_CODE |cut -d = -f 2)"
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
echo.������ɣ�
rd /s /q tmp

.\source\payload\payload-dumper-go.exe -p init_boot -o %boot_origin% .\payload.bin
if not exist %boot_origin%\init_boot.img (echo.��ǰĿ¼û�� init_boot.img �ļ���& pause & exit /b)
if exist %boot_Magiskpatched%\boot_Magiskpatched.img (del /s /q %boot_Magiskpatched%\boot_Magiskpatched.img 1>nul 2>nul)
echo.
bin\busybox bash bin/boot_patch.sh %boot_origin%\init_boot.img
echo.
if exist new-boot.img (move new-boot.img %boot_Magiskpatched%\boot_Magiskpatched.img 1>nul 2>nul&echo.�ɹ��޲� boot.img) else (echo.�޷��޲� boot.img)

%adb-tools%\adb devices | findstr /r /c:"^[ \t]*[0-9a-zA-Z]+[ \t]*device$"

echo �豸�����ӣ�����ִ����������...

%adb-tools%\adb reboot bootloader

echo ���ڵȴ� 10 ��...�Ա��豸�ܽ���fastboot
timeout /t 10 >nul

echo �豸�����ӣ�����ִ����������...
%adb-tools%\fastboot flash init_boot %boot_Magiskpatched%\boot_Magiskpatched.img

echo �豸����3�����������ϵͳ��ף��ʹ�����~
timeout /t 3 >nul
%adb-tools%\fastboot reboot
goto end


:end
echo.    �Ƿ�ɾ��payload.bin�ļ���(Yɾ��/N��ɾ)
choice /c YN

if errorlevel 2 (
    echo ����ɾ�������ļ�
	del /s /q %boot_Magiskpatched%\boot_Magiskpatched.img
	del /s /q %boot_origin%\boot.img
	del /s /q %boot_origin%\init_boot.img
) else (
    echo ɾ���ļ�
    del /s /q .\payload.bin
	del /s /q %boot_Magiskpatched%\boot_Magiskpatched.img
	del /s /q %boot_origin%\boot.img
	del /s /q %boot_origin%\init_boot.img
)
endlocal

echo.    ִ����ϣ�ϣ������õĿ���ѽ
echo.    �������Ļ���עһ���ҵ�bվ�£�����ȥ�ᰲ����badnng��ע�ң�������������Һ�ƿ��Ȫˮ�Ļ����һ�ӱ���л��ģ�
start .\source\QRCode\cd85617e1d34b8ebe63db88c22abd09.jpg
echo.    �����ڽ���6���ӹر�~
timeout /t 6 >nul
explorer "https://space.bilibili.com/355631279?spm_id_from=333.1007.0.0"