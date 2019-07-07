XILINX_INSTALL_PATH=/mnt/data/Xilinx/SDK/2018.3/
XILINX_PATH=$(XILINX_INSTALL_PATH)gnu/aarch32/lin/gcc-arm-linux-gnueabi/bin/
XILINX_PATH_BIN=$(XILINX_INSTALL_PATH)/bin/
MKIMAGE_PATH=$(PWD)/u-boot-xlnx/tools/
DTC_PATH=$(PWD)/u-boot-xlnx/scripts/dtc/
PATHS=$(XILINX_PATH):$(XILINX_PATH_BIN):$(MKIMAGE_PATH):$(DTC_PATH):$(PATH)
CROSS_COMPILE=arm-linux-gnueabihf-
ARCH=arm 
UIMAGE_LOADADDR=0x8000

.PHONY: buildroot fsbl

all: images
	cp -f IMAGE/boot.bin SD/boot.bin
	cp -f IMAGE/image.itb SD/image.itb

linux_defconfig: linux-xlnx/.config

linux-xlnx/.config:
	PATH=$(PATHS) CROSS_COMPILE=$(CROSS_COMPILE) make -C ./linux-xlnx/ ARCH=$(ARCH) xilinx_zynq_defconfig
	
linux_menuconfig: 
	PATH=$(PATHS) CROSS_COMPILE=$(CROSS_COMPILE) make -C ./linux-xlnx/ ARCH=$(ARCH) menuconfig
	
linux: linux-xlnx/.config
	PATH=$(PATHS) CROSS_COMPILE=$(CROSS_COMPILE) make -C ./linux-xlnx/ ARCH=$(ARCH) UIMAGE_LOADADDR=$(UIMAGE_LOADADDR) uImage
	PATH=$(PATHS) CROSS_COMPILE=$(CROSS_COMPILE) make -C ./linux-xlnx/ ARCH=$(ARCH) modules
	PATH=$(PATHS) CROSS_COMPILE=$(CROSS_COMPILE) make -C ./linux-xlnx/ ARCH=$(ARCH) INSTALL_MOD_PATH=../buildroot/overlay/ modules_install
	

	
u-boot-xlnx/.config: configs/uboot_zynq_z_turn_defconfig
	PATH=$(PATHS) CROSS_COMPILE=$(CROSS_COMPILE) make distclean -C ./u-boot-xlnx/
	PATH=$(PATHS) CROSS_COMPILE=$(CROSS_COMPILE) make ../../configs/uboot_zynq_z_turn_defconfig -C ./u-boot-xlnx/
	
	
uboot: u-boot-xlnx/.config buildroot
	PATH=$(PATHS) CROSS_COMPILE=$(CROSS_COMPILE) make -C ./u-boot-xlnx/
	
		
uboot_menuconfig:
	PATH=$(PATHS) CROSS_COMPILE=$(CROSS_COMPILE) make -C ./u-boot-xlnx/ menuconfig
	
uboot_savedefconfig:	
	PATH=$(PATHS) CROSS_COMPILE=$(CROSS_COMPILE) make -C ./u-boot-xlnx/ savedefconfig
	cp ./u-boot-xlnx/defconfig configs/uboot_zynq_z_turn_defconfig
	
dt.dtb: uboot
	PATH=$(PATHS):$(DTC_PATH) make -C ./DT/

	
buildroot_source:
	PATH=$(PATHS) CROSS_COMPILE=$(CROSS_COMPILE) make -C ./buildroot/ source
	
buildroot/.config: configs/buildroot_openDSO_defconfig
	PATH=$(PATHS) CROSS_COMPILE=$(CROSS_COMPILE) BR2_DEFCONFIG=../configs/buildroot_openDSO_defconfig make -C ./buildroot/ defconfig
	
buildroot_savedefconfig:	
	PATH=$(PATHS) CROSS_COMPILE=$(CROSS_COMPILE) BR2_DEFCONFIG=../configs/buildroot_openDSO_defconfig make -C ./buildroot/ savedefconfig
	
buildroot_menuconfig: 
	PATH=$(PATHS) CROSS_COMPILE=$(CROSS_COMPILE) BR2_DEFCONFIG=../configs/buildroot_openDSO_defconfig make -C ./buildroot/ menuconfig
	
	
buildroot: buildroot/.config
	PATH=$(PATHS) CROSS_COMPILE=$(CROSS_COMPILE) BR2_DEFCONFIG=../configs/buildroot_openDSO_defconfig make -C ./buildroot/ 
	
	
fsbl:
	PATH=$(PATHS) CROSS_COMPILE=$(CROSS_COMPILE) make -C ./FSBL/

images: linux fsbl uboot buildroot dt.dtb  
	PATH=$(PATHS) CROSS_COMPILE=$(CROSS_COMPILE) make -C ./IMAGE/
#git clone --depth 1 --recurse-submodules --shallow-submodules -j3 https://github.com/gitmodimo/openDSO.git
#cd openDSO
#make all

# fatload mmc 0 0x1000000 top_wrapper.bit; fpga loadb 0 0x1000000 2083850
# mmc dev 0 && fatload mmc 0 0x10000000 image.itb && bootm 0x10000000

bootcmd:
	setenv serverip 192.168.137.1;setenv ipaddr 192.168.137.10;
	tftpboot 0x1000000 top_wrapper.bit; fpga loadb 0 0x1000000 2083850;tftpboot 0x10000000 image.itb && bootm 0x10000000

	fatload mmc 0 0x1000000 top_wrapper.bit; fpga loadb 0 0x1000000 2083850;fatload mmc 0 0x10000000 image.itb && bootm 0x10000000
	mw 0xF8000008  0xDF0D
	mw F8000240 1
	md F8000240 
	md 41200000 



