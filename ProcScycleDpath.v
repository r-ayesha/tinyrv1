//========================================================================
// ProcScycleDpath
//========================================================================

`ifndef PROC_SCYCLE_DPATH_V
`define PROC_SCYCLE_DPATH_V

`include "lab4/tinyrv1.v"
`include "lab4/Register_32b_RTL.v"
`include "lab4/Adder_32b_GL.v"
`include "lab4/RegfileZ2r1w_32x32b_RTL.v"
`include "lab4/ALU_32b.v"
`include "lab4/ImmGen_RTL.v"
`include "lab4/Multiplier_32x32b_RTL.v"
`include "lab4/Mux2_32b_RTL.v"
`include "lab4/Mux4_32b_RTL.v"

module ProcScycleDpath
(
  (* keep=1 *) input  logic        clk,
  (* keep=1 *) input  logic        rst,

  // Memory Interface

  (* keep=1 *) output logic [31:0] imem_addr,
  (* keep=1 *) input  logic [31:0] imem_rdata,

  (* keep=1 *) output logic [31:0] dmem_addr,
  (* keep=1 *) output logic [31:0] dmem_wdata,
  (* keep=1 *) input  logic [31:0] dmem_rdata,

  // Trace Interface

  (* keep=1 *) output logic [31:0] trace_addr,
  (* keep=1 *) output logic [4:0]  trace_wreg,
  (* keep=1 *) output logic [31:0] trace_wdata,

  // Control Signals (Control Unit -> Datapath)

  (* keep=1 *) input  logic        op2_sel,
  (* keep=1 *) input  logic [1:0]  wb_sel,
  (* keep=1 *) input  logic [1:0]  imm_type,
  (* keep=1 *) input  logic        rf_wen, 
  (* keep=1 *) input  logic [1:0]  pc_sel, 
  (* keep=1 *) input  logic        alu_func, 
  (* keep=1 *) input  logic        pc_en,

  // Status Signals (Datapath -> Control Unit)

  (* keep=1 *) output logic [31:0] inst,
  (* keep=1 *) output logic        eq

);

  // PC Register

  logic [31:0] pc;
  logic [31:0] pc_next;
  logic [31:0] pc_d;

  logic [31:0] jalbr_targ;
  logic [31:0] jr_targ;

  logic [31:0] alu_out;
  logic [31:0] mul_out;
  logic [31:0] op2_out;

  logic [31:0] immgen_imm;

  // PC Register 
  Register_32b_RTL pc_reg
  (
    .clk ( clk   ),
    .rst ( rst   ),
    .en  ( pc_en ),
    .d   ( pc_d  ),
    .q   ( pc    )
  );

  assign imem_addr = pc;

  // PC+4 Adder
  Adder_32b_GL pc_adder
  (
    .in0 ( pc      ),
    .in1 ( 32'd4   ),
    .sum ( pc_next )
   );

  // Mux before PC
  Mux4_32b_RTL pc_mux
  (
    .in0 ( jalbr_targ ),
    .in1 ( jr_targ    ),
    .in2 ( pc_next    ),
    .in3 ( 'x         ),
    .sel ( pc_sel     ),
    .out ( pc_d       )
  );

  // Extract instruction fields

  assign inst = imem_rdata;

  logic [`TINYRV1_INST_RS1_NBITS-1:0] rs1;
  logic [`TINYRV1_INST_RS1_NBITS-1:0] rs2;
  logic [`TINYRV1_INST_RD_NBITS-1:0]  rd;

  assign rs1 = inst[`TINYRV1_INST_RS1];
  assign rs2 = inst[`TINYRV1_INST_RS2];
  assign rd  = inst[`TINYRV1_INST_RD];

  // Register File

  logic [31:0] rf_wdata;
  logic [31:0] rf_rdata0;
  logic [31:0] rf_rdata1;

  // Register rf
  RegfileZ2r1w_32x32b_RTL rf
  (
    .clk    ( clk        ),

    .wen    ( rf_wen     ),
    .waddr  ( rd         ),
    .wdata  ( rf_wdata   ),

    .raddr0 ( rs1        ),
    .rdata0 ( rf_rdata0  ),

    .raddr1 ( rs2        ),
    .rdata1 ( rf_rdata1  )
  );

  // Immediate Generation
  ImmGen_RTL immgen
  (
    .inst     ( inst       ),
    .imm_type ( imm_type   ),
    .imm      ( immgen_imm )
   );

  // Op2 Mux
  Mux2_32b_RTL op2_mux
  (
    .in0 ( rf_rdata1  ),
    .in1 ( immgen_imm ),
    .sel ( op2_sel    ),
    .out ( op2_out    )
  );

  // Immgen Adder
  Adder_32b_GL imm_addr
  (
    .in0 ( immgen_imm ),
    .in1 ( pc         ),
    .sum ( jalbr_targ )
  );

  // ALU
  ALU_32b alu
  (
    .in0 ( rf_rdata0 ),
    .in1 ( op2_out   ),
    .op  ( alu_func  ),
    .out ( alu_out   )
  );

  assign eq = alu_out[0];

  // MUL
  Multiplier_32x32b_RTL mul 
  (
    .in0  ( rf_rdata0 ),
    .in1  ( rf_rdata1 ), 
    .prod ( mul_out   )
  ); 

  logic [31:0] rf_write_final_output;
  assign dmem_addr  = alu_out; // now the address is alu out bc you want to get the imm + value at rs1

  // mux for write file 
  Mux4_32b_RTL regfile_write_final
  (
   .in0  ( mul_out               ),
   .in1  ( alu_out               ),
   .in2  ( pc_next               ), // memory accessed now (if mux = 2, then access mem )
   .in3  ( dmem_rdata            ), // memory accessed now (if mux = 2, then access mem ) 
   .sel  ( wb_sel                ),
   .out  ( rf_write_final_output )
  ); 
  
  // the output before the write data 
  assign rf_wdata = rf_write_final_output; // write rf_wdata as this 

  assign jr_targ = rf_rdata0;

  // Data Memory 
  assign dmem_wdata = rf_rdata1;

  // Trace Output
  assign trace_addr  = pc;
  assign trace_wreg  = rd;
  assign trace_wdata = rf_wdata;

endmodule

`endif /* PROC_SCYCLE_DPATH_V */
