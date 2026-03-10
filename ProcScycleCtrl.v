//========================================================================
// ProcScycleCtrl
//========================================================================

`ifndef PROC_SCYCLE_CTRL_V
`define PROC_SCYCLE_CTRL_V

`include "lab4/tinyrv1.v"

module ProcScycleCtrl
(
  (* keep=1 *) input  logic        rst,

  // Memory Interface

  (* keep=1 *) output logic        imem_val,
  (* keep=1 *) input  logic        imem_wait,

  (* keep=1 *) output logic        dmem_val,
  (* keep=1 *) input  logic        dmem_wait,
  (* keep=1 *) output logic        dmem_type,

  // Trace Interface

  (* keep=1 *) output logic        trace_val,
  (* keep=1 *) output logic        trace_wen,

  // Control Signals (Control Unit -> Datapath)

  (* keep=1 *) output logic [1:0]  pc_sel, 
  (* keep=1 *) output logic [1:0]  imm_type,
  (* keep=1 *) output logic        op2_sel,
  (* keep=1 *) output logic [1:0]  wb_sel,
  (* keep=1 *) output logic        rf_wen, 
  (* keep=1 *) output logic        alu_func, 
  (* keep=1 *) output logic        pc_en,


  // Status Signals (Datapath -> Control Unit)

  (* keep=1 *) input  logic [31:0] inst,
  (* keep=1 *) input  logic        eq

);

  // Localparams for imm-type control signals 
  localparam I = 2'b00; 
  localparam S = 2'b01;
  localparam J = 2'b10; 
  localparam B = 2'b11; 

  // Localparams for op2_sel control signal
  localparam rf  = 1'd0;
  localparam imm = 1'd1;

  // Localparams for wb_sel control signals 
  localparam alu        = 2'd1; 
  localparam mul        = 2'd0;
  localparam dmem_rdata = 2'd3;

  // Localparams for pc_sel control signals 
  localparam jalbr_targ = 2'd0;
  localparam jr_targ    = 2'd1;
  localparam pc_plus4   = 2'd2;

  // Localparams for alu_func control signals
  localparam add = 1'b0;
  localparam cmp = 1'b1;

  // Localparams for dmem_type control signals
  localparam read = 1'd0; 
  localparam write = 1'd1; 

  logic dmem_val_pre; 
  logic dmem_type_pre; 
  logic rf_wen_pre;

  task automatic cs
  (
    input logic [1:0] pc_sel_,
    input logic [1:0] imm_type_, 
    input logic       op2_sel_,
    input logic       alu_func_,
    input logic [1:0] wb_sel_,
    input logic       rf_wen_pre_,
    input logic       dmem_val_,
    input logic       dmem_type_
  );

    pc_sel        = pc_sel_;
    imm_type      = imm_type_; 
    op2_sel       = op2_sel_;
    alu_func      = alu_func_;
    wb_sel        = wb_sel_; 
    rf_wen_pre    = rf_wen_pre_;
    dmem_val_pre  = dmem_val_; 
    dmem_type_pre = dmem_type_;

  endtask

  // Control signal table
  // controls for up tp SW instructions 
  // imm is the type for the immediate 
  // op2 mux select that support whether you want second readfile or the immediate into the alu
  // wb mux select for the final value that goes into the write register 
  // rf is en whether or not to write the register (protection when not writing the memory in that cycle)
  // dmem_val is whether or not the instruction can access the memory
  // dmem_type is what type of access (write or read from memory)

  always_comb begin
    casez ( inst )
                          //  pc                            / imm    / op2   / alu  / wb  /        rf / dmem / dmem
                          //  sel                           / type   / sel   / func / sel /       wen / val  / type
      `TINYRV1_INST_ADDI: cs( pc_plus4,                         I,     imm ,   add  , alu,         1,    0, 'x     );
      `TINYRV1_INST_ADD:  cs( pc_plus4,                        'x,     rf  ,   add  , alu,         1,    0, 'x     );
      `TINYRV1_INST_MUL:  cs( pc_plus4,                        'x,     'x  ,   'x   , mul,         1,    0, 'x     );
      `TINYRV1_INST_LW:   cs( pc_plus4,                         I,     imm ,   add  , dmem_rdata,  1,    1,  read  );
      `TINYRV1_INST_SW:   cs( pc_plus4,                         S,     imm ,   add  , 'x,          0,    1,  write );
      `TINYRV1_INST_JAL:  cs( jalbr_targ,                       J,     'x  ,   'x   , 2'd2,        1,    0, 'x     );
      `TINYRV1_INST_JR:   cs( jr_targ,                          I,     'x  ,   'x   , 'x,          0,    0, 'x     );
      `TINYRV1_INST_BNE:  cs( (eq)? pc_plus4 : jalbr_targ ,     B,      rf ,   cmp  ,  1,          0,    0, 'x     );

      default:            cs( 'x,                              'x,      'x ,    'x  , 'x,         'x,   'x, 'x     );
    endcase
  end

  // Additional combinational logic
  // (only use assign statements, no always_comb blocks!)

  assign imem_val  = !rst;
  assign dmem_val  = !rst && !imem_wait && dmem_val_pre;
  assign dmem_type = !rst && dmem_type_pre;
  assign rf_wen = !rst && !imem_wait && !dmem_wait && rf_wen_pre;
  assign pc_en = !imem_wait && !dmem_wait;

  assign trace_val = !rst && !imem_wait && !dmem_wait;
  assign trace_wen = !rst && rf_wen;

endmodule

`endif /* PROC_SCYCLE_CTRL_V */
