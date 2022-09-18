#!/bin/bash
#---help---
# Usage: exagear-terminal-bionic-fix-install [options]
#
#Options:
#
# -c 		Specify the name of the ExaGer APK you are using.
#    		The default is com.hugo305.benchmark
#
# -f yes	Fixes apt in ExaGear cache
#
# -h 		Show this help message and exit.
#
#
# Использование: exagear-terminal-bionic-fix-install [параметры]
#
#Опции:
#
# -c    	Укажите имя используемого АПК ExaGer.
#		По умолчанию установленo com.hugo305.benchmark
#
# -f yes	Исправляет apt в кеше ExaGear
#
# -h 		Показывает это вспомогательное сообщение
#
#---help---

usage()
{
	sed -En '/^#---help---/,/^#---help---/p' "$0" | sed -E 's/^# ?//; 1d;$d;'
}

gen_chroot_script()
{

	cat <<-EOF
	#!/bin/bash
	set -e
	mount --bind /dev/ exagear-chroot/dev
	mount --bind /sys exagear-chroot/sys
	mount --bind /proc exagear-chroot/proc
	chroot exagear-chroot
	EOF
}

gen_chroot_script2()
{

	cat <<-EOF
        #!/bin/bash
        set -e
	umount -l exagear-chroot/dev/
	umount -l exagear-chroot/sys/
	umount -l exagear-chroot/proc/
	EOF
}

: ${EXAGEAR_CACHE:="com.hugo305.benchmark"}

while getopts ":c:f:h:" OPTION; do
        case "${OPTION}" in
        c) EXAGEAR_CACHE=${OPTARG};;
	f) FIX_APT=${OPTARG} ;;
        h | --help) usage; exit 0;;
        esac
done

echo "$EXAGEAR_CACHE"
echo "$FIX_APT"

apt update
apt install binfmt-support qemu qemu-kvm qemu-user-static unzip -y
update-binfmts --enable qemu-i386
ln -sfnv /data/data/${EXAGEAR_CACHE}/files/image/ exagear-chroot
if [ -d "exagear-chroot/dev" ]
then
echo
else
mkdir exagear-chroot/dev
fi
cp /usr/bin/qemu-i386-static exagear-chroot/usr/bin/
gen_chroot_script > enter-exagear-chroot
chmod +x enter-exagear-chroot
gen_chroot_script2 > unmount-exagear-chroot
chmod +x unmount-exagear-chroot
if [ "${FIX_APT}" == "yes" ]
then
unzip exagear-terminal-bionic-fix.zip
cp -r exagear-terminal-bionic-fix exagear-chroot/root/
rm -rf exagear-terminal-bionic-fix
./enter-exagear-chroot <<-EOF
	unset ANDROID_DATA

	cd /root/exagear-terminal-bionic-fix/
	chmod +x *
	cp etc/ usr/ / -r
	chmod +x /usr/sbin/user*
	chmod +x /etc/default/useradd
	dpkg -i *.deb
	apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 3B4FE6ACC0B21F32
	apt update
	apt install -f -y
	cd && rm -rf /root/exagear-terminal-bionic-fix
	exit
	EOF
echo ""
echo "RU Исправление apt законченно"
echo ""
echo "EN apt fix complete"
echo ""
else
./enter-exagear-chroot <<-EOF
        unset ANDROID_DATA

	apt update
        apt install -f -y
	exit
	EOF
fi
./unmount-exagear-chroot
echo ""
echo ""
echo "RU Для входа в exagear-chroot используйте скрипт enter-exagear-chroot"
echo "RU Никогда не выполняйте следующие команды: apt upgrade apt full-upgrade apt dist-upgrade"
echo "RU Сразу после входа в exagear-chroot всегда вводите эти команды:"
echo "unset ANDROID_DATA"
echo "Всегда после выхода из exagear-chroot не забудьте выполнить скрипт  unmount-exagear-chroot"
echo ""
echo "EN To enter the exagear-chroot, use the enter-exagear-chroot script"
echo "EN Never run the following commands: apt upgrade apt full-upgrade apt dist-upgrade"
echo "EN Immediately after entering exagear-chroot, always enter these commands:"
echo "unset ANDROID_DATA"
echo "Always remember to run the unmount-exagear-chroot script after exiting exagear-chroot"
echo ""
echo ""
echo "Сделал Anonym3310"
echo "Made by Anonym3310"
