@echo off

set adb-tools=.\source\platform-tools
set boot_origin=.\boot
set boot_Magiskpatched=.\boot
set Magisk_source=.\source\Magisk_flies
set aria=.\source\aria2
set payload=.\source\payload
set 7z=.\source\7zip

:start
CLS
rd /s /q %Magisk_source%\Magisk
del /q %Magisk_source%\magisk_lib.zip
set /p payload_file=����������payload.bin·��:
title ȫ�Զ�ˢ��magisk_V2---by badnng
echo.
echo.          ȫ�Զ�ˢ��magisk_V2
echo.                               by badnng
echo.��A����ʼ�����ϻ��͵�boot��ȫ�Զ�ˢ��~
echo.��B����ʼ�����»���init_boot��ȫ�Զ�ˢ��~

:Nopatch_flies
echo.
echo.��ȡ�����ļ�
%aria%\aria2c.exe -x 16 -c --file-allocation=none -o magisk_lib.zip -d %Magisk_source% https://hub.gitmirror.com/https://github.com/badnng/Tools_library_download/releases/download/test/magisk_lib.zip
%aria%\aria2c.exe -x 16 -c --file-allocation=none -o Magisk_26300apk.apk -d %Magisk_source% https://hub.gitmirror.com/https://github.com/badnng/Tools_library_download/releases/download/test/Magisk.apk
echo.������ѡ��:
if exist %Magisk_source%\magisk_lib.zip (
    choice /C AB /N /M ""
    goto flash_boot
    if errorlevel 2 goto flash_initboot
) else (
    goto Nopatch_flies
)

:flash_boot
CLS
echo. ��װMagisk���簲װʧ�ܣ���ȷ���Ƿ��������Ȩusb��װ��ϵͳ�ܼ����أ���MIUI��HyperOS��
%adb-tools%\adb install %Magisk_flies%/Magisk.apk
echo. ��ѹ�����ļ�
%7z%\7z -x %Magisk_source%/magisk_lib.zip -o%Magisk_source% && REM ��ѹmagisk-lib�ļ�
echo. �޲�����ȡboot
%payload%\payload-dumper-go.exe -p boot -o %boot_origin% %payload_file%
%adb-tools%\adb push .\source\Magisk_flies\Magisk\ /data/local/tmp && REM ���ͽű�
%adb-tools%\adb push %boot_origin%\boot.img /data/local/tmp/Magisk && REM ����boot
%adb-tools%\adb shell chmod +x /data/local/tmp/Magisk/* && REM ��Ȩ��
%adb-tools%\adb shell /data/local/tmp/Magisk/boot_patch.sh boot.img && REM ִ�нű�
%adb-tools%\adb pull /data/local/tmp/Magisk/new-boot.img %boot_Magiskpatched%\boot.img && REM ��ȡ����
%adb-tools%\adb shell rm -r /data/local/tmp/Magisk/

echo. ˢ��boot
echo. �豸����10������������fastboot���ڴ��ڼ��벻Ҫ�γ�������!
timeout /t 10 >nul
echo. ��������fastboot
%adb-tools%\adb reboot bootloader
echo. �ȴ�����ˢ��boot
%adb-tools%\fastboot flash boot_ab %boot_Magiskpatched%\boot.img
echo. ���������豸
%adb-tools%\fastboot reboot

goto end

:flash_initboot
CLS
echo. ��װMagisk���簲װʧ�ܣ���ȷ���Ƿ��������Ȩusb��װ��ϵͳ�ܼ����أ���MIUI��HyperOS��
%adb-tools%\adb install %Magisk_flies%/Magisk.apk
echo. ��ѹ�����ļ�
tar -xzvf %Magisk_source%/magisk_lib.zip -C %Magisk_source% && REM ��ѹmagisk-lib�ļ�
echo. �޲�����ȡboot
%payload%\payload-dumper-go.exe -p init_boot -o %boot_origin% %payload_file%
%adb-tools%\adb push .\source\Magisk_flies\Magisk\ /data/local/tmp && REM ���ͽű�
%adb-tools%\adb push %boot_origin%\init_boot.img /data/local/tmp/Magisk && REM ����boot
%adb-tools%\adb shell chmod +x /data/local/tmp/Magisk/* && REM ��Ȩ��
%adb-tools%\adb shell /data/local/tmp/Magisk/boot_patch.sh init_boot.img && REM ִ�нű�
%adb-tools%\adb pull /data/local/tmp/Magisk/new-boot.img %boot_Magiskpatched%\init_boot.img && REM ��ȡ����
%adb-tools%\adb shell rm -r /data/local/tmp/Magisk/

echo. ˢ��boot
echo. �豸����10������������fastboot���ڴ��ڼ��벻Ҫ�γ�������!
timeout /t 10 >nul
echo. ��������fastboot
%adb-tools%\adb reboot bootloader
echo. �ȴ�����ˢ��init_boot(ABͨˢ��֧��K60U��Note13Pro+�Ȼ���)
%adb-tools%\fastboot flash init_boot_ab %boot_Magiskpatched%\init_boot.img
echo. ���������豸
%adb-tools%\fastboot reboot
goto end

:end
CLS
echo.    �Ƿ�ɾ��payload.bin�ļ���(Yɾ��/N��ɾ)
choice /c YN

if errorlevel 2 (
    echo ����ɾ�������ļ�
	del /s /q %boot_origin%\boot.img
	del /s /q %boot_origin%\init_boot.img
) else (
    echo ɾ���ļ�
    del /s /q %payload_file%
	del /s /q %boot_origin%\boot.img
	del /s /q %boot_origin%\init_boot.img
)
echo.    ִ����ϣ�ϣ������õĿ���ѽ
echo.    �������Ļ���עһ���ҵ�bվ�£�����ȥ�ᰲ����badnng��ע�ң�������������Һ�ƿ��Ȫˮ�Ļ����һ�ӱ���л��ģ�
start .\source\QRCode\cd85617e1d34b8ebe63db88c22abd09.jpg
taskkill -f -im adb.exe
echo.    �����ڽ���6���ӹر�~
timeout /t 6 >nul
explorer "https://space.bilibili.com/355631279?spm_id_from=333.1007.0.0"