# **English** | [简体中文](README_CN.md) |

## Automatic_flashing_the_Magisk_Delta

 Can automatic flashing to HuskyDG's or topjohnwu's Magisk

## Features

 You can patch the boot image and flash it without installing Magisk Manager on your phone
 You can use anything Magisk Versions for do it

## System requirements

 A working PC with system is Windows 7 and above

## How to use it 

- Put the payload file of the card swipe packet in this directory
- Now you can flash in with one click without environment variables (please don't delete the source folder!)
- Double-click the start .bat, select the flashing method according to the model, and then the phone can wait after turning on USB debugging in the boot state
- If there is no payload .bin, put boot into the boot_origin directory ~
- **If there is an authorization window on your phone, please authorize, otherwise it will lead to failure!**

## Thanks

- [Magisk](https://github.com/topjohnwu/Magisk): Patch the boot's script
- [Magisk_Delta](https://github.com/HuskyDG/magisk-files): Patch the boot's script
- [Busybox](https://github.com/rmyorston/busybox-w32): Can use .sh on Windows
- [Android Debug Bridge](https://source.android.google.cn/docs/setup/build/adb?hl=zh-cn#download-adb): use the Android Debug Bridge flies