@echo off

set adb-tools=.\source\platform-tools
set boot_origin=.\boot
set boot_Magiskpatched=.\boot
set Magisk_source=.\source\Magisk_flies
set vbmeta=.\vbmeta
set aria=.\source\aria2

:start
CLS
title ȫ�Զ�ˢ��magisk delta ---by badnng
echo.
echo.          ȫ�Զ�ˢ��magisk delta
echo.                               by badnng
echo.��A����ʼ�����ϻ��͵�boot��ȫ�Զ�ˢ��~
echo.��B����ʼ�����»���init_boot��ȫ�Զ�ˢ��~

del %Magisk_source%\Magisk.zip
del %Magisk_source%\Magisk-v26.1.zip

%����ļ��Ƿ�����%
if exist %Magisk_source%\Magisk.zip (
    choice /C AB /N /M ""
    if errorlevel 2 goto flash_b
    goto flash_a
) else (
    goto noMagisk.zip
)


:noMagisk.zip
echo.
echo.  ���ڻ�ȡ���°汾��Magisk.zip�ļ�
%aria%\aria2c.exe -x 16 -c --file-allocation=none -o Magisk.zip -d %Magisk_source% https://badnng.github.io/Automatic_flashing_the_Magisk_Delta/Magisk.zip
%aria%\aria2c.exe -x 16 -c --file-allocation=none -o Magisk-v26.1.zip -d %Magisk_source% https://badnng.github.io/Automatic_flashing_the_Magisk_Delta/Magisk-v26.1.zip
if exist %Magisk_source%\Magisk.zip (
	choice /C AB /N /M "��ѡ�� A �� B��"
    if errorlevel 2 goto flash_b
    goto flash_a
) else (
	goto noMagisk.zip
)

:flash_a
CLS
choice /C AB /N /M "��ѡ��Ҫˢ���Magisk��֧��Magisk_Delta(A) �� Magisk_topjohnwu(B)"
if errorlevel 2 (
    rem ѡ�� B��ִ�� flash_a_top
    goto flash_a_top_check
) else (
    rem ѡ�� A��ִ�� 
	ren "%Magisk_source%.\Magisk.zip" "Magisk.apk"
	%adb-tools%\adb install %Magisk_source%\Magisk.apk
	ren "%Magisk_source%\Magisk.apk" "Magisk.zip"

    bin\busybox unzip %Magisk_source%\Magisk.zip -d tmp -n |bin\busybox grep -E "arm|util_functions" |bin\busybox sed "s/ //g"
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
.\source\payload\payload-dumper-go.exe -p vbmeta -o %vbmeta% .\payload.bin

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

choice /C AB /N /M "���ڲ��ֻ��ͣ���Ҫ�ر�avb��֤�����ж����Ļ����Ƿ���Ҫ�ر�avb��֤����Ҫ����A������Ҫ����B"
if errorlevel 2 (
	echo �豸����������ϵͳ��ף��ʹ�����~
	%adb-tools%\fastboot reboot
	goto end
) else (
	echo �豸����������ϵͳ��ף��ʹ�����~
	%adb-tools%\fastboot --disable-verity --disable-verification flash vbmeta %vbmeta%\vbmeta.img
	%adb-tools%\fastboot reboot
	goto end
)


)



