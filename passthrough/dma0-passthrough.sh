echo 80000000.dma > /sys/bus/platform/drivers/xilinx-vdma/unbind
echo vfio-platform > /sys/bus/platform/devices/80000000.dma/driver_override
echo 80000000.dma > /sys/bus/platform/drivers_probe
