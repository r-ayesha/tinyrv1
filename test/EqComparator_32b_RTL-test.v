//========================================================================
// EqComparator_32b_RTL-test
//========================================================================

`include "ece2300/ece2300-test.v"

// ece2300-lint
`include "lab4/EqComparator_32b_RTL.v"

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
  logic        eq;

  EqComparator_32b_RTL dut
  (
    .in0 (in0),
    .in1 (in1),
    .eq  (eq)
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
    input logic        eq_
  );
    if ( !t.failed ) begin
      t.num_checks += 1;

      in0 = in0_;
      in1 = in1_;

      #8;

      if ( t.n != 0 )
        $display( "%3d: %h == %h (%10d == %10d) > %b", t.cycles,
                  in0, in1, in0, in1, eq );

      `ECE2300_CHECK_EQ( eq, eq_ );

      #2;

    end
  endtask

  //----------------------------------------------------------------------
  // test_case_1_basic
  //----------------------------------------------------------------------

  task test_case_1_basic();
    t.test_case_begin( "test_case_1_basic" );

    //     in0    in1    eq
    check( 32'd0, 32'd0, 1 );
    check( 32'd0, 32'd1, 0 );
    check( 32'd1, 32'd0, 0 );
    check( 32'd1, 32'd1, 1 );

    t.test_case_end();
  endtask

   //----------------------------------------------------------------------
  // test_case_2_directed
  //----------------------------------------------------------------------

  task test_case_2_directed();
    t.test_case_begin( "test_case_2_directed" );
    // testing large and edge cases 

    //     in0       in1        eq
    check( 32'b0000_0000_0000_0000_0000_0000_0000_0000,
          32'b1111_1111_1111_1111_1111_1111_1111_1111, 0 );

    check( 32'b1111_1111_1111_1111_1111_1111_1111_1111,
         32'b1111_1111_1111_1111_1111_1111_1111_1111, 1 );

    check( 32'b1010_1010_1010_1010_1010_1010_1010_1010,
         32'b1010_1010_1010_1010_1010_1010_1010_1010, 1 );

    check( 32'b1010_1010_1010_1010_1010_1010_1010_1010,
         32'b0101_0101_0101_0101_0101_0101_0101_0101, 0 );

    check( 32'b1000_0000_0000_0000_0000_0000_0000_0000,
         32'b1000_0000_0000_0000_0000_0000_0000_0000, 1 );

    check( 32'b1111_1111_1111_1111_1111_1111_1111_1111,
         32'b1111_1111_1111_1111_1111_1111_1111_1110, 0 );

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_random
  //----------------------------------------------------------------------
 
  logic [31:0] rand_in0;
  logic [31:0] rand_in1;
  logic        rand_eq;

  task test_case_random();
    t.test_case_begin("test_case_random");

    for ( int i = 0; i < 100; i++ ) begin

      rand_in0 = 32'($urandom(t.seed));
      rand_in1 = 32'($urandom(t.seed));

      rand_eq = (rand_in0 == rand_in1) ? 1'b1 : 1'b0;

      check( rand_in0, rand_in1, rand_eq );
    end

    t.test_case_end();
  endtask

  //------------------------------------------------------------------------
  // test_case_xprop
  //------------------------------------------------------------------------
 
  task test_case_xprop();
    t.test_case_begin( "test_case_xprop" );

    //     in0    in1     eq
    check( 'x,    'x,    'x );
    check( 'x,     0,    'x );
    check( 'x,     1,    'x );
    check(  0,    'x,    'x );
    check(  1,    'x,    'x );
    check(  0,     0,     1 );

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // main
  //----------------------------------------------------------------------

  initial begin
    t.test_bench_begin();

    if ((t.n <= 0) || (t.n == 1)) test_case_1_basic();
    if ((t.n <= 0) || (t.n == 2)) test_case_2_directed();
    if ((t.n <= 0) || (t.n == 3)) test_case_xprop();
    if ((t.n <= 0) || (t.n == 4)) test_case_random();

    t.test_bench_end();
  end

endmodule

