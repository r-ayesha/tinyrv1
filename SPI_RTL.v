//========================================================================
// SPI_RTL
//========================================================================

`ifndef SPI_RTL_V
`define SPI_RTL_V

`include "ece2300/ece2300-misc.v"

`include "lab4/Synchronizer_RTL.v"
`include "lab4/EdgeDetector_RTL.v"
`include "lab4/ShiftRegister_44b_RTL.v"

module SPI_RTL
(
  (* keep=1 *) input  logic        clk,
  (* keep=1 *) input  logic        rst,

  // Serial Peripheral Interface

  (* keep=1 *) input  logic        cs,
  (* keep=1 *) input  logic        sclk,
  (* keep=1 *) input  logic        mosi,
  (* keep=1 *) output logic        miso,

  // On-chip Interface

  (* keep=1 *) output logic        hmem_val,
  (* keep=1 *) output logic [31:0] hmem_addr,
  (* keep=1 *) output logic [31:0] hmem_wdata
);

  logic        cs_syn_edge;
  logic        sclk_syn_edge;
  logic        edge_reg;
  logic        mosi_syn_reg;
  logic [43:0] reg_out;

  // cs

  Synchronizer_RTL cs_synch
  (
    .clk ( clk         ),
    .d   ( cs          ),
    .q   ( cs_syn_edge )
  );

  EdgeDetector_RTL cs_edged
  (
    .clk      ( clk            ),
    .d        ( cs_syn_edge    ),
    .pos_edge ( hmem_val       )
  );

  // sclk

  Synchronizer_RTL sclk_synch
  (
    .clk ( clk           ),
    .d   ( sclk          ),
    .q   ( sclk_syn_edge )
  );

  EdgeDetector_RTL sclk_edged
  (
    .clk      ( clk           ),
    .d        ( sclk_syn_edge ),
    .pos_edge ( edge_reg      )
  );

  ShiftRegister_44b_RTL shift_reg
  (
    .clk  ( clk          ),
    .rst  ( rst          ),
    .en   ( edge_reg     ),
    .sin  ( mosi_syn_reg ),
    .pout ( reg_out      )
  );

  assign hmem_addr  = { 20'b0, reg_out[43:32 ]};
  assign hmem_wdata = reg_out[31:0]; 

  // mosi

  Synchronizer_RTL mosi_synch
  (
    .clk ( clk          ),
    .d   ( mosi         ),
    .q   ( mosi_syn_reg )
  );

  // miso
  
  assign miso = 0;

endmodule

`endif /* SPI_RTL_V */
