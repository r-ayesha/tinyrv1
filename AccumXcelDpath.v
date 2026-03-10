//========================================================================
// AccumXcelDpath
//========================================================================

`ifndef ACCUM_XCEL_DPATH_V
`define ACCUM_XCEL_DPATH_V

`include "ece2300/ece2300-misc.v"
`include "lab3/Counter_16b_RTL.v"
`include "lab4/Register_32b_RTL.v"
`include "lab4/Mux2_32b_RTL.v"
`include "lab4/Multiplier_32x32b_RTL.v"
`include "lab4/Adder_32b_GL.v"

module AccumXcelDpath
(
  (* keep=1 *) input  logic        clk,
  (* keep=1 *) input  logic        rst,

  // Input val/rdy interface

  (* keep=1 *) input  logic  [6:0] in_size,

  // Result

  (* keep=1 *) output logic [31:0] result,

  // Memory interface

  (* keep=1 *) output logic [31:0] mem_addr,
  (* keep=1 *) input  logic [31:0] mem_rdata,

  // Added connections

  (* keep=1 *) output logic        done,
  (* keep=1 *) input  logic        accum,
  (* keep=1 *) input  logic        load,
  (* keep=1 *) input  logic        acc_reset

);

  logic [31:0] reg2_result;
  logic [31:0] adder_out;
  logic [31:0] counter_q_mul;
  logic [31:0] reg2_d;
  logic [15:0] reg1_size;
  logic [15:0] reg1_q;
  logic [15:0] counter_q;
  logic        n_done_and_accum;
  logic        n_done;
  logic        rst_reg2; 
  logic        n_accum;
  logic        count_done;

  not ( n_accum, accum );

  assign reg1_size[6:0] = in_size;

  Register_16b_RTL reg1
  (
    .clk ( clk       ),
    .rst ( rst       ),
    .en  ( n_accum   ),
    .d   ( reg1_size ),
    .q   ( reg1_q    )
  );

  Counter_16b_RTL counter
  (
    .clk    ( clk        ),
    .rst    ( rst        ),
    .en     ( accum      ),
    .load   ( load       ),
    .start  ( 16'b0      ),
    .incr   ( 16'b1      ),
    .finish ( reg1_q     ),
    .count  ( counter_q  ),
    .done   ( count_done )
  );

  assign done                = count_done;
  assign counter_q_mul[15:0] = counter_q;

  Multiplier_32x32b_RTL multiplier
  (
    .in0  ( counter_q_mul ),
    .in1  ( 32'd4         ),
    .prod ( mem_addr      )
  );

  Adder_32b_GL adder
  (
    .in0 ( reg2_result ),
    .in1 ( mem_rdata   ),
    .sum ( adder_out   )
  );

  assign reg2_d = adder_out;

  not ( n_done, done );
  and ( n_done_and_accum, n_done, accum );
  or  ( rst_reg2, rst, acc_reset ); 

  Register_32b_RTL reg2
  (
    .clk ( clk              ),
    .rst ( rst_reg2         ),
    .en  ( n_done_and_accum ),
    .d   ( reg2_d           ),
    .q   ( reg2_result      )
  );

  assign result = reg2_result;

  assign counter_q_mul[31:16] = 16'b0;
  assign reg1_size[15:7]      = 9'b0;

  `ECE2300_UNUSED  ( adder_out[31:16] );

endmodule

`endif /* ACCUM_XCEL_DPATH_V */
