//========================================================================
// Multiplier_32x32b_RTL-test
//========================================================================

`include "ece2300/ece2300-test.v"

// ece2300-lint
`include "lab4/Multiplier_32x32b_RTL.v"

module Top();

  //----------------------------------------------------------------------
  // Setup
  //----------------------------------------------------------------------

  CombinationalTestUtils t();

  //----------------------------------------------------------------------
  // Instantiate design under test
  //----------------------------------------------------------------------

  logic [31:0] in0;
  logic [31:0] in1;
  logic [31:0] prod;

  Multiplier_32x32b_RTL dut
  (
    .in0  (in0),
    .in1  (in1),
    .prod (prod)
  );

  //----------------------------------------------------------------------
  // check
  //----------------------------------------------------------------------
  // We set the inputs, wait 8 tau, check the outputs, wait 2 tau. Each
  // check will take a total of 10 tau.

  task check
  (
    input logic [31:0] in0_,
    input logic [31:0] in1_,
    input logic [31:0] prod_
  );
    if ( !t.failed ) begin
      t.num_checks += 1;

      in0 = in0_;
      in1 = in1_;

      #8;

      if ( t.n != 0 ) begin
        $display( "%3d: %h * %h (%10d * %10d) > %h (%10d)", t.cycles,
                  in0, in1, in0, in1, prod, prod );
      end

      `ECE2300_CHECK_EQ( prod, prod_ );

      #2;

    end
  endtask

  //----------------------------------------------------------------------
  // test_case_1_basic
  //----------------------------------------------------------------------

  task test_case_1_basic();
    t.test_case_begin( "test_case_1_basic" );

    //     in0    in1    prod
    check( 32'd0, 32'd0, 32'd0 ); // 0 * 0 = 0
    check( 32'd1, 32'd0, 32'd0 ); // 1 * 0 = 0
    check( 32'd1, 32'd1, 32'd1 ); // 1 * 1 = 1
    check( 32'd1, 32'd2, 32'd2 ); // 1 * 2 = 2
    check( 32'd1, 32'd3, 32'd3 ); // 1 * 3 = 3

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // directed testing
  //----------------------------------------------------------------------
  task test_case_2_directed();
    t.test_case_begin( "test_case_2_directed" );

    //     in0    in1    prod
    check(32'd0,          32'd0,          32'd0);
    check(32'd0,          32'd123456,     32'd0);
    check(32'd1,          32'd98765,      32'd98765);
    check(32'd3,          32'd7,          32'd21);
    check(32'd15,         32'd15,         32'd225);
    check(32'd255,        32'd255,        32'd65025);
    check(32'hFFFF,       32'hFFFF,       32'hFFFE0001);
    check(32'h8000_0000,  32'd2,          32'h0000_0000); //overflow
    check(32'd12345,      32'd6789,       32'd83810205); // mid range

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // random testing 
  //----------------------------------------------------------------------
  logic[31:0] in0_rand;  
  logic[31:0] in1_rand; 
  logic[31:0] prod_random; 

   task test_case_random();
    t.test_case_begin( "test_case_random" );

    for (int i = 0; i <= 100; i++ ) begin

      in0_rand = 32'($urandom(t.seed));
      in1_rand = 32'($urandom(t.seed));

      prod_random = in0_rand * in1_rand; 

      check( in0_rand, in1_rand, prod_random ); 

    end 

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // xprop testing 
  //----------------------------------------------------------------------
  task test_case_xprop();
    t.test_case_begin( "test_case_xprop" );

    //     in0    in1    prod
    check( 'x, 'x, 'x );

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // main
  //----------------------------------------------------------------------

  initial begin
    t.test_bench_begin();

    if ((t.n <= 0) || (t.n == 1)) test_case_1_basic();
    if ((t.n <= 0) || (t.n == 2)) test_case_2_directed();
    if ((t.n <= 0) || (t.n == 3)) test_case_random();
    if ((t.n <= 0) || (t.n == 4)) test_case_xprop();

    t.test_bench_end();
  end

endmodule