:flash_b
CLS
choice /C AB /N /M "��ѡ��Ҫˢ���Magisk��֧��Magisk_Delta(A) �� Magisk_topjohnwu(B)"
if errorlevel 2 (
    rem ѡ�� B��ִ�� flash_b_top
    goto flash_a_top_check
) else (
    rem ѡ�� A��ִ�� flash_b
	ren "%Magisk_source%\Magisk.zip" "Magisk.apk"
	%adb-tools%\adb install %Magisk_source%\Magisk.apk
	ren "%Magisk_source%\Magisk.apk" "Magisk.zip"

    bin\busybox unzip %Magisk_source%\Magisk.zip -d tmp -n |bin\busybox grep -E "arm|util_functions" |bin\busybox sed "s/ //g"
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
.\source\payload\payload-dumper-go.exe -p vbmeta -o %vbmeta% .\payload.bin
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

choice /C AB /N /M "���ڲ��ֻ��ͣ���Ҫ�ر�avb��֤�����ж����Ļ����Ƿ���Ҫ�ر�avb��֤����Ҫ����A������Ҫ����B"
if errorlevel 2 (
	echo �豸����������ϵͳ��ף��ʹ�����~
	%adb-tools%\fastboot reboot
	goto end
) else (
	echo �豸����������ϵͳ��ף��ʹ�����~
	%adb-tools%\fastboot --disable-verity --disable-verification flash vbmeta %vbmeta%\vbmeta.img
	%adb-tools%\fastboot reboot
	goto end
)



:flash_a_top_check
CLS
if exist %Magisk_source%\Magisk-v26.1.zip (
    goto flash_a_top
) else (
    curl -o %Magisk_source%\Magisk-v26.1.zip https://badnng.github.io/Automatic_flashing_the_Magisk_Delta/Magisk-v26.1.zip
	goto flash_a_top_check
)

:flash_a_top
CLS
ren "%Magisk_source%\Magisk-v26.1.zip" "Magisk-v26.1.apk"
%adb-tools%\adb install %Magisk_source%\Magisk-v26.1.apk
ren "%Magisk_source%\Magisk-v26.1.apk" "Magisk-v26.1.zip"

bin\busybox unzip %Magisk_source%\Magisk-v26.1.zip -d tmp -n |bin\busybox grep -E "arm|util_functions" |bin\busybox sed "s/ //g"
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
.\source\payload\payload-dumper-go.exe -p vbmeta -o %vbmeta% .\payload.bin

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

choice /C AB /N /M "���ڲ��ֻ��ͣ���Ҫ�ر�avb��֤�����ж����Ļ����Ƿ���Ҫ�ر�avb��֤����Ҫ����A������Ҫ����B"
if errorlevel 2 (
	echo �豸����������ϵͳ��ף��ʹ�����~
	%adb-tools%\fastboot reboot
	goto end
) else (
	echo �豸����������ϵͳ��ף��ʹ�����~
	%adb-tools%\fastboot --disable-verity --disable-verification flash vbmeta %vbmeta%\vbmeta.img
	%adb-tools%\fastboot reboot
	goto end
)

:flash_b_top_check
CLS
if exist .\Magisk-v26.1.zip (
    goto flash_b_top
) else (
    curl -o %Magisk_source%\Magisk-v26.1.zip https://badnng.github.io/Automatic_flashing_the_Magisk_Delta/Magisk-v26.1.zip
	goto flash_b_top_check
)

:flash_b_top
CLS
ren "%Magisk_source%\Magisk-v26.1.zip" "Magisk-v26.1.apk"
%adb-tools%\adb install %Magisk_source%\Magisk-v26.1.apk
ren "%Magisk_source%\Magisk-v26.1.apk" "Magisk-v26.1.zip"

bin\busybox unzip %Magisk_source%\Magisk-V26.1.zip -d tmp -n |bin\busybox grep -E "arm|util_functions" |bin\busybox sed "s/ //g"
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
.\source\payload\payload-dumper-go.exe -p vbmeta -o %vbmeta% .\payload.bin

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

choice /C AB /N /M "���ڲ��ֻ��ͣ���Ҫ�ر�avb��֤�����ж����Ļ����Ƿ���Ҫ�ر�avb��֤����Ҫ����A������Ҫ����B"
if errorlevel 2 (
	echo �豸����������ϵͳ��ף��ʹ�����~
	%adb-tools%\fastboot reboot
	goto end
) else (
	echo �豸����������ϵͳ��ף��ʹ�����~
	%adb-tools%\fastboot --disable-verity --disable-verification flash vbmeta %vbmeta%\vbmeta.img
	%adb-tools%\fastboot reboot
	goto end
)



:end
echo.    �Ƿ�ɾ��payload.bin�ļ���(Yɾ��/N��ɾ)
choice /c YN

if errorlevel 2 (
    echo ����ɾ�������ļ�
	del /s /q %boot_Magiskpatched%\boot_Magiskpatched.img
	del /s /q %boot_origin%\boot.img
	del /s /q %boot_origin%\init_boot.img
	del /s /q %Magisk_source%\Magisk.zip
	del /s /q %Magisk_source%\Magisk-v26.1.zip
) else (
    echo ɾ���ļ�
    del /s /q .\payload.bin
	del /s /q %boot_Magiskpatched%\boot_Magiskpatched.img
	del /s /q %boot_origin%\boot.img
	del /s /q %boot_origin%\init_boot.img
	del /s /q %Magisk_source%\Magisk.zip
	del /s /q %Magisk_source%\Magisk-v26.1.zip
)
endlocal

echo.    ִ����ϣ�ϣ������õĿ���ѽ
echo.    �������Ļ���עһ���ҵ�bվ�£�����ȥ�ᰲ����badnng��ע�ң�������������Һ�ƿ��Ȫˮ�Ļ����һ�ӱ���л��ģ�
start .\source\QRCode\cd85617e1d34b8ebe63db88c22abd09.jpg
echo.    �����ڽ���6���ӹر�~
timeout /t 6 >nul
explorer "https://space.bilibili.com/355631279?spm_id_from=333.1007.0.0"