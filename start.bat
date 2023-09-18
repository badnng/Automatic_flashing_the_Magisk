@echo off

set adb-tools=.\source\platform-tools
set boot_origin=.\boot
set boot_Magiskpatched=.\boot
set Magisk_source=.\source\Magisk_flies
set payload=.\source\payload

pause

:payload-dumper
if not exist %boot_origin%\*boot.img (
    @REM 解包init_boot.img
    set /p payload_file=payload.bin: 
    %payload%\payload-dumper-go.exe -p init_boot -o %boot_origin% %payload_file%
    if not exist %boot_origin%\init_boot.img (
        %payload%\payload-dumper-go.exe -p boot -o %boot_origin% %payload_file%
    )
    goto payload-dumper
) else if exist %boot_origin%\boot.img if exist %boot_origin%\init_boot.img (
    exit
) else if exist %boot_origin%\boot.img (
    set image=boot
) else if exist %boot_origin%\init_boot.img (
    set image=init_boot
)

CLS

@REM 安装Magisk
%adb-tools%\adb install %Magisk_source%\Magisk.apk

@REM 修补镜像
%adb-tools%\adb push %Magisk_source%\magisk /data/local/tmp
%adb-tools%\adb push %boot_origin%\%image%.img /data/local/tmp/magisk
%adb-tools%\adb shell chmod +x /data/local/tmp/magisk/*
%adb-tools%\adb shell /data/local/tmp/magisk/boot_patch.sh %image%.img
%adb-tools%\adb pull /data/local/tmp/magisk/new-boot.img %boot_Magiskpatched%

@REM 刷入镜像
%adb-tools%\adb reboot bootloader
ping>nul 2>nul localhost
%adb-tools%\fastboot flash %image% %boot_Magiskpatched%\new-boot.img

pause

%adb-tools%\fastboot reboot
del %boot_Magiskpatched%\new-boot.img