echo 80001000.dma > /sys/bus/platform/drivers/xilinx-vdma/unbind
echo vfio-platform > /sys/bus/platform/devices/80001000.dma/driver_override
echo 80001000.dma > /sys/bus/platform/drivers_probe
