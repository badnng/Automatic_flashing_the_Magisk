[English](README.md) | **简体中文** |
# Automatic_flashing_the_Magisk_Delta
 可以在电脑上执行修补到刷入Magisk

## 特点
 可以在电脑上执行修补boot并刷入magisk
 可以任意切换magisk版本（只要你的magisk可以刷入即可）

## 系统要求
 需要一个可以正常运行Windows7及以上操作系统的电脑

## 如何使用
 - 将卡刷包的payload文件放在此目录里面
 - 现在无需环境变量即可一键刷入(请不要删除source文件夹!)
 - 双击开始.bat，按照机型选择刷入方式，然后手机在开机状态，开启了usb调试之后即可等待
 - 如果没有payload.bin，放入boot到boot_origin目录即可~
 - 如果要更换面具版本，直接下好对应的magisk版本的apk，然后将.apk改成Magisk.zip放入即可~
 - 手机上有授权窗口请授权，不然会导致失败！

 ## 鸣谢
- [Magisk](https://github.com/topjohnwu/Magisk): 提供修补boot的脚本
- [Magisk_Delta](https://github.com/HuskyDG/magisk-files): 提供修补boot的脚本
- [Busybox](https://github.com/rmyorston/busybox-w32): 可以在Windows使用.sh的框架
- [Android Debug Bridge](https://source.android.google.cn/docs/setup/build/adb?hl=zh-cn#download-adb): 调用adb调试
