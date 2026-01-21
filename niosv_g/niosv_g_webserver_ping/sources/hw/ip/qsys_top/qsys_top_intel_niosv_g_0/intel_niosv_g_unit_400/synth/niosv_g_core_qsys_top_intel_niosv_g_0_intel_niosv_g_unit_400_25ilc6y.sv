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


// TODO: DO all TODO's and remove TODO's
`default_nettype none

`timescale 1 ns / 1 ns

module niosv_g_core_qsys_top_intel_niosv_g_0_intel_niosv_g_unit_400_25ilc6y 
   import   niosv_opcode_def::*, 
            niosv_g_fp_def::*,
            riscv_pkg::LB,
            riscv_pkg::LH,
            riscv_pkg::LW,
            riscv_pkg::LBU,
            riscv_pkg::LHU,
            riscv_pkg::SB,
            riscv_pkg::SH,
            riscv_pkg::SW;
# (
   parameter DBG_EXPN_VECTOR          = 32'h80000000,
   parameter RESET_VECTOR             = 32'h00000000,
   parameter CORE_EXTN                = 26'h0000100,  // RV32I
   parameter HARTID                   = 32'h00000000,
   parameter DISABLE_FSQRT_FDIV       = 1'b0,
   parameter DEBUG_ENABLED            = 1'b0,
   parameter DEVICE_FAMILY            = "Stratix 10",
   parameter DBG_PARK_LOOP_OFFSET     = 32'd24,
   parameter USE_RESET_REQ            = 1'b0,
   parameter OPTIMIZE_ALU_AREA        = 1'b1,
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
   // This would be a localparam if Quartus Standard supported the necessary syntax
   /*local*/ parameter PLAT_IRQ_VEC_W = (NUM_PLATFORM_INTERRUPTS < 1) ? 1 : NUM_PLATFORM_INTERRUPTS
) (
   input  wire clk,
   input  wire reset,
   input  wire reset_req,
   output wire reset_req_ack,

   // AXI4-Lite Interfaces

   // ================== Instruction Interface ==================
   // write address
   output wire [31:0]                 instr_awaddr,
   output wire [2:0]                  instr_awprot,
   output wire                        instr_awvalid,
   output wire [2:0]                  instr_awsize,
   output wire [7:0]                  instr_awlen,
   output wire [1:0]                  instr_awburst,
   input  wire                        instr_awready,

   // write data
   output wire                        instr_wvalid,
   output wire [31:0]                 instr_wdata,
   output wire [3:0]                  instr_wstrb,
   output wire                        instr_wlast,
   input  wire                        instr_wready,

   // write response
   input  wire                        instr_bvalid,
   input  wire [1:0]                  instr_bresp,
   output wire                        instr_bready,

   // read address
   output wire [31:0]                 instr_araddr,
   output wire [2:0]                  instr_arprot,
   output wire                        instr_arvalid,
   output wire [2:0]                  instr_arsize,
   output wire [7:0]                  instr_arlen,
   output wire [1:0]                  instr_arburst,
   input  wire                        instr_arready,

   // read response
   input  wire [31:0]                 instr_rdata,
   input  wire                        instr_rvalid,
   input  wire [1:0]                  instr_rresp,
   input  wire                        instr_rlast,
   output wire                        instr_rready,

   // ===================== Data Interface ======================
   // write address
   output wire [ADDR_W-1:0]           data_awaddr,
   output wire [2:0]                  data_awprot,
   output wire                        data_awvalid,
   output wire [2:0]                  data_awsize,
   output wire [7:0]                  data_awlen,
   input  wire                        data_awready,

   // write data
   output wire                        data_wvalid,
   output wire [DATA_W-1:0]           data_wdata,
   output wire [3:0]                  data_wstrb,
   output wire                        data_wlast,
   input  wire                        data_wready,

   // write response
   input  wire                        data_bvalid,
   input  wire [1:0]                  data_bresp,
   output wire                        data_bready,

   // read address
   output wire [ADDR_W-1:0]           data_araddr,
   output wire [2:0]                  data_arprot,
   output wire                        data_arvalid,
   output wire [2:0]                  data_arsize,
   output wire [7:0]                  data_arlen,
   input  wire                        data_arready,

   // read response
   input  wire [DATA_W-1:0]           data_rdata,
   input  wire                        data_rvalid,
   input  wire [1:0]                  data_rresp,
   input  wire                        data_rlast,
   output wire                        data_rready,

   // Interrupts
   input wire                         timer_irq,
   input wire                         sw_irq,
   input wire [PLAT_IRQ_VEC_W-1:0]    plat_irq_vec,
   input wire                         ext_irq,
   input wire                         debug_irq,

   // Custom Instructions
   output wire [31:0]                 core_ci_data0,
   output wire [31:0]                 core_ci_data1,
   output wire [31:0]                 core_ci_alu_result,
   output wire [31:0]                 core_ci_ctrl,
   output wire                        core_ci_enable,
   output wire [3:0]                  core_ci_op,
   input  wire                        core_ci_done,
   input  wire [31:0]                 core_ci_result,

   // ECC
   output wire [3:0]                  core_ecc_src,
   output wire [1:0]                  core_ecc_status,

   // ===================== ITCM1 Interface =====================
   // write address
   input  wire [ITCS1_ADDR_WIDTH-1:0] itcs1_awaddr,
   input  wire [2:0]                  itcs1_awprot,
   input  wire                        itcs1_awvalid,
   output wire                        itcs1_awready,

   // write data
   input  wire                        itcs1_wvalid,
   input  wire [31:0]                 itcs1_wdata,
   input  wire [3:0]                  itcs1_wstrb,
   output wire                        itcs1_wready,

   // write response
   output wire                        itcs1_bvalid,
   output wire [1:0]                  itcs1_bresp,
   input  wire                        itcs1_bready,

   // read address
   input  wire [ITCS1_ADDR_WIDTH-1:0] itcs1_araddr,
   input  wire [2:0]                  itcs1_arprot,
   input  wire                        itcs1_arvalid,
   output wire                        itcs1_arready,

   // read response
   output wire [31:0]                 itcs1_rdata,
   output wire                        itcs1_rvalid,
   output wire [1:0]                  itcs1_rresp,
   input  wire                        itcs1_rready,

   // ===================== ITCM2 Interface =====================
   // write address
   input  wire [ITCS2_ADDR_WIDTH-1:0] itcs2_awaddr,
   input  wire [2:0]                  itcs2_awprot,
   input  wire                        itcs2_awvalid,
   output wire                        itcs2_awready,
   // write data
   input  wire                        itcs2_wvalid,
   input  wire [31:0]                 itcs2_wdata,
   input  wire [3:0]                  itcs2_wstrb,
   output wire                        itcs2_wready,

   // write response
   output wire                        itcs2_bvalid,
   output wire [1:0]                  itcs2_bresp,
   input  wire                        itcs2_bready,

   // read address
   input  wire [ITCS2_ADDR_WIDTH-1:0] itcs2_araddr,
   input  wire [2:0]                  itcs2_arprot,
   input  wire                        itcs2_arvalid,
   output wire                        itcs2_arready,

   // read response
   output wire [31:0]                 itcs2_rdata,
   output wire                        itcs2_rvalid,
   output wire [1:0]                  itcs2_rresp,
   input  wire                        itcs2_rready,

   // ===================== DTCM1 Interface =====================
   // write address
   input  wire [DTCS1_ADDR_WIDTH-1:0] dtcs1_awaddr,
   input  wire [2:0]                  dtcs1_awprot,
   input  wire                        dtcs1_awvalid,
   output wire                        dtcs1_awready,

   // write data
   input  wire                        dtcs1_wvalid,
   input  wire [31:0]                 dtcs1_wdata,
   input  wire [3:0]                  dtcs1_wstrb,
   output wire                        dtcs1_wready,

   // write response
   output wire                        dtcs1_bvalid,
   output wire [1:0]                  dtcs1_bresp,
   input  wire                        dtcs1_bready,

   // read address
   input  wire [DTCS1_ADDR_WIDTH-1:0] dtcs1_araddr,
   input  wire [2:0]                  dtcs1_arprot,
   input  wire                        dtcs1_arvalid,
   output wire                        dtcs1_arready,

   // read response
   output wire [31:0]                 dtcs1_rdata,
   output wire                        dtcs1_rvalid,
   output wire [1:0]                  dtcs1_rresp,
   input  wire                        dtcs1_rready,

   // ===================== DTCM2 Interface =====================
   // write address
   input  wire [DTCS2_ADDR_WIDTH-1:0] dtcs2_awaddr,
   input  wire [2:0]                  dtcs2_awprot,
   input  wire                        dtcs2_awvalid,
   output wire                        dtcs2_awready,

   // write data
   input  wire                        dtcs2_wvalid,
   input  wire [31:0]                 dtcs2_wdata,
   input  wire [3:0]                  dtcs2_wstrb,
   output wire                        dtcs2_wready,

   // write response
   output wire                        dtcs2_bvalid,
   output wire [1:0]                  dtcs2_bresp,
   input  wire                        dtcs2_bready,

   // read address
   input  wire [DTCS2_ADDR_WIDTH-1:0] dtcs2_araddr,
   input  wire [2:0]                  dtcs2_arprot,
   input  wire                        dtcs2_arvalid,
   output wire                        dtcs2_arready,

   // read response
   output wire [31:0]                 dtcs2_rdata,
   output wire                        dtcs2_rvalid,
   output wire [1:0]                  dtcs2_rresp,
   input  wire                        dtcs2_rready,

   // ===================== RISC V FORMAL PORT INTRODUCTION =====================
   //INSTRUCTION META DATA SIGNALS
   output   logic                rvfi_valid,
   output   logic                rvfi_halt,
   output   logic                rvfi_trap,
   output   logic                rvfi_intr,
   output   logic [         1:0] rvfi_mode,
   output   logic [         1:0] rvfi_ixl,
   output   logic [INSTR_W -1:0] rvfi_insn,
   output   logic [        63:0] rvfi_order,

   //PC SIGNALS
   output   logic [MXLEN   -1:0] rvfi_pc_rdata,
   output   logic [MXLEN   -1:0] rvfi_pc_wdata,

   //GPR SIGNALS
   output   logic [         4:0] rvfi_rs1_addr,
   output   logic [         4:0] rvfi_rs2_addr,
   output   logic [         4:0] rvfi_rd_addr, 
   output   logic [MXLEN   -1:0] rvfi_rs1_rdata,
   output   logic [MXLEN   -1:0] rvfi_rs2_rdata,
   output   logic [MXLEN   -1:0] rvfi_rd_wdata,

   //MEM SIGNALS
   output   logic [MXLEN/8 -1:0] rvfi_mem_rmask,
   output   logic [MXLEN/8 -1:0] rvfi_mem_wmask,
   output   logic [MXLEN   -1:0] rvfi_mem_addr,
   output   logic [MXLEN   -1:0] rvfi_mem_rdata,
   output   logic [MXLEN   -1:0] rvfi_mem_wdata
);

   localparam RAM_TYPE = ((DEVICE_FAMILY == "Arria 10") || (DEVICE_FAMILY == "Arria V GZ")  || (DEVICE_FAMILY == "Stratix V")) ? "M20K" :
                         ((DEVICE_FAMILY == "Arria V" ) || (DEVICE_FAMILY == "Cyclone V")) ? "M10K" :
                         ((DEVICE_FAMILY == "Arria II GX" ) || (DEVICE_FAMILY == "Arria II GZ") || (DEVICE_FAMILY == "Cyclone 10 LP") || (DEVICE_FAMILY == "Cyclone IV E") ||
                          (DEVICE_FAMILY == "Cyclone IV GX") || (DEVICE_FAMILY == "MAX 10") || (DEVICE_FAMILY == "Stratix IV")) ? "M9K" : "AUTO";

   localparam NUM_BANKS_CHK = $clog2(NUM_SRF_BANKS) == 0 ? 2 : NUM_SRF_BANKS;
   localparam NUM_REG = get_num_gpr(CORE_EXTN);
   localparam RF_ADDR_W = $clog2(NUM_REG);
   // localparam LOCAL_RST_DEPTH = 8;
   localparam ATOMIC_ENABLED = CORE_EXTN[RV_A];
   localparam MULDIV_ENABLED = CORE_EXTN[RV_M];
   localparam FLOAT_ENABLED  = CORE_EXTN[RV_F];

   localparam DBG_PARK_LOOP = DBG_EXPN_VECTOR + DBG_PARK_LOOP_OFFSET;
   localparam RST_REQ_DEPTH = 16;

   initial begin
      assert ((NUM_SRF_BANKS <= 2) || (NUM_SRF_BANKS == CLIC_NUM_LEVELS-1) || (NUM_SRF_BANKS == CLIC_NUM_LEVELS));
   end

   wire internal_reset;

   wire core_nmi_irq = 1'b0;

   // register file signals
   wire [RF_ADDR_W-1:0] rd_reg_a;
   wire [RF_ADDR_W-1:0] rd_reg_b;
   wire [RF_ADDR_W-1:0] rd_reg_c;  // only applies to FPR

   wire [DATA_W-1:0]    rd_gpr_data_a;
   wire [DATA_W-1:0]    rd_gpr_data_b;
   wire                 wr_gpr_en;
   wire [RF_ADDR_W-1:0] wr_gpr;
   wire [DATA_W-1:0]    wr_gpr_data;

   wire [FP32_W-1:0]    rd_fpr_data_a;
   wire [FP32_W-1:0]    rd_fpr_data_b;
   wire [FP32_W-1:0]    rd_fpr_data_c;
   wire                 wr_fpr_en;
   wire [RF_ADDR_W-1:0] wr_fpr;
   wire [FP32_W-1:0]    wr_fpr_data;

   wire  D_ready;
   wire  E_ready;
   wire  M0_ready;
   wire  M1_ready;
   wire  W_ready;

   logic I_instr_valid;
   reg   D_instr_valid;
   reg   E_instr_valid;
   reg   M0_instr_valid;
   reg   M1_instr_valid;
   reg   W_instr_valid;

   logic [31:0] I_instr_pc;
   reg   [31:0] D_instr_pc;
   reg   [31:0] E_instr_pc;
   reg   [31:0] E_nxt_seq_pc;
   reg   [31:0] M0_nxt_seq_pc;
   reg   [31:0] M0_instr_pc;
   reg   [31:0] M0_nxt_pc;
   reg   [31:0] M1_nxt_seq_pc;
   reg   [31:0] M1_instr_pc;
   reg   [31:0] M1_nxt_pc;

   logic [31:0] I_instr_word;
   reg   [31:0] D_instr_word;
   reg   [31:0] E_instr_word;
   reg   [31:0] M0_instr_word;
   reg   [31:0] M1_instr_word;
   reg   [31:0] W_instr_word;

   wire I_jalr_instr;
   reg  D_jalr_instr;
   reg  E_jalr_instr;

   wire I_use_imm;
   reg  D_use_imm;
   wire [IMM_W-1:0] I_imm;
   reg  [IMM_W-1:0] D_imm;
   reg  [4:0] E_shift_amt;

   wire  I_misc_mem_op;

   wire  D_cmo_op;
   reg   E_cmo_op;
   reg   M0_cmo_op;
   reg   M1_cmo_op;

   wire  I_amo_op;
   reg   D_amo_op;
   reg   E_amo_op;
   logic M0_amo_op;
   logic M1_amo_op;
   wire  D_mul_op;
   wire  D_muldiv_ctrl_1;
   wire  D_muldiv_ctrl_2;
   wire  D_mul_use_lsw;
   reg   E_mul_op;
   reg   E_muldiv_ctrl_1;
   reg   E_muldiv_ctrl_2;
   reg   E_mul_use_lsw;
   wire  E_mul_valid;
   reg   M0_muldiv_ctrl_1;
   reg   M0_muldiv_ctrl_2;
   reg   M0_mul_op;
   reg   M1_mul_op;
   wire  D_div_op;
   reg   E_div_op;
   reg   M0_div_op;
   reg   M1_div_op;

   wire [4:0] E_amo_op_type  = E_instr_word[31:27];
   wire [4:0] M0_amo_op_type = M0_instr_word[31:27];
   wire [2:0] M0_cmo_op_type = {M0_instr_word[27], M0_instr_word[21:20]};
   wire [4:0] M1_amo_op_type = M1_instr_word[31:27];
   wire [2:0] M1_cmo_op_type = {M1_instr_word[27], M1_instr_word[21:20]};

   exe_ops_t D_exe_op;
   exe_ops_t E_exe_op;
   exe_ops_t M0_exe_op;

   fp_op_decode_t D_fp_op_decode;
   fp_op_decode_t E_fp_op_decode;

   reg   [31:0] D_i_mtval;
   reg   [31:0] E_d_mtval;
   logic [31:0] M0_d_mtval;
   logic [31:0] M0_e_mtval;
   wire  [31:0] M0_mtval;
   reg   [31:0] M1_m0_mtval;
   wire  [31:0] M1_mtval;
   reg   [31:0] C_expn_mtval;

   reg   [5:0] D_i_mtval2;
   reg   [5:0] E_d_mtval2;
   logic [5:0] M0_d_mtval2;
   logic [5:0] M0_e_mtval2;
   logic [5:0] M0_mtval2;
   reg   [5:0] M1_m0_mtval2;
   logic [5:0] M1_mtval2;
   reg   [5:0] C_expn_mtval2;

   wire  E_unaligned_redir;
   logic M0_unaligned_redir;

   wire  D_needs_gp_rs1;
   wire  D_needs_gp_rs2;

   wire  D_gpr_wr_en;
   reg   E_gpr_wr_en;
   reg   M0_gpr_wr_en;
   reg   M1_gpr_wr_en;
   wire  M1_gpr_wr_en_nxt;
   reg   W_gpr_wr_en;

   wire  D_needs_fp_rs1;
   wire  D_needs_fp_rs2;
   wire  D_needs_fp_rs3;

   wire  D_fpr_wr_en;
   reg   E_fpr_wr_en;
   reg   M0_fpr_wr_en;
   reg   M1_fpr_wr_en;
   wire  M1_fpr_wr_en_nxt;
   reg   W_fpr_wr_en;

   reg   M1_load_en;
   wire  M1_load_en_nxt;

   wire  [DATA_W-1:0] E_exe_result;
   wire  [DATA_W-1:0] E_alu_result;
   wire  [DATA_W-1:0] E_ls_addr;
   reg   [DATA_W-1:0] M0_exe_result;
   wire  [DATA_W-1:0] M0_ls_addr = M0_exe_result;
   logic [DATA_W-1:0] M0_gpr_result_data_nxt;
   logic [FP32_W-1:0] M0_fpr_result_data_nxt;

   reg   [DATA_W-1:0] M1_exe_result;
   wire  [DATA_W-1:0] M1_ls_addr = M1_exe_result;

   wire  [DATA_W-1:0] M1_load_data;
   logic [DATA_W-1:0] M1_gpr_result_data_nxt;
   logic [FP32_W-1:0] M1_fpr_result_data_nxt;

   reg   [DATA_W-1:0] W_gpr_exe_result;
   reg   [DATA_W-1:0] W_fpr_exe_result;

   wire  [RF_ADDR_W-1:0] D_rd;
   reg   [RF_ADDR_W-1:0] E_rd;
   reg   [RF_ADDR_W-1:0] M0_rd;
   reg                   M0_rd_is_zero;
   reg   [RF_ADDR_W-1:0] M1_rd;
   reg                   M1_rd_is_zero;
   reg   [RF_ADDR_W-1:0] W_rd;

   wire  [DATA_W-1:0] D_exe_s1;
   wire  [DATA_W-1:0] D_exe_s2;
   reg   [DATA_W-1:0] E_csr_s1;
   reg   [DATA_W-1:0] E_exe_s1;
   reg   [DATA_W-1:0] E_exe_s2;

   reg   [DATA_W-1:0] M0_csr_s1;
   reg   [DATA_W-1:0] M0_exe_s1;
   reg   [DATA_W-1:0] M0_exe_s2;

   reg   [DATA_W-1:0] M1_exe_s1;
   reg   [DATA_W-1:0] M1_exe_s2;

   wire I_mem_op;
   wire I_load_op;
   wire I_store_op;
   reg  D_branch_op;
   reg  D_jump_op;
   reg  D_auipc_lui_op;
   reg  D_beq_bne_op;
   reg  D_blt_bge_op;
   reg  D_bne_bge_op;	
   reg  D_mem_op;
   reg  D_load_op;
   reg  D_store_op;
   wire D_2stage_fp_op;
   wire D_3stage_fp_op;
   wire D_long_fp_op;
   reg  E_branch_op;
   reg  E_jump_op;
   reg  E_jalr_op;
   reg  E_auipc_lui_op;
   reg  E_beq_bne_op;
   reg  E_blt_bge_op;
   reg  E_bne_bge_op;	
   reg  E_cmp_lt_ltu_op;
   reg  E_sra_op;
   reg  E_srx_op;
   reg  E_sll_op;
   reg  E_or_op;
   reg  E_xor_op;
   reg  E_and_op;
   reg  E_alu_use_addsub_result; // indicates to ALU that op is an add or sub
   reg  E_alu_use_logic_result;  // indicates to ALU that op is one of and, or, xor
   reg  E_mem_op;
   reg  E_load_op;
   reg  E_store_op;
   reg  E_long_op;
   reg  E_3stage_fp_op;
   reg  E_long_fp_op;
   reg  E_multicycle_op;
   reg  M0_mem_op;
   reg  M0_load_op;
   reg  M0_store_op;
   reg  M0_long_op;
   reg  M0_3stage_fp_op;
   reg  M1_mem_op;
   reg  M1_long_op;
   wire D_ebreak_instr;
   wire D_ecall_instr;
   reg  E_ebreak_instr;
   reg  E_ecall_instr;
   wire D_signed_cmp;
   wire D_alu_sub;
   reg  E_signed_cmp;
   reg  E_alu_sub;
   reg  M0_ecall_instr;

   wire        M1_mul_pending;
   wire        M1_div_pending;

   wire        M1_mul_done;
   wire        M1_div_done;
   wire        M1_div_stall;
   wire [31:0] M1_mul_result;
   wire [31:0] M1_div_result;

   mem_size_t  D_mem_size;
   byteen_t    D_mem_byteen;
   wire        D_mem_signext;
   mem_size_t  E_mem_size;
   byteen_t    E_mem_byteen;
   reg         E_mem_signext;
   wire        E_mem_unaligned;
   mem_size_t  M0_mem_size;
   byteen_t    M0_mem_byteen;
   reg         M0_mem_signext;
   reg         M0_mem_unaligned;
   mem_size_t  M1_mem_size;
   byteen_t    M1_mem_byteen;
   reg         M1_mem_signext;

   logic       E_fpu_state_dirtied;    // For updates to FPU state in MSTATUS

   wire        E_fpu_to_fpr_done;
   wire [31:0] E_fpu_to_fpr_result;
   wire        E_fpu_to_gpr_done;
   wire [31:0] E_fpu_to_gpr_result;
   fp_flags_t  E_fpu_flags;
   reg         M0_fpu_to_fpr_e_done;   // FPU single-cycle instruction outputs carried in pipeline from E stage
   reg [31:0]  M0_fpu_to_fpr_e_result;
   reg         M0_fpu_to_gpr_e_done;
   reg [31:0]  M0_fpu_to_gpr_e_result;
   fp_flags_t  M0_fpu_e_flags;
   reg         M0_fpu_to_fpr_done;     // FPU 2-cycle instruction outputs directly into M0 stage
   reg [31:0]  M0_fpu_to_fpr_result;
   reg         M0_fpu_to_gpr_done;
   reg [31:0]  M0_fpu_to_gpr_result;
   fp_flags_t  M0_fpu_flags;
   reg         M1_fpu_to_fpr_m0_done;  // FPU 1-cycle and 2-cycle instruction outputs carried in pipeline from M0 stage
   reg [31:0]  M1_fpu_to_fpr_m0_result;
   reg         M1_fpu_to_gpr_m0_done;
   reg [31:0]  M1_fpu_to_gpr_m0_result;
   fp_flags_t  M1_fpu_m0_flags;
   wire        M1_fpu_op_pending;      // FPU multi-cycle instruction outputs directly into M1 stage
   reg         M1_fpu_to_fpr_done;
   reg [31:0]  M1_fpu_to_fpr_result;
   reg         M1_fpu_to_gpr_done;
   reg [31:0]  M1_fpu_to_gpr_result;
   fp_flags_t  M1_fpu_flags;

   logic [4:0] M1_fpu_fflags;          // For CSR interface
   logic       M1_fpu_fflags_valid;

   wire [3:0]  D_ci_op;
   reg  [3:0]  E_ci_op;
   reg  [3:0]  M0_ci_op;
   wire        M0_ci_enable = (|M0_ci_op);
   reg         M0_ci_pending;
   reg  [3:0]  M1_ci_op;
   wire        M1_ci_enable = (|M1_ci_op);
   reg         M1_ci_pending;

   wire [RS1_FIELD_W-1:0]   I_iw_rs1 = I_instr_word[RS1_FIELD_H:RS1_FIELD_L];
   wire [RS2_FIELD_W-1:0]   I_iw_rs2 = I_instr_word[RS2_FIELD_H:RS2_FIELD_L];
   wire [R_RS3_FIELD_W-1:0] I_iw_rs3 = I_instr_word[R_RS3_FIELD_H:R_RS3_FIELD_L];

   //access previous register file when csrrw AND CSR==ALT_MRDPSRF
   wire                     I_previous_srf = I_instr_word[6:0]==7'b1110011 & I_instr_word[14:12]==001 &
                                             I_instr_word[31:20]==ALT_MRDPSRF;

   reg  [RS1_FIELD_W-1:0]   D_iw_rs1;  // TODO: why register this when we're already registering D_instruction_word ??
   reg  [RS2_FIELD_W-1:0]   D_iw_rs2;
   reg  [R_RS3_FIELD_W-1:0] D_iw_rs3;
   reg                      D_iw_rs1_is_zero;
   reg                      D_iw_rs2_is_zero;
   reg                      D_previous_srf;

   reg  [DATA_W-1:0]        D_rs1_gpr_val;
   reg  [DATA_W-1:0]        D_rs2_gpr_val;
   reg  [FP32_W-1:0]        D_rs1_fpr_val;
   reg  [DATA_W-1:0]        D_rs2_fpr_val;
   reg  [DATA_W-1:0]        D_rs3_fpr_val;

   reg                      E_iw_rs1_is_zero;
   reg  [DATA_W-1:0]        E_rs1_gpr_val;
   reg  [DATA_W-1:0]        E_rs2_gpr_val;
   reg  [FP32_W-1:0]        E_rs1_fpr_val;
   reg  [FP32_W-1:0]        E_rs2_fpr_val;
   reg                      E_store_gpr;   // indicates that the store will take its data from a GPR, not FPR

   reg                      M0_iw_rs1_is_zero;
   reg  [DATA_W-1:0]        M0_rs1_gpr_val;
   reg  [DATA_W-1:0]        M0_rs2_gpr_val;
   reg  [DATA_W-1:0]        M0_store_data;

   reg  [DATA_W-1:0]        M1_rs1_gpr_val;
   reg  [DATA_W-1:0]        M1_rs2_gpr_val;

   reg  M0_instr_done;
   reg  M0_instr_to_gpr_done;
   reg  M0_instr_to_fpr_done;
   wire M0_ls_op_stall;
   wire M0_stall;
   wire M0_csr_stall;
   reg  M0_non_mem_long_op;

   wire M1_ls_op_done;
   wire M1_ld_op_done;
   wire M1_instr_done;
   wire M1_instr_to_gpr_done;
   wire M1_instr_to_fpr_done;
   wire M1_multicycle_instr_pending;

   wire M1_ls_instr_pending;

   wire D_dep_stall_from_E;
   wire D_dep_stall_from_M0;
   wire D_dep_stall_from_M1;

   wire [31:0] D_computed_pc;
   reg  [31:0] E_computed_pc;
   reg  [31:0] M0_computed_pc;

   wire [31:0] E_redirect_pc;
   reg  [31:0] M0_redirect_pc;
   reg  [31:0] M1_redirect_pc;
   reg  [31:0] nxt_M0_redirect_pc;
   wire        E_unaligned_redirect_pc;
   wire        E_redirect;
   wire        E_redirect_alu;
   reg         M0_redirect;
   reg         M1_redirect;
   wire        M0_redirect_nxt;
   wire        M0_redirect_nxt_branch;

   wire        D_csr_read;
   wire        D_csr_write;
   wire        D_csr_set;
   wire        D_csr_clr;
   wire [11:0] D_csr_addr = D_instr_word[I_IMM_FIELD_H:I_IMM_FIELD_L];
   wire        D_rdpsrf;
   wire        D_wrpsrf;
   reg         E_csr_read;
   reg         E_csr_write;
   reg         E_csr_set;
   reg         E_csr_clr;
   reg  [11:0] E_csr_addr;
   reg         E_rdpsrf;
   reg         E_wrpsrf;
   reg         M0_csr_read;
   reg         M0_csr_write;
   reg         M0_csr_set;
   reg         M0_csr_clr;
   reg  [11:0] M0_csr_addr;
   reg         M0_rdpsrf;
   reg         M0_wrpsrf;
   reg         M1_rdpsrf;
   reg         M1_wrpsrf;
   reg         W_rdpsrf;
   reg         W_wrpsrf;
   wire [11:0] C_addr;
   csr_op_t    C_csr_op;
   wire        C_rs1_is_zero;
   wire        C_rd_is_zero;
   wire        C_read;
   reg         C_write;
   wire        C_set;
   wire        C_clr;
   wire [31:0] C_read_data;
   wire [31:0] C_write_data;
   wire [31:0] C_expn_redirect_pc;
   wire [31:0] C_csr_epc;
   wire [31:0] C_debug_pc;

   reg  D_i_expn;
   wire D_expn;
   reg  E_d_expn;
   wire E_expn;
   reg  M0_e_expn;
   reg  M1_m0_expn;
   wire M0_expn;
   wire M1_expn;
   wire M0_ls_expn;
   wire M1_ls_expn;
   wire C_csr_access_expn;

   wire M1_sstep_expn;

   csr_to_hart_t csr_to_hart;
   xcause_code_t D_expn_cause;
   xcause_code_t E_expn_cause;
   xcause_code_t M0_expn_cause;
   xcause_code_t M0_ls_expn_cause;
   xcause_code_t M1_expn_cause;
   xcause_code_t M1_ls_expn_cause;

   xcause_code_t D_i_expn_cause;

   xcause_code_t E_d_expn_cause;

   xcause_code_t M0_e_expn_cause;
   xcause_code_t M1_m0_expn_cause;

   reg           C_expn_is_interrupt;
   xcause_code_t C_expn_cause;
   reg   [7:0]   C_expn_level;
   reg           C_expn_hv;
   reg           C_expn_update;
   reg           C_expn_taken;

   reg   [31:0]  C_expn_pc;
   logic [31:0]  C_dbg_expn_pc;
   wire          C_sstep_en;

   logic         nxt_csr_expn_is_interrupt;
   xcause_code_t nxt_csr_expn_cause;
   logic [7:0]   nxt_csr_expn_level;
   logic         nxt_csr_expn_hv;
   reg           nxt_csr_expn_update;
   reg           nxt_expn_taken;
   reg   [31:0]  nxt_csr_expn_pc;
   reg   [31:0]  nxt_dbg_expn_pc;

   wire flush_M0;
   wire flush_E;
   wire flush_D;
   wire flush_I;

   reg irq_flush;
   reg nxt_reset_req_flush;
   reg C_reset_req_flush;

   logic [1:0] I_instr_resp;

   wire E_pc_trigger;
   reg  M0_instr_trigger;
   reg  M1_instr_trigger;
   wire E_iw_trigger;
   wire C_trig_pc_en;
   wire C_trig_iw_en;
   wire C_trig_st_data_en;
   wire C_trig_st_adrs_en;
   wire C_trig_ld_data_en;
   wire C_trig_ld_adrs_en;
   wire C_trig_in_dm;
   wire M0_ls_triggered = 1'b0;
   wire M1_ls_triggered = 1'b0;
   wire [31:0] C_tdata2;
   wire M1_ebreak_to_dm;
   wire trig_to_dm;

   wire  I_branch_pred_taken;
   logic D_branch_pred_taken;
   logic E_branch_pred_taken;
   logic M0_branch_pred_taken;

   //ECC signals
   ecc_status_t csr_ecc_status;
   ecc_status_t csr_ecc_inject;


   // Instruction Words carry forward chain from one stage to next
   // in --> I --> D --> E --> M0 --> W
   //
   // **************************************************************************** //
   // ********************************* in --> I ********************************* //
   // **************************************************************************** //

   wire I_is_branch;
   reg D_is_branch;
   reg E_is_branch;
   reg M0_is_branch;
   reg M1_is_branch;

   wire I_is_wfi;
   reg D_is_wfi;
   reg E_is_wfi;
   reg M0_is_wfi;
   reg M1_is_wfi;

   reg D_mret_instr;
   reg E_mret_instr;
   reg M0_mret_instr;
   reg M1_mret_instr;

   reg D_dret_instr;
   reg E_dret_instr;
   reg M0_dret_instr;
   reg M1_dret_instr;

   reg D_fencei_instr;
   reg E_fencei_instr;
   reg M0_fencei_instr;

   wire M0_expn_ret;
   wire M0_dbg_ret;
   wire M1_expn_ret;
   wire M1_dbg_ret;
   wire M0_icache_inv;

   wire C_debug_mode;
   wire C_ebreak_in_dm;

   dbg_expn_code_t nxt_dbg_expn_type, C_dbg_expn_type;

   logic C_dbg_expn_update;
   logic C_dbg_expn_taken;

   wire nxt_dbg_expn_update;
   reg  nxt_dbg_expn_taken;
   
   wire          core_irq_en;
   wire          core_irq;
   wire          core_irq_pndg;
   xcause_code_t core_irq_cause;
   wire [7:0]    core_irq_level;
   wire          core_irq_hv;
   wire          core_debug_irq;

   wire M1_wait_for_irq;
   wire M1_ecc_wait_for_nmi;
   reg  M1_ecc_stall;

   wire nxt_reset_req_done;
   wire PC_reset_ack;
   reg [RST_REQ_DEPTH-1:0] reset_req_done_q;
   reg reset_req_ack_reg;
   reg  core_reset_req;

   wire [3:0] instr_ecc;
   wire [1:0] itag_ecc;

   wire [1:0] D_gpr_ecc;
   reg  [1:0] E_gpr_ecc;
   reg  [1:0] M0_gpr_ecc;
   reg  [1:0] M1_gpr_ecc;
   wire [1:0] D_fpr_ecc;
   reg  [1:0] E_fpr_ecc;
   reg  [1:0] M0_fpr_ecc;
   reg  [1:0] M1_fpr_ecc;
   wire D_gpr_incorrect;
   reg  E_gpr_incorrect;
   reg  M0_gpr_incorrect;
   reg  M1_gpr_incorrect;
   wire D_fpr_incorrect;
   reg  E_fpr_incorrect;
   reg  M0_fpr_incorrect;
   reg  M1_fpr_incorrect;
   wire D_instr_incorrect;
   reg  E_instr_incorrect;
   reg  M0_instr_incorrect;
   reg  M1_instr_incorrect;
   wire D_itag_incorrect;
   reg  E_itag_incorrect;
   reg  M0_itag_incorrect;
   reg  M1_itag_incorrect;
   wire D_fatal_ecc;

   wire [1:0] M1_dcache_data_ecc;
   wire [1:0] M1_dcache_dtag_ecc;
   wire [1:0] M1_dcache_dtcm1_ecc;
   wire [1:0] M1_dcache_dtcm2_ecc;
   reg  [1:0] M1_dcache_data_ecc_q;
   reg  [1:0] M1_dcache_dtag_ecc_q;
   reg  [1:0] M1_dcache_dtcm1_ecc_q;
   reg  [1:0] M1_dcache_dtcm2_ecc_q;
   wire       M1_data_incorrect;
   wire       M1_dtag_incorrect;
   wire       M1_dtcm1_incorrect;
   wire       M1_dtcm2_incorrect;

   logic  [1:0] W_dcache_data_ecc;
   logic  [1:0] W_dcache_dtag_ecc;
   logic  [1:0] W_dcache_dtcm1_ecc;
   logic  [1:0] W_dcache_dtcm2_ecc;

   reg  E_fatal_ecc;
   reg  M0_fatal_ecc;
   reg  M1_fatal_ecc;

   wire [3:0] I_instr_ecc;
   reg  [3:0] D_instr_ecc;
   reg  [3:0] E_instr_ecc;
   reg  [3:0] M0_instr_ecc;
   reg  [3:0] M1_instr_ecc;
   wire [1:0] I_itag_ecc;
   reg  [1:0] D_itag_ecc;
   reg  [1:0] E_itag_ecc;
   reg  [1:0] M0_itag_ecc;
   reg  [1:0] M1_itag_ecc;

   reg [4:0] E_ecc_rs1;
   reg [4:0] E_ecc_rs2;
   reg [4:0] M0_ecc_rs1;
   reg [4:0] M0_ecc_rs2;
   reg [4:0] M1_ecc_rs1;
   reg [4:0] M1_ecc_rs2;

   reg [5:0] ecc_status;
   reg [31:0] ecc_src;

   wire [1:0] D_rs1_gpr_ecc;
   wire [1:0] D_rs2_gpr_ecc;
   wire [1:0] D_rs1_fpr_ecc;
   wire [1:0] D_rs2_fpr_ecc;
   wire [1:0] D_rs3_fpr_ecc;
   wire D_ecc;

   logic        D_fix_gpr;
   logic [4:0]  D_fix_gpr_rd;
   logic [31:0] D_fix_gpr_val;
   logic        E_fix_gpr;
   logic [4:0]  E_fix_gpr_rd;
   logic [31:0] E_fix_gpr_val;
   logic        M0_fix_gpr;
   logic [4:0]  M0_fix_gpr_rd;
   logic [31:0] M0_fix_gpr_val;
   logic        M1_fix_gpr;
   logic [4:0]  M1_fix_gpr_rd;
   logic [31:0] M1_fix_gpr_val;

   logic        D_fix_fpr;
   logic [4:0]  D_fix_fpr_rd;
   logic [31:0] D_fix_fpr_val;
   logic        E_fix_fpr;
   logic [4:0]  E_fix_fpr_rd;
   logic [31:0] E_fix_fpr_val;
   logic        M0_fix_fpr;
   logic [4:0]  M0_fix_fpr_rd;
   logic [31:0] M0_fix_fpr_val;
   logic        M1_fix_fpr;
   logic [4:0]  M1_fix_fpr_rd;
   logic [31:0] M1_fix_fpr_val;
   logic        E_fix_gpr_fpr;
   
   logic        W_fix_gpr;
   logic        W_fix_fpr;

   wire D_use_rs1_gpr;
   wire D_use_rs2_gpr;
   wire D_use_rs1_fpr;
   wire D_use_rs2_fpr;
   wire D_use_rs3_fpr;

   wire D_dep_stall;
   wire E_ctrl_inv;
   wire M0_ctrl_inv;

   always @(posedge clk, posedge reset) begin
      if (reset)
         core_reset_req <= 1'b0;
      else
         core_reset_req <= USE_RESET_REQ & reset_req & ~(C_debug_mode | C_dbg_expn_update);
   end

   reg [31:0] dbg_vector;

   wire M1_ci_done = core_ci_done;
   wire [31:0] M1_ci_result = core_ci_result;
   assign core_ci_data0       = M1_exe_s1;
   assign core_ci_data1       = M1_exe_s2;
   assign core_ci_alu_result  = M1_exe_result;
   assign core_ci_ctrl        = M1_instr_word;
   assign core_ci_enable      = M1_ci_enable;
   assign core_ci_op          = M1_ci_op;

   always @(posedge clk, posedge internal_reset) begin
      if (internal_reset)
         dbg_vector <= DBG_EXPN_VECTOR;
      else begin
         if (M0_instr_valid)
            if (C_debug_mode)
               dbg_vector <= DBG_PARK_LOOP;
            else
               dbg_vector <= DBG_EXPN_VECTOR;
      end
   end

   // Issue new instruction request (or not)
   //    - Branch being processed by pipeline
   //          - TODO: This inserts a stall in pipe. To be removed and replaced with branch prediction logic
   //    - Instruction request sent, waiting for response
   //    - Instruction request asserted, waiting for it to be accepted
   //    - Intruction in F stage not consumed (stalled)
   wire[31:0] instr_fetch_araddr;
   wire       instr_fetch_arvalid;
   wire       instr_fetch_arready;
   wire       instr_fetch_rvalid;
   wire[31:0] instr_fetch_rdata;

   //Cleanly instantiate wires needed for the newly added PC NEXT INFO port signals from the fetch / new PC modules.
   wire           redir_pc_update_req, seq_pc_update_req, branch_pred_update_req;
   wire  [31:0]   fetch_pc, predicted_pc;
   generate
      if (BRANCHPREDICTION_EN == 0) begin : pc_next_info_signals_without_branch_prediction
         assign   branch_pred_update_req  =  1'b0; 
         assign   predicted_pc            =  32'd0;
      end
   endgenerate

   generate
      if (BRANCHPREDICTION_EN == 0) begin : gen_without_branch_prediction
         //branch prediction is not enabled, tie the 'taken' signal to 0
         assign I_branch_pred_taken = 'b0;
         niosv_g_fetch # (
            .RESET_VECTOR     (RESET_VECTOR),
            .ECC_EN           (ECC_EN),
            .BUFFER_SIZE      (4)
         ) instr_fetch_inst (
            .clk              (clk),
            .reset            (internal_reset),
            .external_reset   (reset),
            .reset_req        (core_reset_req && USE_RESET_REQ),
            .reset_ack        (PC_reset_ack),
      
            // ======== AXI4-Lite Interface ========
            // read address
            .instr_araddr     (instr_fetch_araddr),
            .instr_arvalid    (instr_fetch_arvalid),
            .instr_arready    (instr_fetch_arready),
      
            // read response
            .instr_rvalid     (instr_fetch_rvalid),
            .instr_rdata      (instr_fetch_rdata),
            .instr_rresp      (instr_rresp),           // This is weird but carried over from older versions of the core
            .instr_ecc        (instr_ecc),
            .itag_ecc         (itag_ecc),
      
            // ========== Core Interface ===========
            .dbg_expn_redir   (DEBUG_ENABLED ? C_dbg_expn_taken : 1'b0),      // 1st priority: Debug Exceptions
            .expn_redir       (C_expn_taken),                                 // 2nd priority: Exceptions in machine mode
            .instr_redir      (M1_ready & M0_redirect & ~flush_M0),           // 3rd priority: Instruction Redirect
                                                                              // TODO: do we neeed M0_instr_valid here?
            .dbg_vector       (dbg_vector),
            .expn_vector      (C_expn_redirect_pc),
            .branch_addr      (M0_redirect_pc),
            .hazard           (~D_ready),
            .prg_addr         (I_instr_pc),
            .prg_data         (I_instr_word),
            .prg_resp         (I_instr_resp),
            .prg_instr_ecc    (I_instr_ecc),
            .prg_itag_ecc     (I_itag_ecc),
      
            .prg_data_valid   (I_instr_valid),

            .redir_pc_update_req_o   (redir_pc_update_req),
            .seq_pc_update_req_o     (seq_pc_update_req  ),
            .fetch_pc_o              (fetch_pc           )
         );
      end else begin : gen_branch_prediction
         niosv_g_new_pc # (
             .RESET_VECTOR (RESET_VECTOR),
             .ECC_EN       (ECC_EN)
         )  new_pc_inst (
             .clk              (clk),
             .external_reset   (reset),
             .reset            (internal_reset),
             .reset_req        (core_reset_req && USE_RESET_REQ),
             .reset_ack        (PC_reset_ack),
         
             // ======== AXI4-Lite Interface ========
             // read address
             .instr_araddr     (instr_fetch_araddr), 
             .instr_arvalid    (instr_fetch_arvalid),
             .instr_arready    (instr_fetch_arready),
         
             // read response 
             .instr_rvalid     (instr_fetch_rvalid),
             .instr_rdata      (instr_fetch_rdata),   
             .instr_rresp      (instr_rresp),   
             .instr_ecc        (instr_ecc),
             .itag_ecc         (itag_ecc),
         
             // ========== Core Interface ===========
             .dbg_expn_redir   (DEBUG_ENABLED ? C_dbg_expn_taken : 1'b0), // 1st priority: Debug Exceptions 
             .expn_redir       (C_expn_taken),                            // 2nd priority: Exceptions in machine mode
             .instr_redir      (M1_ready & M0_redirect & ~flush_M0),      // 3rd priority: Instruction Redirect in case of a misprediction 
             .dbg_vector       (dbg_vector),           // Debug Exception PC
             .expn_vector      (C_expn_redirect_pc),   // Exception PC in machine mode 
             .branch_addr      (M0_redirect_pc),       // Branch misprediction PC
             .hazard           (~D_ready),             // Stall for Hazards
         
             .prg_addr         (I_instr_pc),           // Instr PC
             .prg_data         (I_instr_word),         // Instr Data
             .prg_resp         (I_instr_resp),         // Instr Response
             .prg_instr_ecc    (I_instr_ecc),          // Instr ECC
             .prg_itag_ecc     (I_itag_ecc),           // Itag  ECC
             .prg_data_valid   (I_instr_valid),        // Data Valid
             //.mispred_pc       (I_mispred_pc),
         
             .branch_pred_taken(I_branch_pred_taken),   // Branch Prediction taken signal

             .redir_pc_update_req_o       (redir_pc_update_req    ),
             .seq_pc_update_req_o         (seq_pc_update_req      ),
             .branch_pred_update_req_o    (branch_pred_update_req ),
             .fetch_pc_o                  (fetch_pc               ),
             .predicted_pc_o              (predicted_pc           )
         );
      end
   endgenerate

   generate
      if ((INST_CACHE_SIZE == 0) && (ITCM1_SIZE == 0) && (ITCM2_SIZE == 0)) begin : gen_direct_instr_fetch
         // In the absence of an I-cache module, some signals need to be tied off 
         assign instr_ecc           = 4'b0;
         assign itag_ecc            = 2'b0;
         // Other than that, just expose the AXI4-Lite interface of the instruction fetch unit
         assign instr_awvalid       = 1'b0;
         assign instr_awaddr        = 32'b0;
         assign instr_awprot        = 3'b010;
         assign instr_awsize        = 3'd2;
         assign instr_awlen         = 8'b0;
         assign instr_awburst       = 2'b1;
         assign instr_wvalid        = 1'b0;
         assign instr_wdata         = 32'b0;
         assign instr_wstrb         = 4'b0;
         assign instr_wlast         = 1'b1;
         assign instr_bready        = 1'b1;
         assign instr_arvalid       = instr_fetch_arvalid;
         assign instr_araddr        = instr_fetch_araddr;
         assign instr_arprot        = 3'b010;
         assign instr_arsize        = 3'd2;
         assign instr_arlen         = 8'b0;
         assign instr_arburst       = 2'b1;
         assign instr_fetch_arready = instr_arready;
         assign instr_fetch_rvalid  = instr_rvalid;
         assign instr_fetch_rdata   = instr_rdata;
         assign instr_rready        = 1'b1;
         assign instr_ecc           = 4'b0;
         assign itag_ecc            = 2'b0;
         assign itcs1_awready       = 1'b0;
         assign itcs1_wready        = 1'b0;
         assign itcs1_arready       = 1'b0;
         assign itcs1_rvalid        = 1'b0;
         assign itcs1_rresp         = 2'b0;
         assign itcs1_rdata         = 32'd0;
         assign itcs1_bvalid        = 1'b0;
         assign itcs1_bresp         = 2'b0;
         assign itcs2_awready       = 1'b0;
         assign itcs2_wready        = 1'b0;
         assign itcs2_arready       = 1'b0;
         assign itcs2_rvalid        = 1'b0;
         assign itcs2_rresp         = 2'b0;
         assign itcs2_rdata         = 32'd0;
         assign itcs2_bvalid        = 1'b0;
         assign itcs2_bresp         = 2'b0;
      end 
      else if ((INST_CACHE_SIZE == 0) && ( (ITCM1_SIZE > 0) || (ITCM2_SIZE > 0)) ) begin : gen_tcm_only_instr_fetch
         logic[31:0] instr_word_awaddr;
         logic[31:0] instr_word_araddr;
      
         // Word to byte address conversion
         // I_cache logic is word address based hence this is required.
         assign instr_awaddr = {instr_word_awaddr[29:0], 2'b00};
         assign instr_araddr = {instr_word_araddr[29:0], 2'b00};
      
         niosv_g_itcm # (
            .RAM_TYPE                  (RAM_TYPE),
            .ITCM1_SIZE                (ITCM1_SIZE),
            .ITCM1_BASE                (ITCM1_BASE),
            .ITCM1_INIT_FILE           (ITCM1_INIT_FILE),
            .ITCM2_SIZE                (ITCM2_SIZE),
            .ITCM2_BASE                (ITCM2_BASE),
            .ITCM2_INIT_FILE           (ITCM2_INIT_FILE),
            .ECC_EN                    (ECC_EN),
            .DEVICE_FAMILY             (DEVICE_FAMILY),
            .ITCS1_ADDR_WIDTH          (ITCS1_ADDR_WIDTH),
            .ITCS2_ADDR_WIDTH          (ITCS2_ADDR_WIDTH)
         ) itcm_inst (
            .clk                       (clk),
            .rst                       (reset),
      
            .write_ready               (),
            .read_ready                (instr_fetch_arready),
            .read_valid                (instr_fetch_rvalid),
            .cpu_wren                  (1'b0),
            .cpu_ren                   (instr_fetch_arvalid),               // Instr request
            .cpu_address               ({2'b00, instr_fetch_araddr[31:2]}), // Requested PC
            .to_cpu                    (instr_fetch_rdata),                 // Response Instruction from icache or itcm
            .from_cpu                  (32'h00000000),
      
            .ecc_inject                (csr_ecc_inject),
            .instr_ecc_to_cpu          (instr_ecc),
            .itag_ecc_to_cpu           (itag_ecc),
      
            .awaddr                    (instr_word_awaddr),
            .awprot                    (instr_awprot),
            .awvalid                   (instr_awvalid),
            .awsize                    (instr_awsize),
            .awlen                     (instr_awlen),
            .awburst                   (instr_awburst),
            .awready                   (instr_awready),
      
            .wvalid                    (instr_wvalid),
            .wdata                     (instr_wdata),
            .wstrb                     (instr_wstrb),
            .wlast                     (instr_wlast),
            .wready                    (instr_wready),
      
            .bvalid                    (instr_bvalid),
            .bresp                     (instr_bresp),
            .bready                    (instr_bready),
      
            // I-cache write interface from core interface
            .araddr                    (instr_word_araddr),
            .arprot                    (instr_arprot),
            .arvalid                   (instr_arvalid),
            .arsize                    (instr_arsize),
            .arlen                     (instr_arlen),
            .arburst                   (instr_arburst),
            .arready                   (instr_arready),
      
            .rdata                     (instr_rdata),
            .rvalid                    (instr_rvalid),
            .rresp                     (instr_rresp),
            .rready                    (instr_rready),
      
            .itcs1_awaddr              (itcs1_awaddr),
            .itcs1_awprot              (itcs1_awprot),
            .itcs1_awvalid             (itcs1_awvalid),
            .itcs1_awready             (itcs1_awready),
      
            .itcs1_wvalid              (itcs1_wvalid),
            .itcs1_wdata               (itcs1_wdata),
            .itcs1_wstrb               (itcs1_wstrb),
            .itcs1_wready              (itcs1_wready),
      
            .itcs1_bvalid              (itcs1_bvalid),
            .itcs1_bresp               (itcs1_bresp),
            .itcs1_bready              (itcs1_bready),
      
            .itcs1_araddr              (itcs1_araddr),
            .itcs1_arprot              (itcs1_arprot),
            .itcs1_arvalid             (itcs1_arvalid),
            .itcs1_arready             (itcs1_arready),
      
            .itcs1_rdata               (itcs1_rdata),
            .itcs1_rvalid              (itcs1_rvalid),
            .itcs1_rresp               (itcs1_rresp),
            .itcs1_rready              (itcs1_rready),
      
            .itcs2_awaddr              (itcs2_awaddr),
            .itcs2_awprot              (itcs2_awprot),
            .itcs2_awvalid             (itcs2_awvalid),
            .itcs2_awready             (itcs2_awready),
      
            .itcs2_wvalid              (itcs2_wvalid),
            .itcs2_wdata               (itcs2_wdata),
            .itcs2_wstrb               (itcs2_wstrb),
            .itcs2_wready              (itcs2_wready),
      
            .itcs2_bvalid              (itcs2_bvalid),
            .itcs2_bresp               (itcs2_bresp),
            .itcs2_bready              (itcs2_bready),
      
            .itcs2_araddr              (itcs2_araddr),
            .itcs2_arprot              (itcs2_arprot),
            .itcs2_arvalid             (itcs2_arvalid),
            .itcs2_arready             (itcs2_arready),
      
            .itcs2_rdata               (itcs2_rdata),
            .itcs2_rvalid              (itcs2_rvalid),
            .itcs2_rresp               (itcs2_rresp),
            .itcs2_rready              (itcs2_rready)
         );
      end 
      else begin : gen_cached_instr_fetch
         logic[31:0] instr_word_awaddr;
         logic[31:0] instr_word_araddr;
      
         // Word to byte address conversion
         // I_cache logic is word address based hence this is required.
         assign instr_awaddr = {instr_word_awaddr[29:0], 2'b00};
         assign instr_araddr = {instr_word_araddr[29:0], 2'b00};
      
         // ache NCR parameters are word addresses...
         // Set start address higher than end address to disable a region
         niosv_g_instr_cache # (
            .RAM_TYPE                  (RAM_TYPE),
            .NCR1_START                (DBG_DATA_S_BASE / 4),
            .NCR1_END                  ((DBG_DATA_S_BASE + 32'h0000ffff) / 4),
            .NCR2_START                (0),
            .NCR2_END                  (2000000),
      
            .ICACHE_SIZE               (INST_CACHE_SIZE),
            .DEBUG_ENABLED             (DEBUG_ENABLED),
            .DBG_DATA_S_BASE           (DBG_DATA_S_BASE),
            .TIMER_MSIP_DATA_S_BASE    (TIMER_MSIP_DATA_S_BASE),
            .PERIPHERAL_REGION_A_SIZE  (PERIPHERAL_REGION_A_SIZE),
            .PERIPHERAL_REGION_A_BASE  (PERIPHERAL_REGION_A_BASE),
            .PERIPHERAL_REGION_B_SIZE  (PERIPHERAL_REGION_B_SIZE),
            .PERIPHERAL_REGION_B_BASE  (PERIPHERAL_REGION_B_BASE),
            .ITCM1_SIZE                (ITCM1_SIZE),
            .ITCM1_BASE                (ITCM1_BASE),
            .ITCM1_INIT_FILE           (ITCM1_INIT_FILE),
            .ITCM2_SIZE                (ITCM2_SIZE),
            .ITCM2_BASE                (ITCM2_BASE),
            .ITCM2_INIT_FILE           (ITCM2_INIT_FILE),
            .ECC_EN                    (ECC_EN),
            .ECC_FULL                  (ECC_FULL),
            .DEVICE_FAMILY             (DEVICE_FAMILY),
            .ITCS1_ADDR_WIDTH          (ITCS1_ADDR_WIDTH),
            .ITCS2_ADDR_WIDTH          (ITCS2_ADDR_WIDTH)
         ) icache_inst (
            .clk                       (clk),
            .rst                       (reset),
            .flush                     (1'b0),
            .prefetch                  (1'b0),
            .cache_inv_req             (M0_icache_inv),
      
            .write_ready               (),
            .read_ready                (instr_fetch_arready),
            .read_valid                (instr_fetch_rvalid),
            .cpu_wren                  (1'b0),
            .cpu_ren                   (instr_fetch_arvalid),               // Instr request
            .cpu_address               ({2'b00, instr_fetch_araddr[31:2]}), // Requested PC
            .to_cpu                    (instr_fetch_rdata),                 // Response Instruction from icache or itcm
            .from_cpu                  (32'h00000000),
      
            .ecc_inject                (csr_ecc_inject),
            .instr_ecc_to_cpu          (instr_ecc),
            .itag_ecc_to_cpu           (itag_ecc),
      
            .awaddr                    (instr_word_awaddr),
            .awprot                    (instr_awprot),
            .awvalid                   (instr_awvalid),
            .awsize                    (instr_awsize),
            .awlen                     (instr_awlen),
            .awburst                   (instr_awburst),
            .awready                   (instr_awready),
      
            .wvalid                    (instr_wvalid),
            .wdata                     (instr_wdata),
            .wstrb                     (instr_wstrb),
            .wlast                     (instr_wlast),
            .wready                    (instr_wready),
      
            .bvalid                    (instr_bvalid),
            .bresp                     (instr_bresp),
            .bready                    (instr_bready),
      
            // I-cache write interface from core interface
            .araddr                    (instr_word_araddr),
            .arprot                    (instr_arprot),
            .arvalid                   (instr_arvalid),
            .arsize                    (instr_arsize),
            .arlen                     (instr_arlen),
            .arburst                   (instr_arburst),
            .arready                   (instr_arready),
      
            .rdata                     (instr_rdata),
            .rvalid                    (instr_rvalid),
            .rresp                     (instr_rresp),
            .rready                    (instr_rready),
      
            .itcs1_awaddr              (itcs1_awaddr),
            .itcs1_awprot              (itcs1_awprot),
            .itcs1_awvalid             (itcs1_awvalid),
            .itcs1_awready             (itcs1_awready),
      
            .itcs1_wvalid              (itcs1_wvalid),
            .itcs1_wdata               (itcs1_wdata),
            .itcs1_wstrb               (itcs1_wstrb),
            .itcs1_wready              (itcs1_wready),
      
            .itcs1_bvalid              (itcs1_bvalid),
            .itcs1_bresp               (itcs1_bresp),
            .itcs1_bready              (itcs1_bready),
      
            .itcs1_araddr              (itcs1_araddr),
            .itcs1_arprot              (itcs1_arprot),
            .itcs1_arvalid             (itcs1_arvalid),
            .itcs1_arready             (itcs1_arready),
      
            .itcs1_rdata               (itcs1_rdata),
            .itcs1_rvalid              (itcs1_rvalid),
            .itcs1_rresp               (itcs1_rresp),
            .itcs1_rready              (itcs1_rready),
      
            .itcs2_awaddr              (itcs2_awaddr),
            .itcs2_awprot              (itcs2_awprot),
            .itcs2_awvalid             (itcs2_awvalid),
            .itcs2_awready             (itcs2_awready),
      
            .itcs2_wvalid              (itcs2_wvalid),
            .itcs2_wdata               (itcs2_wdata),
            .itcs2_wstrb               (itcs2_wstrb),
            .itcs2_wready              (itcs2_wready),
      
            .itcs2_bvalid              (itcs2_bvalid),
            .itcs2_bresp               (itcs2_bresp),
            .itcs2_bready              (itcs2_bready),
      
            .itcs2_araddr              (itcs2_araddr),
            .itcs2_arprot              (itcs2_arprot),
            .itcs2_arvalid             (itcs2_arvalid),
            .itcs2_arready             (itcs2_arready),
      
            .itcs2_rdata               (itcs2_rdata),
            .itcs2_rvalid              (itcs2_rvalid),
            .itcs2_rresp               (itcs2_rresp),
            .itcs2_rready              (itcs2_rready)
         );
      end
   endgenerate

   wire [COPCODE_W-1:0]  I_iw_cop = I_instr_word[COPCODE_FIELD_H:COPCODE_FIELD_L];
   wire [OPCODE_W-1:0]   E_iw_op  = E_instr_word[OPCODE_FIELD_H:OPCODE_FIELD_L];
   wire [OPCODE_W-1:0]   M0_iw_op = M0_instr_word[OPCODE_FIELD_H:OPCODE_FIELD_L];
   wire [F3_FIELD_W-1:0] I_iw_f3  = I_instr_word[F3_FIELD_H:F3_FIELD_L];
   wire [F3_FIELD_W-1:0] M0_iw_f3 = M0_instr_word[F3_FIELD_H:F3_FIELD_L];

   wire I_ld_op        = (I_iw_cop == LOAD_COP);
   wire I_st_op        = (I_iw_cop == STORE_COP);
   wire I_branch_op    = (I_iw_cop == B_COP);
   wire I_alu_i_op     = (I_iw_cop == ALU_I_COP);

   assign I_jalr_instr = (I_iw_cop == JALR_COP);
   wire I_jal_instr    = (I_iw_cop == JAL_COP);
   wire I_auipc_instr  = (I_iw_cop == AUIPC_COP);
   wire I_lui_instr    = (I_iw_cop == LUI_COP);
   wire I_fp_ld_op     = FLOAT_ENABLED /*&& (I_iw_f3 == F3_2)*/ && (I_iw_cop == FP_LOAD_COP);
   wire I_fp_st_op     = FLOAT_ENABLED /*&& (I_iw_f3 == F3_2)*/ && (I_iw_cop == FP_STORE_COP);

   wire I_beq_instr    = I_branch_op && (I_iw_f3 == F3_0);
   wire I_bne_instr    = I_branch_op && (I_iw_f3 == F3_1);
   wire I_blt_instr    = I_branch_op && (I_iw_f3 == F3_4);
   wire I_bge_instr    = I_branch_op && (I_iw_f3 == F3_5);
   wire I_bltu_instr   = I_branch_op && (I_iw_f3 == F3_6);
   wire I_bgeu_instr   = I_branch_op && (I_iw_f3 == F3_7);
   wire I_ebreak_instr = (I_instr_word == EBREAK_INSTR);
   wire I_ecall_instr  = (I_instr_word == ECALL_INSTR);
   wire I_mret_instr   = (I_instr_word == MRET_INSTR);
   wire I_dret_instr   = DEBUG_ENABLED && (I_instr_word == DRET_INSTR);
   wire I_fencei_instr = (I_iw_cop == MISC_MEM_COP) && (I_iw_f3 == F3_1);

   assign I_load_op    = I_ld_op | I_fp_ld_op;
   assign I_store_op   = I_st_op | I_fp_st_op;

   wire I_itype        = I_jalr_instr | I_load_op | I_alu_i_op;
   wire I_stype        = I_store_op;
   wire I_btype        = I_branch_op;
   wire I_utype        = I_lui_instr | I_auipc_instr;
   wire I_jtype        = I_jal_instr;

   // Extended immediate for various instructions
   // Use itype immediate as shamt for shift instructions since only lower five bits will ever be used
   wire [IMM_W-1:0] I_itype_ext_imm = {{I_IMM_EXT{I_instr_word[I_IMM_S]}}, I_instr_word[I_IMM_FIELD_H:I_IMM_FIELD_L]};
   wire [IMM_W-1:0] I_stype_ext_imm = {{S_IMM_EXT{I_instr_word[S_IMM_S]}}, I_instr_word[S_IMM1_FIELD_H:S_IMM1_FIELD_L], I_instr_word[S_IMM0_FIELD_H:S_IMM0_FIELD_L]};
   wire [IMM_W-1:0] I_btype_ext_imm = {
                        {B_IMM_EXT{I_instr_word[B_IMM3_FIELD_H]}},      // sign extension
                        I_instr_word[B_IMM3_FIELD_H:B_IMM3_FIELD_L],
                        I_instr_word[B_IMM2_FIELD_H:B_IMM2_FIELD_L],
                        I_instr_word[B_IMM1_FIELD_H:B_IMM1_FIELD_L],
                        I_instr_word[B_IMM0_FIELD_H:B_IMM0_FIELD_L],
                        1'b0
                     };
   wire [IMM_W-1:0] I_utype_ext_imm = {I_instr_word[U_IMM_FIELD_H:U_IMM_FIELD_L], LUI_EXT};
   wire [IMM_W-1:0] I_jtype_ext_imm = {
                        {J_IMM_EXT{I_instr_word[J_IMM3_FIELD_H]}},      // sign extension
                        I_instr_word[J_IMM3_FIELD_H:J_IMM3_FIELD_L],
                        I_instr_word[J_IMM2_FIELD_H:J_IMM2_FIELD_L],
                        I_instr_word[J_IMM1_FIELD_H:J_IMM1_FIELD_L],
                        I_instr_word[J_IMM0_FIELD_H:J_IMM0_FIELD_L],
                        1'b0
                     };

   assign I_mem_op = I_load_op | I_store_op;
   assign I_amo_op = ATOMIC_ENABLED & (I_iw_cop == ATOMIC_COP);
   assign I_misc_mem_op = (I_iw_cop == MISC_MEM_COP);

   assign I_use_imm = I_itype | I_stype | I_utype | I_amo_op | I_misc_mem_op;  // when setting D_exe_s2 = D_imm; want D_imm = 32'b0 for atomics and misc_mem_ops
   assign I_imm = ({IMM_W{I_itype}} & I_itype_ext_imm) |
                  ({IMM_W{I_stype}} & I_stype_ext_imm) |
                  ({IMM_W{I_btype}} & I_btype_ext_imm) |
                  ({IMM_W{I_utype}} & I_utype_ext_imm) |
                  ({IMM_W{I_jtype}} & I_jtype_ext_imm);

   assign I_is_branch = I_instr_valid & (I_jal_instr   |
                                         I_jalr_instr  |
                                         I_beq_instr   |
                                         I_bne_instr   |
                                         I_blt_instr   |
                                         I_bge_instr   |
                                         I_bltu_instr  |
                                         I_bgeu_instr  |
                                         I_mret_instr  |
                                         (I_dret_instr & C_debug_mode)
                                        );

   always @(posedge clk, posedge internal_reset) begin
      if (internal_reset) begin
         D_is_branch  <= 1'b0;
         E_is_branch  <= 1'b0;
         M0_is_branch <= 1'b0;
      end
      else begin
         if (D_ready) begin
            D_is_branch <= I_is_branch;
         end

         if (E_ready) begin
            E_is_branch <= D_is_branch & D_instr_valid;
         end

         if (M0_ready) begin
            M0_is_branch <= E_is_branch & E_instr_valid;
         end
      end
   end

   // ***** WFI instruction ***** //
   // Pass on the instruction to M0 and wait for any interrupt. Interrupt need not be service.
   // As soon as interrupt is pending, M0 is ready.
   // If interrupts are enabled, it should be taken on the next instruction.

   assign I_is_wfi = (I_instr_word == WFI_INSTR);

   always @(posedge clk, posedge internal_reset) begin
      if (internal_reset) begin
         D_is_wfi  <= 1'b0;
         E_is_wfi  <= 1'b0;
         M0_is_wfi <= 1'b0;
         M1_is_wfi <= 1'b0;
      end
      else begin
         if (D_ready) begin
            D_is_wfi <= I_is_wfi & ~C_debug_mode;
         end

         if (E_ready) begin
            E_is_wfi <= D_is_wfi & D_instr_valid;
         end

         if (M0_ready) begin
            M0_is_wfi <= E_is_wfi & E_instr_valid & ~flush_E;
         end

         if (M1_ready) begin
            M1_is_wfi <= M0_is_wfi & M0_instr_valid & ~flush_M0;
         end
      end
   end

   // **************************************************************************** //
   // ********************************* I --> D ********************************** //
   // **************************************************************************** //

   // Dependency Check and Stall for all instructions, single- and multicycle
   // TODO: Include logic for stalls from branch and exceptions (may already be solved by the formulation below).

   // For M1, need to stall additionally for E_csr_read. With M0, C_read is
   // done at E-stage, which is sufficient when forwarded to D. For M1, C_read
   // is done at M0 stage and cannot be forwarded. Need to stall to let
   // E_csr_read to go to M0, then forward from M0->D.

   assign D_dep_stall_from_E = E_instr_valid & E_multicycle_op &
                               (((E_rd == D_iw_rs1) &
                                 ((E_gpr_wr_en & D_needs_gp_rs1) | (E_fpr_wr_en & D_needs_fp_rs1))) ||
                                ((E_rd == D_iw_rs2) &
                                 ((E_gpr_wr_en & D_needs_gp_rs2) | (E_fpr_wr_en & D_needs_fp_rs2))) ||
                                ((E_rd == D_iw_rs3) &
                                 (E_fpr_wr_en & D_needs_fp_rs3)));

   assign D_dep_stall_from_M0 = ~M0_instr_done &
                                (((M0_rd == D_iw_rs1) &
                                  ((M0_gpr_wr_en & D_needs_gp_rs1) | (M0_fpr_wr_en & D_needs_fp_rs1))) ||
                                 ((M0_rd == D_iw_rs2) &
                                  ((M0_gpr_wr_en & D_needs_gp_rs2) | (M0_fpr_wr_en & D_needs_fp_rs2))) ||
                                 ((M0_rd == D_iw_rs3) &
                                  (M0_fpr_wr_en & D_needs_fp_rs3)));

   assign D_dep_stall_from_M1 = ~M1_instr_done &
                                (((M1_rd == D_iw_rs1) &
                                  ((M1_gpr_wr_en & D_needs_gp_rs1) | (M1_fpr_wr_en & D_needs_fp_rs1))) ||
                                 ((M1_rd == D_iw_rs2) &
                                  ((M1_gpr_wr_en & D_needs_gp_rs2) | (M1_fpr_wr_en & D_needs_fp_rs2))) ||
                                 ((M1_rd == D_iw_rs3) &
                                  (M1_fpr_wr_en & D_needs_fp_rs3)));
                                    
   assign D_dep_stall = D_dep_stall_from_E | D_dep_stall_from_M0 | D_dep_stall_from_M1;

   assign D_ready = flush_E | (E_ready & ~D_dep_stall);

   generate if (DEBUG_ENABLED) begin : gen_E_debug
   // Instruction trigger will be flagged before completion of the instruction.
   // Comparision is done in E stage to be precise: Instruction ahead of this instruction could update the trigger settings.

      // TODO: Currently exact match only for instruction PC
      assign E_pc_trigger = C_trig_pc_en & (E_instr_pc == C_tdata2);

      // Opcode match only for instruction trigger.
      assign E_iw_trigger = C_trig_iw_en & (E_iw_op == C_tdata2[6:0]);
   end
   else begin : gen_E_debug_tieoff
      assign E_pc_trigger = 1'b0;
      assign E_iw_trigger = 1'b0;
   end
   endgenerate

   always @(posedge clk) begin
      if (D_ready) begin
         D_instr_pc       <= I_instr_pc;
         D_previous_srf   <= I_previous_srf;
         D_iw_rs1         <= I_iw_rs1;
         D_iw_rs2         <= I_iw_rs2;
         D_iw_rs3         <= I_iw_rs3;
         D_iw_rs1_is_zero <= (I_iw_rs1 == 5'd0);
         D_iw_rs2_is_zero <= (I_iw_rs2 == 5'd0);
         D_branch_op      <= I_branch_op;
         D_jump_op        <= I_jal_instr | I_jalr_instr;
         D_auipc_lui_op   <= I_auipc_instr | I_lui_instr;    
         D_beq_bne_op     <= I_beq_instr | I_bne_instr;
         D_blt_bge_op     <= I_blt_instr | I_bge_instr | I_bltu_instr | I_bgeu_instr;
         D_bne_bge_op     <= I_bne_instr | I_bge_instr | I_bgeu_instr;
         D_load_op        <= I_load_op;
         D_store_op       <= I_store_op;
         D_mem_op         <= I_mem_op;
         D_amo_op         <= I_amo_op;
         D_jalr_instr     <= I_jalr_instr;
         D_imm            <= I_imm;
         D_use_imm        <= I_use_imm;
      end
   end

   always @(posedge clk, posedge internal_reset) begin
      if (internal_reset) begin
         D_instr_valid <= 1'b0;
         D_instr_word <= NOP_VAL;  // NOP
         D_branch_pred_taken <= 1'b0;
      end
      else if (D_ready) begin
         D_instr_word <= I_instr_word;
         D_branch_pred_taken <= I_branch_pred_taken & I_instr_valid;

         if (flush_I | C_expn_taken | C_dbg_expn_taken)
            D_instr_valid <= 1'b0;
         else
            D_instr_valid <= I_instr_valid;
      end
   end

   reg D_icache_ecc;

   always @(posedge clk, posedge reset) begin
      if (reset) begin
         D_instr_ecc  <= 4'b0;
         D_itag_ecc   <= 2'b0;
         D_icache_ecc <= 1'b0;
      end
      else if (D_ready) begin
         D_instr_ecc  <= I_instr_ecc;
         D_itag_ecc   <= I_itag_ecc;
         D_icache_ecc <= ~|I_instr_ecc[3:2];
      end
   end

   always @(posedge clk, posedge internal_reset) begin
      if (internal_reset) begin
         D_mret_instr   <= 1'b0;
         D_dret_instr   <= 1'b0;
         D_fencei_instr <= 1'b0;
      end
      else if (D_ready) begin
         D_mret_instr   <= I_mret_instr;
         D_dret_instr   <= I_dret_instr;
         D_fencei_instr <= I_fencei_instr;
      end
   end

   // **************************************************************************** //
   // ********************************* D --> E ********************************** //
   // **************************************************************************** //

   logic E_mispred;
   assign E_ready = M0_ready;

   assign E_redirect = E_redirect_alu != E_branch_pred_taken;
   assign E_mispred  = ~E_redirect_alu & E_branch_pred_taken;

   always @(posedge clk, posedge internal_reset) begin
      if (internal_reset) begin
         E_instr_word <= NOP_VAL;  // NOP
      end
      else if (E_ready) begin
         E_instr_word <= D_instr_word;
      end
   end

   always @(posedge clk) begin
      if (E_ready) begin
         E_csr_s1         <= D_exe_s1;
         E_exe_s1         <= D_exe_s1;
         E_exe_s2         <= D_exe_s2;
         E_muldiv_ctrl_1  <= D_muldiv_ctrl_1;
         E_muldiv_ctrl_2  <= D_muldiv_ctrl_2;
         E_mul_use_lsw    <= D_mul_use_lsw;
         E_rd             <= D_rd;
         E_shift_amt      <= D_use_imm ? D_imm[4:0] : D_rs2_gpr_val[4:0];
         E_exe_op         <= D_exe_op;
         E_fp_op_decode   <= D_fp_op_decode;
         E_iw_rs1_is_zero <= D_iw_rs1_is_zero;
         E_rs1_gpr_val    <= D_rs1_gpr_val;
         E_rs2_gpr_val    <= D_rs2_gpr_val;
         E_rs1_fpr_val    <= D_rs1_fpr_val;
         E_rs2_fpr_val    <= D_rs2_fpr_val;
         E_store_gpr      <= D_needs_gp_rs2;
         E_instr_pc       <= D_instr_pc;
         E_nxt_seq_pc     <= D_instr_pc + 4'd4;
         E_computed_pc    <= D_computed_pc;   
         E_csr_addr       <= D_csr_addr;
         E_jalr_instr     <= D_jalr_instr & ~D_ecc;
      end
   end

   always @(posedge clk, posedge internal_reset) begin
      if (internal_reset) begin
         E_instr_valid     <= 1'b0;
         E_gpr_wr_en       <= 1'b0;
         E_fpr_wr_en       <= 1'b0;
         E_fatal_ecc       <= 1'b0;
         E_gpr_incorrect   <= 1'b0;
         E_fpr_incorrect   <= 1'b0;
         E_instr_incorrect <= 1'b0;
         E_itag_incorrect  <= 1'b0;
      end
      else if (flush_D) begin
         E_instr_valid     <= 1'b0;
         E_gpr_wr_en       <= 1'b0;
         E_fpr_wr_en       <= 1'b0;
         E_fatal_ecc       <= 1'b0;
         E_gpr_incorrect   <= 1'b0;
         E_fpr_incorrect   <= 1'b0;
         E_instr_incorrect <= 1'b0;
         E_itag_incorrect  <= 1'b0;
      end
      else if (E_ready) begin
         if (D_dep_stall) begin
            E_instr_valid     <= 1'b0;
            E_gpr_wr_en       <= 1'b0;
            E_fpr_wr_en       <= 1'b0;
            E_fatal_ecc       <= 1'b0;
            E_gpr_incorrect   <= 1'b1;
            E_fpr_incorrect   <= 1'b1;
            E_instr_incorrect <= 1'b0;
            E_itag_incorrect  <= 1'b0;
         end
         else begin
            E_gpr_wr_en       <= D_gpr_wr_en & D_instr_valid & ~D_ecc;
            E_fpr_wr_en       <= D_fpr_wr_en & D_instr_valid & ~D_ecc;
            E_instr_valid     <= D_instr_valid;
            E_fatal_ecc       <= D_fatal_ecc & D_instr_valid;
            E_gpr_incorrect   <= D_gpr_incorrect & D_instr_valid;
            E_fpr_incorrect   <= D_fpr_incorrect & D_instr_valid;
            E_instr_incorrect <= D_instr_incorrect & D_instr_valid;
            E_itag_incorrect  <= D_itag_incorrect & D_instr_valid;
         end
      end
   end

   always @(posedge clk, posedge internal_reset) begin
      if (internal_reset) begin
         E_multicycle_op         <= 1'b0;
         E_long_op               <= 1'b0;
         E_3stage_fp_op          <= 1'b0;
         E_long_fp_op            <= 1'b0;
         E_branch_op             <= 1'b0;
         E_jump_op               <= 1'b0;
         E_jalr_op               <= 1'b0;
         E_auipc_lui_op          <= 1'b0;
         E_beq_bne_op            <= 1'b0;
         E_blt_bge_op            <= 1'b0;
         E_bne_bge_op            <= 1'b0;
         E_cmp_lt_ltu_op         <= 1'b0;
         E_srx_op                <= 1'b0;
         E_sra_op                <= 1'b0;
         E_sll_op                <= 1'b0;
         E_or_op                 <= 1'b0;
         E_xor_op                <= 1'b0;
         E_and_op                <= 1'b0;
         E_mem_op                <= 1'b0;
         E_load_op               <= 1'b0;
         E_store_op              <= 1'b0;
         E_ebreak_instr          <= 1'b0;
         E_ecall_instr           <= 1'b0;
         E_signed_cmp            <= 1'b0;
         E_csr_write             <= 1'b0;
         E_csr_read              <= 1'b0;
         E_cmo_op                <= 1'b0;
         E_amo_op                <= 1'b0;
         E_mul_op                <= 1'b0;
         E_div_op                <= 1'b0;
         E_ci_op                 <= 4'b0;
         E_alu_use_addsub_result <= 1'b0;
         E_alu_use_logic_result  <= 1'b0;
         E_branch_pred_taken     <= 1'b0;
         E_rdpsrf                <= 1'b0;
         E_wrpsrf                <= 1'b0; 
      end
      else if (E_ready) begin
         logic is_long_op;  // op only produces a result in M1?
         is_long_op = D_load_op | D_store_op | D_mul_op   | D_div_op |
                      D_amo_op  | D_cmo_op   | (|D_ci_op) | D_long_fp_op;

         E_csr_read  <= D_csr_read;
         E_csr_set   <= D_csr_set;
         E_csr_clr   <= D_csr_clr;
         E_rdpsrf    <= D_rdpsrf;
         E_wrpsrf    <= D_wrpsrf;

         if(D_ecc) begin
            E_multicycle_op         <= 1'b0; 
            E_long_op               <= 1'b0; 
            E_3stage_fp_op          <= 1'b0; 
            E_long_fp_op            <= 1'b0; 
            E_ebreak_instr          <= 1'b0; 
            E_ecall_instr           <= 1'b0; 
            E_signed_cmp            <= 1'b0; 
            E_csr_write             <= 1'b0; 
            E_mul_op                <= 1'b0; 
            E_div_op                <= 1'b0; 
            E_ci_op                 <= 4'b0; 
            E_branch_op             <= 1'b0; 
            E_jump_op               <= 1'b0;
            E_jalr_op               <= 1'b0;
            E_auipc_lui_op          <= 1'b0;
            E_beq_bne_op            <= 1'b0;
            E_blt_bge_op            <= 1'b0;
            E_bne_bge_op            <= 1'b0;
            E_cmp_lt_ltu_op         <= 1'b0;
            E_srx_op                <= 1'b0;
            E_sra_op                <= 1'b0;
            E_sll_op                <= 1'b0;
            E_or_op                 <= 1'b0;
            E_xor_op                <= 1'b0;
            E_and_op                <= 1'b0;
            E_mem_op                <= 1'b0; 
            E_load_op               <= 1'b0; 
            E_store_op              <= 1'b0; 
            E_cmo_op                <= 1'b0; 
            E_amo_op                <= 1'b0;
            E_alu_use_addsub_result <= 1'b0;
            E_alu_use_logic_result  <= 1'b0;
            E_branch_pred_taken     <= 1'b0; 
         end
         else begin
            E_multicycle_op         <= is_long_op | D_2stage_fp_op | D_3stage_fp_op | D_csr_read;
            E_long_op               <= is_long_op;
            E_3stage_fp_op          <= D_3stage_fp_op;
            E_long_fp_op            <= D_long_fp_op;
            E_branch_op             <= D_branch_op;
            E_jump_op               <= D_jump_op;
            E_jalr_op               <= (D_exe_op == JALR);
            E_auipc_lui_op          <= D_auipc_lui_op;
            E_beq_bne_op            <= D_beq_bne_op;
            E_blt_bge_op            <= D_blt_bge_op;
            E_bne_bge_op            <= D_bne_bge_op;
            E_cmp_lt_ltu_op         <= (D_exe_op == CMP_LT_LTU);
            E_srx_op                <= (D_exe_op == SRA) || (D_exe_op == SRL);
            E_sra_op                <= (D_exe_op == SRA);
            E_sll_op                <= (D_exe_op == SLL);
            E_or_op                 <= (D_exe_op == OR);
            E_xor_op                <= (D_exe_op == XOR);
            E_and_op                <= (D_exe_op == AND);
            E_alu_use_addsub_result <= (D_exe_op == ADD) || (D_exe_op == SUB);
            E_alu_use_logic_result  <= (D_exe_op == OR)  || (D_exe_op == XOR) || (D_exe_op == AND);  
            E_ebreak_instr          <= D_ebreak_instr;
            E_ecall_instr           <= D_ecall_instr;
            E_mem_op                <= D_mem_op;
            E_load_op               <= D_load_op;
            E_store_op              <= D_store_op;
            E_signed_cmp            <= D_signed_cmp;
            E_csr_write             <= D_csr_write;
            E_csr_read              <= D_csr_read;
            E_csr_set               <= D_csr_set;
            E_csr_clr               <= D_csr_clr;
            E_cmo_op                <= D_cmo_op;
            E_amo_op                <= D_amo_op;
            E_mul_op                <= D_mul_op;
            E_div_op                <= D_div_op;
            E_ci_op                 <= D_ci_op;
            E_branch_pred_taken     <= D_branch_pred_taken & D_instr_valid;
         end
      end
   end

   always @(posedge clk, posedge internal_reset) begin
      if (internal_reset) begin
         E_mret_instr   <= 1'b0;
         E_dret_instr   <= 1'b0;
         E_fencei_instr <= 1'b0;
      end
      else if (E_ready) begin
         E_mret_instr   <= D_mret_instr;
         E_dret_instr   <= D_dret_instr & C_debug_mode;
         E_fencei_instr <= D_fencei_instr;
      end
   end

   always @(posedge clk) begin
      if (E_ready) begin
         E_mem_size    <= D_mem_size;
         E_mem_byteen  <= D_mem_byteen;
         E_mem_signext <= D_mem_signext;
         E_alu_sub     <= D_alu_sub;
      end
   end

   assign E_exe_result = E_alu_result;

   // **************************************************************************** //
   // ********************************* E --> M0 ********************************* //
   // **************************************************************************** //

   assign M0_ready = ~M0_stall & M1_ready;
   assign M0_stall = M0_ls_op_stall | M0_csr_stall | M0_non_mem_long_op;

   // Normally, nxt_M0_redirect_pc is calculated in E stage, and
   // M0_redirect_pc takes the value in M0 stage.
   // However, in the case of previous instruction in M0 write to CSR (csrw mepc),
   // and current instruction in M0 is mret or dret, or C_read, which uses the updated
   // epc value -> we can branch the next cycle, which means we need to stall
   // for a cycle and let M0 be two cycles.
   // We will do three things:
   // 1) let csr write instruction continue to M1
   // 2) clear out the current instr_valid in M0, since it has entered M1.
   // 3) stall M0_ready for another cycle (this allows the nxt_M0_redirect_pc
   // to settle with the new value). The current instruction in E can enter M0
   // in the third cycle.
   assign M0_csr_stall =  C_write;

   // Kill redirection from E instruction if M0 flags exception
   assign E_unaligned_redir = (E_redirect   & (|E_redirect_pc[1:0]));

   assign M0_redirect_nxt_branch = (E_redirect_alu | E_mret_instr | E_dret_instr | E_fencei_instr) & E_instr_valid & ~flush_E;
   assign M0_redirect_nxt = (E_redirect | E_mret_instr | E_dret_instr | E_fencei_instr | E_fix_gpr | E_fix_fpr) & E_instr_valid & ~flush_E & ~E_unaligned_redir;

   always @(*) begin
      unique case (1)
         E_dret_instr   : nxt_M0_redirect_pc = C_debug_pc;
         E_mret_instr   : nxt_M0_redirect_pc = C_csr_epc;
         E_fencei_instr : nxt_M0_redirect_pc = E_nxt_seq_pc;
         E_mispred      : nxt_M0_redirect_pc = E_nxt_seq_pc;
         E_fix_gpr_fpr  : nxt_M0_redirect_pc = E_instr_pc; 
         default        : nxt_M0_redirect_pc = E_redirect_pc;
      endcase
   end

   always @(posedge clk, posedge internal_reset) begin
      if (internal_reset) begin
         M0_instr_word <= NOP_VAL;  // NOP
         M0_redirect <= 1'b1;
         M0_mret_instr <= 1'b0;
         M0_dret_instr <= 1'b0;
         M0_fencei_instr <= 1'b0;
         M0_branch_pred_taken <= 1'b0;
      end
      else if (M0_ready) begin
         M0_instr_word <= E_instr_word;
         M0_redirect   <= M0_redirect_nxt;
         M0_mret_instr <= E_mret_instr;
         M0_dret_instr <= E_dret_instr;
         M0_fencei_instr <= E_fencei_instr;
         M0_branch_pred_taken <= E_branch_pred_taken & E_instr_valid;
      end
   end

   always @(posedge clk, posedge internal_reset) begin
      if (internal_reset)
         M0_redirect_pc <= RESET_VECTOR;
      else if (M1_ready)
         // M0_redirect_pc only valid in the last cycle of M0, when redirect
         // takes place. This ensures the redirect pc to settle in the case of csr reads.
         M0_redirect_pc <= nxt_M0_redirect_pc;
   end

   always @(posedge clk) begin
      if (M0_ready) begin
         M0_instr_pc      <= E_instr_pc;
         M0_nxt_seq_pc    <= E_nxt_seq_pc;
         M0_exe_op        <= E_exe_op;
         M0_muldiv_ctrl_1 <= E_muldiv_ctrl_1;
         M0_muldiv_ctrl_2 <= E_muldiv_ctrl_2;
      end
   end

   always @(posedge clk, posedge internal_reset) begin
      if (internal_reset)
         M0_nxt_pc <= RESET_VECTOR;
      else if (M0_ready & E_instr_valid & ~flush_E) begin
         if (M0_redirect_nxt_branch)
            M0_nxt_pc <= nxt_M0_redirect_pc;
         else
            M0_nxt_pc <= E_nxt_seq_pc;
      end
   end

   assign E_ctrl_inv = flush_E | E_expn | E_d_expn; 

   // M0_instr_valid should stay high until pipeline transition. This is
   // required. Consider when instruction is in M0, but M1_ready is low. If
   // instr_valid deasserts after the first cycle, then M1_instr_valid will
   // never pick this up (and hence we see some skipping of instructions.)
   // M0_instr_done signals that the current instn in M0 stage is pass-through
   // It evaluates to true if
   //    1) Current instn does not involve M0 work (completed in E)
   //    2) If instruction completes in M0

   always @(posedge clk, posedge internal_reset) begin
      if (internal_reset) begin
         M0_instr_valid       <= 1'b0;
         M0_gpr_wr_en         <= 1'b0;
         M0_fpr_wr_en         <= 1'b0;
         M0_gpr_incorrect     <= 1'b0;
         M0_fpr_incorrect     <= 1'b0;
         M0_instr_incorrect   <= 1'b0;
         M0_itag_incorrect    <= 1'b0;
         M0_fatal_ecc         <= 1'b0;
         M0_mem_op            <= 1'b0;
         M0_load_op           <= 1'b0;
         M0_store_op          <= 1'b0;
         M0_long_op           <= 1'b0;
         M0_non_mem_long_op   <= 1'b0;
         M0_3stage_fp_op      <= 1'b0;
         M0_instr_done        <= 1'b0;
         M0_instr_to_gpr_done <= 1'b0;
         M0_instr_to_fpr_done <= 1'b0;
      end
      else if (flush_E | M0_csr_stall | M0_non_mem_long_op | M0_ls_op_stall) begin
         // Need to clear instr valid when we are stalling M0, since we let
         // instruction go to M1 (we didn't block M1) and don't want to have
         // repeated instructions.
         M0_instr_valid       <= 1'b0;
         M0_gpr_wr_en         <= 1'b0;
         M0_fpr_wr_en         <= 1'b0;
         M0_gpr_incorrect     <= 1'b0;
         M0_fpr_incorrect     <= 1'b0;
         M0_instr_incorrect   <= 1'b0;
         M0_itag_incorrect    <= 1'b0;
         M0_fatal_ecc         <= 1'b0;
         M0_mem_op            <= 1'b0;
         M0_load_op           <= 1'b0;
         M0_store_op          <= 1'b0;
         M0_long_op           <= 1'b0;
         M0_non_mem_long_op   <= 1'b0;
         M0_3stage_fp_op      <= 1'b0;
         M0_instr_done        <= 1'b0;
         M0_instr_to_gpr_done <= 1'b0;
         M0_instr_to_fpr_done <= 1'b0;
      end

      else if (M0_ready) begin
         M0_instr_valid    <= E_instr_valid;
         M0_gpr_wr_en      <= E_gpr_wr_en & E_instr_valid;
         M0_fpr_wr_en      <= E_fpr_wr_en & E_instr_valid;
         M0_gpr_incorrect  <= E_gpr_incorrect & E_instr_valid;
         M0_fpr_incorrect  <= E_fpr_incorrect & E_instr_valid;
         M0_instr_incorrect<= E_instr_incorrect & E_instr_valid;
         M0_itag_incorrect <= E_itag_incorrect & E_instr_valid;
         M0_fatal_ecc      <= E_fatal_ecc;

         // De-assert mem_op & similar signals in case that M0_ready, but E_instr_valid low. This prevents
         // LSU from starting sooner than expected (e.g. when store_data value not settled.)
         // M0_instr_done can be determined at entry to M0 because either the instruction was already
         // done in E, or if it finishes in M0 it will do so in a single cycle. 
         // All that is necessary is to exclude ops that will complete in M1. 
         M0_mem_op            <= E_instr_valid & ~E_ctrl_inv & E_mem_op;
         M0_load_op           <= E_instr_valid & ~E_ctrl_inv & E_load_op;
         M0_store_op          <= E_instr_valid & ~E_ctrl_inv & E_store_op;
         M0_long_op           <= E_instr_valid & E_long_op;
         M0_non_mem_long_op   <= E_instr_valid & (E_mul_op | E_div_op | (|E_ci_op) | E_long_fp_op);
         M0_3stage_fp_op      <= E_instr_valid & E_3stage_fp_op;
         M0_instr_done        <= E_instr_valid & ~E_ctrl_inv & ~(E_long_op | E_3stage_fp_op);
         M0_instr_to_gpr_done <= E_instr_valid & ~E_ctrl_inv & E_gpr_wr_en & ~(E_long_op | E_3stage_fp_op);
         M0_instr_to_fpr_done <= E_instr_valid & ~E_ctrl_inv & E_fpr_wr_en & ~(E_long_op | E_3stage_fp_op);
      end
      else begin
         // The guarded de-assertion is needed so that when M0 is stalled, and mem_op transitions
         // to M1, we don't have a bogus mem_op in M0 stage. Cannot clear earlier because M0_mem_op
         // may be back pressured in M0.
         // However, with current constraints (M0 and M1 forced to be contiguous for memory ops),
         // this is not needed. Once mem_op enters M0, it is guaranteed to enter M1 the next cycle.
         // M0_ready will be low immediately.

         // if (~M0_instr_valid) begin
         //    M0_mem_op   <= 1'b0;
         //    M0_load_op  <= 1'b0;
         //    M0_store_op <= 1'b0;
         // end
         M0_mem_op           <= 1'b0;
         M0_load_op          <= 1'b0;
         M0_store_op         <= 1'b0;
         M0_long_op          <= 1'b0;
         M0_non_mem_long_op  <= 1'b0;  // de-asserted immediately to stall only one cycle
         M0_3stage_fp_op     <= 1'b0;
      end
   end

   generate if (ATOMIC_ENABLED) begin : gen_M0_atomic
      always @(posedge clk, posedge internal_reset) begin
         if (internal_reset)
            M0_amo_op <= 1'b0;
         else if (M0_ready) begin
            if (E_instr_valid)
               M0_amo_op <= E_amo_op & ~E_ctrl_inv;
            else
               M0_amo_op <= 1'b0;
         end
         // Need to hold value until de-assertion of M0_instr_valid, which signals the transition of amo_op from M0 to M1.
         // This signal is used in dcache to derive amo_op, which marks the start of the FSM.
         // This happens when we de-assert M0_ready (via stalling), and need to let the instruction go from M0 to M1.
         // However, with current constraints (M0 and M1 forced to be contiguous for memory operations), this is not needed.
         // Once amo_op enters M0, it is guaranteed to enter M1 the next cycle. M0_ready will be low immediately.

         // else if (~M0_instr_valid) begin
         //    M0_amo_op <= 1'b0;
         // end
         else begin
            M0_amo_op <= 1'b0;
         end
      end
   end
   else begin : gen_M0_atomic_tieoff
      assign M0_amo_op = 1'b0;
   end
   endgenerate

   always @(posedge clk, posedge internal_reset) begin
      if (internal_reset)
         M0_cmo_op <= 1'b0;
      else if (M0_ready) begin
         if (E_instr_valid)
            M0_cmo_op <= E_cmo_op & ~E_ctrl_inv;
         else
            M0_cmo_op <= 1'b0;
      end
      // Need to hold value until de-assertion of M0_instr_valid, which
      // signals the transition of cmo_op from M0 to M1. This signal is
      // used in dcache to derive cmo_op, which marks the start of the FSM.
      // This happens when we de-assert M0_ready (via stalling), and need
      // to let the instruction go from M0 to M1.
      // However, with current constraints (M0 and M1 forced to be
      // contiguous), this is not needed. Once amo_op enters M0, it is
      // gaurantee to enter M1 the next cycle. M0_ready will be low
      // immediately.

      // else if (~M0_instr_valid) begin
      //    M0_cmo_op <= 1'b0;
      // end
      else begin
         M0_cmo_op <= 1'b0;
      end
   end

   assign E_mul_valid = E_instr_valid & E_mul_op & ~E_ctrl_inv;

   always @(posedge clk, posedge internal_reset) begin
      if (internal_reset) begin
         M0_mul_op <= 1'b0;
         M0_div_op <= 1'b0;
         M0_ci_op  <= 4'b0;
      end
      else if (M0_ready) begin
         if (E_instr_valid) begin
            M0_mul_op <= ~E_ctrl_inv & E_mul_op;
            M0_div_op <= ~E_ctrl_inv & E_div_op;
            M0_ci_op  <=  E_ctrl_inv ? 4'b0 : E_ci_op;
         end
         else if (M0_expn) begin     // TODO: Is this ever valid
            M0_mul_op <= 1'b0;
            M0_div_op <= 1'b0;
            M0_ci_op  <= 4'b0;
         end
      end
         // Need to hold value until de-assertion of M0_instr_valid, which
         // signals the transition of cmo_op from M0 to M1. This signal is
         // used in dcache to derive cmo_op, which marks the start of the FSM.
         // This happens when we de-assert M0_ready (via stalling), and need
         // to let the instruction go from M0 to M1.
         // However, with current constraints (M0 and M1 forced to be
         // contiguous), this is not needed. Once amo_op enters M0, it is
         // gaurantee to enter M1 the next cycle. M0_ready will be low
         // immediately.
      // else if (~M0_instr_valid) begin
      //    M0_mul_op <= 1'b0;
      //    M0_div_op <= 1'b0;
      //    M0_ci_op  <= 4'b0;
      // end
      else begin
         M0_mul_op <= 1'b0;
         M0_div_op <= 1'b0;
         M0_ci_op  <= 4'b0;
      end
   end

   always @(posedge clk) begin
      if (M0_ready) begin
         M0_rd             <= E_rd;
         M0_rd_is_zero     <= (E_rd == 5'd0);
         M0_iw_rs1_is_zero <= E_iw_rs1_is_zero;
         M0_exe_result     <= E_exe_result;
         M0_rs1_gpr_val    <= E_rs1_gpr_val;
         M0_rs2_gpr_val    <= E_rs2_gpr_val;
         M0_store_data     <= E_store_gpr ? E_rs2_gpr_val : E_rs2_fpr_val;
      end
   end

   always @(posedge clk) begin
      if (M0_ready) begin
         M0_mem_size      <= E_mem_size;
         M0_mem_byteen    <= E_mem_byteen;
         M0_mem_signext   <= E_mem_signext;
         M0_mem_unaligned <= E_mem_unaligned;
      end
   end

   always @(posedge clk) begin
      if (M0_ready) begin
         M0_fpu_to_fpr_e_done   <= E_fpu_to_fpr_done;
         M0_fpu_to_fpr_e_result <= E_fpu_to_fpr_result;
         M0_fpu_to_gpr_e_done   <= E_fpu_to_gpr_done;
         M0_fpu_to_gpr_e_result <= E_fpu_to_gpr_result;
      end
   end

   always @(posedge clk, posedge internal_reset) begin
      if (internal_reset) begin
         M0_fpu_e_flags <= deasserted_fp_flags();
      end
      else if (M0_ready) begin
         M0_fpu_e_flags <= E_fpu_flags;
      end
   end

   always @(posedge clk) begin
      if (M0_ready) begin
         M0_csr_s1 <= E_csr_s1;
         M0_exe_s1 <= E_exe_s1;
         M0_exe_s2 <= E_exe_s2;
      end
   end

   always @(posedge clk) begin
      if (internal_reset) begin
         M0_csr_read    <= 1'b0;
         M0_csr_write   <= 1'b0;
         M0_csr_addr    <= 0;
         M0_ecall_instr <= 1'b0;
         M0_csr_set     <= 1'b0;
         M0_csr_clr     <= 1'b0;
         M0_rdpsrf      <= 1'b0;
         M0_wrpsrf      <= 1'b0;
      end
      else if (M0_ready) begin
         M0_csr_read    <= E_csr_read;
         M0_csr_write   <= E_csr_write;
         M0_csr_addr    <= E_csr_addr;
         M0_ecall_instr <= E_ecall_instr;
         M0_csr_set     <= E_csr_set;
         M0_csr_clr     <= E_csr_clr;
         M0_rdpsrf      <= E_rdpsrf;
         M0_wrpsrf      <= E_wrpsrf;
      end
   end

   always @(*) begin
      if (M0_rd_is_zero) begin
         M0_gpr_result_data_nxt = 32'b0;
      end
      else begin
         M0_gpr_result_data_nxt = M0_exe_result;
         case (1'b1)
            C_read               : M0_gpr_result_data_nxt = C_read_data;
            M0_fpu_to_gpr_done   : M0_gpr_result_data_nxt = M0_fpu_to_gpr_result;
            M0_fpu_to_gpr_e_done : M0_gpr_result_data_nxt = M0_fpu_to_gpr_e_result;
         endcase
      end
   end

   always @(*) begin
      M0_fpr_result_data_nxt = M0_fpu_to_fpr_done ? M0_fpu_to_fpr_result : M0_fpu_to_fpr_e_result;
   end

   // **************************************************************************** //
   // ******************************** M0 --> M1 ********************************* //
   // **************************************************************************** //

   assign M1_wait_for_irq = M1_is_wfi & ~core_irq_pndg;
   assign M1_ecc_wait_for_nmi = (~ECC_FULL & (M1_ecc_stall | M1_fatal_ecc | M1_dtag_incorrect | M1_data_incorrect | M1_dtcm1_incorrect | M1_dtcm2_incorrect))  & ~(core_nmi_irq | core_debug_irq | core_reset_req);

   always @(posedge clk, posedge internal_reset) begin
      if (internal_reset) begin
         M1_instr_word <= NOP_VAL; // NOP
      end
      else if (M1_ready) begin
         M1_instr_word <= M0_instr_word;
      end
   end

   always @(posedge clk, posedge internal_reset) begin
      if (internal_reset)
         M1_nxt_pc <= RESET_VECTOR;
      else if (M1_ready & M0_instr_valid & ~flush_M0) begin
            M1_nxt_pc <= M0_nxt_pc;
      end
   end

   always @(posedge clk) begin
      if (M1_ready) begin
         M1_instr_pc    <= M0_instr_pc;
         M1_nxt_seq_pc  <= M0_nxt_seq_pc;
         M1_redirect_pc <= M0_redirect_pc;  // used only by verification

         M1_rd          <= M0_rd;
         M1_rd_is_zero  <= M0_rd_is_zero;
         M1_exe_result  <= M0_gpr_result_data_nxt;
         M1_rs1_gpr_val <= M0_rs1_gpr_val;
         M1_rs2_gpr_val <= M0_rs2_gpr_val;
         M1_rdpsrf      <= M0_rdpsrf;
         M1_wrpsrf      <= M0_wrpsrf;

         M1_mem_size    <= M0_mem_size;
         M1_mem_byteen  <= M0_mem_byteen;
         M1_mem_signext <= M0_mem_signext;

         M1_fpu_to_fpr_m0_done   <= M0_fpu_to_fpr_done | M0_fpu_to_fpr_e_done;
         M1_fpu_to_fpr_m0_result <= M0_fpr_result_data_nxt;
         M1_fpu_to_gpr_m0_done   <= M0_fpu_to_gpr_done | M0_fpu_to_gpr_e_done;
         M1_fpu_to_gpr_m0_result <= M0_fpu_to_gpr_done ? M0_fpu_to_gpr_result : M0_fpu_to_gpr_e_result;

         M1_exe_s1 <= M0_exe_s1;
         M1_exe_s2 <= M0_exe_s2;
      end
   end

   assign M0_ctrl_inv = flush_M0 | M0_expn | M0_e_expn;

   always @(posedge clk, posedge internal_reset) begin
      if (internal_reset) begin
         M1_instr_valid          <= 1'b0;
         M1_mem_op               <= 1'b0;
         M1_long_op              <= 1'b0;
         M1_mret_instr           <= 1'b0;
         M1_dret_instr           <= 1'b0;
         M1_gpr_incorrect        <= 1'b0;
         M1_fpr_incorrect        <= 1'b0;
         M1_instr_incorrect      <= 1'b0;
         M1_itag_incorrect       <= 1'b0;
         M1_fatal_ecc            <= 1'b0;
         M1_redirect             <= 1'b0;   // used only by verification
         M1_is_branch            <= 1'b0;   // used only by verification
      end
      else if (M1_ready) begin
         if (flush_M0)
            M1_instr_valid <= 1'b0;
         else begin
            M1_instr_valid          <= M0_instr_valid;
            M1_mem_op               <= M0_instr_valid & M0_mem_op & ~M0_ctrl_inv;
            M1_long_op              <= M0_instr_valid & M0_long_op;
            M1_mret_instr           <= M0_instr_valid & M0_mret_instr;
            M1_dret_instr           <= M0_instr_valid & M0_dret_instr;
            M1_gpr_incorrect        <= M0_instr_valid & M0_gpr_incorrect;
            M1_fpr_incorrect        <= M0_instr_valid & M0_fpr_incorrect;
            M1_instr_incorrect      <= M0_instr_valid & M0_instr_incorrect;
            M1_itag_incorrect       <= M0_instr_valid & M0_itag_incorrect;
            M1_fatal_ecc            <= M0_instr_valid & M0_fatal_ecc;
            M1_redirect             <= M0_instr_valid & M0_redirect;   // used only by verification
            M1_is_branch            <= M0_instr_valid & M0_is_branch;  // used only by verification
         end
      end
      else begin
         M1_instr_valid <= 1'b0;
      end
   end

   generate if (ATOMIC_ENABLED) begin : gen_M1_amo
      always @(posedge clk, posedge internal_reset) begin
         if (internal_reset) begin
            M1_amo_op <= 1'b0;
         end
         else if (M1_ready) begin
            if (M0_instr_valid) begin
               M1_amo_op <= M0_amo_op & ~M0_ctrl_inv;
            end
            else if (M1_expn) begin
               M1_amo_op <= 1'b0;
            end
         end
         else begin
            M1_amo_op <= 1'b0;
         end
      end
   end
   else begin : gen_dummy_M1_amo
      assign M1_amo_op = 1'b0;
   end
   endgenerate

   always @(posedge clk, posedge internal_reset) begin
      if (internal_reset) begin
         M1_cmo_op <= 1'b0;
      end
      else if (M1_ready) begin
         if (M0_instr_valid) begin
            M1_cmo_op <= M0_cmo_op & ~M0_ctrl_inv;
         end
         else if (M1_expn) begin
            M1_cmo_op <= 1'b0;
         end
      end
      else begin
         M1_cmo_op <= 1'b0;
      end
   end

   always @(posedge clk, posedge internal_reset) begin
      if (internal_reset) begin
         M1_mul_op <= 1'b0;
         M1_div_op <= 1'b0;
         M1_ci_op  <= 4'b0;
      end
      else if (M1_ready) begin
         if (M0_instr_valid) begin
            M1_mul_op <= ~M0_ctrl_inv & M0_mul_op;
            M1_div_op <= ~M0_ctrl_inv & M0_div_op;
            M1_ci_op  <=  M0_ctrl_inv ? 4'b0 : M0_ci_op;
         end
         else if (M1_expn) begin     // TODO: Is this ever valid
            M1_mul_op <= 1'b0;
            M1_div_op <= 1'b0;
            M1_ci_op  <= 4'b0;
         end
      end
      else begin
         M1_mul_op <= 1'b0;
         M1_div_op <= 1'b0;
         M1_ci_op  <= 4'b0;
      end
   end

   // M1 register write enables and derived values are sticky for load and multicycle instructions.

   assign M1_load_en_nxt   = M1_load_en;
   assign M1_gpr_wr_en_nxt = M1_gpr_wr_en;
   assign M1_fpr_wr_en_nxt = M1_fpr_wr_en;

   always @(posedge clk, posedge internal_reset) begin
      if (internal_reset) begin
         M1_load_en              <= 1'b0;
         M1_gpr_wr_en            <= 1'b0;
         M1_fpr_wr_en            <= 1'b0;
      end
      else if (M1_ready && M0_instr_valid) begin
         M1_load_en   <= M0_load_op;
         // Disable M1 gpr write if M0 flags exception
         M1_gpr_wr_en <= M0_gpr_wr_en & ~M0_ctrl_inv;
         M1_fpr_wr_en <= M0_fpr_wr_en & ~M0_ctrl_inv;
      end
      else if (M1_multicycle_instr_pending) begin
         M1_load_en              <= M1_load_en_nxt;
         M1_gpr_wr_en            <= M1_gpr_wr_en_nxt;
         M1_fpr_wr_en            <= M1_fpr_wr_en_nxt;
      end
      else begin
         M1_gpr_wr_en            <= 1'b0;
         M1_gpr_wr_en            <= 1'b0;
         M1_fpr_wr_en            <= 1'b0;
      end
   end

   always @(posedge clk, posedge internal_reset) begin
      if (internal_reset)
         M1_ci_pending <= 1'b0;
      else if (|(M1_ci_op))
         M1_ci_pending <= 1'b1;
      else if (M1_ci_done)
         M1_ci_pending <= 1'b0;
   end

   always @(posedge clk, posedge internal_reset) begin
      if (internal_reset) begin
         M1_fpu_m0_flags <= deasserted_fp_flags();
      end
      else if (M1_ready) begin
         M1_fpu_m0_flags <= (M0_fpu_to_fpr_done | M0_fpu_to_gpr_done) ? M0_fpu_flags : M0_fpu_e_flags;
      end
   end

   // Stall from M1 Stage- load/store instructions and other multicycle
   // instructions cause this stall.
   assign M1_multicycle_instr_pending =  M1_ecc_wait_for_nmi
                                       | M1_ls_instr_pending
                                       | M1_wait_for_irq
                                       | M1_mul_pending
                                       | M1_div_pending
                                       | ((M1_ci_pending | (|M1_ci_op)) & ~M1_ci_done)
                                       | M1_fpu_op_pending;

   // M1_ready is deasserted for multicycle instructions,
   assign M1_ready = ~M1_multicycle_instr_pending & W_ready;

   // TODO: This assumes that specific ops will take more than 1 cycle. This may change.
   assign M1_instr_done =  (M1_instr_valid & ~M1_long_op) |                            // Single cycle ops executed in E stage, or 2-cycle completed in M0.
                            M1_ls_op_done | M1_mul_done | M1_div_done | M1_ci_done |
                            M1_fpu_to_fpr_done | M1_fpu_to_gpr_done;

   assign M1_instr_to_fpr_done = M1_fpu_to_fpr_done | 
                                 (M1_fpr_wr_en & (M1_ld_op_done | (M1_instr_valid & ~M1_long_op)));
   assign M1_instr_to_gpr_done = M1_fpu_to_gpr_done | 
                                 (M1_gpr_wr_en & (M1_ld_op_done |
                                                  (M1_instr_valid & ~M1_long_op) |
                                                   M1_mul_done | M1_div_done | M1_ci_done));

   // If rd == 0, M1_exe_result will be zero, so no explicit test for M1_rd == 0 is required here. 
   always @(*) begin
      unique case (1'b1)
         M1_ld_op_done         : M1_gpr_result_data_nxt = M1_load_data;
         M1_mul_done           : M1_gpr_result_data_nxt = M1_mul_result;
         M1_div_done           : M1_gpr_result_data_nxt = M1_div_result;
         M1_ci_done            : M1_gpr_result_data_nxt = M1_ci_result;
         M1_fpu_to_gpr_done    : M1_gpr_result_data_nxt = M1_fpu_to_gpr_result;
         M1_fpu_to_gpr_m0_done : M1_gpr_result_data_nxt = M1_fpu_to_gpr_m0_result;
         default               : M1_gpr_result_data_nxt = M1_exe_result;
      endcase
   end

   always @(*) begin
      unique case (1'b1)
         M1_ld_op_done      : M1_fpr_result_data_nxt = M1_load_data;
         M1_fpu_to_fpr_done : M1_fpr_result_data_nxt = M1_fpu_to_fpr_result;
         default            : M1_fpr_result_data_nxt = M1_fpu_to_fpr_m0_result;
      endcase
   end

   // **************************************************************************** //
   // ********************************* M1 --> W ********************************* //
   // **************************************************************************** //
   // Old M0 -> W, renamed everything to M1

   assign W_ready = 1'b1;

   always @(posedge clk, posedge internal_reset) begin
      if (internal_reset) begin
         W_instr_word <= NOP_VAL;  // NOP
      end
      else if (W_ready & M1_instr_done) begin
         W_instr_word <= M1_instr_word;
      end
   end

   always @(posedge clk, posedge internal_reset) begin
      if (internal_reset) begin
         W_gpr_wr_en   <= 1'b0;
         W_fpr_wr_en   <= 1'b0;
         W_instr_valid <= 1'b0;
      end
      else if (W_ready & M1_instr_done) begin
         W_gpr_wr_en <= M1_gpr_wr_en & ~M1_expn;
         W_fpr_wr_en <= M1_fpr_wr_en & ~M1_expn;
         W_instr_valid <= 1'b1;
      end
      else begin
         W_gpr_wr_en   <= 1'b0;
         W_fpr_wr_en   <= 1'b0;
         W_instr_valid <= 1'b0;
      end
   end

   always @(posedge clk) begin
      if (W_ready) begin
         W_rd             <= M1_rd;
         W_rdpsrf         <= M1_rdpsrf;
         W_wrpsrf         <= M1_wrpsrf;
         W_gpr_exe_result <= M1_gpr_result_data_nxt;
         W_fpr_exe_result <= M1_fpr_result_data_nxt;
      end
   end

   // **************************************************************************** //
   // ************ Exception/Interrupt/Debug Interrupt Control Logic ************* //
   // **************************************************************************** //

   // Exception information trickels through the pipe. This keeps things in
   // order. Also, this avoids unnecessary stalls and wait. Flush logic is
   // central to M0 stage.
   // M0 stage is critical. This is where magic happens. Make sure the
   // following functionality is disabled if there is an exception from
   // previous stage:
   //    - gpr / fpr write
   //    - mem ops
   //    - branch redirection
   //    - mret/dret redirection
   //    - csr write
   //
   // When passing down the information, previous stage exception takes
   // priority. If I stage had exception, exception in D stage from that
   // instruction is meaningless. And so on...

   // I -> D exception information
   // Unaligned instruction or response error
  
   wire I_itcm1_correctable_error,I_itcm1_uncorrectable_error,I_itcm2_correctable_error,I_itcm2_uncorrectable_error;
   wire I_itcm_expn;
   reg D_itcm_expn, E_itcm_expn, M0_itcm_expn, M1_itcm_expn;

   generate if (ECC_FULL) begin : itcm_ecc_full
         assign I_itcm1_correctable_error   = (I_instr_ecc == 4'b01_10); 
         assign I_itcm1_uncorrectable_error = (I_instr_ecc == 4'b01_11); 
         
         assign I_itcm2_correctable_error   = (I_instr_ecc == 4'b11_10); 
         assign I_itcm2_uncorrectable_error = (I_instr_ecc == 4'b11_11); 

         assign I_itcm_expn = I_itcm1_correctable_error | I_itcm1_uncorrectable_error | I_itcm2_correctable_error | I_itcm2_uncorrectable_error;
      end
      else begin : itcm_ecc_full_tieoff 
         assign I_itcm_expn = 1'b0;
      end
   endgenerate
      

   always @(posedge clk, posedge internal_reset) begin
      if (internal_reset) begin
         D_i_expn    <= 1'b0;
         D_itcm_expn <= 1'b0;
      end
      else if (D_ready & I_instr_valid) begin
         D_i_expn    <= (|I_instr_pc[1:0]) || (|I_instr_resp) || I_itcm_expn;
         D_itcm_expn <= I_itcm_expn;
      end
   end

   always @(posedge clk) begin
      if (D_ready & I_instr_valid) begin
         D_i_expn_cause <= (|I_instr_pc[1:0]) ? INSTR_ADDR_MISAL : (|I_instr_resp) ? INSTR_ACCESS_ERR : HW_ERROR;  // in order of mcause priority
         D_i_mtval      <= I_instr_pc;
      end
   end

// mtval2 encoding scheme followed from SAS
   always @(posedge clk) begin
      if (D_ready & I_instr_valid) begin
         if      (I_itcm1_uncorrectable_error || I_itcm2_uncorrectable_error)
            D_i_mtval2 <= ECC_INSTR_LOAD_UNCORRECTABLE;
         else if (I_itcm1_correctable_error   || I_itcm2_correctable_error  )
            D_i_mtval2 <= ECC_INSTR_LOAD_CORRECTABLE;
      end
   end

   // D -> E exception information
   always @(posedge clk, posedge internal_reset) begin
      if (internal_reset) begin
         E_d_expn <= 1'b0;
         E_itcm_expn <= 1'b0;
      end
      else if (E_ready) begin
         E_d_expn <= D_instr_valid & (D_expn | D_i_expn);
         E_itcm_expn <= D_itcm_expn;
      end
   end

   always @(posedge clk) begin
      if (D_instr_valid & E_ready) begin
         E_d_expn_cause <= D_i_expn ? D_i_expn_cause : D_expn_cause;
         E_d_mtval      <= D_i_expn ? D_i_mtval      : D_instr_word;
      end
   end

// mtval2 encoding scheme followed from SAS
   always @(posedge clk) begin
      if (D_instr_valid & E_ready) begin
         if (D_itcm_expn)
            E_d_mtval2 <= D_i_mtval2;          
         else if (D_gpr_incorrect)
            E_d_mtval2 <= ECC_GPR_UNCORRECTABLE;   // 'd1         
         else if (D_fpr_incorrect)
            E_d_mtval2 <= ECC_FPR_UNCORRECTABLE;   // 'd3 
         else          
            E_d_mtval2 <= 6'd0;
      end
   end

   // E -> M0 exception information
   always @(posedge clk, posedge internal_reset) begin
      if (internal_reset) begin
         M0_e_expn <= 1'b0;
         M0_itcm_expn <= 1'b0;
      end
      else if (M0_ready) begin
         M0_e_expn <= E_instr_valid & ~flush_E & (E_expn | E_d_expn);
         M0_itcm_expn <= E_itcm_expn;
      end
   end

   always @(posedge clk) begin
      if (E_instr_valid & M0_ready) begin
         M0_e_expn_cause    <= E_d_expn ? E_d_expn_cause : E_expn_cause;
         M0_d_mtval         <= E_d_mtval;
         M0_d_mtval2        <= E_d_mtval2;
         M0_unaligned_redir <= E_unaligned_redir;
      end
   end

   assign M0_e_mtval = M0_unaligned_redir ? M0_nxt_pc : M0_d_mtval;
   //assign M0_e_mtval2 = M0_d_mtval;
   assign M0_expn_cause = M0_e_expn ? M0_e_expn_cause :
                          M0_ls_expn? M0_ls_expn_cause: ILLEGAL_INSTR;
   // C_csr_access_expn should be illegal instruction
   assign M0_mtval = M0_e_expn ? M0_e_mtval : M0_ls_addr;
   assign M0_expn = M0_ls_expn | M0_e_expn| C_csr_access_expn;
   // M0_ls_expn and M0_e_expn are mutually exclusive because none of the LSU implementations
   // flag exceptions in E. If M0_e_expn then M0 won't have memory instruction and hence
   // M0_ls_expn cannot be 1.
   
   assign M0_mtval2 = M0_d_mtval2;


   // M0 -> M1 exception information
   always @(posedge clk, posedge internal_reset) begin
      if (internal_reset) begin
         M1_m0_expn <= 1'b0;
         M1_itcm_expn <= 1'b0;
      end
      else if (M1_ready) begin
         M1_m0_expn <= M0_instr_valid & ~flush_M0 & (M0_expn | M0_e_expn);
         M1_itcm_expn <= M0_itcm_expn;
      end
   end

   always @(posedge clk) begin
      if (M0_instr_valid & M1_ready) begin
         M1_m0_expn_cause <= M0_expn_cause;
         M1_m0_mtval      <= M0_mtval;
         M1_m0_mtval2     <= M0_mtval2;
      end
   end

   assign M1_expn_cause = M1_m0_expn ? M1_m0_expn_cause : M1_ls_expn_cause;
   assign M1_expn       = M1_m0_expn | M1_ls_expn;
   assign M1_mtval      = M1_m0_expn ? M1_m0_mtval: M1_ls_addr;

   always @* begin 
      if (M1_itcm_expn | M1_gpr_incorrect | M1_fpr_incorrect)
         M1_mtval2 = M1_m0_mtval2;          
      else if (M1_dcache_dtcm1_ecc == 2'b11 || M1_dcache_dtcm2_ecc == 2'b11)
         M1_mtval2 = M1_ld_op_done ? ECC_DATA_LOAD_UNCORRECTABLE : ECC_DATA_STORE_UNCORRECTABLE;
      else if (M1_dcache_dtcm1_ecc == 2'b10 || M1_dcache_dtcm2_ecc == 2'b10)
         M1_mtval2 = M1_ld_op_done ? ECC_DATA_LOAD_CORRECTABLE   : ECC_DATA_STORE_CORRECTABLE;
      else if (M1_dcache_dtag_ecc == 2'b11)
         M1_mtval2 = ECC_DCACHE_TAG_UNCORRECTABLE;
      else if (M1_dcache_data_ecc == 2'b11)    
         M1_mtval2 = ECC_DCACHE_DATA_UNCORRECTABLE;
      else          
         M1_mtval2 = 6'd0;
   end


   //------------------------------------------//
   //---------------- Triggers ----------------//
   //------------------------------------------//
   always @(posedge clk, posedge internal_reset) begin
      if (internal_reset)
         M0_instr_trigger <= 1'b0;
      else if (M0_ready)
         M0_instr_trigger <= E_instr_valid & (E_iw_trigger | E_pc_trigger);
   end
   always @(posedge clk, posedge internal_reset) begin
      if (internal_reset)
         M1_instr_trigger <= 1'b0;
      else if (M1_ready)
         M1_instr_trigger <= M0_instr_valid & M0_instr_trigger;
   end

   // Single step: If single step is enabled the let an instruction complete and then take debug exception.

   generate
      if (DEBUG_ENABLED) begin : gen_M0_debug
         assign M1_ebreak_to_dm = M1_expn & (M1_expn_cause == BREAKPOINT) & (M1_instr_trigger ? C_trig_in_dm : C_ebreak_in_dm);
         assign trig_to_dm      = ~M1_expn & M1_ls_triggered & C_trig_in_dm;
         assign M1_sstep_expn   = ~C_debug_mode & C_sstep_en & M1_instr_done & ~trig_to_dm & ~M1_ebreak_to_dm;
         // Exceptions in debug mode don't modify debug CSRs. Just redirection!
         assign nxt_dbg_expn_update = nxt_dbg_expn_taken & ~C_debug_mode;
      end
      else begin : gen_M0_debug_tieoff
         assign M1_sstep_expn = 1'b0;
         assign nxt_dbg_expn_update = 1'b0;
         assign M1_ebreak_to_dm = 1'b0;
         assign trig_to_dm = 1'b0;
      end
   endgenerate

   // TODO: CSR update takes 2 cycles for exception. Analyze side effect. If
   // there are none, keep it this way. Otherwise, use nxt_* to register the
   // vaules in CSRs.
   // TODO: Nested exceptions in normal mode.

   // ************ Single stepping and exception ************//
   // If single stepping in enabled, prevent pipeline state updation due to any exception.
   // Pipeline state gets updated by single step exception.
   assign nxt_expn_taken = nxt_csr_expn_update & ~M1_sstep_expn;

   always @(posedge clk, posedge internal_reset) begin
      if (internal_reset) begin
         C_expn_update <= 1'b0;
         C_expn_taken  <= 1'b0;
      end
      else begin
         C_expn_update <= nxt_csr_expn_update;
         C_expn_taken <= nxt_expn_taken;
      end
   end

   always @(posedge clk) begin
      C_expn_is_interrupt <= nxt_csr_expn_is_interrupt;
      C_expn_cause        <= nxt_csr_expn_cause;
      C_expn_level        <= CLIC_EN && nxt_csr_expn_level;
      C_expn_hv           <= CLIC_EN && nxt_csr_expn_hv;
      C_expn_pc           <= nxt_csr_expn_pc;
      C_expn_mtval        <= M1_mtval;
      C_expn_mtval2       <= M1_mtval2;
   end

   generate if (DEBUG_ENABLED) begin : gen_C_debug
      always @(posedge clk, posedge internal_reset) begin
         if (internal_reset) begin
            C_dbg_expn_update <= 1'b0;
            C_dbg_expn_taken  <= 1'b0;
         end
         else begin
            C_dbg_expn_taken  <= nxt_dbg_expn_taken;
            C_dbg_expn_update <= nxt_dbg_expn_update;
         end
      end

      always @(posedge clk) begin
         C_dbg_expn_type <= nxt_dbg_expn_type;
         C_dbg_expn_pc   <= nxt_dbg_expn_pc;
      end
   end
   else begin
      assign C_dbg_expn_update = 1'b0;
      assign C_dbg_expn_taken  = 1'b0;
      assign C_dbg_expn_type   = NO_EXPN;
      assign C_dbg_expn_pc     = 32'b0;
   end
   endgenerate

   always @(posedge clk, posedge reset) begin
      if (reset)
         C_reset_req_flush <= 1'b0;
      else
         C_reset_req_flush <= nxt_reset_req_flush;
   end

   always @(*) begin
      nxt_csr_expn_update       = 1'b0;
      nxt_csr_expn_is_interrupt = 1'b0;
      nxt_csr_expn_cause        = M1_expn_cause;
      nxt_csr_expn_level        = {$bits(nxt_csr_expn_level){1'b0}};
      nxt_csr_expn_hv           = 1'b0;
      nxt_csr_expn_pc           = M1_instr_pc;

      nxt_dbg_expn_taken        = 1'b0;
      nxt_dbg_expn_type         = NO_EXPN;
      nxt_dbg_expn_pc           = M1_instr_pc;
      irq_flush                 = 1'b0;

      nxt_reset_req_flush       = 1'b0;

      if (ECC_EN & ~ECC_FULL & (M1_gpr_incorrect | M1_fpr_incorrect)) begin
         if (core_debug_irq) begin
            irq_flush = 1'b1;
            nxt_dbg_expn_taken = 1'b1;
            nxt_dbg_expn_type = DM_IRQ;
         end
         else if (core_nmi_irq) begin
            irq_flush = 1'b1;
            nxt_csr_expn_update = 1'b1;
            nxt_csr_expn_cause  = HW_ERROR;
            nxt_csr_expn_pc     = M1_instr_pc;
         end
      end
      if (DEBUG_ENABLED & ~M1_multicycle_instr_pending & core_debug_irq & ~C_dbg_expn_update & ~core_reset_req) begin
            irq_flush = 1'b1;

            nxt_dbg_expn_taken = 1'b1;
            nxt_dbg_expn_type = DM_IRQ;

         if (M1_expn) begin
            nxt_dbg_expn_pc = M1_instr_pc;
         end
         else begin
            nxt_dbg_expn_pc = M1_nxt_pc;
         end

      end
      else if (USE_RESET_REQ & ~M1_multicycle_instr_pending & core_reset_req & ~ (C_debug_mode | C_dbg_expn_update))
      begin
         irq_flush = 1'b1;
         nxt_reset_req_flush = 1'b1;
      end
      else if (~M1_multicycle_instr_pending & core_irq & core_irq_en & ~C_expn_taken & ~C_dbg_expn_update) begin
         irq_flush = 1'b1;
         nxt_csr_expn_update       = 1'b1;
         nxt_csr_expn_is_interrupt = 1'b1;
         nxt_csr_expn_cause        = core_irq_cause;
         nxt_csr_expn_level        = core_irq_level;
         nxt_csr_expn_hv           = core_irq_hv;

         // PC value for EPC/DPC due to interrupt
         //    If M0 instruction causes exception when interrupt is to be
         //    serviced, take interrupt and reexecute exceptional instructio. If
         //    M0 has redirection due to branch, attach new PC to intr. Otherwise
         //    let M0 instruction retire and find instruction in E, D, I or
         //    buffer.
         //    If there is no insturction in the pipe, attach interrupt to
         //    incoming instruction. And flush when the instruction arrives.

         if (M1_expn) begin
            nxt_csr_expn_pc = M1_instr_pc;
         end
         else begin
            nxt_csr_expn_pc = M1_nxt_pc;
         end

      end
         // Exception in debug mode: debug registers are not updated
      else if (M1_expn & C_debug_mode) begin
         nxt_dbg_expn_taken  = 1'b1;
         nxt_csr_expn_update = 1'b0;
      end
      // Trigger takes to debug mode
      else if (~M1_expn & M1_ls_triggered & C_trig_in_dm) begin
         nxt_dbg_expn_taken  = 1'b1;
         nxt_dbg_expn_type   = EBREAK_DBG;
         nxt_dbg_expn_pc     = M1_nxt_pc;
      end
      // EBREAK takes to debug mode
      else if (M1_ebreak_to_dm) begin
         nxt_dbg_expn_taken  = 1'b1;
         nxt_dbg_expn_type   = EBREAK_DBG;
         nxt_dbg_expn_pc     = M1_instr_pc;
      end
      else if (M1_sstep_expn) begin
         nxt_dbg_expn_taken  = 1'b1;
         nxt_dbg_expn_type   = SINGLE_STP;

         // DPC value for single step exception.
         //    If there is an exception, update EPC with PC causing the exception and
         //    update DPC with "normal mode" exception vector address.

         if (M1_expn) begin
            nxt_dbg_expn_pc = C_expn_redirect_pc;

            nxt_csr_expn_update = 1'b1;
            nxt_csr_expn_pc     = M1_instr_pc;
         end
         else
            nxt_dbg_expn_pc = M1_nxt_pc;

      end
      else if (M1_expn) begin
         nxt_csr_expn_update = 1'b1;
         nxt_dbg_expn_taken  = 1'b0;
         nxt_csr_expn_cause  = M1_expn_cause;
         nxt_csr_expn_pc     = M1_instr_pc;
      end
      else if (M1_ls_triggered) begin
         nxt_csr_expn_update = 1'b1;
         nxt_dbg_expn_taken  = 1'b0;
         nxt_csr_expn_cause  = BREAKPOINT;
         nxt_csr_expn_pc     = M1_nxt_pc;
      end
   end

   // invlidates instructions going from M0 to M1
   // M1 exception OR Interrupt flush
   assign flush_M0 = M1_expn | M1_ls_triggered | irq_flush | M1_sstep_expn | M1_fix_gpr | M1_fix_fpr;

   // Invalidate instruction going from E to M0
   // M0_redirect
   assign flush_E = flush_M0 | (M1_ready & M0_redirect);
   assign flush_D = flush_E;       // Invalidate instruction going from D to E;
   assign flush_I = flush_D;       // Invalidate instruction going from I to D

   assign M0_expn_ret = ~flush_M0 & M1_ready & M0_redirect & M0_mret_instr;
   assign M0_dbg_ret =  ~flush_M0 & M1_ready & M0_redirect & M0_dret_instr;
   assign M0_icache_inv = ~flush_M0 & M1_ready & M0_redirect & M0_fencei_instr;

   assign M1_expn_ret = M1_instr_valid & M1_mret_instr;
   assign M1_dbg_ret = M1_instr_valid & M1_dret_instr;

   //------------------------------------------------------//
   //------- Register Files (GPR and optional FPR) --------//
   //------------------------------------------------------//

   // **************************************************************************** //
   // ************************* Register File RAM Write  ************************* //
   // **************************************************************************** //

   // Write GPR or FPR: 2 cycle RAM latency hence result from one stage before W.
   // Abandon register write if load results in exception.
   assign wr_gpr_en   = (M1_instr_to_gpr_done & ~M1_expn) | M1_fix_gpr;
   assign wr_gpr      = M1_fix_gpr ? M1_fix_gpr_rd  : M1_rd;
   assign wr_gpr_data = M1_fix_gpr ? M1_fix_gpr_val : M1_gpr_result_data_nxt;

   assign wr_fpr_en   = (M1_instr_to_fpr_done & ~M1_expn) | M1_fix_fpr;
   assign wr_fpr      = M1_fix_fpr ? M1_fix_fpr_rd  : M1_rd;
   assign wr_fpr_data = M1_fix_fpr ? M1_fix_fpr_val : M1_fpr_result_data_nxt;

   assign rd_reg_a = D_ready ? I_iw_rs1 : D_iw_rs1;
   assign rd_reg_b = D_ready ? I_iw_rs2 : D_iw_rs2;
   assign rd_reg_c = D_ready ? I_iw_rs3 : D_iw_rs3;  // FP only

   /** Read/Write shadow register file (bank)
    */
   wire rd_previous_srf = D_ready ? I_previous_srf : D_previous_srf;
   wire [$clog2(NUM_BANKS_CHK)-1:0] rd_srf = rd_previous_srf ? csr_to_hart.msrfstatus.psrf : csr_to_hart.msrfstatus.asrf;

   //do we need to fix rs1/rs2 due to an ECC issue?
   wire wr_previous_srf = M1_fix_gpr ? M1_rdpsrf : M1_wrpsrf;
   wire [$clog2(NUM_BANKS_CHK)-1:0] wr_srf = wr_previous_srf ? csr_to_hart.msrfstatus.psrf : csr_to_hart.msrfstatus.asrf;

   niosv_reg_file # (
      .RAM_TYPE                   ( RAM_TYPE                           ),
      .NUM_BANKS                  ( NUM_BANKS_CHK                      ),
      .NUM_REG                    ( NUM_REG                            ),
      .NUM_RD                     ( 2                                  ),
      .DATA_W                     ( DATA_W                             ),
      .ECC_EN                     ( ECC_EN                             ),
      .DEVICE_FAMILY              ( DEVICE_FAMILY                      ))
   gp_reg_file_inst (
      .clk                        ( clk                                ),
      .reset                      ( internal_reset                     ),

      .rd_bank                    ( rd_srf                             ),
      .rd_reg_a                   ( rd_reg_a                           ),
      .rd_data_a                  ( rd_gpr_data_a                      ),
      .rd_reg_b                   ( rd_reg_b                           ),
      .rd_data_b                  ( rd_gpr_data_b                      ),
      .rd_reg_c                   (),
      .rd_data_c                  (),

      .wr_en                      ( wr_gpr_en                          ),
      .wr_bank                    ( wr_srf                             ),
      .wr_reg                     ( wr_gpr                             ),
      .wr_data                    ( wr_gpr_data                        ),

      .ecc_inject_correctable_i   ( csr_ecc_inject.gpr_correctable_error   ),
      .ecc_inject_uncorrectable_i ( csr_ecc_inject.gpr_uncorrectable_error ),
      .eccstatus_reg_a            ( D_rs1_gpr_ecc                      ),
      .eccstatus_reg_b            ( D_rs2_gpr_ecc                      ),
      .eccstatus_reg_c            () );

   generate
      if (!FLOAT_ENABLED) begin : gen_fp_reg_file_tieoff
         assign rd_fpr_data_a = 32'h00000000;
         assign rd_fpr_data_b = 32'h00000000;
         assign rd_fpr_data_c = 32'h00000000;
         assign D_rs1_fpr_ecc = 2'b00;
         assign D_rs2_fpr_ecc = 2'b00;
         assign D_rs3_fpr_ecc = 2'b00;
      end
      else begin : gen_fp_reg_file
         niosv_reg_file # (
            .RAM_TYPE                   ( RAM_TYPE                           ),
            .NUM_BANKS                  ( NUM_BANKS_CHK                      ),
            .NUM_REG                    ( NUM_REG                            ),
            .NUM_RD                     ( 3                                  ),
            .DATA_W                     ( FP32_W                             ),
            .ECC_EN                     ( ECC_EN                             ),
            .DEVICE_FAMILY              ( DEVICE_FAMILY                      )
         ) fp_reg_file_inst (
            .clk                        ( clk                                ),
            .reset                      ( internal_reset                     ),

            .rd_bank                    ( rd_srf                             ),
            .rd_reg_a                   ( rd_reg_a                           ),
            .rd_data_a                  ( rd_fpr_data_a                      ),
            .rd_reg_b                   ( rd_reg_b                           ),
            .rd_data_b                  ( rd_fpr_data_b                      ),
            .rd_reg_c                   ( rd_reg_c                           ),
            .rd_data_c                  ( rd_fpr_data_c                      ),

            .wr_en                      ( wr_fpr_en                          ),
            .wr_bank                    ( wr_srf                             ),
            .wr_reg                     ( wr_fpr                             ),
            .wr_data                    ( wr_fpr_data                        ),

            .ecc_inject_correctable_i   ( csr_ecc_inject.fpr_correctable_error   ),
            .ecc_inject_uncorrectable_i ( csr_ecc_inject.fpr_uncorrectable_error ),

            .eccstatus_reg_a            ( D_rs1_fpr_ecc                      ),
            .eccstatus_reg_b            ( D_rs2_fpr_ecc                      ),
            .eccstatus_reg_c            ( D_rs3_fpr_ecc                      )
         );
      end
   endgenerate

   //------------------------------------------------------//
   //--------------- Dependency Resolution ----------------//
   //------------------------------------------------------//

   // Take most recent value- nearest stage
   // Note that dependency resolution does not need to check whether the op in E or M0
   // has actually completed; dependency stall logic will keep the op in D until the op
   // on which it is dependent has completed. 
   // Also, if E or Mx is flushed, the op in D is also flushed - so flushes do not need to 
   // be taken into account. 

   always @(*) begin
      if (D_iw_rs1_is_zero)
         D_rs1_gpr_val = 32'b0;
      else begin
         if ((D_iw_rs1 == E_rd) && ((D_rdpsrf == E_wrpsrf) || !D_iw_rs1[4]) && E_gpr_wr_en && E_instr_valid)
            D_rs1_gpr_val = E_fpu_to_gpr_done ? E_fpu_to_gpr_result : E_exe_result;
         else if ((D_iw_rs1 == M0_rd) && ((D_rdpsrf == M0_wrpsrf) || !D_iw_rs1[4]) && M0_instr_to_gpr_done)
            D_rs1_gpr_val = M0_gpr_result_data_nxt;
         else if ((D_iw_rs1 == M1_rd) && ((D_rdpsrf == M1_wrpsrf) || !D_iw_rs1[4]) && M1_instr_to_gpr_done)
            D_rs1_gpr_val = M1_gpr_result_data_nxt;
         else if ((D_iw_rs1 == W_rd) && ((D_rdpsrf == W_wrpsrf) || !D_iw_rs1[4]) && W_gpr_wr_en)
            D_rs1_gpr_val = W_gpr_exe_result;
         else
            D_rs1_gpr_val = rd_gpr_data_a;
      end
   end

   // RS2 Dependency resolution
   // TODO: For timing, figure out where to incorporate R0- from ALU or here : R0 = 0 Always!
   always @(*) begin
      if (D_iw_rs2_is_zero)
         D_rs2_gpr_val = 32'b0;
      else begin
         if ((D_iw_rs2 == E_rd) && ((D_rdpsrf == E_wrpsrf) || !D_iw_rs2[4]) && E_gpr_wr_en && E_instr_valid)
            D_rs2_gpr_val = E_fpu_to_gpr_done ? E_fpu_to_gpr_result : E_exe_result;
         else if ((D_iw_rs2 == M0_rd) && ((D_rdpsrf == M0_wrpsrf) || !D_iw_rs2[4]) && M0_instr_to_gpr_done)
            D_rs2_gpr_val = M0_gpr_result_data_nxt;
         else if ((D_iw_rs2 == M1_rd) && ((D_rdpsrf == M1_wrpsrf) || !D_iw_rs2[4]) && M1_instr_to_gpr_done)
            D_rs2_gpr_val = M1_gpr_result_data_nxt;
         else if ((D_iw_rs2 == W_rd) && ((D_rdpsrf == W_wrpsrf) || !D_iw_rs2[4]) && W_gpr_wr_en)
            D_rs2_gpr_val = W_gpr_exe_result;
         else
            D_rs2_gpr_val = rd_gpr_data_b;
      end
   end

   // Dependency resolution for floating-point register accessess - FPR0 is a normal RW register
   always @(*) begin
      if ((D_iw_rs1 == E_rd) && (D_rdpsrf == E_wrpsrf) && E_fpr_wr_en && E_instr_valid)
         D_rs1_fpr_val = E_fpu_to_fpr_result;
      else if ((D_iw_rs1 == M0_rd) && (D_rdpsrf == M0_wrpsrf) && M0_instr_to_fpr_done)
         D_rs1_fpr_val = M0_fpr_result_data_nxt;
      else if ((D_iw_rs1 == M1_rd) && (D_rdpsrf == M1_wrpsrf) && M1_instr_to_fpr_done)
         D_rs1_fpr_val = M1_fpr_result_data_nxt;
      else if ((D_iw_rs1 == W_rd) && (D_rdpsrf == W_wrpsrf) && W_fpr_wr_en)
         D_rs1_fpr_val = W_fpr_exe_result;
      else
         D_rs1_fpr_val = rd_fpr_data_a;
   end
   always @(*) begin
      if ((D_iw_rs2 == E_rd) && (D_rdpsrf == E_wrpsrf) && E_fpr_wr_en)
         D_rs2_fpr_val = E_fpu_to_fpr_result;
      else if ((D_iw_rs2 == M0_rd) && (D_rdpsrf == M0_wrpsrf) && M0_instr_to_fpr_done)
         D_rs2_fpr_val = M0_fpr_result_data_nxt;
      else if ((D_iw_rs2 == M1_rd) && (D_rdpsrf == M1_wrpsrf) && M1_instr_to_fpr_done)
         D_rs2_fpr_val = M1_fpr_result_data_nxt;
      else if ((D_iw_rs2 == W_rd) && (D_rdpsrf == W_wrpsrf) && W_fpr_wr_en)
         D_rs2_fpr_val = W_fpr_exe_result;
      else
         D_rs2_fpr_val = rd_fpr_data_b;
   end
   always @(*) begin
      if ((D_iw_rs3 == E_rd) && (D_rdpsrf == E_wrpsrf) && E_fpr_wr_en)
         D_rs3_fpr_val = E_fpu_to_fpr_result;
      else if ((D_iw_rs3 == M0_rd) && (D_rdpsrf == M0_wrpsrf) && M0_instr_to_fpr_done)
         D_rs3_fpr_val = M0_fpr_result_data_nxt;
      else if ((D_iw_rs3 == M1_rd) && (D_rdpsrf == M1_wrpsrf) && M1_instr_to_fpr_done)
         D_rs3_fpr_val = M1_fpr_result_data_nxt;
      else if ((D_iw_rs3 == W_rd) && (D_rdpsrf == W_wrpsrf) && W_fpr_wr_en)
         D_rs3_fpr_val = W_fpr_exe_result;
      else
         D_rs3_fpr_val = rd_fpr_data_c;
   end

   // Dependency Resolution for ECC
   // If value is being forwarded from any of the stages and value read from register file is not
   // used in actual calculations, that error shouldn't be flagged or corrected. If we apply 
   // correction logic, latest value which was forwarded will be lost.

   // RS1
   assign D_use_rs1_gpr = ~(((D_iw_rs1 == E_rd)  && ((D_rdpsrf == E_wrpsrf ) || !D_iw_rs1[4]) && E_gpr_wr_en   && E_instr_valid) |
                            ((D_iw_rs1 == M0_rd) && ((D_rdpsrf == M0_wrpsrf) || !D_iw_rs1[4]) && M0_instr_done && M0_gpr_wr_en)  |
                            ((D_iw_rs1 == M1_rd) && ((D_rdpsrf == M1_wrpsrf) || !D_iw_rs1[4]) && M1_instr_done && M1_gpr_wr_en)  |
                            ((D_iw_rs1 == W_rd)  && ((D_rdpsrf == W_wrpsrf ) || !D_iw_rs1[4]) && W_gpr_wr_en));

   // RS2
   assign D_use_rs2_gpr = ~(((D_iw_rs2 == E_rd)  && ((D_rdpsrf == E_wrpsrf ) || !D_iw_rs2[4]) && E_gpr_wr_en   && E_instr_valid) |
                            ((D_iw_rs2 == M0_rd) && ((D_rdpsrf == M0_wrpsrf) || !D_iw_rs2[4]) && M0_instr_done && M0_gpr_wr_en)  |
                            ((D_iw_rs2 == M1_rd) && ((D_rdpsrf == M1_wrpsrf) || !D_iw_rs2[4]) && M1_instr_done && M1_gpr_wr_en)  |
                            ((D_iw_rs2 == W_rd)  && ((D_rdpsrf == W_wrpsrf ) || !D_iw_rs2[4]) && W_gpr_wr_en));


   // FPR RS1
   assign D_use_rs1_fpr = ~(((D_iw_rs1 == E_rd)  && (D_rdpsrf == E_wrpsrf ) && E_fpu_to_fpr_done && E_instr_valid) |
                            ((D_iw_rs1 == M0_rd) && (D_rdpsrf == M0_wrpsrf) && M0_instr_done     && M0_fpr_wr_en)  |
                            ((D_iw_rs1 == M1_rd) && (D_rdpsrf == M1_wrpsrf) && M1_instr_done     && M1_fpr_wr_en)  |
                            ((D_iw_rs1 == W_rd)  && (D_rdpsrf == W_wrpsrf ) && W_fpr_wr_en));

   // FPR RS2   
   assign D_use_rs2_fpr = ~(((D_iw_rs2 == E_rd)  && (D_rdpsrf == E_wrpsrf ) && E_fpu_to_fpr_done && E_instr_valid) |
                            ((D_iw_rs2 == M0_rd) && (D_rdpsrf == M0_wrpsrf) && M0_instr_done     && M0_fpr_wr_en)  |
                            ((D_iw_rs2 == M1_rd) && (D_rdpsrf == M1_wrpsrf) && M1_instr_done     && M1_fpr_wr_en)  |
                            ((D_iw_rs2 == W_rd)  && (D_rdpsrf == W_wrpsrf ) && W_fpr_wr_en));

   // FPR RS3
   assign D_use_rs3_fpr = ~(((D_iw_rs3 == E_rd)  && (D_rdpsrf == E_wrpsrf ) && E_fpu_to_fpr_done && E_instr_valid) |
                            ((D_iw_rs3 == M0_rd) && (D_rdpsrf == M0_wrpsrf) && M0_instr_done     && M0_fpr_wr_en)  |
                            ((D_iw_rs3 == M1_rd) && (D_rdpsrf == M1_wrpsrf) && M1_instr_done     && M1_fpr_wr_en)  |
                            ((D_iw_rs3 == W_rd)  && (D_rdpsrf == W_wrpsrf ) && W_fpr_wr_en));


   ///////////////////////////////////////////////////////////////////////////
   /////////////////////////// Instruction Decode ////////////////////////////
   ///////////////////////////////////////////////////////////////////////////

   // TODO:parts of instr decode can be moved to pre-decode/ fectch stage for
   // timing. Ease pressure on decode mux.
   instr_decoder_qsys_top_intel_niosv_g_0_intel_niosv_g_unit_400_25ilc6y # (
      .ATOMIC_ENABLED      (ATOMIC_ENABLED),
      .MULDIV_ENABLED      (MULDIV_ENABLED),
      .FLOAT_ENABLED       (FLOAT_ENABLED),
      .ECC_EN              (ECC_EN),
      .OPTIMIZE_ALU_AREA   (OPTIMIZE_ALU_AREA),
      .DISABLE_FSQRT_FDIV  (DISABLE_FSQRT_FDIV)
   ) instr_decoder_inst (
      .clk                 (clk),
      .reset               (internal_reset),

      .D_instr_valid       (D_instr_valid),
      .D_iw                (D_instr_word),
      .D_imm               (D_imm),
      .D_use_imm           (D_use_imm),
      .D_rs1_gpr_val       (D_rs1_gpr_val),    // Input to decoder after hazard resolution
      .D_rs2_gpr_val       (D_rs2_gpr_val),    // Input to decoder after hazard resolution

      .D_exe_s1            (D_exe_s1),         // Output from decoder- not necessarily D_rs1_gpr_val
      .D_exe_s2            (D_exe_s2),         // Output from decoder- not necessarily D_rs2_gpr_val

      .D_muldiv_ctrl_1     (D_muldiv_ctrl_1),  // mul_s1_signed | ctrl_div_signed
      .D_muldiv_ctrl_2     (D_muldiv_ctrl_2),  // mul_s2_signed | rem_op
      .D_mul_use_lsw       (D_mul_use_lsw),

      .D_mem_size          (D_mem_size),
      .D_mem_byteen        (D_mem_byteen),
      .D_mem_signext       (D_mem_signext),

      .D_rd                (D_rd),
      .D_exe_op            (D_exe_op),
      .D_signed_cmp        (D_signed_cmp),
      .D_alu_sub           (D_alu_sub),

      .D_mul_op            (D_mul_op),
      .D_div_op            (D_div_op),
      .D_cmo_op            (D_cmo_op),
      .D_ci_op             (D_ci_op),

      .D_needs_gp_rs1      (D_needs_gp_rs1),
      .D_needs_gp_rs2      (D_needs_gp_rs2),
      .D_gpr_wr_en         (D_gpr_wr_en),
      .D_needs_fp_rs1      (D_needs_fp_rs1),
      .D_needs_fp_rs2      (D_needs_fp_rs2),
      .D_needs_fp_rs3      (D_needs_fp_rs3),
      .D_fpr_wr_en         (D_fpr_wr_en),

      .D_csr_read          (D_csr_read),
      .D_csr_write         (D_csr_write),
      .D_csr_set           (D_csr_set),
      .D_csr_clr           (D_csr_clr),
      .D_csr_rdpsrf        (D_rdpsrf),
      .D_csr_wrpsrf        (D_wrpsrf),

      .D_instr_pc          (D_instr_pc),
      .D_computed_pc       (D_computed_pc),

      .D_ebreak_instr      (D_ebreak_instr),
      .D_ecall_instr       (D_ecall_instr),

      .D_fp_op_decode      (D_fp_op_decode),

      .D_expn              (D_expn),
      .D_expn_cause        (D_expn_cause),
      .C_debug_mode        (C_debug_mode),

      .D_gpr_incorrect     (D_gpr_incorrect),
      .D_fpr_incorrect     (D_fpr_incorrect)
   );

   //------------------------------------------------------//
   //--------------- Arithmetic Logic Unit ----------------//
   //------------------------------------------------------//

   niosv_g_alu # (
      .CSR_ENABLED             (1'b1),
      .SHIFT_BY                (0),
      .OPTIMIZE_ALU_AREA       (OPTIMIZE_ALU_AREA)
   ) alu_inst (
      .clk                     (clk),
      .reset                   (internal_reset),

      .E_rs1_gpr_val           (E_rs1_gpr_val),
      .E_exe_s2                (E_exe_s2),
      .E_cmp_lt_ltu_op         (E_cmp_lt_ltu_op),
      .E_srx_op                (E_srx_op),
      .E_sra_op                (E_sra_op),
      .E_sll_op                (E_sll_op),
      .E_or_op                 (E_or_op),
      .E_xor_op                (E_xor_op),
      .E_and_op                (E_and_op),
      .E_jump_op               (E_jump_op),
      .E_jalr_op               (E_jalr_op),
      .E_auipc_lui_op          (E_auipc_lui_op),
      .E_beq_bne_op            (E_beq_bne_op),
      .E_blt_bge_op            (E_blt_bge_op),
      .E_bne_bge_op            (E_bne_bge_op),
      .E_signed_cmp            (E_signed_cmp),
      .E_alu_sub               (E_alu_sub),
      .E_shift_amt             (E_shift_amt),
      .E_use_addsub_result     (E_alu_use_addsub_result),
      .E_use_logic_result      (E_alu_use_logic_result),
      .E_instr_pc_nxt          (E_nxt_seq_pc),
      .E_computed_pc           (E_computed_pc),
      .E_redirect              (E_redirect_alu),
      .E_redirect_pc           (E_redirect_pc),
      .E_unaligned_redirect_pc (E_unaligned_redirect_pc),
      .E_alu_result            (E_alu_result),
      .E_alu_add_result        (E_ls_addr),
      .E_mem_size              (E_mem_size),
      .E_mem_unaligned         (E_mem_unaligned)
   );

   //------------------------------------------------------//
   //------------------ Multiplier Unit -------------------//
   //------------------------------------------------------//

   generate if (MULDIV_ENABLED) begin : gen_muldiv
      niosv_multiplier # (
         .DEVICE_FAMILY (DEVICE_FAMILY)
      ) mul_inst (
         .clk                 (clk),
         .reset               (internal_reset),

         .E_mul_valid         (E_mul_valid),
         .E_src1              (E_rs1_gpr_val),
         .E_src2              (E_rs2_gpr_val),
         .E_mul_s1_signed     (E_muldiv_ctrl_1),
         .E_mul_s2_signed     (E_muldiv_ctrl_2),
         .E_mul_use_lsw       (E_mul_use_lsw),

         .M0_instr_valid      (M0_instr_valid),
         .M0_ready            (M0_ready),
         .M1_ready            (M1_ready),

         .M1_mul_pending      (M1_mul_pending),
         .M1_mul_done         (M1_mul_done),
         .M1_mul_result       (M1_mul_result)
      );

      niosv_divider div_inst (
         .clk                 (clk),
         .reset               (internal_reset),

         .E_src1              (M0_rs1_gpr_val),
         .E_src2              (M0_rs2_gpr_val),

         .E_valid             (M0_instr_valid),
         .E_ctrl_div_signed   (M0_muldiv_ctrl_1),
         .E_rem_op            (M0_muldiv_ctrl_2),

         .M0_valid            (M1_instr_valid),
         .M0_div_op           (M1_div_op),

         .M0_div_stall        (M1_div_stall),
         .M0_div_done         (M1_div_done),
         .M0_div_result       (M1_div_result)
      );

      assign M1_div_pending = M1_div_op | M1_div_stall;
   end
   else begin : gen_muldiv_tieoff
      assign M1_mul_pending = 1'b0;
      assign M1_mul_done    = 1'b0;

      assign M1_div_stall   = 1'b0;
      assign M1_div_pending = 1'b0;
      assign M1_div_done    = 1'b0;
   end
   endgenerate

   //------------------------------------------------------//
   //------------------ Load/Store Unit -------------------//
   //------------------------------------------------------//

   generate
      if (DATA_CACHE_SIZE == 0) begin : gen_simple_lsu
         assign M1_dcache_data_ecc = 2'b00;
         assign M1_dcache_dtag_ecc = 2'b00;
         // The simple LSU reports all exceptions in M1
         assign M0_ls_expn         = 1'b0;
         assign M0_ls_expn_cause   = INSTR_ADDR_MISAL;  // binary value all-zeroes
         niosv_g_lsu # (
            .RAM_TYPE                  (RAM_TYPE),
            .ATOMIC_ENABLED            (ATOMIC_ENABLED),
            .DEBUG_ENABLED             (DEBUG_ENABLED),
            .TCM1_SIZE                 (DTCM1_SIZE),
            .TCM1_BASE                 (DTCM1_BASE),
            .TCM1_INIT_FILE            (DTCM1_INIT_FILE),
            .TCM2_SIZE                 (DTCM2_SIZE),
            .TCM2_BASE                 (DTCM2_BASE),
            .TCM2_INIT_FILE            (DTCM2_INIT_FILE),
            .DEVICE_FAMILY             (DEVICE_FAMILY),
            .DTCS1_ADDR_WIDTH          (DTCS1_ADDR_WIDTH),
            .DTCS2_ADDR_WIDTH          (DTCS2_ADDR_WIDTH)
         ) simple_lsu_inst (
            .clk                       (clk),
            .reset                     (internal_reset),
      
            .flush_E                   (flush_E),
            .M0_ready                  (M0_ready),
            .flush_M0                  (flush_M0),
            .M1_ready                  (M1_ready),

            .E_instr_valid             (E_instr_valid),
            .E_ls_addr                 (E_ls_addr),
            .E_load_op                 (E_load_op),
            .E_store_op                (E_store_op),
            .E_store_data              (E_store_gpr ? E_rs2_gpr_val : E_rs2_fpr_val),
            .E_amo_op                  (E_amo_op),
            .E_amo_op_type             (E_amo_op_type),
            .E_amo_rs2_val             (E_rs2_gpr_val),
            .E_ls_mem_size             (E_mem_size),
            .E_ls_mem_byteen           (E_mem_byteen),
            .E_ls_mem_signext          (E_mem_signext),
            
            .M0_ls_op_stall            (M0_ls_op_stall),
            
            .M1_ls_instr_pending       (M1_ls_instr_pending),
            .M1_ls_op_done             (M1_ls_op_done),
            .M1_ld_op_done             (M1_ld_op_done),
            .M1_load_data              (M1_load_data),
            .M1_ls_expn                (M1_ls_expn),
            .M1_ls_expn_cause          (M1_ls_expn_cause),

            .ls_awaddr                 (data_awaddr),
            .ls_awprot                 (data_awprot),
            .ls_awvalid                (data_awvalid),
            .ls_awsize                 (data_awsize),
            .ls_awlen                  (data_awlen),
            .ls_awready                (data_awready),
      
            .ls_wvalid                 (data_wvalid),
            .ls_wdata                  (data_wdata),
            .ls_wstrb                  (data_wstrb),
            .ls_wlast                  (data_wlast),
            .ls_wready                 (data_wready),
      
            .ls_bvalid                 (data_bvalid),
            .ls_bresp                  (data_bresp),
            .ls_bready                 (data_bready),
      
            .ls_araddr                 (data_araddr),
            .ls_arprot                 (data_arprot),
            .ls_arvalid                (data_arvalid),
            .ls_arsize                 (data_arsize),
            .ls_arlen                  (data_arlen),
            .ls_arready                (data_arready),
      
            .ls_rdata                  (data_rdata),
            .ls_rvalid                 (data_rvalid),
            .ls_rresp                  (data_rresp),
            .ls_rready                 (data_rready),
            .ls_rlast                  (data_rlast),

            .tcm1_eccstatus            (M1_dcache_dtcm1_ecc),
            .tcm2_eccstatus            (M1_dcache_dtcm2_ecc),
      
            .dtcs1_awaddr              (dtcs1_awaddr),
            .dtcs1_awprot              (dtcs1_awprot),
            .dtcs1_awvalid             (dtcs1_awvalid),
            .dtcs1_awready             (dtcs1_awready),
      
            .dtcs1_wvalid              (dtcs1_wvalid),
            .dtcs1_wdata               (dtcs1_wdata),
            .dtcs1_wstrb               (dtcs1_wstrb),
            .dtcs1_wready              (dtcs1_wready),
      
            .dtcs1_bvalid              (dtcs1_bvalid),
            .dtcs1_bresp               (dtcs1_bresp),
            .dtcs1_bready              (dtcs1_bready),
      
            .dtcs1_araddr              (dtcs1_araddr),
            .dtcs1_arprot              (dtcs1_arprot),
            .dtcs1_arvalid             (dtcs1_arvalid),
            .dtcs1_arready             (dtcs1_arready),
      
            .dtcs1_rdata               (dtcs1_rdata),
            .dtcs1_rvalid              (dtcs1_rvalid),
            .dtcs1_rresp               (dtcs1_rresp),
            .dtcs1_rready              (dtcs1_rready),
      
            .dtcs2_awaddr              (dtcs2_awaddr),
            .dtcs2_awprot              (dtcs2_awprot),
            .dtcs2_awvalid             (dtcs2_awvalid),
            .dtcs2_awready             (dtcs2_awready),
      
            .dtcs2_wvalid              (dtcs2_wvalid),
            .dtcs2_wdata               (dtcs2_wdata),
            .dtcs2_wstrb               (dtcs2_wstrb),
            .dtcs2_wready              (dtcs2_wready),
      
            .dtcs2_bvalid              (dtcs2_bvalid),
            .dtcs2_bresp               (dtcs2_bresp),
            .dtcs2_bready              (dtcs2_bready),
      
            .dtcs2_araddr              (dtcs2_araddr),
            .dtcs2_arprot              (dtcs2_arprot),
            .dtcs2_arvalid             (dtcs2_arvalid),
            .dtcs2_arready             (dtcs2_arready),
      
            .dtcs2_rdata               (dtcs2_rdata),
            .dtcs2_rvalid              (dtcs2_rvalid),
            .dtcs2_rresp               (dtcs2_rresp),
            .dtcs2_rready              (dtcs2_rready)
         );
      end else begin: gen_dcache_lsu
         // TODO: move M1_ld_op_done into the dcache module (?)
         assign M1_ld_op_done = M1_ls_op_done & M1_load_en;
         // The dcache module only reports unaligned-address exceptions, which allows them
         // to be emitted to the M0 pipline stage. 
         assign M1_ls_expn       = 1'b0;
         assign M1_ls_expn_cause = INSTR_ADDR_MISAL;  // binary value all-zeroes
         niosv_g_dcache # (
            .RAM_TYPE                  (RAM_TYPE),
            .ATOMIC_ENABLED            (ATOMIC_ENABLED),
            .DEBUG_ENABLED             (DEBUG_ENABLED),
            .CACHE_SIZE                (DATA_CACHE_SIZE),
            .DBG_DATA_S_BASE           (DBG_DATA_S_BASE),
            .TIMER_MSIP_DATA_S_BASE    (TIMER_MSIP_DATA_S_BASE),
            .PERIPHERAL_REGION_A_SIZE  (PERIPHERAL_REGION_A_SIZE),
            .PERIPHERAL_REGION_A_BASE  (PERIPHERAL_REGION_A_BASE),
            .PERIPHERAL_REGION_B_SIZE  (PERIPHERAL_REGION_B_SIZE),
            .PERIPHERAL_REGION_B_BASE  (PERIPHERAL_REGION_B_BASE),
            .DTCM1_SIZE                (DTCM1_SIZE),
            .DTCM1_BASE                (DTCM1_BASE),
            .DTCM1_INIT_FILE           (DTCM1_INIT_FILE),
            .DTCM2_SIZE                (DTCM2_SIZE),
            .DTCM2_BASE                (DTCM2_BASE),
            .DTCM2_INIT_FILE           (DTCM2_INIT_FILE),
            .DEVICE_FAMILY             (DEVICE_FAMILY),
            .ECC_EN                    (ECC_EN),
            .ECC_FULL                  (ECC_FULL),
            .DTCS1_ADDR_WIDTH          (DTCS1_ADDR_WIDTH),
            .DTCS2_ADDR_WIDTH          (DTCS2_ADDR_WIDTH)
         ) dcache_lsu_inst (
            .clk                       (clk),
            .reset                     (internal_reset),
      
            .flush_E                   (flush_E),
            .M0_ready                  (M0_ready),
            .flush_M0                  (flush_M0),
            .M1_ready                  (M1_ready),
      
            .E_ls_addr                 (E_ls_addr),
            .E_instr_valid             (E_instr_valid),
            .E_load_op                 (E_load_op),
            .E_store_op                (E_store_op),
            .E_amo_op                  (E_amo_op),
            .E_cmo_op                  (E_cmo_op),
      
            .M0_load_op                (M0_load_op),
            .M0_store_op               (M0_store_op),
            .M0_amo_op                 (M0_amo_op),
            .M0_cmo_op                 (M0_instr_valid & M0_cmo_op), // in case when M0_cmo_op is high for two cycles (TODO: examine M0_amo_op)
            .M0_cmo_op_type            (M0_cmo_op_type),
            .M0_ls_addr                (M0_ls_addr),
            .M0_ls_op_unaligned        (M0_mem_unaligned),
      
            .M0_ls_op_stall            (M0_ls_op_stall),
            .M0_ls_expn                (M0_ls_expn),
            .M0_ls_expn_cause          (M0_ls_expn_cause),

            .Mx_store_data             (M0_store_data),
            .Mx_ls_mem_size            (M0_mem_size),
            .Mx_ls_mem_byteen          (M0_mem_byteen),
            .Mx_ls_mem_signext         (M0_mem_signext),

            .M1_amo_op                 (M1_amo_op),
            .M1_amo_op_type            (M1_amo_op_type),
            .M1_amo_rs2_val            (M1_rs2_gpr_val),
            .M1_cmo_op                 (M1_cmo_op),
      
            .M1_ls_instr_pending       (M1_ls_instr_pending),
            .M1_ls_op_done             (M1_ls_op_done),
            .M1_load_data              (M1_load_data),
      
            .ls_awaddr                 (data_awaddr),
            .ls_awprot                 (data_awprot),
            .ls_awvalid                (data_awvalid),
            .ls_awsize                 (data_awsize),
            .ls_awlen                  (data_awlen),
            .ls_awready                (data_awready),
      
            .ls_wvalid                 (data_wvalid),
            .ls_wdata                  (data_wdata),
            .ls_wstrb                  (data_wstrb),
            .ls_wlast                  (data_wlast),
            .ls_wready                 (data_wready),
      
            .ls_bvalid                 (data_bvalid),
            .ls_bresp                  (data_bresp),
            .ls_bready                 (data_bready),
      
            .ls_araddr                 (data_araddr),
            .ls_arprot                 (data_arprot),
            .ls_arvalid                (data_arvalid),
            .ls_arsize                 (data_arsize),
            .ls_arlen                  (data_arlen),
            .ls_arready                (data_arready),
      
            .ls_rdata                  (data_rdata),
            .ls_rvalid                 (data_rvalid),
            .ls_rresp                  (data_rresp),
            .ls_rready                 (data_rready),
            .ls_rlast                  (data_rlast),
      
            .in_debug_mode             (C_debug_mode),
      
            .ecc_inject                (csr_ecc_inject),
            .dram_eccstatus            (M1_dcache_data_ecc),
            .dtag_eccstatus            (M1_dcache_dtag_ecc),
            .dtcm1_eccstatus           (M1_dcache_dtcm1_ecc),
            .dtcm2_eccstatus           (M1_dcache_dtcm2_ecc),
      
            .dtcs1_awaddr              (dtcs1_awaddr),
            .dtcs1_awprot              (dtcs1_awprot),
            .dtcs1_awvalid             (dtcs1_awvalid),
            .dtcs1_awready             (dtcs1_awready),
      
            .dtcs1_wvalid              (dtcs1_wvalid),
            .dtcs1_wdata               (dtcs1_wdata),
            .dtcs1_wstrb               (dtcs1_wstrb),
            .dtcs1_wready              (dtcs1_wready),
      
            .dtcs1_bvalid              (dtcs1_bvalid),
            .dtcs1_bresp               (dtcs1_bresp),
            .dtcs1_bready              (dtcs1_bready),
      
            .dtcs1_araddr              (dtcs1_araddr),
            .dtcs1_arprot              (dtcs1_arprot),
            .dtcs1_arvalid             (dtcs1_arvalid),
            .dtcs1_arready             (dtcs1_arready),
      
            .dtcs1_rdata               (dtcs1_rdata),
            .dtcs1_rvalid              (dtcs1_rvalid),
            .dtcs1_rresp               (dtcs1_rresp),
            .dtcs1_rready              (dtcs1_rready),
      
            .dtcs2_awaddr              (dtcs2_awaddr),
            .dtcs2_awprot              (dtcs2_awprot),
            .dtcs2_awvalid             (dtcs2_awvalid),
            .dtcs2_awready             (dtcs2_awready),
      
            .dtcs2_wvalid              (dtcs2_wvalid),
            .dtcs2_wdata               (dtcs2_wdata),
            .dtcs2_wstrb               (dtcs2_wstrb),
            .dtcs2_wready              (dtcs2_wready),
      
            .dtcs2_bvalid              (dtcs2_bvalid),
            .dtcs2_bresp               (dtcs2_bresp),
            .dtcs2_bready              (dtcs2_bready),
      
            .dtcs2_araddr              (dtcs2_araddr),
            .dtcs2_arprot              (dtcs2_arprot),
            .dtcs2_arvalid             (dtcs2_arvalid),
            .dtcs2_arready             (dtcs2_arready),
      
            .dtcs2_rdata               (dtcs2_rdata),
            .dtcs2_rvalid              (dtcs2_rvalid),
            .dtcs2_rresp               (dtcs2_rresp),
            .dtcs2_rready              (dtcs2_rready)
         );
      end
   endgenerate

   assign C_addr        = M0_csr_addr;
   assign C_csr_op      = csr_op_t'(M0_iw_f3);
   assign C_rs1_is_zero = M0_iw_rs1_is_zero;
   assign C_rd_is_zero  = M0_rd_is_zero;

   // CSR write cannot be undone. Also, if write is asserted for two or more
   // cycles, mask0 value may result in incorrect value in CSR. Hence write to
   // CSR must be executed when there M0 op is done and there is no exception
   // from M0.
   // TODO: Can CSR read/write be moved to M0?
   assign C_read       = M0_csr_read & M0_instr_valid; // TODO: Analyze read side effects
   assign C_set        = M0_csr_set  & M0_instr_valid;
   assign C_clr        = M0_csr_clr  & M0_instr_valid;
   assign C_write_data = M0_csr_s1;
   assign E_expn       = E_iw_trigger | E_pc_trigger | E_unaligned_redir;
   assign E_expn_cause = (E_iw_trigger | E_pc_trigger) ? BREAKPOINT :
                          E_unaligned_redir            ? INSTR_ADDR_MISAL : ILLEGAL_INSTR;

   always @(*) begin
      C_write = 1'b0;

      if (M0_csr_write & M0_instr_valid & ~flush_M0 & ~M0_instr_trigger) begin
         C_write = M1_ready;
      end
   end

   // FPU state is potentially dirtied by instructions that write to FP registers or have
   // non-zero FP exception flags (FCVT.W[U].S and FCMP have an integer result with FP flags).
   // It's okay to mark FPU state "dirty" in cases where it doesn't actually get dirtied
   // e.g. write to an FPR that already contains the same value, FP operations flushed on
   // interrupt, etc.

   always @(*) begin
      E_fpu_state_dirtied = E_fpr_wr_en |
                           (E_gpr_wr_en &
                           (E_fp_op_decode.is_fcvt_to_gpr_op |
                           (E_fp_op_decode.fcmp_op != FCMP_NOP)));
   end

   always @(*) begin
      if (M1_fpu_to_gpr_done | M1_fpu_to_fpr_done) begin
         M1_fpu_fflags = {M1_fpu_flags.nv,
                          M1_fpu_flags.dz,
                          M1_fpu_flags.of,
                          M1_fpu_flags.uf,
                          M1_fpu_flags.nx};
         M1_fpu_fflags_valid = FLOAT_ENABLED ? 1'b1 : 1'b0;
      end
      else begin
         M1_fpu_fflags = {M1_fpu_m0_flags.nv,
                          M1_fpu_m0_flags.dz,
                          M1_fpu_m0_flags.of,
                          M1_fpu_m0_flags.uf,
                          M1_fpu_m0_flags.nx};
         M1_fpu_fflags_valid = (FLOAT_ENABLED ? 1'b1 : 1'b0)
                             & (M1_fpu_to_gpr_m0_done | M1_fpu_to_fpr_m0_done);
      end
   end

   // Instantiate CSRind interface
   // Note: The CLIC accesses CSrind registers xireg and xireg2

   niosv_csrind_if #(
      .MXLEN      (MXLEN), 
      .PRIV_S_EN  (0),
      .NUM_XIREGS (CLIC_EN ? 2 : 1)  
   ) csrind_if ();

   // CLIC->CSR interfaces (bundles of signals)
   clic_to_csr_t clic_to_csr;
   
   niosv_csr # (
      .RESET_VECTOR            (RESET_VECTOR),
      .CORE_EXTN               (CORE_EXTN),
      .HARTID                  (HARTID),
      .DEBUG_ENABLED           (DEBUG_ENABLED),
      .NUM_PLATFORM_INTERRUPTS (NUM_PLATFORM_INTERRUPTS),
      .NUM_SRF_BANKS           (NUM_SRF_BANKS),
      .CLIC_EN                 (CLIC_EN),
      .CLIC_NUM_LEVELS         (CLIC_NUM_LEVELS),
      .CLIC_VT_ALIGN           (CLIC_VT_ALIGN),
      .ECC_FULL                (ECC_FULL)
   ) csr_inst (
      .clk                     (clk),
      .reset                   (internal_reset),

      // CSR SW read/write
      .csr_read                (C_read),
      .csr_write               (C_write),
      .csr_set                 (C_set),
      .csr_clr                 (C_clr),
      .csr_addr                (C_addr),
      .csr_op                  (C_csr_op),
      .csr_rs1_is_zero         (C_rs1_is_zero),
      .csr_rd_is_zero          (C_rd_is_zero),
      .csr_write_data          (C_write_data),
      .csr_read_data           (C_read_data),
      .csr_access_expn         (C_csr_access_expn),

      // Indirect CSR access interface
      .csrind_if               (csrind_if),

      // CSR exception update
      .csr_expn_update         (C_expn_update),
      .csr_expn_is_interrupt   (C_expn_is_interrupt),
      .csr_expn_cause          (C_expn_cause),
      .csr_expn_level          (C_expn_level),
      .csr_expn_hv             (C_expn_hv),
      .csr_expn_pc             (C_expn_pc),
      .csr_expn_mtval          (C_expn_mtval),
      .csr_expn_mtval2         (C_expn_mtval2),

      .csr_dbg_expn_update     (C_dbg_expn_update),
      .csr_dbg_expn_type       (C_dbg_expn_type),
      .csr_dbg_expn_pc         (C_dbg_expn_pc),

      .expn_redir_pc           (C_expn_redirect_pc),  // Redirect PC for exceptions
      .csr_epc                 (C_csr_epc),
  
      .debug_pc                (C_debug_pc),
  
      .expn_ret                (M1_ready & M0_expn_ret),
      // .dbg_ret              (M1_ready & M0_dbg_ret),  // TODO: investigate when dbg_ret should be taken. Why isn't this consistent with expn_ret?
      .dbg_ret                 (M1_dbg_ret),
  
      .fpu_state_dirtied       (E_fpu_state_dirtied),
      .M_fpu_fflags            (M1_fpu_fflags),
      .M_fpu_fflags_valid      (M1_fpu_fflags_valid),
  
      .timer_irq               (timer_irq),
      .sw_irq                  (sw_irq),
      .plat_irq_vec            (plat_irq_vec),
      .ext_irq                 (ext_irq),
  
      .debug_irq               (debug_irq),
  
      .core_irq_en             (core_irq_en),
      .core_irq                (core_irq),
      .core_irq_pndg           (core_irq_pndg),
      .core_irq_cause          (core_irq_cause),
      .core_irq_level          (core_irq_level),
      .core_irq_hv             (core_irq_hv),
      .core_debug_irq          (core_debug_irq),
  
      .in_debug_mode           (C_debug_mode),
      .csr_step_en             (C_sstep_en),
      .ebreak_in_dm            (C_ebreak_in_dm),
  
      .trig_pc_en              (C_trig_pc_en),
      .trig_instr_en           (C_trig_iw_en),
      .trig_st_adrs_en         (C_trig_st_adrs_en),
      .trig_st_data_en         (C_trig_st_data_en),
      .trig_ld_adrs_en         (C_trig_ld_adrs_en),
      .trig_ld_data_en         (C_trig_ld_data_en),
      .trigger_in_dm           (C_trig_in_dm),
  
      .trig_tdata2             (C_tdata2),
  
      .ecc_inject_o            (csr_ecc_inject),
      .ecc_status_o            (csr_ecc_status),

      .clic_to_csr_i           (clic_to_csr),
      .csr_to_hart_o           (csr_to_hart)
   );

   // Optional Core-level Interrupt controller

   generate
      if (!CLIC_EN) begin : gen_clic_tieoffs   
         always_comb begin
            clic_to_csr = safe_clic_to_csr();
         end
      end
      if (CLIC_EN) begin : gen_clic
         logic [NUM_PLATFORM_INTERRUPTS+16-1:0] clic_interrupt_sources;
         always_comb begin
            clic_interrupt_sources = {plat_irq_vec, 16'b0};
            clic_interrupt_sources[M_SW_IRQ]    = sw_irq;
            clic_interrupt_sources[M_TIMER_IRQ] = timer_irq;
            clic_interrupt_sources[M_EXT_IRQ]   = ext_irq;
         end
         niosv_clic #(
            .MXLEN                    (MXLEN),
            .PRIV_U_EN                (0),
            .PRIV_S_EN                (0),
            .NUM_SRF_BANKS            (NUM_SRF_BANKS),
            .CLIC_NUM_INTERRUPTS      (NUM_PLATFORM_INTERRUPTS+16),
            .CLIC_NUM_LEVELS          (CLIC_NUM_LEVELS),
            .CLIC_NUM_PRIORITIES      (CLIC_NUM_PRIORITIES),
            .CLIC_NUM_DEBUG_TRIGGERS  (CLIC_NUM_DEBUG_TRIGGERS),
            .CLIC_TRIGGER_POLARITY_EN (CLIC_TRIGGER_POLARITY_EN),
            .CLIC_EDGE_TRIGGER_EN     (CLIC_EDGE_TRIGGER_EN),
            .CLIC_VT_ALIGN            (CLIC_VT_ALIGN),
            .CLIC_SHV_EN              (CLIC_SHV_EN)
         ) clic_inst (
            .clk                 (clk),
            .areset              (internal_reset),
            .interrupt_sources_i (clic_interrupt_sources),
            .csr_to_hart_i       (csr_to_hart),
            .clic_to_csr_o       (clic_to_csr),
            .csrind_to_endpoint  (csrind_if)
         );
      end
   endgenerate

   //------------------------------------------------------//
   //---------------- Floating-point Unit -----------------//
   //------------------------------------------------------//

   generate
      if (!FLOAT_ENABLED) begin : gen_fpu_tieoff
         assign D_2stage_fp_op       = 1'b0;
         assign D_3stage_fp_op       = 1'b0;
         assign D_long_fp_op         = 1'b0;
         assign E_fpu_to_fpr_done    = 1'b0;
         assign E_fpu_to_fpr_result  = 32'd0;
         assign E_fpu_to_gpr_done    = 1'b0;
         assign E_fpu_to_gpr_result  = 32'd0;
         assign E_fpu_flags          = deasserted_fp_flags();
         assign M0_fpu_to_fpr_done   = 1'b0;
         assign M0_fpu_to_fpr_result = 32'd0;
         assign M0_fpu_to_gpr_done   = 1'b0;
         assign M0_fpu_to_gpr_result = 32'd0;
         assign M0_fpu_flags         = deasserted_fp_flags();
         assign M1_fpu_op_pending    = 1'b0;
         assign M1_fpu_to_fpr_done   = 1'b0;
         assign M1_fpu_to_fpr_result = 32'd0;
         assign M1_fpu_to_gpr_done   = 1'b0;
         assign M1_fpu_to_gpr_result = 32'd0;
         assign M1_fpu_flags         = deasserted_fp_flags();
      end
      else begin : gen_fpu
         niosv_g_fpu # (
            .DEVICE_FAMILY        (DEVICE_FAMILY),
            .DISABLE_FSQRT_FDIV   (DISABLE_FSQRT_FDIV)
         ) fpu_inst (
            .clk                  (clk),
            .reset                (internal_reset),
            .flush_E              (flush_E),
            .flush_M0             (flush_M0),
            .D_fp_op_decode       (D_fp_op_decode),
            .D_rs1_fpr_val        (D_rs1_fpr_val),
            .D_rs2_fpr_val        (D_rs2_fpr_val),
            .D_rs3_fpr_val        (D_rs3_fpr_val),
            .D_rs1_gpr_val        (D_rs1_gpr_val),
            .D_2stage_fp_op       (D_2stage_fp_op),
            .D_3stage_fp_op       (D_3stage_fp_op),
            .D_long_fp_op         (D_long_fp_op),
            .E_ready              (E_ready),
            .E_instr_valid        (E_instr_valid),
            .E_gpr_wr_en          (E_gpr_wr_en),
            .E_fpu_to_fpr_done    (E_fpu_to_fpr_done),
            .E_fpu_to_fpr_result  (E_fpu_to_fpr_result),
            .E_fpu_to_gpr_done    (E_fpu_to_gpr_done),
            .E_fpu_to_gpr_result  (E_fpu_to_gpr_result),
            .E_fpu_flags          (E_fpu_flags),
            .M0_ready             (M0_ready),
            .M0_fpu_to_fpr_done   (M0_fpu_to_fpr_done),
            .M0_fpu_to_fpr_result (M0_fpu_to_fpr_result),
            .M0_fpu_to_gpr_done   (M0_fpu_to_gpr_done),
            .M0_fpu_to_gpr_result (M0_fpu_to_gpr_result),
            .M0_fpu_flags         (M0_fpu_flags),
            .M1_ready             (M1_ready),
            .M1_fpu_op_pending    (M1_fpu_op_pending),
            .M1_fpu_to_fpr_done   (M1_fpu_to_fpr_done),
            .M1_fpu_to_fpr_result (M1_fpu_to_fpr_result),
            .M1_fpu_to_gpr_done   (M1_fpu_to_gpr_done),
            .M1_fpu_to_gpr_result (M1_fpu_to_gpr_result),
            .M1_fpu_flags         (M1_fpu_flags)
         );
      end
   endgenerate

   //---------------------- Reset Control ----------------------//

   // This is required so that reset_req_ack is not sent when instr request is pending or backpressured.
   //assign nxt_reset_req_done = USE_RESET_REQ ? C_reset_req_flush & (~(instr_req_q & instr_waitreq_q)) & ~instr_req_pending : 1'b0;
   assign nxt_reset_req_done = USE_RESET_REQ && C_reset_req_flush && PC_reset_ack;

   always @(posedge clk, posedge reset) begin
      if (reset) begin
         reset_req_done_q <= {RST_REQ_DEPTH{1'b0}};
      end
      else begin
         reset_req_done_q[0] <= nxt_reset_req_done;
         reset_req_done_q[RST_REQ_DEPTH-1:1] <= reset_req_done_q[RST_REQ_DEPTH-2:0];
      end
   end

   assign reset_req_ack = reset_req_ack_reg;

   // reset_req_ack pulse
   always @(posedge clk) begin
      reset_req_ack_reg <= reset_req_done_q[8] & ~reset_req_ack;
   end

   generate
      if (USE_RESET_REQ) begin : gen_internal_reset_controller
         niosv_reset_controller # (
            .NUM_RESET_INPUTS (2),
            .ADAPT_RESET_REQUEST (1)
         ) rst_ctrl_inst (
            .clk              (clk),

            .reset_in0        (reset),
            .reset_in1        (reset_req_done_q[2]),

            .reset_out        (internal_reset)
         );
      end
      else begin : gen_wired_internal_reset
         assign internal_reset = reset;
      end
   endgenerate

   // ECC Related Logic
   assign D_gpr_ecc = (D_rs1_gpr_ecc & {2{D_use_rs1_gpr & D_needs_gp_rs1}}) | 
                      (D_rs2_gpr_ecc & {2{D_use_rs2_gpr & D_needs_gp_rs2}});

   assign D_fpr_ecc = (D_rs1_fpr_ecc & {2{D_use_rs1_fpr & D_needs_fp_rs1}}) | 
                      (D_rs2_fpr_ecc & {2{D_use_rs2_fpr & D_needs_fp_rs2}}) | 
                      (D_rs3_fpr_ecc & {2{D_use_rs3_fpr & D_needs_fp_rs3}});


   assign D_ecc = ECC_FULL & (D_gpr_ecc[1] | D_fpr_ecc[1] | D_instr_ecc[1] | D_itag_ecc[1]);
//   assign D_fatal_ecc = D_gpr_ecc[0] | D_fpr_ecc[0] | D_instr_ecc[0] | D_itag_ecc[0];
   generate 
      if (ECC_FULL)
         assign D_fatal_ecc = D_gpr_ecc[0] | D_fpr_ecc[0] | D_itcm_expn;
      else
         assign D_fatal_ecc = ECC_EN & (D_gpr_ecc[0] | D_fpr_ecc[0] | D_instr_ecc[0] | D_itag_ecc[0]);
   endgenerate

   assign D_gpr_incorrect = (&D_gpr_ecc);    // D_gpr_ecc == 2'b11, only flag ecc error when there is no data dependency, D_use_rs* factors in dependency
   assign D_fpr_incorrect = (&D_fpr_ecc);    // D_fpr_ecc == 2'b11, only flag ecc error when there is no data dependency, D_use_rs* factors in dependency
   assign D_instr_incorrect = (D_instr_ecc[1:0] == 2'b11);
   assign D_itag_incorrect  = (D_itag_ecc == 2'b11);

   assign M1_data_incorrect  = M1_ld_op_done & (M1_dcache_data_ecc == 2'b11);
   assign M1_dtag_incorrect  = M1_ld_op_done & (M1_dcache_dtag_ecc == 2'b11);
   assign M1_dtcm1_incorrect = M1_ld_op_done & (M1_dcache_dtcm1_ecc == 2'b11);
   assign M1_dtcm2_incorrect = M1_ld_op_done & (M1_dcache_dtcm2_ecc == 2'b11);

   // Preserve worst scenario and associated registers
   // Software write to ecc_status and ecc_src will clear these.
   always @(posedge clk, posedge internal_reset) begin
      if (internal_reset) begin
         E_gpr_ecc    <= 2'b00;
         M0_gpr_ecc   <= 2'b00;
         M1_gpr_ecc   <= 2'b00;

         E_fpr_ecc    <= 2'b00;
         M0_fpr_ecc   <= 2'b00;
         M1_fpr_ecc   <= 2'b00;

         E_instr_ecc  <= 4'b00;
         E_itag_ecc   <= 2'b00;

         M0_instr_ecc <= 4'b00;
         M0_itag_ecc  <= 2'b00;

         M1_instr_ecc <= 4'b00;
         M1_itag_ecc  <= 2'b00;

         M1_dcache_data_ecc_q  <= 2'b00;
         M1_dcache_dtag_ecc_q  <= 2'b00;
         M1_dcache_dtcm1_ecc_q <= 2'b00;
         M1_dcache_dtcm2_ecc_q <= 2'b00;

         M1_ecc_stall <= 1'b0;
      end
      else begin
         if (M1_ecc_wait_for_nmi)
            M1_ecc_stall <= 1'b1;

         if (E_ready & D_instr_valid & ~flush_D & ~D_dep_stall) begin
            if ((~E_gpr_ecc[0] & D_gpr_ecc[0]) | (~E_gpr_ecc[1] & D_gpr_ecc[1]) | ECC_FULL) begin
               E_gpr_ecc <= D_gpr_ecc;
            end

            if ((~E_fpr_ecc[0] & D_fpr_ecc[0]) | (~E_fpr_ecc[1] & D_fpr_ecc[1]) | ECC_FULL) begin
               E_fpr_ecc <= D_fpr_ecc;
            end

            if ((~E_instr_ecc[0] & D_instr_ecc[0]) | (~E_instr_ecc[1] & D_instr_ecc[1]) | ECC_FULL) begin
               E_instr_ecc <= D_instr_ecc;
            end

            if ((~E_itag_ecc[0] & D_itag_ecc[0]) | (~E_itag_ecc[1] & D_itag_ecc[1]) | ECC_FULL) begin
               E_itag_ecc <= D_itag_ecc;
            end

         end

         if (M0_ready & E_instr_valid) begin
            M0_gpr_ecc   <= E_gpr_ecc;
            M0_fpr_ecc   <= E_fpr_ecc;
            M0_instr_ecc <= E_instr_ecc;
            M0_itag_ecc  <= E_itag_ecc;
         end

         if (M1_ready & M0_instr_valid) begin
            M1_gpr_ecc   <= M0_gpr_ecc;
            M1_fpr_ecc   <= M0_fpr_ecc;
            M1_instr_ecc <= M0_instr_ecc;
            M1_itag_ecc  <= M0_itag_ecc;
         end

         if (M1_ld_op_done) begin
            if ((~M1_dcache_data_ecc_q[0] & M1_dcache_data_ecc[0]) | (~M1_dcache_data_ecc_q[1] & M1_dcache_data_ecc[1]) | ECC_FULL) begin
               M1_dcache_data_ecc_q <= M1_dcache_data_ecc;
            end

            if ((~M1_dcache_dtag_ecc_q[0] & M1_dcache_dtag_ecc[0]) | (~M1_dcache_dtag_ecc_q[1] & M1_dcache_dtag_ecc[1]) | ECC_FULL) begin
               M1_dcache_dtag_ecc_q <= M1_dcache_dtag_ecc;
            end

            if ((~M1_dcache_dtcm1_ecc_q[0] & M1_dcache_dtcm1_ecc[0]) | (~M1_dcache_dtcm1_ecc_q[1] & M1_dcache_dtcm1_ecc[1]) | ECC_FULL) begin
               M1_dcache_dtcm1_ecc_q <= M1_dcache_dtcm1_ecc;
            end

            if ((~M1_dcache_dtcm2_ecc_q[0] & M1_dcache_dtcm2_ecc[0]) | (~M1_dcache_dtcm2_ecc_q[1] & M1_dcache_dtcm2_ecc[1]) | ECC_FULL) begin
               M1_dcache_dtcm2_ecc_q <= M1_dcache_dtcm2_ecc;
            end
         end
      end
   end

   always @(posedge clk) begin
      if (E_ready & D_instr_valid & ~flush_D & ~D_dep_stall) begin
         if ((~E_gpr_ecc[0] & D_gpr_ecc[0]) | (~E_gpr_ecc[1] & D_gpr_ecc[1]) |
            (~E_fpr_ecc[0] & D_fpr_ecc[0]) | (~E_fpr_ecc[1] & D_fpr_ecc[1])  | ECC_FULL) begin
            E_ecc_rs1 <= D_iw_rs1;
            E_ecc_rs2 <= D_iw_rs2;
         end
      end

      if (M0_ready & E_instr_valid & ~flush_E) begin
         M0_ecc_rs1 <= E_ecc_rs1;
         M0_ecc_rs2 <= E_ecc_rs2;
      end

      if (M1_ready & M0_instr_valid & ~flush_M0) begin
         M1_ecc_rs1 <= M0_ecc_rs1;
         M1_ecc_rs2 <= M0_ecc_rs2;
      end
   end

   always @(posedge clk, posedge internal_reset) begin
      if (internal_reset) begin
         ecc_status <= 6'b0;
         ecc_src <= 32'b0;
      end
      else if (M1_instr_valid) begin
         if (|M1_gpr_ecc) begin
            ecc_status <= {4'd1, M1_gpr_ecc};
            //ecc_src[RS1_FIELD_H:RS1_FIELD_L] <= M1_ecc_rs1;
            //ecc_src[RS2_FIELD_H:RS2_FIELD_L] <= M1_ecc_rs2;
         end
         else if (|M1_fpr_ecc) begin  // ECC status for FPR
            ecc_status <= {4'd10, M1_fpr_ecc};
            //ecc_src[RS1_FIELD_H:RS1_FIELD_L] <= M1_ecc_rs1;
            //ecc_src[RS2_FIELD_H:RS2_FIELD_L] <= M1_ecc_rs2;
         end
         else if (|M1_instr_ecc[1:0]) begin
            ecc_status[5:2] <= (M1_instr_ecc[3:2] == 2'b01) ? 4'd6 : (M1_instr_ecc[3:2] == 2'b11) ? 4'd7 : 4'd2;  // selection between instr cache , itcm1/itcm2
            ecc_status[1:0] <= M1_instr_ecc[1:0];
         end
         else if (|M1_itag_ecc) begin
            ecc_status <= {4'd3, M1_itag_ecc};
         end
         else if (M1_ls_op_done & (M1_load_en | (ECC_FULL & (M1_dcache_dtag_ecc[0] | M1_dcache_data_ecc[0]))) ) begin  
            // Note: Uncorrectable error in tag ram & data ram needs to be propagated for store instr as well.
            // A cache hit allows for M1_ls_op_done and M1_instr_valid to be high
            // simulataneouly. Therefore, we need to have lsu_ecc checked twice.
            // Once for a cache hit, and the other for a cache miss.
            if (|M1_dcache_data_ecc) begin
               ecc_status <= {4'd4, M1_dcache_data_ecc};
            end
            else if (|M1_dcache_dtag_ecc) begin
               ecc_status <= {4'd5, M1_dcache_dtag_ecc};
            end
            else if (|M1_dcache_dtcm1_ecc) begin
               ecc_status <= {4'd8, M1_dcache_dtcm1_ecc};
            end
            else if (|M1_dcache_dtcm2_ecc) begin
               ecc_status <= {4'd9, M1_dcache_dtcm2_ecc};
            end
         end
         else if (ECC_FULL && (W_fix_gpr || W_fix_fpr || (^W_dcache_data_ecc) || (^W_dcache_dtag_ecc) || (^W_dcache_dtcm1_ecc) || (^W_dcache_dtcm2_ecc))) begin
               ecc_status <= {ecc_status[5:2], 2'b00};         // change the status back to no error if there was correctable error
         end
      end
      else if (M1_ls_op_done & (M1_load_en | (ECC_FULL & (M1_dcache_dtag_ecc[0] | M1_dcache_data_ecc[0]))) ) begin  
         // Uncorrectable error in tag ram & data ram needs to be propagated for store instr as well
         if (|M1_dcache_data_ecc) begin
            ecc_status <= {4'd4, M1_dcache_data_ecc};
         end
         else if (|M1_dcache_dtag_ecc) begin
            ecc_status <= {4'd5, M1_dcache_dtag_ecc};
         end
         else if (|M1_dcache_dtcm1_ecc) begin
            ecc_status <= {4'd8, M1_dcache_dtcm1_ecc};
         end
         else if (|M1_dcache_dtcm2_ecc) begin
            ecc_status <= {4'd9, M1_dcache_dtcm2_ecc};
         end
      end
      else if (ECC_FULL && (W_fix_gpr || W_fix_fpr || (^W_dcache_data_ecc) || (^W_dcache_dtag_ecc) || (^W_dcache_dtcm1_ecc) || (^W_dcache_dtcm2_ecc))) begin
            ecc_status <= {ecc_status[5:2], 2'b00};         // change the status back to no error if there was correctable error
      end 
   end

   assign {core_ecc_src, core_ecc_status} = ecc_status;

   generate if(ECC_FULL) begin : ecc_full
      assign D_fix_gpr = ^D_gpr_ecc;
      assign D_fix_gpr_rd  = (^D_rs1_gpr_ecc) ? D_iw_rs1 : D_iw_rs2;
      assign D_fix_gpr_val = (^D_rs1_gpr_ecc) ? rd_gpr_data_a : rd_gpr_data_b; 

      assign D_fix_fpr = ^D_fpr_ecc;
      assign D_fix_fpr_rd  = (^D_rs1_fpr_ecc) ? D_iw_rs1 : (^D_rs2_fpr_ecc) ? D_iw_rs2 : D_iw_rs3;
      assign D_fix_fpr_val = (^D_rs1_fpr_ecc) ? rd_fpr_data_a : (^D_rs2_fpr_ecc) ? rd_fpr_data_b : rd_fpr_data_c;

      always @ (posedge clk) begin
         if (E_ready & D_instr_valid & ~flush_D & ~D_dep_stall) begin
            E_fix_gpr_rd <= D_fix_gpr_rd; 
            E_fix_gpr_val <= D_fix_gpr_val;

            E_fix_fpr_rd <= D_fix_fpr_rd;
            E_fix_fpr_val <= D_fix_fpr_val;
         end

         if (M0_ready & E_instr_valid) begin
            M0_fix_gpr_val <= E_fix_gpr_val;
            M0_fix_gpr_rd <= E_fix_gpr_rd;

            M0_fix_fpr_rd <= E_fix_fpr_rd;
            M0_fix_fpr_val <= E_fix_fpr_val;
         end
         
         if (M1_ready & M0_instr_valid & ~flush_M0) begin
            M1_fix_gpr_rd <= M0_fix_gpr_rd;
            M1_fix_gpr_val <= M0_fix_gpr_val;

            M1_fix_fpr_rd <= M0_fix_fpr_rd;
            M1_fix_fpr_val <= M0_fix_fpr_val;
         end
      end

      always @(posedge clk, posedge internal_reset) begin
         if(internal_reset) begin
            E_fix_gpr <= 1'b0;
            E_fix_fpr <= 1'b0;   
         end
         else if(flush_D) begin
            E_fix_gpr <= 1'b0;
            E_fix_fpr <= 1'b0;
         end
         else if(E_ready) begin
            if (D_dep_stall) begin
               E_fix_gpr <= 1'b0;
               E_fix_fpr <= 1'b0;
            end
            else begin
               E_fix_gpr <= D_fix_gpr;
               E_fix_fpr <= D_fix_fpr;
            end
         end
      end

      assign E_fix_gpr_fpr = E_fix_gpr | E_fix_fpr;

      always @(posedge clk, posedge internal_reset) begin
         if(internal_reset) begin
            M0_fix_gpr <= 1'b0;
            M0_fix_fpr <= 1'b0;
         end
         else if (flush_E | M0_csr_stall | M0_non_mem_long_op | M0_ls_op_stall) begin
            M0_fix_gpr <= 1'b0;
            M0_fix_fpr <= 1'b0;
         end
         else if (M0_ready) begin   
            M0_fix_gpr <= E_fix_gpr;
            M0_fix_fpr <= E_fix_fpr;
         end
      end

      always @(posedge clk, posedge internal_reset) begin
         if(internal_reset) begin
            M1_fix_gpr <= 1'b0;
            M1_fix_fpr <= 1'b0;
         end
         else if (M1_ready & M0_instr_valid & ~flush_M0) begin
            M1_fix_gpr <= M0_fix_gpr;
            M1_fix_fpr <= M0_fix_fpr;
         end
         else begin
            M1_fix_gpr <= 1'b0;
            M1_fix_fpr <= 1'b0;
         end 
      end

      always @(posedge clk, posedge internal_reset) begin
         if(internal_reset) begin
            W_fix_gpr <= 1'b0;
            W_fix_fpr <= 1'b0;
         end
         else if (W_ready & M1_instr_done) begin
            W_fix_gpr <= M1_fix_gpr;
            W_fix_fpr <= M1_fix_fpr;
         end
         else begin
            W_fix_gpr <= 1'b0;
            W_fix_fpr <= 1'b0;
         end 
      end

      always @(posedge clk, posedge internal_reset) begin
         if(internal_reset) begin
            W_dcache_data_ecc    <= 2'b0;
            W_dcache_dtag_ecc    <= 2'b0;
            W_dcache_dtcm1_ecc   <= 2'b0;
            W_dcache_dtcm2_ecc   <= 2'b0;
         end
         else if (W_ready & M1_instr_done) begin
            W_dcache_data_ecc    <= M1_dcache_data_ecc;
            W_dcache_dtag_ecc    <= M1_dcache_dtag_ecc;
            W_dcache_dtcm1_ecc   <= M1_dcache_dtcm1_ecc;
            W_dcache_dtcm2_ecc   <= M1_dcache_dtcm2_ecc;
         end
         else begin
            W_dcache_data_ecc    <= 2'b0;
            W_dcache_dtag_ecc    <= 2'b0;
            W_dcache_dtcm1_ecc   <= 2'b0;
            W_dcache_dtcm2_ecc   <= 2'b0;
         end 
      end

   end
   else begin : ecc_full_tieoff
      assign D_fix_gpr  = 1'b0;
      assign E_fix_gpr  = 1'b0;
      assign M0_fix_gpr = 1'b0;
      assign M1_fix_gpr = 1'b0;
      assign W_fix_gpr  = 1'b0;

      assign D_fix_fpr  = 1'b0;
      assign E_fix_fpr  = 1'b0;
      assign M0_fix_fpr = 1'b0;
      assign M1_fix_fpr = 1'b0;
      assign W_fix_fpr  = 1'b0;

      assign E_fix_gpr_fpr = 1'b0;

      assign W_dcache_data_ecc  = 2'b0;
      assign W_dcache_dtag_ecc  = 2'b0;
      assign W_dcache_dtcm1_ecc = 2'b0;
      assign W_dcache_dtcm2_ecc = 2'b0;
   end
   endgenerate

   /**
    *
    *
    *@Block description:   //Begin mapping internal signals to the output RISC V FORMAL ports
    *                      //Implementation done for the:
    *                                                    (1)   PC signals
    *                                                    (2)   GPR signals
    *                                                    (3)   MEM signals
    *                                                    (4)   CPU meta data signals
    *                      //Pending implementation work:
    *                                                    (1)   Floating point signals:
    *                                                                                  (1.1) Need to add new pipeline registers for the current floating point instruction.
    *                                                                                        This is to make sure that the correct set of SRC and DS registers, value and status bits
    *                                                                                        travel through the pipeline along with its instruction word.
    *                                                                                  (1.2) Have to be careful about the update logic as these instructions stall the previous stages
    *                                                                                         for either a fixed or variable amount of clock cycles.
    *                                                                                  (1.3) Be sure to make use of MXLEN and FP32_W constants while declaring dimensions.
    *
    */

   logic                M1_ecall_instr;

   always_ff @ (posedge clk, posedge internal_reset) begin
      if(internal_reset)   M1_ecall_instr <= 'd0;
      else                 M1_ecall_instr <= M0_ecall_instr;
   end

   wire                 instr_retire  = M1_instr_done & ~((M1_fix_gpr | M1_fix_fpr) & ~M1_ecall_instr);
   logic [MXLEN  -1:0]  first_pc_at_trap;

   //Static assignments: IXL, MODE & HALT
   assign   rvfi_halt   = 1'b0;
   assign   rvfi_mode   = 2'b11;
   assign   rvfi_ixl    = (MXLEN == 32) ? 2'b01 : 2'b10;

   always_ff @ (posedge clk, posedge internal_reset) begin
      if(internal_reset)                     first_pc_at_trap  <= 'd0;
      else if(M1_expn_ret)                   first_pc_at_trap  <= 'd0;
      else if(core_irq && C_expn_taken)      first_pc_at_trap  <= C_expn_redirect_pc;
   end

   always_ff @ (posedge clk, posedge internal_reset) begin
      if(internal_reset)      rvfi_valid  <= 'b0;
      else                    rvfi_valid  <= instr_retire;
   end

   always_ff @ (posedge clk, posedge internal_reset) begin
      if(internal_reset)      rvfi_order  <= 'd0;
      else if(instr_retire)   rvfi_order  <= rvfi_order + 64'd1;
   end

   always_ff @ (posedge clk, posedge internal_reset) begin
      if(internal_reset) begin
         //rvfi signals to indicate first instruction in the ISR and whether retired instruction caused an exception
         rvfi_intr            <= 'd0;
         rvfi_trap            <= 'd0;

         //rvfi_pc_*: PC of retiring instruction
         rvfi_pc_rdata        <= 'd0;

         //rvfi_insn: current retiring instruction's instruction word
         rvfi_insn            <= 'd0;

         //rvfi_r*: integer GPR read and write information
         rvfi_rs1_addr        <= 'd0;
         rvfi_rs1_rdata       <= 'd0;

         rvfi_rs2_addr        <= 'd0;
         rvfi_rs2_rdata       <= 'd0;

         rvfi_rd_addr         <= 'd0;
         rvfi_rd_wdata        <= 'd0;

         //rvfi_mem_*: memory access information
         rvfi_mem_addr        <= 'd0;
         rvfi_mem_rdata       <= 'd0;
         rvfi_mem_wdata       <= 'd0;
      end
      else begin
         rvfi_intr            <= ~|(M1_instr_pc ^ first_pc_at_trap) & core_irq; 
         rvfi_trap            <= M1_expn & ~C_expn_is_interrupt;

         rvfi_insn            <= M1_instr_word;

         rvfi_rs1_addr        <= M1_instr_word[19:15];
         rvfi_rs1_rdata       <= M1_rs1_gpr_val;

         rvfi_rs2_addr        <= M1_instr_word[24:20];
         rvfi_rs2_rdata       <= M1_rs2_gpr_val;

         rvfi_rd_addr         <= wr_gpr;
         rvfi_rd_wdata        <= wr_gpr_data;

         rvfi_pc_rdata        <= M1_instr_pc;

         rvfi_mem_addr        <= M1_ls_addr;
         rvfi_mem_wdata       <= data_wdata;
         rvfi_mem_rdata       <= M1_load_data;
      end
   end

   always_ff @ (posedge clk, posedge internal_reset) begin
      if(internal_reset) begin
         rvfi_mem_rmask <= 'd0;
         rvfi_mem_wmask <= 'd0;
      end
      else begin
         //Updating rvfi_mem_rmask below.
         if (instr_retire && (M1_instr_word[6:0] == LOAD_OP))  begin
            unique case(M1_instr_word[14:12])
               LB:      rvfi_mem_rmask <= 4'h1;
               LBU:     rvfi_mem_rmask <= 4'h1;
               LH:      rvfi_mem_rmask <= 4'h3;
               LHU:     rvfi_mem_rmask <= 4'h3;
               LW:      rvfi_mem_rmask <= 4'hF;
               default: rvfi_mem_rmask <= 4'h0;
            endcase
         end
         else
            rvfi_mem_rmask <= 'd0;

         //Updating rvfi_mem_wmask below.
         if (instr_retire && (M1_instr_word[6:0] == STORE_OP)) begin
            unique case(M1_instr_word[14:12])
               SB:      rvfi_mem_wmask <= 4'h1;
               SH:      rvfi_mem_wmask <= 4'h3;
               SW:      rvfi_mem_wmask <= 4'hF;
               default: rvfi_mem_wmask <= 4'h0;
            endcase
         end
         else
            rvfi_mem_wmask <= 4'd0;
      end
   end

   generate
      if(BRANCHPREDICTION_EN == 0) begin : rvfi_pc_wdata_without_branch_prediction_setup
         always_ff @ (posedge clk, posedge internal_reset) begin
            if(internal_reset)            rvfi_pc_wdata  <= 'd0;
            else if(redir_pc_update_req)  rvfi_pc_wdata  <= fetch_pc;
            else if(seq_pc_update_req)    rvfi_pc_wdata  <= rvfi_pc_wdata + 32'd4;
         end
      end
      else begin : rvfi_pc_wdata_with_branch_prediction_setup
         always_ff @ (posedge clk, posedge internal_reset) begin
            if(internal_reset)            rvfi_pc_wdata  <= 'd0;
            else if(redir_pc_update_req)  rvfi_pc_wdata  <= (branch_pred_update_req) ? predicted_pc : fetch_pc;
            else if(seq_pc_update_req)    rvfi_pc_wdata  <= rvfi_pc_wdata + 32'd4;
         end
      end
   endgenerate

endmodule

`default_nettype wire


