//========================================================================
// ShiftRegister_44b_RTL
//========================================================================

`ifndef SHIFT_REGISTER_44B_RTL_V
`define SHIFT_REGISTER_44B_RTL_V

`include "ece2300/ece2300-misc.v"

module ShiftRegister_44b_RTL
(
  (* keep=1 *) input  logic        clk,
  (* keep=1 *) input  logic        rst,
  (* keep=1 *) input  logic        en,
  (* keep=1 *) input  logic        sin,
  (* keep=1 *) output logic [43:0] pout
);

  always_ff @( posedge clk ) begin
    
    if ( rst == 1 )
      pout <= '0;
    else begin
      if ( en == 1 ) 
        pout <= { pout[42:0], sin }; 
    end
    
   `ECE2300_SEQ_XPROP(pout, $isunknown(rst));
   `ECE2300_SEQ_XPROP(pout, (rst == 0) && $isunknown(en));

  end 

endmodule

`endif /* SHIFT_REGISTER_44B_RTL_V */
