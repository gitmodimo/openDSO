XILINX_INSTALL_PATH=/mnt/data/Xilinx/SDK/2018.3/
XILINX_PATH=$(XILINX_INSTALL_PATH)gnu/aarch32/lin/gcc-arm-linux-gnueabi/bin/
MKIMAGE_PATH=$(PWD)/u-boot-xlnx/tools/
PATHS=$(XILINX_PATH):$(MKIMAGE_PATH):$(PATH)
CROSS_COMPILE=arm-linux-gnueabihf-
ARCH=arm 
UIMAGE_LOADADDR=0x8000

all: linux uboot

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
	
	
uboot: u-boot-xlnx/.config
	PATH=$(PATHS) CROSS_COMPILE=$(CROSS_COMPILE) make -C ./u-boot-xlnx/
	
test:
	PATH=$(PATHS) mkimage
