//========================================================================
// Mux2_32b_RTL
//========================================================================

`ifndef MUX2_32B_RTL
`define MUX2_32B_RTL

`include "ece2300/ece2300-misc.v"

module Mux2_32b_RTL
(
  (* keep=1 *) input  logic [31:0] in0,
  (* keep=1 *) input  logic [31:0] in1,
  (* keep=1 *) input  logic        sel,
  (* keep=1 *) output logic [31:0] out
);

  always_comb begin
    out = 'x;

    if( sel == 0 )
      out = in0;
    else if( sel == 1 )
      out = in1;
    
    `ECE2300_XPROP(out, $isunknown(sel));
  end

endmodule

`endif /* MUX2_32B_RTL */

