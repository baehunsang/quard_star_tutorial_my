SHELL_FOLDER=$(cd "$(dirname "$0")";pwd)

CROSS_PREFIX=/home/hunsang/qemu2/riscv64-lp64d--glibc--stable-2024.05-1/bin/riscv64-buildroot-linux-gnu
CROSS_COMPILE_DIR=/home/hunsang/qemu2/riscv64-lp64d--glibc--stable-2024.05-1

# Loader (BL1)
if [ ! -d "$SHELL_FOLDER/output/lowlevelboot" ]; then  
mkdir $SHELL_FOLDER/output/lowlevelboot
fi  
cd $SHELL_FOLDER/lowlevelboot
$CROSS_PREFIX-gcc -fno-pic -x assembler-with-cpp -c startup.s -o $SHELL_FOLDER/output/lowlevelboot/startup.o
$CROSS_PREFIX-gcc -nostartfiles -T./boot.lds -Wl,-Map=$SHELL_FOLDER/output/lowlevelboot/lowlevel_fw.map -Wl,--gc-sections $SHELL_FOLDER/output/lowlevelboot/startup.o -o $SHELL_FOLDER/output/lowlevelboot/lowlevel_fw.elf
$CROSS_PREFIX-objcopy -O binary -S $SHELL_FOLDER/output/lowlevelboot/lowlevel_fw.elf $SHELL_FOLDER/output/lowlevelboot/lowlevel_fw.bin
$CROSS_PREFIX-objdump --source --demangle --disassemble --reloc --wide $SHELL_FOLDER/output/lowlevelboot/lowlevel_fw.elf > $SHELL_FOLDER/output/lowlevelboot/lowlevel_fw.lst

# Open SBI already built in ch5
if [ ! -d "$SHELL_FOLDER/output/opensbi" ]; then  
mkdir $SHELL_FOLDER/output/opensbi
fi  
cd $SHELL_FOLDER/opensbi-0.9
make CROSS_COMPILE=$CROSS_PREFIX- PLATFORM=quard_star
cp -r $SHELL_FOLDER/opensbi-0.9/build/platform/quard_star/firmware/fw_jump.bin $SHELL_FOLDER/output/opensbi/fw_jump.bin
cp -r $SHELL_FOLDER/opensbi-0.9/build/platform/quard_star/firmware/fw_jump.elf $SHELL_FOLDER/output/opensbi/fw_jump.elf
$CROSS_PREFIX-objdump --source --demangle --disassemble --reloc --wide $SHELL_FOLDER/output/opensbi/fw_jump.elf > $SHELL_FOLDER/output/opensbi/fw_jump.lst


#Build DTS to DTB
cd $SHELL_FOLDER/dts
dtc -I dts -O dtb -o $SHELL_FOLDER/output/opensbi/quard_star_sbi.dtb quard_star_sbi.dts

# build trusted_domain fw
if [ ! -d "$SHELL_FOLDER/output/trusted_domain" ]; then  
mkdir $SHELL_FOLDER/output/trusted_domain
fi  
cd $SHELL_FOLDER/trusted_domain
$CROSS_PREFIX-gcc -x assembler-with-cpp -c startup.s -o $SHELL_FOLDER/output/trusted_domain/startup.o
$CROSS_PREFIX-gcc -nostartfiles -T./link.lds -Wl,-Map=$SHELL_FOLDER/output/trusted_domain/trusted_fw.map -Wl,--gc-sections $SHELL_FOLDER/output/trusted_domain/startup.o -o $SHELL_FOLDER/output/trusted_domain/trusted_fw.elf
$CROSS_PREFIX-objcopy -O binary -S $SHELL_FOLDER/output/trusted_domain/trusted_fw.elf $SHELL_FOLDER/output/trusted_domain/trusted_fw.bin
$CROSS_PREFIX-objdump --source --demangle --disassemble --reloc --wide $SHELL_FOLDER/output/trusted_domain/trusted_fw.elf > $SHELL_FOLDER/output/trusted_domain/trusted_fw.lst


# Compile uboot
if [ ! -d "$SHELL_FOLDER/output/uboot" ]; then  
mkdir $SHELL_FOLDER/output/uboot
fi  
cd $SHELL_FOLDER/u-boot-2021.07
make CROSS_COMPILE=$CROSS_PREFIX- qemu-quard-star_defconfig
make CROSS_COMPILE=$CROSS_PREFIX- -j16
cp $SHELL_FOLDER/u-boot-2021.07/u-boot $SHELL_FOLDER/output/uboot/u-boot.elf
cp $SHELL_FOLDER/u-boot-2021.07/u-boot.map $SHELL_FOLDER/output/uboot/u-boot.map
cp $SHELL_FOLDER/u-boot-2021.07/u-boot.bin $SHELL_FOLDER/output/uboot/u-boot.bin
$CROSS_PREFIX-objdump --source --demangle --disassemble --reloc --wide $SHELL_FOLDER/output/uboot/u-boot.elf > $SHELL_FOLDER/output/uboot/u-boot.lst
# compile uboot.dtb
cd $SHELL_FOLDER/dts
dtc -I dts -O dtb -o $SHELL_FOLDER/output/uboot/quard_star_uboot.dtb quard_star_uboot.dts

