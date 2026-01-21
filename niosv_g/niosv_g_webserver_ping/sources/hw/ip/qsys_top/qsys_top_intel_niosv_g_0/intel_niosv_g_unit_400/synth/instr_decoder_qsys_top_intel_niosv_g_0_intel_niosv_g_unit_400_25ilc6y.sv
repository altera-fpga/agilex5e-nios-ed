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


`default_nettype none
`timescale 1 ns / 1 ns
import niosv_opcode_def::*;
import niosv_g_fp_def::*;

module instr_decoder_qsys_top_intel_niosv_g_0_intel_niosv_g_unit_400_25ilc6y # (
   parameter ATOMIC_ENABLED     = 1'b0,
   parameter MULDIV_ENABLED     = 1'b0,
   parameter FLOAT_ENABLED      = 1'b0,
   parameter ECC_EN             = 1'b0,
   parameter OPTIMIZE_ALU_AREA  = 1'b0,
   parameter DISABLE_FSQRT_FDIV = 1'b0
) (
   input wire                    clk,
   input wire                    reset,

   input wire                    D_instr_valid,
   input wire [31:0]             D_iw,
   input wire [IMM_W-1:0]        D_imm,
   input wire                    D_use_imm,
   input wire [31:0]             D_rs1_gpr_val,
   input wire [31:0]             D_rs2_gpr_val,

   output logic [31:0]           D_exe_s1,
   output logic [31:0]           D_exe_s2,

   output logic                  D_muldiv_ctrl_1,
   output logic                  D_muldiv_ctrl_2,
   output logic                  D_mul_use_lsw,

   output mem_size_t             D_mem_size,
   output byteen_t               D_mem_byteen,
   output logic                  D_mem_signext,

   output wire [4:0]             D_rd,
   output exe_ops_t              D_exe_op,
   output wire                   D_signed_cmp,
   output logic                  D_alu_sub,

   output logic                  D_mul_op,
   output logic                  D_div_op,
   output logic                  D_cmo_op,
   output logic [3:0]            D_ci_op,

   output logic                  D_needs_gp_rs1,
   output logic                  D_needs_gp_rs2,
   output logic                  D_gpr_wr_en,
   output logic                  D_needs_fp_rs1,
   output logic                  D_needs_fp_rs2,
   output logic                  D_needs_fp_rs3,
   output logic                  D_fpr_wr_en,

   output wire                   D_csr_read,
   output wire                   D_csr_write,
   output wire                   D_csr_set,
   output wire                   D_csr_clr,
   output wire                   D_csr_rdpsrf,
   output wire                   D_csr_wrpsrf,

   input  wire [31:0]            D_instr_pc,
   output wire [31:0]            D_computed_pc,

   output wire                   D_ebreak_instr,
   output wire                   D_ecall_instr,

   output fp_op_decode_t         D_fp_op_decode,

   input  wire                   C_debug_mode,

   output wire                   D_expn,
   output xcause_code_t          D_expn_cause,

   input wire                    D_gpr_incorrect,
   input wire                    D_fpr_incorrect
);
   wire [OPCODE_W-1:0]    D_iw_op  = D_iw[OPCODE_FIELD_H:OPCODE_FIELD_L];
   wire [COPCODE_W-1:0]   D_iw_cop = D_iw[COPCODE_FIELD_H:COPCODE_FIELD_L];
   wire [F3_FIELD_W-1:0]  D_iw_f3  = D_iw[F3_FIELD_H:F3_FIELD_L];
   wire [F7_FIELD_W-1:0]  D_iw_f7  = D_iw[F7_FIELD_H:F7_FIELD_L];
   wire [RS1_FIELD_W-1:0] D_iw_rs1 = D_iw[RS1_FIELD_H:RS1_FIELD_L];
   wire [RS2_FIELD_W-1:0] D_iw_rs2 = D_iw[RS2_FIELD_H:RS2_FIELD_L];
   wire [RD_FIELD_W-1:0]  D_iw_rd  = D_iw[RD_FIELD_H:RD_FIELD_L];

   wire [31:0] D_uimm_ext_rs1  = {27'b0, D_iw[RS1_FIELD_H:RS1_FIELD_L]};

   // Fields of the R-type format used for floating point operations
   wire [R_F5_FIELD_W-1:0]  D_iw_r_f5  = D_iw[R_F5_FIELD_H:R_F5_FIELD_L];
   wire [R_FMT_FIELD_W-1:0] D_iw_r_fmt = D_iw[R_FMT_FIELD_H:R_FMT_FIELD_L];
   wire [R_RM_FIELD_W-1:0]  D_iw_r_rm  = D_iw[R_RM_FIELD_H:R_RM_FIELD_L];
   wire [R_RS3_FIELD_W-1:0] D_iw_r_rs3 = D_iw[R_RS3_FIELD_H:R_RS3_FIELD_L];

   wire  D_iw_rd_is_zero;
   logic D_fp_rm_is_valid;

   wire  D_cbo_instr;
   logic D_cbo_inv;
   logic D_cbo_flush;
   logic D_cbo_clean;

   logic D_illegal_instr;
   wire  D_gpr_fpr_incorrect;

   assign D_rd = D_iw_rd;
   assign D_iw_rd_is_zero = (D_iw_rd == GPR0);

   assign D_cbo_instr = (D_iw_cop == MISC_MEM_COP) & (D_iw_f3 == F3_2) & (D_iw_rd == GPR0);

   // Jump and change mode instructions
   assign D_ebreak_instr = (D_iw == EBREAK_INSTR);
   assign D_ecall_instr  = (D_iw == ECALL_INSTR);

   // GPR/FPR uncorrectable ECC
   wire   D_gpr_incorrect_valid  = D_gpr_incorrect & (D_needs_gp_rs1 | D_needs_gp_rs2);
   wire   D_fpr_incorrect_valid  = D_fpr_incorrect & (D_needs_fp_rs1 | D_needs_fp_rs2 | D_needs_fp_rs3);
   assign D_gpr_fpr_incorrect    = D_gpr_incorrect_valid | D_fpr_incorrect_valid;   

   // Exceptions
   assign D_expn = D_instr_valid & (D_ecall_instr | D_ebreak_instr | D_illegal_instr | D_gpr_incorrect_valid | D_fpr_incorrect_valid);
   assign D_expn_cause = D_ecall_instr        ? M_ECALL    :
                         D_ebreak_instr       ? BREAKPOINT : 
                         D_gpr_fpr_incorrect  ? HW_ERROR   : ILLEGAL_INSTR;

   // Memory instruction: CSR
   // CSR set/clear ops with rs1 or immediate == 0 do NOT cause a write 
   assign D_csr_read   = (D_iw_cop == CTRL_COP) & |(D_iw_f3[1:0]);
   assign D_csr_write  = (D_iw_cop == CTRL_COP) & ((D_iw_f3[1:0] == 2'b01) | (D_iw_f3[1] & (D_iw_rs1 != 5'b0)));
   assign D_csr_set    = (D_iw_f3[1:0] == 2'b10);
   assign D_csr_clr    = (D_iw_f3[1:0] == 2'b11);
   assign D_csr_rdpsrf = D_csr_write & (D_iw[I_IMM_FIELD_H:I_IMM_FIELD_L] == ALT_MRDPSRF);
   assign D_csr_wrpsrf = D_csr_write & (D_iw[I_IMM_FIELD_H:I_IMM_FIELD_L] == ALT_MWRPSRF);

   // Memory instruction: LSU
   always @(*) begin
      unique case (D_iw_f3[1:0])
         2'b00 : begin
            D_mem_size = BYTE_SZ;
            D_mem_byteen = BE_B;
         end
         2'b01 : begin
            D_mem_size = HALF_W;
            D_mem_byteen = BE_H;
         end
         default : begin
            D_mem_size = WORD_SZ;
            D_mem_byteen = BE_W;
         end
      endcase
   end

   assign D_mem_signext = FLOAT_ENABLED ? ~D_iw_f3[2] & (D_iw_cop != FP_LOAD_COP) : ~D_iw_f3[2];
   assign D_signed_cmp  = (D_iw_f3 == F3_0) | (D_iw_f3 == F3_1) | (D_iw_f3 == F3_2) | (D_iw_f3 == F3_4) | (D_iw_f3 == F3_5);

   // Muldiv instructions
   always @(*) begin
      // D_mul_s1_signed   = (D_exe_op != MULHU)
      // D_mul_s2_signed   = (D_exe_op == MUL) | (D_exe_op == MULH)
      // D_mul_use_lsw     = (D_exe_op == MUL)
      // D_ctrl_div_signed = (D_exe_op == DIV) | (D_exe_op == REM)
      // D_rem_op          = (D_exe_op == REM) | (D_exe_op == REMU)

      D_muldiv_ctrl_1 = 1'b1;  // muldiv_ctrl_1 = mul_s1_signed | ctrl_div_signed
      D_muldiv_ctrl_2 = 1'b0;  // muldiv_ctrl_2 = mul_s2_signed | rem_op
      D_mul_use_lsw = 1'b0;

      unique case (D_iw_f3)
         F3_0 : begin   // MUL
            D_mul_use_lsw = 1'b1;
            D_muldiv_ctrl_2 = 1'b1;
         end
         F3_1 : begin   // MULH
            D_muldiv_ctrl_2 = 1'b1;
         end
         F3_2 : begin   // MULHSU
         end
         F3_3 : begin   // MULHU
            D_muldiv_ctrl_1 = 1'b0;
         end

         F3_4 : begin   // DIV
         end
         F3_5 : begin   // DIVU
            D_muldiv_ctrl_1 = 1'b0;
         end
         F3_6 : begin   // REM
            D_muldiv_ctrl_2 = 1'b1;
         end
         F3_7 : begin   // REMU
            D_muldiv_ctrl_1 = 1'b0;
            D_muldiv_ctrl_2 = 1'b1;
         end
         default : begin
         end
      endcase
   end

   // Immediates
   assign D_exe_s2 = D_use_imm ? D_imm : D_rs2_gpr_val;
   // The top 2 bits of D_iw_cop[6:5] distinguish LUI from AUIPC, JAL, and JALR
   // In the case of LUI, D_computed_pc is not actually a PC value - but it is convenient to use the same adder
   assign D_computed_pc = ((D_iw_cop[COPCODE_W-1:COPCODE_W-2] == 2'b01) ? 32'b0 : D_instr_pc) + D_imm;

   always @(*) begin
      D_exe_s1          = D_rs1_gpr_val;
      D_gpr_wr_en       = 1'b0;
      D_fpr_wr_en       = 1'b0;
      D_illegal_instr   = (D_iw[1:0] != INSTR_LEN_GE_32BIT);
      D_alu_sub         = 1'b0;
      D_exe_op          = ADD;
      D_mul_op          = 1'b0;
      D_div_op          = 1'b0;
      D_ci_op           = 4'b0;
      D_cmo_op          = 1'b0;
      D_fp_op_decode    = safe_fp_op_decode();
      D_needs_gp_rs1    = 1'b0;
      D_needs_gp_rs2    = 1'b0;
      D_needs_fp_rs1    = 1'b0;
      D_needs_fp_rs2    = 1'b0;
      D_needs_fp_rs3    = 1'b0;

      // Floating point rounding mode validation
      // Required for FMA operations and FP-OP operations that don't have a "don't check RM" bit set
      // Only used in decode for FP-class operations (instr[6:5] = 'b01)
      D_fp_rm_is_valid = ((D_iw_op[4:2] == FP_FP_OP[4:2]) && D_iw_r_f5[2]) |
                         validate_fp_rm (fp_rm_t'(D_iw_f3));

      // Floating point operation modifiers. Do not need to be guarded by checks as to whether this is an FP op
      // and only perform limited checks as to which op it is. This works because the modifiers only take effect
      // when the op to which they apply has been identified by the decoder. 
      if (FLOAT_ENABLED) begin
        D_fp_op_decode.negate_fma_s3              = D_iw_op[2]; // set in FMSUB and FNMADD opcodes, clear in FMADD and FNMSUB
        D_fp_op_decode.negate_fma_multiply_result = D_iw_op[3]; // set in FNMSUB and FNMADD opcodes, clear in FMADD and FMSUB
        D_fp_op_decode.negate_adder_s2 = (D_iw_r_f5 == FP_FSUB) | (D_iw_r_f5 == FP_FMIN_MAX) | (D_iw_r_f5 == FP_FEQ_LT_LE);
        // Operation modifiers for FCVTW[U]S and FCVTSW[U]
        D_fp_op_decode.is_signed_cvt_op   = ~(D_iw_rs2[0]);
        D_fp_op_decode.is_unsigned_cvt_op = D_iw_rs2[0];
        D_fp_op_decode.is_trunc_cvt_op    = (fp_rm_t'(D_iw_r_rm) == FP_RM_RTZ);
      end

      if (FLOAT_ENABLED                       &&
         (D_iw_op[6:5] == FP_OP_CLASS)        &&
         (D_iw_op[1:0] == INSTR_LEN_GE_32BIT) &&
         (D_iw_r_fmt   == FP_FMT_S)           &&
         (D_fp_rm_is_valid)) begin
         D_exe_op = ADD;
         D_needs_fp_rs1 = 1'b1;
         D_needs_fp_rs2 = 1'b1;
         D_fpr_wr_en    = 1'b1;
         unique case (D_iw_op[4:2])
            FP_MADD_OP[4:2]  : begin
               D_fp_op_decode.is_fma_op = 1'b1;
               D_needs_fp_rs3           = 1'b1;
            end
            FP_MSUB_OP[4:2]  : begin
               D_fp_op_decode.is_fma_op = 1'b1;
               D_needs_fp_rs3           = 1'b1;
            end
            FP_NMSUB_OP[4:2] : begin
               D_fp_op_decode.is_fma_op = 1'b1;
               D_needs_fp_rs3           = 1'b1;
            end
            FP_NMADD_OP[4:2] : begin
               D_fp_op_decode.is_fma_op = 1'b1;
               D_needs_fp_rs3           = 1'b1;
            end
            FP_FP_OP[4:2] : begin
               unique case (D_iw_r_f5)
                  FP_FADD : begin
                     D_fp_op_decode.is_fadd_sub_op = 1'b1;
                  end
                  FP_FSUB : begin
                     D_fp_op_decode.is_fadd_sub_op = 1'b1;
                  end
                  FP_FMUL : begin
                     D_fp_op_decode.is_fmul_op = 1'b1;
                  end
                  FP_FDIV : 
                     if (!DISABLE_FSQRT_FDIV) begin
                        D_fp_op_decode.is_fdiv_op = 1'b1;
                     end else begin
                        D_illegal_instr = 1'b1;
                     end
                  FP_FSQRT : begin
                     D_needs_fp_rs2 = 1'b0;
                     if (!DISABLE_FSQRT_FDIV && (D_iw_rs2 == 5'd0)) begin
                        D_fp_op_decode.is_fsqrt_op = 1'b1;
                     end else begin
                        D_illegal_instr = 1'b1;
                     end
                  end
                  FP_FSGNJ :
                     if ((D_iw_f3 == F3_0) || (D_iw_f3 == F3_1) || (D_iw_f3 == F3_2)) begin
                        D_fp_op_decode.fsgnj_op = fsgnj_op_t'(D_iw_f3[1:0]);
                     end else begin
                        D_illegal_instr = 1'b1;
                     end
                  FP_FMIN_MAX :
                     if ((D_iw_f3 == F3_0) || (D_iw_f3 == F3_1)) begin
                        D_fp_op_decode.is_fmin_fmax_op = 1'b1;
                        D_fp_op_decode.is_fmin_op      = ~D_iw_f3[0];
                     end else begin
                        D_illegal_instr = 1'b1;
                     end
                  FP_FCVTSW : begin
                     D_needs_fp_rs1 = 1'b0;
                     D_needs_fp_rs2 = 1'b0;
                     D_needs_gp_rs1 = 1'b1;
                     if ((D_iw_rs2 == 5'd0) || (D_iw_rs2 == 5'd1)) begin
                        D_fp_op_decode.is_fcvt_to_fpr_op = 1'b1;
                     end else begin
                        D_illegal_instr = 1'b1;
                     end
                  end
                  FP_FMVXW_CLASS : begin
                     D_needs_fp_rs2 = 1'b0;
                     D_fpr_wr_en    = 1'b0;
                     D_gpr_wr_en    = 1'b1;
                     if ((D_iw_rs2 == 5'd0) && ((D_iw_f3 == F3_0) || (D_iw_f3 == F3_1))) begin
                        D_fp_op_decode.is_fmv_to_gpr_op = ~D_iw_f3[0];
                        D_fp_op_decode.is_fclass_op     = D_iw_f3[0];
                     end else begin
                        D_illegal_instr = 1'b1;
                     end
                  end
                  FP_FEQ_LT_LE : begin
                     D_fpr_wr_en = 1'b0;
                     D_gpr_wr_en = 1'b1;
                     if ((D_iw_f3 == F3_0) || (D_iw_f3 == F3_1) || (D_iw_f3 == F3_2)) begin
                        D_fp_op_decode.fcmp_op = fcmp_op_t'(D_iw_f3[1:0]);
                     end else begin
                        D_illegal_instr = 1'b1;
                     end
                  end
                  FP_FCVTWS : begin
                     D_needs_fp_rs2 = 1'b0;
                     D_fpr_wr_en    = 1'b0;
                     D_gpr_wr_en    = 1'b1;
                     if ((D_iw_rs2 == 5'd0) || (D_iw_rs2 == 5'd1)) begin
                        D_fp_op_decode.is_fcvt_to_gpr_op = 1'b1;
                     end else begin
                        D_illegal_instr = 1'b1;
                     end
                  end
                  FP_FMVWX : begin
                     D_needs_fp_rs1 = 1'b0;
                     D_needs_fp_rs2 = 1'b0;
                     if ((D_iw_rs2 == 5'd0) && (D_iw_f3 == F3_0)) begin
                        D_fp_op_decode.is_fmv_to_fpr_op = 1'b1;
                     end else begin
                        D_illegal_instr = 1'b1;
                     end
                  end
                  default : begin
                     D_illegal_instr = 1'b1;
                  end
               endcase
            end
            default : begin
               D_illegal_instr = 1'b1;
            end
         endcase
      end
      else begin
         D_needs_gp_rs1 = 1'b1; // the vast majority of integer instruction will need GP rs1
         unique case (D_iw_cop)
            MISC_MEM_COP : begin
               if ((D_iw_f3 == F3_0) | (D_iw_f3 == F3_1)) begin                     // FENCE and FENCE.I
                  D_exe_op       = ADD;
                  D_needs_gp_rs1 = 1'b0;
               end
               else if ((D_iw_f3 == F3_2) & D_iw_rd_is_zero) begin
                  case (D_iw[I_IMM_FIELD_H:I_IMM_FIELD_L])                          // Cache Maintanence Ops
                     CBO_INVAL, CBO_CLEAN, CBO_FLUSH,
                     CBO_INVAL_IDX, CBO_CLEAN_IDX, CBO_FLUSH_IDX : begin
                        D_exe_op = ADD;
                        D_cmo_op = 1'b1;
                     end

                     default : begin
                        D_illegal_instr = 1'b1;
                     end
                  endcase
               end
               else begin
                  D_illegal_instr = 1'b1;
               end
            end

            CTRL_COP : begin
               D_needs_gp_rs1 = ~D_iw_f3[2];
               D_exe_s1 = D_needs_gp_rs1 ? D_rs1_gpr_val : D_uimm_ext_rs1;
               D_gpr_wr_en = D_csr_read;
               unique case (D_iw_f3)
                  F3_0 : begin
                     if ((D_iw_rs1 == 0) & (D_rd == 'd0) &
                        (((D_iw_rs2 == 'd0)  & (D_iw_f7 == 'd0))  |                 // ECALL
                         ((D_iw_rs2 == 'd1)  & (D_iw_f7 == 'd0))  |                 // EBREAK
                         ((D_iw_rs2 == 'd2)  & (D_iw_f7 == 'h18)) |                 // MRET
                         ((D_iw_rs2 == 'd5)  & (D_iw_f7 == 'h8))  |                 // WFI
                         ((D_iw_rs2 == 'h12) & (D_iw_f7 == 'h3D) & C_debug_mode)))  // DRET
                     begin
                     end
                     else begin
                        D_illegal_instr = 1'b1;
                     end
                  end
                  F3_1 : begin                                                      // CSRRW
                  end
                  F3_2 : begin                                                      // CSRRS - high mask set
                  end
                  F3_3 : begin                                                      // CSRRC
                  end
                  F3_5 : begin                                                      // CSRRWI
                  end
                  F3_6 : begin                                                      // CSRRSI
                  end
                  F3_7 : begin                                                      // CSRRCI
                  end
                  default : begin
                     D_illegal_instr = 1'b1;
                  end
               endcase
            end

            B_COP : begin                                                           // Branches
               D_needs_gp_rs2 = 1'b1;
               D_alu_sub = OPTIMIZE_ALU_AREA ? 1'b1 : 1'b0;

               unique case (D_iw_f3)
                  F3_0 : D_exe_op = CMP_EQ;                                         // BEQ
                  F3_1 : D_exe_op = CMP_NE;                                         // BNE
                  F3_4 : D_exe_op = CMP_LT_LTU;                                     // BLT
                  F3_5 : D_exe_op = CMP_GE_GEU;                                     // BGE
                  F3_6 : D_exe_op = CMP_LT_LTU;                                     // BLTU
                  F3_7 : D_exe_op = CMP_GE_GEU;                                     // BGEU

                  default : begin
                     D_illegal_instr = 1'b1;
                  end
               endcase
            end

            LOAD_COP : begin
               D_gpr_wr_en = 1'b1;
               unique case (D_iw_f3)
                  F3_0, F3_1, F3_2, F3_4, F3_5 : begin                              // LB, LH, LW, LBU, LHU
                     D_exe_op = ADD;
                  end

                  default : begin
                     D_illegal_instr = 1'b1;
                  end
               endcase
            end

            STORE_COP : begin
               D_needs_gp_rs2 = 1'b1;
               unique case (D_iw_f3)
                  F3_0, F3_1, F3_2 : begin                                          // SB, SH, SW
                     D_exe_op = ADD;
                  end

                  default : begin
                     D_illegal_instr = 1'b1;
                  end
               endcase
            end

            FP_LOAD_COP : begin
               D_fpr_wr_en = 1'b1;
               if (FLOAT_ENABLED && (D_iw_f3 == F3_2)) begin                        // FLW
                  D_exe_op = ADD;
               end
               else begin
                  D_illegal_instr = 1'b1;
               end
            end

            FP_STORE_COP : begin
               D_needs_fp_rs2 = 1'b1;
               if (FLOAT_ENABLED && (D_iw_f3 == F3_2)) begin                        // SW
                  D_exe_op = ADD;
               end
               else begin
                  D_illegal_instr = 1'b1;
               end
            end

            ALU_I_COP : begin
               D_gpr_wr_en = 1'b1;

               unique case (D_iw_f3)
                  F3_0 : D_exe_op = ADD;                                            // ADDI
                  F3_2 : begin
                     D_exe_op = CMP_LT_LTU;                                         // SLTI
                     D_alu_sub = OPTIMIZE_ALU_AREA ? 1'b1 : 1'b0;
                  end
                  F3_3 : begin
                     D_exe_op = CMP_LT_LTU;                                         // SLTIU
                     D_alu_sub = OPTIMIZE_ALU_AREA ? 1'b1 : 1'b0;
                  end
                  F3_4 : D_exe_op = XOR;                                            // XORI
                  F3_6 : D_exe_op = OR;                                             // ORI
                  F3_7 : D_exe_op = AND;                                            // ANDI

                  F3_1 : begin
                     unique case (D_iw_f7)
                        F7_0 : begin
                           D_exe_op = SLL;                                          // SLLI
                        end

                        default : begin
                           D_illegal_instr = 1'b1;
                        end
                     endcase
                  end

                  F3_5 : begin
                     unique case (D_iw_f7)
                        F7_0 : begin
                           D_exe_op = SRL;                                          // SRLI
                        end

                        F7_20: begin
                           D_exe_op = SRA;                                          // SRAI
                        end

                        default : begin
                           D_illegal_instr = 1'b1;
                        end
                     endcase
                  end

                  default : begin
                     D_illegal_instr = 1'b1;
                  end
               endcase
            end

            ALU_COP : begin
               D_needs_gp_rs2 = 1'b1;
               D_gpr_wr_en = 1'b1;

               unique case (D_iw_f7)
                  F7_0 : begin
                     unique case (D_iw_f3)
                        F3_0 : D_exe_op = ADD;
                        F3_1 : D_exe_op = SLL;
                        F3_2 : begin
                           D_exe_op = CMP_LT_LTU;                                   // SLT
                           D_alu_sub = OPTIMIZE_ALU_AREA ? 1'b1 : 1'b0;
                        end
                        F3_3 : begin
                           D_exe_op = CMP_LT_LTU;                                   // SLTU
                           D_alu_sub = OPTIMIZE_ALU_AREA ? 1'b1 : 1'b0;
                        end
                        F3_4 : D_exe_op = XOR;
                        F3_5 : D_exe_op = SRL;
                        F3_6 : D_exe_op = OR;
                        F3_7 : D_exe_op = AND;

                        default : begin
                           D_illegal_instr = 1'b1;
                        end
                     endcase
                  end

                  F7_1 : begin
                     if (MULDIV_ENABLED) begin
                        unique case (D_iw_f3)
                           F3_0, F3_1, F3_2, F3_3 : begin
                              D_mul_op = 1'b1;
                           end
                           F3_4, F3_5, F3_6, F3_7 : begin
                              D_div_op = 1'b1;
                           end
                        endcase
                     end

                     else begin
                        D_illegal_instr = 1'b1;
                     end
                  end

                  F7_20 : begin
                     D_alu_sub = OPTIMIZE_ALU_AREA ? 1'b1 : 1'b0;

                     unique case (D_iw_f3)
                        F3_0 : begin                                                // SUB
                           D_exe_op = OPTIMIZE_ALU_AREA ? ADD : SUB;
                        end
                        F3_5 : D_exe_op = SRA;

                        default : begin
                           D_illegal_instr = 1'b1;
                        end
                     endcase
                  end

                  default : begin
                     D_illegal_instr = 1'b1;
                  end
               endcase
            end

            JAL_COP : begin
               D_exe_op       = JAL;                                                // JAL
               D_needs_gp_rs1 = 1'b0;
               D_gpr_wr_en    = 1'b1;
            end

            JALR_COP : begin
               D_exe_op       = JALR;                                               // JALR
               D_gpr_wr_en    = 1'b1;

               if (D_iw_f3 != F3_0) begin
                  D_illegal_instr = 1'b1;
               end
            end

            AUIPC_COP : begin
               D_exe_op       = AUIPC;                                              // AUIPC
               D_needs_gp_rs1 = 1'b0;
               D_gpr_wr_en    = 1'b1;
            end

            LUI_COP : begin
               D_exe_op       = AUIPC;                                              // LUI treated as a variant of AUIPC
               D_exe_s1       = 32'b0;
               D_needs_gp_rs1 = 1'b0;
               D_gpr_wr_en    = 1'b1;
            end

            // TODO: make atomic ops optional
            // TODO: account for aq/rl

            ATOMIC_COP : begin
               if (ATOMIC_ENABLED & (D_iw_f3 == F3_2)) begin
                  D_gpr_wr_en = 1'b1;

                  case (D_iw_f7[6:2])
                     AMO_LR, AMO_SC, AMO_SWAP,
                     AMO_ADD, AMO_AND, AMO_XOR,
                     AMO_OR, AMO_MIN, AMO_MAX,
                     AMO_MINU, AMO_MAXU : begin
                        D_exe_op = ADD;
                        D_needs_gp_rs2 = 1'b1;
                     end

                     default : begin
                        D_illegal_instr = 1'b1;
                     end
                  endcase
               end
               else begin
                  D_illegal_instr = 1'b1;
               end
            end

            default : begin
               D_illegal_instr = 1'b1;
            end

         endcase
      end
   end

endmodule

`default_nettype wire

