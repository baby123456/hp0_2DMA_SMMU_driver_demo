# hp0_2DMA_SMMU_driver_demo

## introduction
* This is a demo to show how to use ARM SMMU in VM with DMA driver in SG mode. 
* There are 2 AXI DMAs which passthrough to corresponding KVM VM respectively , and DMA driver can be used to do loop test in corresponding VM simultaneously.

## hw
* Support interwiser and nf board
* Two AXI DMAs connect to zynq MPSOC HP0 via crossbar
* AxPROT signals of HP0 with a value of 0x2 being non-privileged, non-secure, and data

## pl_dtsi
* Support interwiser and nf board
* enable `smmu`, add two AXI DMA node with `iommus` property , add proxy_dma driver node with `iommus` property
* HOST dtb set `uncache`, that is **not** set `dma-coherent` in axi-dma dtb node

## HOST Image
* xilinx-v2020.1-dev, *815443a5bcaba7c75831da7ddba2d8c67ea6343a*
### driver prerequisites
* KVM kernel module
* SMMUv2 driver
* vfio-platform driver
* AXI DMA driver compitable for both HOST and VM
* AXI DMA `passthrough reset driver`

## passthrough
* Load the `VFIO platform driver`, unbind the existing DMA driver and start the VFIO platform driver for the AXI DMA hardware which was connected to the HP0 port of MPSOC.

## vm-start
### Qemu
* v4.2.0-dev, *592608a8256fb7d1d16e2ef3c5d2c7267e80cf99*
* AXI DMA passthrough model based on vfio-platform abstract device model
* set `uncache`, that is **not** set `dma-coherent` in axi-dma dtb node
### vm*_start.sh
* Each VM passthrough with an AXI DMA device
### VM Image
* xilinx-v2020.1-dev，*815443a5bcaba7c75831da7ddba2d8c67ea6343a*
* AXI DMA driver compitable for both HOST and VM

## driver/dma-proxy
* compitable for both HOST and VM
* set `internal_test = 1` to do DMA loop test while insmod dma-proxy driver
* user mode DMA loop test: `./dma-proxy-test <# of DMA transfers to perform> <# of bytes in each transfer (< 3MB)`

## other issues
* As for nf using 5.4.0+ version Linux, execute `mw 0xff180408 0xff` in uboot command to avoid issues for NIC being added to SMMU
* If encounter other issues with SDHCI and NIC, one can attempt to comment the `iommus` property of related SDHIC or NIC