# build busybox
if [ ! -d "$SHELL_FOLDER/output/busybox" ]; then  
mkdir $SHELL_FOLDER/output/busybox
cd $SHELL_FOLDER/busybox-1.33.1
#make ARCH=riscv CROSS_COMPILE=$CROSS_PREFIX- quard_star_defconfig
make ARCH=riscv CROSS_COMPILE=$CROSS_PREFIX- -j16
make ARCH=riscv CROSS_COMPILE=$CROSS_PREFIX- install
fi  




# Build linux (IF already built linux, disable this)
if [ ! -d "$SHELL_FOLDER/output/linux_kernel" ]; then  
mkdir $SHELL_FOLDER/output/linux_kernel
cd $SHELL_FOLDER/linux-5.10.42
#make ARCH=riscv CROSS_COMPILE=$CROSS_PREFIX- defconfig
make ARCH=riscv CROSS_COMPILE=$CROSS_PREFIX- -j16
cp $SHELL_FOLDER/linux-5.10.42/arch/riscv/boot/Image $SHELL_FOLDER/output/linux_kernel/Image
fi

# gemerate rootfs
if [ ! -d "$SHELL_FOLDER/output/rootfs" ]; then  
mkdir $SHELL_FOLDER/output/rootfs
fi 
if [ ! -d "$SHELL_FOLDER/output/rootfs/rootfs" ]; then  
mkdir $SHELL_FOLDER/output/rootfs/rootfs
fi
if [ ! -d "$SHELL_FOLDER/output/rootfs/bootfs" ]; then  
mkdir $SHELL_FOLDER/output/rootfs/bootfs
fi
cd $SHELL_FOLDER/output/rootfs
if [ ! -f "$SHELL_FOLDER/output/rootfs/rootfs.img" ]; then  
dd if=/dev/zero of=rootfs.img bs=1M count=1024
sudo $SHELL_FOLDER/build_rootfs/generate_rootfs.sh $SHELL_FOLDER/output/rootfs/rootfs.img $SHELL_FOLDER/build_rootfs/sfdisk
fi
cp $SHELL_FOLDER/output/linux_kernel/Image $SHELL_FOLDER/output/rootfs/bootfs/Image
cp $SHELL_FOLDER/output/uboot/quard_star_uboot.dtb $SHELL_FOLDER/output/rootfs/bootfs/quard_star.dtb
cp -r $SHELL_FOLDER/output/busybox/* $SHELL_FOLDER/output/rootfs/rootfs/
cp -r $SHELL_FOLDER/target_root_script/* $SHELL_FOLDER/output/rootfs/rootfs/
cp $SHELL_FOLDER/bash-5.2.37/output/bin/bash $SHELL_FOLDER/output/rootfs/rootfs/bin/
chmod +777 $SHELL_FOLDER/output/rootfs/rootfs/bin/bash
mkdir $SHELL_FOLDER/output/rootfs/rootfs/lib
ln -s ./lib ./lib64
cp -r $CROSS_COMPILE_DIR/riscv64-buildroot-linux-gnu/sysroot/lib/* $SHELL_FOLDER/output/rootfs/rootfs/lib
cp $CROSS_COMPILE_DIR/riscv64-buildroot-linux-gnu/sysroot/usr/bin/* $SHELL_FOLDER/output/rootfs/rootfs/usr/bin
cp $SHELL_FOLDER/screenfetch-dev $SHELL_FOLDER/output/rootfs/rootfs/usr/bin
mkdir $SHELL_FOLDER/output/rootfs/rootfs/proc
mkdir $SHELL_FOLDER/output/rootfs/rootfs/sys
mkdir $SHELL_FOLDER/output/rootfs/rootfs/dev
mkdir $SHELL_FOLDER/output/rootfs/rootfs/tmp
$SHELL_FOLDER/u-boot-2021.07/tools/mkimage -A riscv -O linux -T script -C none -a 0 -e 0 -n "Distro Boot Script" -d $SHELL_FOLDER/dts/quard_star_uboot.cmd $SHELL_FOLDER/output/rootfs/bootfs/boot.scr
sudo $SHELL_FOLDER/build_rootfs/build.sh $SHELL_FOLDER/output/rootfs




# Build firmware
if [ ! -d "$SHELL_FOLDER/output/fw" ]; then
mkdir $SHELL_FOLDER/output/fw
fi
cd $SHELL_FOLDER/output/fw
rm -rf fw.bin
dd of=fw.bin bs=1k count=32k if=/dev/zero
dd of=fw.bin bs=1k conv=notrunc seek=0 if=$SHELL_FOLDER/output/lowlevelboot/lowlevel_fw.bin
dd of=fw.bin bs=1k conv=notrunc seek=512 if=$SHELL_FOLDER/output/opensbi/quard_star_sbi.dtb
dd of=fw.bin bs=1k conv=notrunc seek=1K if=$SHELL_FOLDER/output/uboot/quard_star_uboot.dtb
dd of=fw.bin bs=1k conv=notrunc seek=2K if=$SHELL_FOLDER/output/opensbi/fw_jump.bin
dd of=fw.bin bs=1k conv=notrunc seek=4K if=$SHELL_FOLDER/output/trusted_domain/trusted_fw.bin
dd of=fw.bin bs=1k conv=notrunc seek=8K if=$SHELL_FOLDER/output/uboot/u-boot.bin
cd $SHELL_FOLDER