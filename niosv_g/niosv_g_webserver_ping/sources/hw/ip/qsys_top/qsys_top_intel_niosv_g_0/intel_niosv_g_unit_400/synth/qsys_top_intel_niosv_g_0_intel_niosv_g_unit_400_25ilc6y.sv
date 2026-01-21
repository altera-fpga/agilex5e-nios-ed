// (C) 2001-2025 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files from any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera IP License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


`timescale 1 ns / 1 ns

module qsys_top_intel_niosv_g_0_intel_niosv_g_unit_400_25ilc6y 
   import niosv_opcode_def::*;
# (
   parameter DBG_EXPN_VECTOR          = 32'h80000000,
   parameter RESET_VECTOR             = 32'h00000000,
   parameter CORE_EXTN                = 26'h0000100, // RV32I
   parameter HARTID                   = 32'h00000000,
   parameter DISABLE_FSQRT_FDIV       = 1'b0,
   parameter DEBUG_ENABLED            = 1'b0,
   parameter DEVICE_FAMILY            = "Stratix 10",
   parameter DBG_PARK_LOOP_OFFSET     = 32'd24,
   parameter USE_RESET_REQ            = 1'b0,
   parameter DBG_DATA_S_BASE          = 32'h000A0000,
   parameter TIMER_MSIP_DATA_S_BASE   = 32'h000B0000,
   parameter DATA_CACHE_SIZE          = 4096,
   parameter INST_CACHE_SIZE          = 4096,
   parameter ITCM1_SIZE               = 0,
   parameter ITCM1_BASE               = 32'h0,
   parameter ITCM1_INIT_FILE          = "UNUSED",
   parameter ITCM2_SIZE               = 0,
   parameter ITCM2_BASE               = 32'h0,
   parameter ITCM2_INIT_FILE          = "UNUSED",
   parameter PERIPHERAL_REGION_A_SIZE = 0,
   parameter PERIPHERAL_REGION_A_BASE = 32'h0,
   parameter PERIPHERAL_REGION_B_SIZE = 0,
   parameter PERIPHERAL_REGION_B_BASE = 32'h0,
   parameter DTCM1_SIZE               = 0,
   parameter DTCM1_BASE               = 32'h0,
   parameter DTCM1_INIT_FILE          = "UNUSED",
   parameter DTCM2_SIZE               = 0,
   parameter DTCM2_BASE               = 32'h0,
   parameter DTCM2_INIT_FILE          = "UNUSED",
   parameter ECC_EN                   = 1'b0,
   parameter ECC_FULL                 = 1'b0,
   parameter BRANCHPREDICTION_EN      = 1'b1,
   parameter ITCS1_ADDR_WIDTH         = 4'd10,
   parameter ITCS2_ADDR_WIDTH         = 4'd10,
   parameter DTCS1_ADDR_WIDTH         = 4'd10,
   parameter DTCS2_ADDR_WIDTH         = 4'd10,
   parameter NUM_PLATFORM_INTERRUPTS  = 16,
   parameter NUM_SRF_BANKS            = 2,
   parameter CLIC_EN                  = 0,
   parameter CLIC_NUM_LEVELS          = 1,
   parameter CLIC_NUM_PRIORITIES      = 8,
   parameter CLIC_NUM_DEBUG_TRIGGERS  = 0,
   parameter CLIC_TRIGGER_POLARITY_EN = 0,
   parameter CLIC_EDGE_TRIGGER_EN     = 0,
   parameter CLIC_VT_ALIGN            = 8,
   parameter CLIC_SHV_EN              = 0,
   parameter BLIND_WINDOW_PERIOD      = 1000,
   parameter DEFAULT_TIMEOUT_PERIOD   = 255,
   parameter REMOVE_TIME_DIVERSITY    = 0,   
   parameter DCLS_EXTRST_IF_ACTIVE    = 0,
   // this would be a localparam if Quartus Standard supported the necessary syntax
   parameter PLAT_IRQ_VEC_W = (NUM_PLATFORM_INTERRUPTS < 1) ? 1 : NUM_PLATFORM_INTERRUPTS
) (

   input  wire                       clk,
   input  wire                       reset,
   input  wire                       reset_req,
   output wire                       reset_req_ack,

   // write command
   //    address
   output wire [31:0]                instr_awaddr,
   output wire [2:0]                 instr_awprot,
   output wire                       instr_awvalid,
   input                             instr_awready,
   output wire [2:0]                 instr_awsize,
   output wire [7:0]                 instr_awlen,
   output wire [1:0]                 instr_awburst,

   //  data
   output wire                       instr_wvalid,
   output wire [31:0]                instr_wdata,
   output wire [3:0]                 instr_wstrb,
   input                             instr_wready,
   output wire                       instr_wlast,

   //write response
   input                             instr_bvalid,
   input [1:0]                       instr_bresp,
   output wire                       instr_bready,

   //read command
   output wire [31:0]                instr_araddr,
   output wire [2:0]                 instr_arprot,
   output wire                       instr_arvalid,
   input                             instr_arready,
   output wire [2:0]                 instr_arsize,
   output wire [7:0]                 instr_arlen,
   output wire [1:0]                 instr_arburst,

   //read response
   input [31:0]                      instr_rdata,
   input                             instr_rvalid,
   input [1:0]                       instr_rresp,
   output wire                       instr_rready,
   input                             instr_rlast,

   // write command
   //    address
   output wire [ADDR_W-1:0]          data_awaddr,
   output wire [2:0]                 data_awprot,
   output wire                       data_awvalid,
   input                             data_awready,
   output wire [2:0]                 data_awsize,
   output wire [7:0]                 data_awlen,

   //  data
   output wire                       data_wvalid,
   output wire [DATA_W-1:0]          data_wdata,
   output wire [3:0]                 data_wstrb,
   input                             data_wready,
   output wire                       data_wlast,

   //write response
   input                             data_bvalid,
   input [1:0]                       data_bresp,
   output wire                       data_bready,

   //read command
   output wire [ADDR_W-1:0]          data_araddr,
   output wire [2:0]                 data_arprot,
   output wire                       data_arvalid,
   input                             data_arready,
   output wire [2:0]                 data_arsize,
   output wire [7:0]                 data_arlen,

   //read response
   input [DATA_W-1:0]                data_rdata,
   input                             data_rvalid,
   input [1:0]                       data_rresp,
   output wire                       data_rready,
   input                             data_rlast,


   input wire                        irq_timer,
   input wire                        irq_sw,
   input wire [PLAT_IRQ_VEC_W-1:0]   irq_plat_vec,
   input wire                        irq_ext,

   input wire                        irq_debug,

   output wire [1:0]                 core_ecc_status,
   output wire [3:0]                 core_ecc_src,

   // axi4-lite interface to access ITCM1
   // write command
   //    address
   input wire [ITCS1_ADDR_WIDTH-1:0] itcs1_awaddr,
   input wire [2:0]                  itcs1_awprot,
   input wire                        itcs1_awvalid,
   output                            itcs1_awready,
   //  data
   input wire                        itcs1_wvalid,
   input wire [31:0]                 itcs1_wdata,
   input wire [3:0]                  itcs1_wstrb,
   output                            itcs1_wready,
 
   //write response
   output                            itcs1_bvalid,
   output [1:0]                      itcs1_bresp,
   input wire                        itcs1_bready,
 
   //read command
   input wire [ITCS1_ADDR_WIDTH-1:0] itcs1_araddr,
   input wire [2:0]                  itcs1_arprot,
   input wire                        itcs1_arvalid,
   output                            itcs1_arready,
 
   //read response
   output [31:0]                     itcs1_rdata,
   output                            itcs1_rvalid,
   output [1:0]                      itcs1_rresp,
   input wire                        itcs1_rready,

   // axi4-lite interface to access ITCM2
   // write command
   //    address
   input wire [ITCS2_ADDR_WIDTH-1:0] itcs2_awaddr,
   input wire [2:0]                  itcs2_awprot,
   input wire                        itcs2_awvalid,
   output                            itcs2_awready,
   //  data
   input wire                        itcs2_wvalid,
   input wire [31:0]                 itcs2_wdata,
   input wire [3:0]                  itcs2_wstrb,
   output                            itcs2_wready,
 
   //write response
   output                            itcs2_bvalid,
   output [1:0]                      itcs2_bresp,
   input wire                        itcs2_bready,
 
   //read command
   input wire [ITCS2_ADDR_WIDTH-1:0] itcs2_araddr,
   input wire [2:0]                  itcs2_arprot,
   input wire                        itcs2_arvalid,
   output                            itcs2_arready,
 
   //read response
   output [31:0]                     itcs2_rdata,
   output                            itcs2_rvalid,
   output [1:0]                      itcs2_rresp,
   input wire                        itcs2_rready,


   // axi4-lite interface to access DTCM1
   // write command
   //    address
   input wire [DTCS1_ADDR_WIDTH-1:0] dtcs1_awaddr,
   input wire [2:0]                  dtcs1_awprot,
   input wire                        dtcs1_awvalid,
   output                            dtcs1_awready,
   //  data
   input wire                        dtcs1_wvalid,
   input wire [31:0]                 dtcs1_wdata,
   input wire [3:0]                  dtcs1_wstrb,
   output                            dtcs1_wready,
 
   //write response
   output                            dtcs1_bvalid,
   output [1:0]                      dtcs1_bresp,
   input wire                        dtcs1_bready,
 
   //read command
   input wire [DTCS1_ADDR_WIDTH-1:0] dtcs1_araddr,
   input wire [2:0]                  dtcs1_arprot,
   input wire                        dtcs1_arvalid,
   output                            dtcs1_arready,
 
   //read response
   output [31:0]                     dtcs1_rdata,
   output                            dtcs1_rvalid,
   output [1:0]                      dtcs1_rresp,
   input wire                        dtcs1_rready,

   // axi4-lite interface to access DTCM2
   // write command
   //    address
   input wire [DTCS2_ADDR_WIDTH-1:0] dtcs2_awaddr,
   input wire [2:0]                  dtcs2_awprot,
   input wire                        dtcs2_awvalid,
   output                            dtcs2_awready,
   //  data
   input wire                        dtcs2_wvalid,
   input wire [31:0]                 dtcs2_wdata,
   input wire [3:0]                  dtcs2_wstrb,
   output                            dtcs2_wready,
 
   //write response
   output                            dtcs2_bvalid,
   output [1:0]                      dtcs2_bresp,
   input wire                        dtcs2_bready,
 
   //read command
   input wire [DTCS2_ADDR_WIDTH-1:0] dtcs2_araddr,
   input wire [2:0]                  dtcs2_arprot,
   input wire                        dtcs2_arvalid,
   output                            dtcs2_arready,
 
   //read response
   output [31:0]                     dtcs2_rdata,
   output                            dtcs2_rvalid,
   output [1:0]                      dtcs2_rresp,
   input wire                        dtcs2_rready

   `ifdef RISCV_FORMAL
   // =============== RISC V FORMAL INTERFACE ===============
   ,
   output   wire                    rvfi_valid, 
   output   wire                    rvfi_halt,
   output   wire                    rvfi_trap,
   output   wire                    rvfi_intr,
   output   wire  [         1:0]    rvfi_mode,
   output   wire  [         1:0]    rvfi_ixl,
   output   wire  [MXLEN/8 -1:0]    rvfi_mem_rmask,
   output   wire  [MXLEN/8 -1:0]    rvfi_mem_wmask,
   output   wire  [         4:0]    rvfi_rs1_addr,
   output   wire  [         4:0]    rvfi_rs2_addr,
   output   wire  [         4:0]    rvfi_rd_addr,
   output   wire  [INSTR_W -1:0]    rvfi_insn,
   output   wire  [MXLEN   -1:0]    rvfi_pc_rdata,
   output   wire  [MXLEN   -1:0]    rvfi_pc_wdata,
   output   wire  [MXLEN   -1:0]    rvfi_rs1_rdata,
   output   wire  [MXLEN   -1:0]    rvfi_rs2_rdata,
   output   wire  [MXLEN   -1:0]    rvfi_rd_wdata,
   output   wire  [MXLEN   -1:0]    rvfi_mem_addr,
   output   wire  [MXLEN   -1:0]    rvfi_mem_rdata,
   output   wire  [MXLEN   -1:0]    rvfi_mem_wdata,
   output   wire  [        63:0]    rvfi_order
   `endif      //    RISCV_FORMAL      //

);

   wire [31:0] core_ci_data0;
   wire [31:0] core_ci_data1;
   wire [31:0] core_ci_alu_result;
   wire [31:0] core_ci_ctrl;
   wire        core_ci_enable;
   wire [3:0]  core_ci_op;
   reg  [31:0] core_ci_result_int;
   wire [31:0] core_ci_result;
   wire        core_ci_done;

   wire [F7_FIELD_W-1:0] core_ci_f7 = core_ci_ctrl[F7_FIELD_H:F7_FIELD_L]; 

   // IRQ signal rename (main CPU instance uses wildcard signal binding)
   wire        timer_irq                  = irq_timer;
   wire        sw_irq                     = irq_sw;
   wire [PLAT_IRQ_VEC_W-1:0] plat_irq_vec = irq_plat_vec;
   wire        ext_irq                    = irq_ext;
   wire        debug_irq                  = irq_debug;

   /**
    *Block description: //RISCV_FORMAL flag is used to expose the core's output formal interface signals for the design validation work flow at the unit level.
    *                   With or without dual core lockstep enabled, the RVFI signals output port of the primary CPU instance represents the unit level RVFI.
    *                   //The RVFI ports of the of the right CPU instance (secondary CPU) are left floating i.e. unconnected.
    *                   //In case RISCV_FORMAL is defined at compile time, then the RVFI output ports from the main CPU instance are exposed.
    *                   //(* keep *) attribute is applied to preserve only those RVFI signals that are needed for signal tap.
    */

   `ifndef RISCV_FORMAL
   (* keep*)   logic                   rvfi_valid; 
               logic                   rvfi_halt;
               logic                   rvfi_trap;
               logic                   rvfi_intr;
               logic  [         1:0]   rvfi_mode;
               logic  [         1:0]   rvfi_ixl;
               logic  [MXLEN/8 -1:0]   rvfi_mem_rmask;
               logic  [MXLEN/8 -1:0]   rvfi_mem_wmask;
               logic  [         4:0]   rvfi_rs1_addr;
               logic  [         4:0]   rvfi_rs2_addr;
               logic  [         4:0]   rvfi_rd_addr;
   (* keep *)  logic  [INSTR_W -1:0]   rvfi_insn;
   (* keep *)  logic  [MXLEN   -1:0]   rvfi_pc_rdata;
               logic  [MXLEN   -1:0]   rvfi_pc_wdata;
               logic  [MXLEN   -1:0]   rvfi_rs1_rdata;
               logic  [MXLEN   -1:0]   rvfi_rs2_rdata;
               logic  [MXLEN   -1:0]   rvfi_rd_wdata;
               logic  [MXLEN   -1:0]   rvfi_mem_addr;
               logic  [MXLEN   -1:0]   rvfi_mem_rdata;
               logic  [MXLEN   -1:0]   rvfi_mem_wdata;
               logic  [        63:0]   rvfi_order;
   `endif   //    RISCV_FORMAL      //







   niosv_g_core_qsys_top_intel_niosv_g_0_intel_niosv_g_unit_400_25ilc6y # (
      .DBG_EXPN_VECTOR          (DBG_EXPN_VECTOR          ), 
      .RESET_VECTOR             (RESET_VECTOR             ),
      .USE_RESET_REQ            (USE_RESET_REQ            ), 
      .CORE_EXTN                (CORE_EXTN                ),
      .HARTID                   (HARTID                   ),
      .DISABLE_FSQRT_FDIV       (DISABLE_FSQRT_FDIV       ),
      .DEBUG_ENABLED            (DEBUG_ENABLED            ),
      .DEVICE_FAMILY            (DEVICE_FAMILY            ),
      .DBG_PARK_LOOP_OFFSET     (DBG_PARK_LOOP_OFFSET     ),
      .DBG_DATA_S_BASE          (DBG_DATA_S_BASE          ),
      .TIMER_MSIP_DATA_S_BASE   (TIMER_MSIP_DATA_S_BASE   ),
      .DATA_CACHE_SIZE          (DATA_CACHE_SIZE          ),
      .INST_CACHE_SIZE          (INST_CACHE_SIZE          ),
      .ITCM1_SIZE               (ITCM1_SIZE               ),
      .ITCM1_BASE               (ITCM1_BASE               ),
      .ITCM1_INIT_FILE          (ITCM1_INIT_FILE          ),
      .ITCM2_SIZE               (ITCM2_SIZE               ),
      .ITCM2_BASE               (ITCM2_BASE               ),
      .ITCM2_INIT_FILE          (ITCM2_INIT_FILE          ),      
      .PERIPHERAL_REGION_A_SIZE (PERIPHERAL_REGION_A_SIZE ),
      .PERIPHERAL_REGION_A_BASE (PERIPHERAL_REGION_A_BASE ),
      .PERIPHERAL_REGION_B_SIZE (PERIPHERAL_REGION_B_SIZE ),
      .PERIPHERAL_REGION_B_BASE (PERIPHERAL_REGION_B_BASE ),
      .DTCM1_SIZE               (DTCM1_SIZE               ),
      .DTCM1_BASE               (DTCM1_BASE               ),
      .DTCM1_INIT_FILE          (DTCM1_INIT_FILE          ),
      .DTCM2_SIZE               (DTCM2_SIZE               ),
      .DTCM2_BASE               (DTCM2_BASE               ),
      .DTCM2_INIT_FILE          (DTCM2_INIT_FILE          ),
      .ECC_EN                   (ECC_EN                   ),
      .ECC_FULL                 (ECC_FULL                 ),
      .BRANCHPREDICTION_EN      (BRANCHPREDICTION_EN      ),
      .ITCS1_ADDR_WIDTH         (ITCS1_ADDR_WIDTH         ),
      .ITCS2_ADDR_WIDTH         (ITCS2_ADDR_WIDTH         ),
      .DTCS1_ADDR_WIDTH         (DTCS1_ADDR_WIDTH         ),
      .DTCS2_ADDR_WIDTH         (DTCS2_ADDR_WIDTH         ),
      .NUM_PLATFORM_INTERRUPTS  (NUM_PLATFORM_INTERRUPTS  ),
      .NUM_SRF_BANKS            (NUM_SRF_BANKS            ),
      .CLIC_EN                  (CLIC_EN                  ),
      .CLIC_NUM_LEVELS          (CLIC_NUM_LEVELS          ),
      .CLIC_NUM_PRIORITIES      (CLIC_NUM_PRIORITIES      ),
      .CLIC_NUM_DEBUG_TRIGGERS  (CLIC_NUM_DEBUG_TRIGGERS  ),
      .CLIC_TRIGGER_POLARITY_EN (CLIC_TRIGGER_POLARITY_EN ),
      .CLIC_EDGE_TRIGGER_EN     (CLIC_EDGE_TRIGGER_EN     ),
      .CLIC_VT_ALIGN            (CLIC_VT_ALIGN            ),
      .CLIC_SHV_EN              (CLIC_SHV_EN              )
   ) core_inst (
      .* 
   );
   assign core_ci_done = 1'b0;
   assign core_ci_result = 32'b0;




endmodule

