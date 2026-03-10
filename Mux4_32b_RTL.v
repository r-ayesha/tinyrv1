//========================================================================
// Mux4_32b_RTL
//========================================================================

`ifndef MUX4_32b_RTL
`define MUX4_32b_RTL

`include "ece2300/ece2300-misc.v"

module Mux4_32b_RTL
(
  (* keep=1 *) input  logic [31:0] in0,
  (* keep=1 *) input  logic [31:0] in1,
  (* keep=1 *) input  logic [31:0] in2,
  (* keep=1 *) input  logic [31:0] in3,
  (* keep=1 *) input  logic  [1:0] sel,
  (* keep=1 *) output logic [31:0] out
);

  always_comb begin 
    out = 'x; 
  
    if ( sel == 2'b00 )
      out = in0; 
    else if ( sel == 2'b01 )
      out = in1;
    else if ( sel == 2'b10 )
      out = in2;
    else 
      out = in3; 

    `ECE2300_XPROP(out, $isunknown(sel));
  end

endmodule

`endif /* MUX4_32b_RTL */

