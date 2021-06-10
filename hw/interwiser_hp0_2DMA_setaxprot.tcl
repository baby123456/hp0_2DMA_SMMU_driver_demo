
################################################################
# This is a generated script based on design: design_1
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2019.1
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_msg_id "BD_TCL-109" "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source design_1_script.tcl

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xczu19eg-ffvc1760-2-e
   set_property BOARD_PART sugon:nf_card:part0:2.0 [current_project]
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name design_mpsoc

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_msg_id "BD_TCL-001" "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_msg_id "BD_TCL-002" "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_msg_id "BD_TCL-003" "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_msg_id "BD_TCL-004" "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_msg_id "BD_TCL-005" "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_msg_id "BD_TCL-114" "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
xilinx.com:ip:axi_crossbar:2.1\
xilinx.com:ip:axi_dma:7.1\
xilinx.com:ip:axis_data_fifo:2.0\
xilinx.com:ip:proc_sys_reset:5.0\
xilinx.com:ip:system_ila:1.1\
xilinx.com:ip:xlconcat:2.1\
xilinx.com:ip:xlconstant:1.1\
xilinx.com:ip:zynq_ultra_ps_e:3.3\
"

   set list_ips_missing ""
   common::send_msg_id "BD_TCL-006" "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_msg_id "BD_TCL-115" "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

