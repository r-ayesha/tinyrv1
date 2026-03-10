//========================================================================
// EdgeDetector_RTL
//========================================================================

`ifndef EDGE_DETECTOR_RTL_V
`define EDGE_DETECTOR_RTL_V

`include "ece2300/ece2300-misc.v"
`include "lab3/DFF_RTL.v"

module EdgeDetector_RTL
(
  (* keep=1 *) input  logic clk,
  (* keep=1 *) input  logic d,
  (* keep=1 *) output logic pos_edge
);

  logic d_prev;

  DFF_RTL dff_rtl
  (
    .clk ( clk    ),
    .d   (  d     ),
    .q   ( d_prev )
  );

  assign pos_edge = d & ~d_prev;

endmodule

`endif /* EDGE_DETECTOR_RTL_V */
