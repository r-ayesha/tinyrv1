//========================================================================
// RegfileZ2r1w_32x32b_RTL
//========================================================================
// Register file with 32 32-bit entries, two read ports, and one write
// port. Reading register zero should always return zero. If waddr ==
// raddr then rdata should be the old data.

`ifndef REGFILE_Z_2R1W_32X32B_RTL
`define REGFILE_Z_2R1W_32X32B_RTL

`include "ece2300/ece2300-misc.v"

module RegfileZ2r1w_32x32b_RTL
(
  (* keep=1 *) input  logic        clk,

  (* keep=1 *) input  logic        wen,
  (* keep=1 *) input  logic  [4:0] waddr,
  (* keep=1 *) input  logic [31:0] wdata,

  (* keep=1 *) input  logic  [4:0] raddr0,
  (* keep=1 *) output logic [31:0] rdata0,

  (* keep=1 *) input  logic  [4:0] raddr1,
  (* keep=1 *) output logic [31:0] rdata1
);
  // makes into 32 x 32 states 
  logic [31:0] m [31:0];

  // sequential write port 
  always_ff @(posedge clk) begin
    if (wen && (waddr != 5'd0)) begin
      m[waddr] <= wdata;
    end
  end
 
  // read port read 0 will give 0 else read 
  always_comb begin
    rdata0 = (raddr0 == 5'd0) ? 32'b0 : m[raddr0];
    rdata1 = (raddr1 == 5'd0) ? 32'b0 : m[raddr1];
  end

endmodule

`endif /* REGFILE_Z_2R1W_32x32b_RTL */
