GLIB_ELF_CROSS_COMPILE_DIR=/opt/gcc-riscv64-unknown-linux-gnu
GLIB_ELF_CROSS_PREFIX=$(GLIB_ELF_CROSS_COMPILE_DIR)/bin/riscv64-unknown-linux-gnu

define FIND_SRC_FILE
	$(addprefix $(1)/,$(notdir $(patsubst %.c,%.o,$(wildcard $(dir $(abspath $(lastword $(MAKEFILE_LIST))))$(1)/*.c))))
endef

ifeq ($(KERNELRELEASE), )
KERNELDIR := ../../linux-6.1.11
PWD :=$(shell pwd)
default:
	$(MAKE) -C $(KERNELDIR)  M=$(PWD) ARCH=riscv CROSS_COMPILE=$(GLIB_ELF_CROSS_PREFIX)-
clean:
	rm -rf .tmp_versions Module.symvers *.mod *.mod.c *.o *.ko .*.cmd built-in.a Module.markers modules.order .cache.mk
load:
	insmod virts.ko
unload:
	rmmod virts
install:
	cp virts.ko /lib/modules/$(shell uname -r)/kernel/drivers/virts.ko
else
	obj-m := virts.o
	virts-objs := \
		$(call FIND_SRC_FILE,.)
endif