if { $bCheckIPsPassed != 1 } {
  common::send_msg_id "BD_TCL-1003" "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports

  # Create ports

  # Create instance: axi_crossbar_0, and set properties
  set axi_crossbar_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_crossbar:2.1 axi_crossbar_0 ]
  set_property -dict [ list \
   CONFIG.ADDR_RANGES {1} \
   CONFIG.M00_A00_ADDR_WIDTH {32} \
   CONFIG.M00_A00_BASE_ADDR {0x0000000000000000} \
   CONFIG.NUM_MI {1} \
   CONFIG.NUM_SI {6} \
 ] $axi_crossbar_0

  # Create instance: axi_dma_0, and set properties
  set axi_dma_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma:7.1 axi_dma_0 ]
  set_property -dict [ list \
   CONFIG.c_addr_width {64} \
   CONFIG.c_include_mm2s_dre {1} \
   CONFIG.c_include_s2mm_dre {1} \
   CONFIG.c_m_axi_mm2s_data_width {32} \
   CONFIG.c_m_axis_mm2s_tdata_width {32} \
   CONFIG.c_mm2s_burst_size {16} \
   CONFIG.c_sg_include_stscntrl_strm {0} \
   CONFIG.c_sg_length_width {26} \
 ] $axi_dma_0

  # Create instance: axi_dma_1, and set properties
  set axi_dma_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma:7.1 axi_dma_1 ]
  set_property -dict [ list \
   CONFIG.c_addr_width {64} \
   CONFIG.c_include_mm2s_dre {1} \
   CONFIG.c_include_s2mm_dre {1} \
   CONFIG.c_m_axi_mm2s_data_width {32} \
   CONFIG.c_m_axis_mm2s_tdata_width {32} \
   CONFIG.c_mm2s_burst_size {16} \
   CONFIG.c_sg_include_stscntrl_strm {0} \
   CONFIG.c_sg_length_width {26} \
 ] $axi_dma_1

  # Create instance: axis_data_fifo_0, and set properties
  set axis_data_fifo_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 axis_data_fifo_0 ]

  # Create instance: axis_data_fifo_1, and set properties
  set axis_data_fifo_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 axis_data_fifo_1 ]

  # Create instance: ps8_0_axi_periph, and set properties
  set ps8_0_axi_periph [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 ps8_0_axi_periph ]
  set_property -dict [ list \
   CONFIG.NUM_MI {2} \
 ] $ps8_0_axi_periph

  # Create instance: rst_ps8_0_99M, and set properties
  set rst_ps8_0_99M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_ps8_0_99M ]

  # Create instance: system_ila_0, and set properties
  set system_ila_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:system_ila:1.1 system_ila_0 ]
  set_property -dict [ list \
   CONFIG.C_MON_TYPE {INTERFACE} \
   CONFIG.C_NUM_MONITOR_SLOTS {4} \
   CONFIG.C_SLOT_0_INTF_TYPE {xilinx.com:interface:axis_rtl:1.0} \
   CONFIG.C_SLOT_1_INTF_TYPE {xilinx.com:interface:axis_rtl:1.0} \
   CONFIG.C_SLOT_2_INTF_TYPE {xilinx.com:interface:axis_rtl:1.0} \
   CONFIG.C_SLOT_3_INTF_TYPE {xilinx.com:interface:axis_rtl:1.0} \
 ] $system_ila_0

  # Create instance: system_ila_1, and set properties
  set system_ila_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:system_ila:1.1 system_ila_1 ]
  set_property -dict [ list \
   CONFIG.C_MON_TYPE {INTERFACE} \
   CONFIG.C_NUM_MONITOR_SLOTS {7} \
 ] $system_ila_1

  # Create instance: xlconcat_0, and set properties
  set xlconcat_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_0 ]
  set_property -dict [ list \
   CONFIG.NUM_PORTS {4} \
 ] $xlconcat_0

  # Create instance: xlconstant_0, and set properties
  set xlconstant_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_0 ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {0x2} \
   CONFIG.CONST_WIDTH {3} \
 ] $xlconstant_0

  # Create instance: zynq_ultra_ps_e_0, and set properties
  set zynq_ultra_ps_e_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:zynq_ultra_ps_e:3.3 zynq_ultra_ps_e_0 ]
  apply_bd_automation -rule xilinx.com:bd_rule:zynq_ultra_ps_e -config {apply_board_preset "1"} $zynq_ultra_ps_e_0
  set_property -dict [ list CONFIG.PSU__USE__M_AXI_GP2 {1} \
   CONFIG.PSU__USE__S_AXI_GP2 {1} \
   CONFIG.PSU__SAXIGP2__DATA_WIDTH {32} \
   CONFIG.PSU__USE__IRQ0 {1} \
 ] $zynq_ultra_ps_e_0

  # Create interface connections
  # crossbar
  connect_bd_intf_net [get_bd_intf_pins axi_crossbar_0/M00_AXI] \
	[get_bd_intf_pins zynq_ultra_ps_e_0/S_AXI_HP0_FPD]
  # MM2S SG
  connect_bd_intf_net [get_bd_intf_pins axi_crossbar_0/S00_AXI] \
	[get_bd_intf_pins axi_dma_0/M_AXI_SG]
  connect_bd_intf_net [get_bd_intf_pins axi_crossbar_0/S01_AXI] \
	[get_bd_intf_pins axi_dma_0/M_AXI_MM2S]
  connect_bd_intf_net [get_bd_intf_pins axi_crossbar_0/S02_AXI] \
	[get_bd_intf_pins axi_dma_0/M_AXI_S2MM]
  
  connect_bd_intf_net [get_bd_intf_pins axi_crossbar_0/S03_AXI] \
	[get_bd_intf_pins axi_dma_1/M_AXI_SG]
  connect_bd_intf_net [get_bd_intf_pins axi_crossbar_0/S04_AXI] \
	[get_bd_intf_pins axi_dma_1/M_AXI_MM2S]
  connect_bd_intf_net [get_bd_intf_pins axi_crossbar_0/S05_AXI] \
	[get_bd_intf_pins axi_dma_1/M_AXI_S2MM]

  # FIFO0
  connect_bd_intf_net [get_bd_intf_pins axi_dma_0/M_AXIS_MM2S] \
	[get_bd_intf_pins axis_data_fifo_0/S_AXIS]
  connect_bd_intf_net [get_bd_intf_pins axi_dma_0/S_AXIS_S2MM] \
	[get_bd_intf_pins axis_data_fifo_0/M_AXIS]
  #fifo1
  connect_bd_intf_net [get_bd_intf_pins axi_dma_1/M_AXIS_MM2S] \
	[get_bd_intf_pins axis_data_fifo_1/S_AXIS]
  connect_bd_intf_net [get_bd_intf_pins axi_dma_1/S_AXIS_S2MM] \
	[get_bd_intf_pins axis_data_fifo_1/M_AXIS]
   
    #ic dma0 dma1 HPM0
    connect_bd_intf_net [get_bd_intf_pins axi_dma_0/S_AXI_LITE] \
	[get_bd_intf_pins ps8_0_axi_periph/M00_AXI]
    connect_bd_intf_net [get_bd_intf_pins axi_dma_1/S_AXI_LITE] \
	[get_bd_intf_pins ps8_0_axi_periph/M01_AXI]
    connect_bd_intf_net [get_bd_intf_pins ps8_0_axi_periph/S00_AXI] \
	[get_bd_intf_pins zynq_ultra_ps_e_0/M_AXI_HPM0_LPD]

   # axi ila 
   # ila0
   connect_bd_intf_net [get_bd_intf_pins system_ila_0/SLOT_0_AXIS] \
	[get_bd_intf_pins axi_dma_0/M_AXIS_MM2S] 
   connect_bd_intf_net [get_bd_intf_pins system_ila_0/SLOT_1_AXIS]\
	[get_bd_intf_pins axis_data_fifo_0/M_AXIS] 
   connect_bd_intf_net [get_bd_intf_pins system_ila_0/SLOT_2_AXIS]\
	[get_bd_intf_pins axi_dma_1/M_AXIS_MM2S] 
   connect_bd_intf_net [get_bd_intf_pins system_ila_0/SLOT_3_AXIS]\
	[get_bd_intf_pins axis_data_fifo_1/M_AXIS] 
  
   # ila1
   connect_bd_intf_net [get_bd_intf_pins system_ila_1/SLOT_0_AXI] \
	[get_bd_intf_pins axi_dma_0/M_AXI_SG] 
   connect_bd_intf_net [get_bd_intf_pins system_ila_1/SLOT_1_AXI] \
	[get_bd_intf_pins axi_dma_0/M_AXI_MM2S] 
   connect_bd_intf_net [get_bd_intf_pins system_ila_1/SLOT_2_AXI] \
	[get_bd_intf_pins axi_dma_0/M_AXI_S2MM] 
   connect_bd_intf_net [get_bd_intf_pins system_ila_1/SLOT_3_AXI] \
	[get_bd_intf_pins axi_crossbar_0/M00_AXI] 
   connect_bd_intf_net [get_bd_intf_pins system_ila_1/SLOT_4_AXI] \
	[get_bd_intf_pins axi_dma_1/M_AXI_SG] 
   connect_bd_intf_net [get_bd_intf_pins system_ila_1/SLOT_5_AXI] \
	[get_bd_intf_pins axi_dma_1/M_AXI_MM2S] 
   connect_bd_intf_net [get_bd_intf_pins system_ila_1/SLOT_6_AXI] \
	[get_bd_intf_pins axi_dma_1/M_AXI_S2MM] 

  # Create port connections
  connect_bd_net [get_bd_pins axi_dma_0/mm2s_introut] \
	[get_bd_pins xlconcat_0/In0]
  connect_bd_net [get_bd_pins axi_dma_0/s2mm_introut] \
	[get_bd_pins xlconcat_0/In1]
  connect_bd_net [get_bd_pins axi_dma_1/mm2s_introut] \
	[get_bd_pins xlconcat_0/In2]
  connect_bd_net [get_bd_pins axi_dma_1/s2mm_introut] \
	[get_bd_pins xlconcat_0/In3]
  
  #rst	
  connect_bd_net [get_bd_pins axi_crossbar_0/aresetn] \
	[get_bd_pins axi_dma_0/axi_resetn] \
	[get_bd_pins axi_dma_1/axi_resetn] \
	[get_bd_pins axis_data_fifo_0/s_axis_aresetn] \
	[get_bd_pins axis_data_fifo_1/s_axis_aresetn] \
	[get_bd_pins ps8_0_axi_periph/ARESETN] \
	[get_bd_pins ps8_0_axi_periph/M00_ARESETN] \
	[get_bd_pins ps8_0_axi_periph/M01_ARESETN] \
	[get_bd_pins ps8_0_axi_periph/S00_ARESETN] \
	[get_bd_pins rst_ps8_0_99M/peripheral_aresetn] \
	[get_bd_pins system_ila_0/resetn] \
	[get_bd_pins system_ila_1/resetn]
  
  #irq
  connect_bd_net [get_bd_pins xlconcat_0/dout] \
	[get_bd_pins zynq_ultra_ps_e_0/pl_ps_irq0]
  
  #awprot arprot to 0x2 
  connect_bd_net [get_bd_pins xlconstant_0/dout] \
	[get_bd_pins zynq_ultra_ps_e_0/saxigp2_arprot] \
	[get_bd_pins zynq_ultra_ps_e_0/saxigp2_awprot]
  
  #clk 
  connect_bd_net [get_bd_pins axi_crossbar_0/aclk] \
	[get_bd_pins axi_dma_0/m_axi_mm2s_aclk] \
	[get_bd_pins axi_dma_0/m_axi_s2mm_aclk] \
	[get_bd_pins axi_dma_0/m_axi_sg_aclk] \
	[get_bd_pins axi_dma_0/s_axi_lite_aclk] \
	[get_bd_pins axi_dma_1/m_axi_mm2s_aclk] \
	[get_bd_pins axi_dma_1/m_axi_s2mm_aclk] \
	[get_bd_pins axi_dma_1/m_axi_sg_aclk] \
	[get_bd_pins axi_dma_1/s_axi_lite_aclk] \
	[get_bd_pins axis_data_fifo_0/s_axis_aclk] \
	[get_bd_pins axis_data_fifo_1/s_axis_aclk] \
	[get_bd_pins ps8_0_axi_periph/ACLK] \
	[get_bd_pins ps8_0_axi_periph/M00_ACLK] \
	[get_bd_pins ps8_0_axi_periph/M01_ACLK] \
	[get_bd_pins ps8_0_axi_periph/S00_ACLK] \
	[get_bd_pins rst_ps8_0_99M/slowest_sync_clk] \
	[get_bd_pins system_ila_0/clk] \
	[get_bd_pins system_ila_1/clk] \
	[get_bd_pins zynq_ultra_ps_e_0/maxihpm0_lpd_aclk] \
	[get_bd_pins zynq_ultra_ps_e_0/pl_clk0] \
	[get_bd_pins zynq_ultra_ps_e_0/saxihp0_fpd_aclk]
  
   connect_bd_net [get_bd_pins rst_ps8_0_99M/ext_reset_in] \
	[get_bd_pins zynq_ultra_ps_e_0/pl_resetn0]

  # Create address segments
  #dma0 sg
  create_bd_addr_seg -range 0x80000000 -offset 0x0 [get_bd_addr_spaces axi_dma_0/Data_SG] [get_bd_addr_segs zynq_ultra_ps_e_0/SAXIGP2/HP0_DDR_LOW] HP0_DDR_LOW
  #dma0 MM2S 
  create_bd_addr_seg -range 0x80000000 -offset 0x0 [get_bd_addr_spaces axi_dma_0/Data_MM2S] [get_bd_addr_segs zynq_ultra_ps_e_0/SAXIGP2/HP0_DDR_LOW] HP0_DDR_LOW
  #dma0 S2MM
  create_bd_addr_seg -range 0x80000000 -offset 0x0 [get_bd_addr_spaces axi_dma_0/Data_S2MM] [get_bd_addr_segs zynq_ultra_ps_e_0/SAXIGP2/HP0_DDR_LOW] HP0_DDR_LOW
  # dma1 sg
  create_bd_addr_seg -range 0x80000000 -offset 0x0 [get_bd_addr_spaces axi_dma_1/Data_SG] [get_bd_addr_segs zynq_ultra_ps_e_0/SAXIGP2/HP0_DDR_LOW] HP0_DDR_LOW
  #dma1 mm2s
  create_bd_addr_seg -range 0x80000000 -offset 0x00000000 [get_bd_addr_spaces axi_dma_1/Data_MM2S] [get_bd_addr_segs zynq_ultra_ps_e_0/SAXIGP2/HP0_DDR_LOW] HP0_DDR_LOW
  #dma1 s2mm
  create_bd_addr_seg -range 0x80000000 -offset 0x00000000 [get_bd_addr_spaces axi_dma_1/Data_S2MM] [get_bd_addr_segs zynq_ultra_ps_e_0/SAXIGP2/HP0_DDR_LOW] HP0_DDR_LOW

  # DMA0 DMA1 axi lite 
  create_bd_addr_seg -range 0x00001000 -offset 0x80000000 [get_bd_addr_spaces zynq_ultra_ps_e_0/Data] [get_bd_addr_segs axi_dma_0/S_AXI_LITE/Reg] SEG_axi_dma_0_Reg
  create_bd_addr_seg -range 0x00001000 -offset 0x80001000 [get_bd_addr_spaces zynq_ultra_ps_e_0/Data] [get_bd_addr_segs axi_dma_1/S_AXI_LITE/Reg] SEG_axi_dma_1_Reg

  # Exclude Address Segment

  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


