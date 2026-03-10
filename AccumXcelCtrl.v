//========================================================================
// AccumXcelCtrl
//========================================================================

`ifndef ACCUM_XCEL_CTRL_V
`define ACCUM_XCEL_CTRL_V

`include "ece2300/ece2300-misc.v"
`include "lab3/Register_16b_RTL.v"
`include "lab3/DFFR_RTL.v"

module AccumXcelCtrl
(
  (* keep=1 *) input   logic        clk,
  (* keep=1 *) input   logic        rst,

  // Input val/rdy interface

  (* keep=1 *) input   logic        in_val,
  (* keep=1 *) output  logic        in_rdy,

  // Memory interface

  (* keep=1 *) output  logic        mem_val,

  // Added connections

  (* keep=1 *) input   logic        done,
  (* keep=1 *) output  logic        accum,
  (* keep=1 *) output  logic        load,
  (* keep=1 *) output  logic        acc_reset
);

  // verilator lint_off UNUSEDPARAM
  localparam STATE_BEGIN  = 2'b00;
  localparam STATE_ACCUM  = 2'b01;
  localparam STATE_DONE   = 2'b10;
  // verilator lint_on UNUSEDPARAM

  //--------------------------------------------------------------------------
  // Sequential:  DFFR_RTL flip flops to hold currrent state (3 states)
  //--------------------------------------------------------------------------
  logic [1:0] state;
  logic [1:0] state_next;
  
  DFFR_RTL ff0
  (
    .clk ( clk           ),
    .rst ( rst           ),
    .d   ( state_next[0] ),
    .q   ( state[0]      )
  );

  DFFR_RTL ff1
  (
    .clk ( clk           ),
    .rst ( rst           ),
    .d   ( state_next[1] ),
    .q   ( state[1]      )
  );

  //--------------------------------------------------------------------------
  // Combinational: next state logic
  //--------------------------------------------------------------------------
  always_comb begin

    case (state)
      STATE_BEGIN : state_next = (in_val) ? STATE_ACCUM : STATE_BEGIN;
      STATE_ACCUM : state_next = STATE_DONE;
      STATE_DONE  : state_next = (done)   ? STATE_BEGIN : STATE_DONE;
      default     : state_next = 'x;
    endcase

    `ECE2300_XPROP( state_next, $isunknown(state) );
  end

  //--------------------------------------------------------------------------
  // Combinational: output logic
  //--------------------------------------------------------------------------
  always_comb begin

    case (state)
      STATE_BEGIN: begin
        in_rdy    = 1'b1;
        mem_val   = 1'b0;
        accum     = 1'b0;
        load      = 1'b0;
        acc_reset = in_val & in_rdy;
      end

      STATE_ACCUM: begin
        in_rdy    = 1'b0;
        mem_val   = 1'b1;
        accum     = 1'b1;
        load      = 1'b1;
        acc_reset = 1'b0;
      end

      STATE_DONE: begin
        in_rdy    = 1'b0;
        mem_val   = 1'b1;
        accum     = 1'b1;
        load      = 1'b0;
        acc_reset = 1'b0;
      end
    
      default: begin
        in_rdy    = 'x;
        mem_val   = 'x;
        accum     = 'x;
        load      = 'x;
        acc_reset = 'x;
      end

    endcase

    `ECE2300_XPROP( in_rdy,     $isunknown(state) );
    `ECE2300_XPROP( mem_val,    $isunknown(state) );
    `ECE2300_XPROP( accum,      $isunknown(state) );
    `ECE2300_XPROP( load,       $isunknown(state) );
    `ECE2300_XPROP( acc_reset,  $isunknown(state) );

  end

endmodule

`endif /* ACCUM_XCEL_CTRL_V */
