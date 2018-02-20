#!/bin/bash

# Script to help cross-compile Qt5 for RasPI
# Created by piano_jonas
# USE AT YOUR OWN RISK!

###############################################################################################################
# Start edit your settings here -->

RASPI_HOSTNAME="tut"
RASPI_USER="pi"
RASPI_QT_DIR="/usr/local/qt5pi"

HOST_RASPI_DIR="/opt/raspi"
HOST_QT_DIR="/opt/Qt/5.10.1"

# Stop edit here if you are mortal --<


# Edit here only if you are a dåre -->

HOST_RASPI_SYSROOT_DIR=$HOST_RASPI_DIR"/sysroot"
HOST_RASPI_QT_DIR=$HOST_RASPI_DIR"/qt5pi"

HOST_QT_BUID_DIR=$HOST_QT_DIR"/build_arm"
HOST_QT_HOSTPREFIX_DIR=$HOST_QT_DIR"/arm_64"

# Absolutely no more to edit after this point --<
###############################################################################################################


# Check diretories

echo ""
echo "Cheking your directory settings..."

cd $HOST_RASPI_DIR 2> /dev/null
if [ "$?" -gt 0 ] ; then
    echo "* The host directory for raspi '$HOST_RASPI_DIR' does not exist or you don't have acces to it."
    exit
fi

touch $HOST_RASPI_DIR/test.txt 2> /dev/null
if [ "$?" -gt 0 ] ; then
    echo "* Can' write to host directory for raspi '$HOST_RASPI_DIR' . Check permissions."
    exit
fi
rm $HOST_RASPI_DIR/test.txt

cd $HOST_QT_DIR 2> /dev/null
if [ "$?" -gt 0 ] ; then
    echo "* The Qt directory '$HOST_QT_DIR' does not exist or you don't have acces to it."
    exit
fi

touch $HOST_QT_DIR/test.txt
if [ "$?" -gt 0 ] ; then
    echo "* Can' write to Qt directory '$HOST_QT_DIR' . Check permissions."
    exit
fi
rm $HOST_QT_DIR/test.txt

echo "ok"


#Creat directory structures

echo ""
echo "Creating directory structure in $HOST_RASPI_DIR..."

mkdir $HOST_RASPI_SYSROOT_DIR
mkdir $HOST_RASPI_SYSROOT_DIR/usr 
mkdir $HOST_RASPI_SYSROOT_DIR/opt
mkdir $HOST_RASPI_QT_DIR

tree $HOST_RASPI_DIR -L 2


echo ""
echo "Creating Qt build structure in $HOST_QT_DIR..."

mkdir $HOST_QT_BUID_DIR
mkdir $HOST_QT_HOSTPREFIX_DIR

tree $HOST_QT_DIR -L 1

echo ""

#Create script files

CMD_SYNC="$HOST_RASPI_DIR/sync_sysroot.sh"
touch $CMD_SYNC
chmod 775 $CMD_SYNC

echo "Creating script file for syncing your pi ($CMD_SYNC)..."
echo "#!/bin/bash">$CMD_SYNC
echo "">>$CMD_SYNC
echo "rsync -avz $RASPI_USER@$RASPI_HOSTNAME:/lib $HOST_RASPI_SYSROOT_DIR">>$CMD_SYNC
echo "rsync -avz $RASPI_USER@$RASPI_HOSTNAME:/usr/include $HOST_RASPI_SYSROOT_DIR/usr">>$CMD_SYNC
echo "rsync -avz $RASPI_USER@$RASPI_HOSTNAME:/usr/lib $HOST_RASPI_SYSROOT_DIR/usr">>$CMD_SYNC
echo "rsync -avz $RASPI_USER@$RASPI_HOSTNAME:/opt/vc $HOST_RASPI_SYSROOT_DIR/opt">>$CMD_SYNC
echo "rsync -avz $HOST_RASPI_QT_DIR $RASPI_USER@$RASPI_HOSTNAME:/usr/local">>$CMD_SYNC


