SHELL_FOLDER=$(cd "$(dirname "$0")";pwd)
CROSS_PREFIX=/opt/riscv64--glibc--bleeding-edge-2020.08-1/bin/riscv64-linux

cd $SHELL_FOLDER/qemu-6.0.0
if [ ! -d "$SHELL_FOLDER/output/qemu" ]; then  
./configure --prefix=$SHELL_FOLDER/output/qemu  --target-list=riscv64-softmmu --enable-gtk  --enable-virtfs --disable-gio
fi  
make -j16
make install
