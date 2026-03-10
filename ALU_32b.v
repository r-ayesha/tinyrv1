//========================================================================
// ALU_32b
//========================================================================
// Simple ALU which supports both addition and equality comparision. For
// equality comparison the least-significant bit will be one if in0
// equals in1 and zero otherwise; the remaining 31 bits will always be
// zero.
//
//  - op == 0 : add
//  - op == 1 : equality comparison
//

`ifndef ALU_32B_V
`define ALU_32B_V

`include "ece2300/ece2300-misc.v"
`include "lab4/Adder_32b_GL.v"
`include "lab4/EqComparator_32b_RTL.v"
`include "lab4/Mux2_32b_RTL.v"

module ALU_32b
(
  (* keep=1 *) input  logic [31:0] in0,
  (* keep=1 *) input  logic [31:0] in1,
  (* keep=1 *) input  logic        op,
  (* keep=1 *) output logic [31:0] out
);

logic [31:0] add_out; 
logic [31:0] eqcomp;
logic eqcomp_out; 

Adder_32b_GL addition
(
.in0 ( in0     ),
.in1 ( in1     ),
.sum ( add_out )
); 

EqComparator_32b_RTL eqcomparator
(
.in1 ( in0        ),
.in0 ( in1        ),
.eq  ( eqcomp_out ) // 1 if equal 0 else 
); 

assign eqcomp[0] = eqcomp_out;
assign eqcomp[31:1] = '0; 

Mux2_32b_RTL select
(
.in0 ( add_out ), 
.in1 ( eqcomp  ), 
.sel ( op      ),
.out ( out     )
); 


endmodule

`endif /* ALU_32B_V */