CMD_SYMLINK="$HOST_RASPI_DIR/fix_symlinks.sh"
touch $CMD_SYMLINK
chmod 775 $CMD_SYMLINK

echo "Creating script file for fixing symlinks ($CMD_SYMLINK)..."
echo "#!/bin/bash">$CMD_SYMLINK
echo "">>$CMD_SYMLINK
echo "cd $HOST_RASPI_DIR">>$CMD_SYMLINK
echo "wget https://raw.githubusercontent.com/riscv/riscv-poky/priv-1.10/scripts/sysroot-relativelinks.py">>$CMD_SYMLINK
echo "python sysroot-relativelinks.py sysroot">>$CMD_SYMLINK


CMD_MAKE="$HOST_QT_BUID_DIR/conf.sh"
touch $CMD_MAKE
chmod 775 $CMD_MAKE

echo "Creating script file for building qmake ($CMD_MAKE)..."
echo "#!/bin/bash">$CMD_MAKE
echo "">>$CMD_MAKE
echo "$HOST_QT_DIR/Src/configure -release -opengl es2 -no-libinput -device linux-rasp-pi3-g++ -no-use-gold-linker -device-option CROSS_COMPILE=$HOST_RASPI_DIR/tools/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian-x64/bin/arm-linux-gnueabihf- -sysroot $HOST_RASPI_SYSROOT_DIR -opensource -confirm-license -make libs -make tools -skip qtscript -skip qtwebengine -skip qtwayland -prefix /usr/local/qt5pi -extprefix $HOST_RASPI_QT_DIR -hostprefix $HOST_QT_HOSTPREFIX_DIR -v">>$CMD_MAKE

echo "Done"
echo ""

CMD_INSTRUCT="$HOST_RASPI_DIR/README.txt"

echo "">$CMD_INSTRUCT
echo "1. Download toolchain, run:">>$CMD_INSTRUCT
echo "      git clone https://github.com/raspberrypi/tools $HOST_RASPI_DIR/tools">>$CMD_INSTRUCT
echo "">>$CMD_INSTRUCT
echo "2. Sync your sysroot with the pi device, run:">>$CMD_INSTRUCT
echo "      $CMD_SYNC">>$CMD_INSTRUCT
echo "">>$CMD_INSTRUCT
echo "3. Fix symlinks, run:">>$CMD_INSTRUCT
echo "      $CMD_SYMLINK">>$CMD_INSTRUCT
echo "">>$CMD_INSTRUCT
echo "4. Goto the Qt build directory, run:">>$CMD_INSTRUCT
echo "      cd $HOST_QT_BUID_DIR">>$CMD_INSTRUCT
echo "">>$CMD_INSTRUCT
echo "5. Configure qmake, run:">>$CMD_INSTRUCT
echo "      ./conf.sh">>$CMD_INSTRUCT
echo "">>$CMD_INSTRUCT
echo "6. Build qmake, run:">>$CMD_INSTRUCT
echo "      make">>$CMD_INSTRUCT
echo "">>$CMD_INSTRUCT
echo "7. Install qmake in $HOST_RASPI_SYSROOT_DIR and $HOST_QT_HOSTPREFIX_DIR, run:">>$CMD_INSTRUCT
echo "      sudo make install">>$CMD_INSTRUCT
echo "">>$CMD_INSTRUCT
echo "8. Sync your sysroot with the pi device, run:">>$CMD_INSTRUCT
echo "      $CMD_SYNC">>$CMD_INSTRUCT
echo "">>$CMD_INSTRUCT
echo "9. Good luck :-), run">>$CMD_INSTRUCT
echo "      [heavy insults] > /dev/null">>$CMD_INSTRUCT
echo "">>$CMD_INSTRUCT
echo "by piano_jonas 2018">>$CMD_INSTRUCT
echo "">>$CMD_INSTRUCT

echo "Follow instructions in '$CMD_INSTRUCT'"

