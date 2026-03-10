//========================================================================
// Synchronizer_RTL
//========================================================================

`ifndef SYNCHRONIZER_RTL_V
`define SYNCHRONIZER_RTL_V

`include "ece2300/ece2300-misc.v"
`include "lab3/DFF_RTL.v"

module Synchronizer_RTL
(
  (* keep=1 *) input  logic clk,
  (* keep=1 *) input  logic d,
  (* keep=1 *) output logic q
);

  logic d2;

  DFF_RTL dff_rtl1
  (
    .clk( clk ),
    .d  ( d   ),
    .q  ( d2  )
  );

  DFF_RTL dff_rtl2
  (
    .clk( clk ),
    .d  ( d2  ),
    .q  ( q   )
  );

endmodule

`endif /* SYNCHRONIZER_RTL_V */
