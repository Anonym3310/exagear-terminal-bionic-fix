#!/bin/bash
#---help---
# Usage: exagear-terminal-bionic-fix-install [options]
#
#Options:
#
# -c 	Specify the name of the ExaGer APK you are using.
#    	The default is com.hugo305.benchmark
#
# -h 	Show this help message and exit.
#
#
# Использование: exagear-terminal-bionic-fix-install [параметры]
#
#Опции:
#
# -c    Укажите имя используемого АПК ExaGer.
#	По умолчанию установленo com.hugo305.benchmark
#
# -h 	Показывает это вспомогательное сообщение
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


while getopts 'c:h' OPTION; do
        case "$OPTION" in
        c) EXAGEAR_CACHE="$OPTARG";;
        h) usage; exit 0;;
        esac
done

: ${EXAGEAR_CACHE:="com.hugo305.benchmark"}

apt update
apt install binfmt-support qemu qemu-kvm qemu-user-static unzip -y
update-binfmts --enable qemu-i386
ln -sfnv /data/data/${EXAGEAR_CACHE}/files/image/ exagear-chroot
cp /usr/bin/qemu-i386-static exagear-chroot/usr/bin/
unzip exagear-terminal-bionic-fix.zip
cp -r exagear-terminal-bionic-fix exagear-chroot/root/
rm -rf exagear-terminal-bionic-fix

gen_chroot_script > enter-exagear-chroot
chmod +x enter-exagear-chroot
gen_chroot_script2 > unmount-exagear-chroot
chmod +x unmount-exagear-chroot
./enter-exagear-chroot <<-EOF
	#!/bin/bash
	set -e
	unset ANDROID_ART_ROOT
	unset ANDROID_DATA
	unset ANDROID_ROOT
	unset LD_PRELOAD
	unset PREFIX
	unset TMPDIR

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
./unmount-exagear-chroot
echo "RU Исправление apt законченно"
echo "RU Для входа в exagear-chroot используйте скрипт enter-exagear-chroot"
echo "RU Никогда не выполняйте следующие команды: apt upgrade apt full-upgrade apt dist-upgrade"
echo "RU Сразу после входа в exagear-chroot всегда вводите эти команды:"
echo "unset ANDROID_ART_ROOT"
echo "unset ANDROID_DATA"
echo "unset ANDROID_ROOT"
echo "unset LD_PRELOAD"
echo "unset PREFIX"
echo "unset TMPDIR"
echo "Всегда после выхода из exagear-chroot не забудьте выполнить скрипт  unmount-exagear-chroot"
echo ""
echo "EN apt fix complete"
echo "EN To enter the exagear-chroot, use the enter-exagear-chroot script"
echo "EN Never run the following commands: apt upgrade apt full-upgrade apt dist-upgrade"
echo "EN Immediately after entering exagear-chroot, always enter these commands:"
echo "unset ANDROID_ART_ROOT"
echo "unset ANDROID_DATA"
echo "unset ANDROID_ROOT"
echo "unset LD_PRELOAD"
echo "unset PREFIX"
echo "unset TMPDIR"
echo "Always remember to run the unmount-exagear-chroot script after exiting exagear-chroot"
echo ""
echo ""
echo "Сделал Anonym3310"
echo "Made by Anonym3310"
