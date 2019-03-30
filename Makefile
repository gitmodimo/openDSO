XILINX_INSTALL_PATH=/mnt/data/Xilinx/SDK/2018.3/
XILINX_PATH=$(XILINX_INSTALL_PATH)gnu/aarch32/lin/gcc-arm-linux-gnueabi/bin/
MKIMAGE_PATH=$(PWD)/u-boot-xlnx/tools/
DTC_PATH=$(PWD)/u-boot-xlnx/scripts/dtc/
PATHS=$(XILINX_PATH):$(MKIMAGE_PATH):$(DTC_PATH):$(PATH)
CROSS_COMPILE=arm-linux-gnueabihf-
ARCH=arm 
UIMAGE_LOADADDR=0x8000

.PHONY: buildroot

all: boot_image

boot_image: buildroot dtb linux uboot
	PATH=$(PATHS) mkimage -f image.its image.itb

linux_defconfig: linux-xlnx/.config

linux-xlnx/.config:
	PATH=$(PATHS) CROSS_COMPILE=$(CROSS_COMPILE) make -C ./linux-xlnx/ ARCH=$(ARCH) xilinx_zynq_defconfig
	
linux_menuconfig: 
	PATH=$(PATHS) CROSS_COMPILE=$(CROSS_COMPILE) make -C ./linux-xlnx/ ARCH=$(ARCH) menuconfig
	
linux: linux-xlnx/.config
	PATH=$(PATHS) CROSS_COMPILE=$(CROSS_COMPILE) make -C ./linux-xlnx/ ARCH=$(ARCH) UIMAGE_LOADADDR=$(UIMAGE_LOADADDR) uImage

	
u-boot-xlnx/.config:
	PATH=$(PATHS) CROSS_COMPILE=$(CROSS_COMPILE) make distclean -C ./u-boot-xlnx/
	PATH=$(PATHS) CROSS_COMPILE=$(CROSS_COMPILE) make zynq_zed_config -C ./u-boot-xlnx/
	
	
uboot: u-boot-xlnx/.config buildroot
	PATH=$(PATHS) CROSS_COMPILE=$(CROSS_COMPILE) make -C ./u-boot-xlnx/
	
dtb:
	PATH=$(PATHS) $(DTC_PATH)/dtc -I dts -O dtb -o ./dt.dtb ./linux-xlnx/arch/arm/boot/dts/zynq-microzed.dts

	
buildroot_source:
	PATH=$(PATHS) CROSS_COMPILE=$(CROSS_COMPILE) make -C ./buildroot/ source
	
buildroot/.config:
	PATH=$(PATHS) CROSS_COMPILE=$(CROSS_COMPILE) BR2_DEFCONFIG=../configs/buildroot_openDSO_defconfig make -C ./buildroot/ defconfig
	
buildroot_menuconfig: 
	PATH=$(PATHS) CROSS_COMPILE=$(CROSS_COMPILE) BR2_DEFCONFIG=../configs/buildroot_openDSO_defconfig make -C ./buildroot/ menuconfig
	
	
buildroot: buildroot/.config
	PATH=$(PATHS) CROSS_COMPILE=$(CROSS_COMPILE) BR2_DEFCONFIG=../configs/buildroot_openDSO_defconfig make -C ./buildroot/ 
	
	

#git clone --depth 1 --recurse-submodules --shallow-submodules -j3 https://github.com/gitmodimo/openDSO.git
#cd openDSO
#make all

# mmc dev 1 && fatload mmc 1 0x10000000 image.itb && bootm 0x10000000
