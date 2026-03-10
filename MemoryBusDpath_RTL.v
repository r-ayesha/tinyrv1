//========================================================================
// MemoryBusDpath_RTL
//========================================================================

`ifndef MEMORY_BUS_DPATH_RTL_V
`define MEMORY_BUS_DPATH_RTL_V

`include "ece2300/ece2300-misc.v"

`include "lab4/Mux2_32b_RTL.v"
`include "lab4/Register_32b_RTL.v"
`include "lab4/MemoryBusAddrDecoder_RTL.v"
`include "lab4/MemoryBusDataMux_RTL.v"

module MemoryBusDpath_RTL
(
  (* keep=1 *) input  logic        clk,
  (* keep=1 *) input  logic        rst,

  // Processor Interface
  (* keep=1 *) input  logic [31:0] imem_addr,
  (* keep=1 *) output logic [31:0] imem_rdata,

  (* keep=1 *) input  logic [31:0] dmem_addr,
  (* keep=1 *) input  logic [31:0] dmem_wdata,
  (* keep=1 *) output logic [31:0] dmem_rdata,

  // SPI Interface

  (* keep=1 *) input  logic [31:0] hmem_addr,
  (* keep=1 *) input  logic [31:0] hmem_wdata,

  // Memory Interface

  (* keep=1 *) output logic [31:0] mem0_addr,
  (* keep=1 *) output logic [31:0] mem0_wdata,
  (* keep=1 *) input  logic [31:0] mem0_rdata,

  (* keep=1 *) output logic [31:0] mem1_addr,
  (* keep=1 *) output logic [31:0] mem1_wdata,
  (* keep=1 *) input  logic [31:0] mem1_rdata,

  // External I/O Interface

  (* keep=1 *) input  logic [31:0] in0,
  (* keep=1 *) input  logic [31:0] in1,
  (* keep=1 *) input  logic [31:0] in2,
  (* keep=1 *) input  logic [31:0] in3,

  (* keep=1 *) output logic [31:0] out0,
  (* keep=1 *) output logic [31:0] out1,
  (* keep=1 *) output logic [31:0] out2,
  (* keep=1 *) output logic [31:0] out3,

  // Control Signals (ctrl -> dpath)

  (* keep=1 *) input  logic        mem0_addr_sel,
  (* keep=1 *) input  logic        dmem_wen
);

  Mux2_32b_RTL addr_mux
  (
  .in0 ( imem_addr ),
  .in1 ( hmem_addr ),
  .sel ( mem0_addr_sel ),
  .out ( mem0_addr )
  ); 

  // comes from mem0 of the read and write for mem0
  assign imem_rdata = mem0_rdata;
  assign mem0_wdata = hmem_wdata;

  // mem1 which stores and loads from normal data path
  assign mem1_addr  = dmem_addr;
  assign mem1_wdata = dmem_wdata;

  MemoryBusDataMux_RTL data_mux
  (
  .std  ( mem1_rdata ), 
  .in0  ( in0 ),
  .in1  ( in1 ),
  .in2  ( in2 ),
  .in3  ( in3 ), 
  .addr ( dmem_addr ),
  .out  ( dmem_rdata )
  ); 
 
  // to enable for each register for outputs 
  logic out0_en;
  logic out1_en; 
  logic out2_en;
  logic out3_en; 

  MemoryBusAddrDecoder_RTL mem_bus_decoder
  (
  .en      ( dmem_wen ), 
  .addr    ( dmem_addr ), 
  .out0_en ( out0_en ), 
  .out1_en ( out1_en ), 
  .out2_en ( out2_en ), 
  .out3_en ( out3_en )
  );

  Register_32b_RTL reg_out0
  (
  .clk ( clk ), 
  .rst ( rst ),
  .en  ( dmem_wen && out0_en ),
  .d   ( dmem_wdata ),
  .q   ( out0 )
  );

  Register_32b_RTL reg_out1
  (
  .clk ( clk ), 
  .rst ( rst ),
  .en  ( dmem_wen && out1_en ),
  .d   ( dmem_wdata ),
  .q   ( out1 )
  );

  Register_32b_RTL reg_out2
  (
  .clk ( clk ), 
  .rst ( rst ),
  .en  ( dmem_wen && out2_en ),
  .d   ( dmem_wdata ),
  .q   ( out2 )
  );

  Register_32b_RTL reg_out3
  (
  .clk ( clk ), 
  .rst ( rst ),
  .en  ( dmem_wen && out3_en ),
  .d   ( dmem_wdata ),
  .q   ( out3 )
  );

endmodule

`endif /* MEMORY_BUS_DPATH_RTL_V */
