//========================================================================
// Synchronizer_RTL-test
//========================================================================

`include "ece2300/ece2300-test.v"

// ece2300-lint
`include "lab4/Synchronizer_RTL.v"

module Top();

  //----------------------------------------------------------------------
  // Setup
  //----------------------------------------------------------------------

  logic clk;
  logic rst;

  TestUtilsClkRst t
  (
    .clk (clk),
    .rst (rst)
  );

  `ECE2300_UNUSED( rst );

  //----------------------------------------------------------------------
  // Instantiate design under test
  //----------------------------------------------------------------------

  logic d;
  logic q;

  Synchronizer_RTL dut
  (
    .clk (clk),
    .d   (d),
    .q   (q)
  );

  //----------------------------------------------------------------------
  // check
  //----------------------------------------------------------------------
  // The ECE 2300 test framework adds a 1 tau delay with respect to the
  // rising clock edge at the very beginning of the test bench. So if we
  // immediately set the inputs this will take effect 1 tau after the
  // clock edge. Then we wait 8 tau, check the outputs, and wait 2 tau
  // which means the next check will again start 1 tau after the rising
  // clock edge.

  task check
  (
    input logic d_,
    input logic q_,
    input logic outputs_undefined = 0
  );
    if ( !t.failed ) begin
      t.num_checks += 1;

      d = d_;

      #8;

      if ( t.n != 0 )
        $display( "%3d: %b > > %b", t.cycles, d, q );

      if ( !outputs_undefined )
        `ECE2300_CHECK_EQ( q, q_ );

      #2;

    end
  endtask

  //----------------------------------------------------------------------
  // test_case_1_basic
  //----------------------------------------------------------------------

  task test_case_1_basic();
    t.test_case_begin( "test_case_1_basic" );

    //     d  q
    check( 0, 'x, t.outputs_undefined );
    check( 0, 'x, t.outputs_undefined );
    check( 0, 0 );
    check( 0, 0 );

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_directed
  //----------------------------------------------------------------------

    task test_case_2_directed();
    t.test_case_begin("test_case_2_directed");

    //     d   q
    check( 1, 'x, t.outputs_undefined );
    check( 1, 'x, t.outputs_undefined );
    check( 1, 1 );
    check( 1, 1 );
    check( 0, 'x, t.outputs_undefined );
    check( 0, 'x, t.outputs_undefined );
    check( 0, 0 );
    check( 0, 0 );

    t.test_case_end();
  endtask

  task test_case_3_directed();
    t.test_case_begin("test_case_3_directed");

    //     d   q
    check( 0, 'x, t.outputs_undefined );
    check( 0, 'x, t.outputs_undefined );
    check( 1, 'x, t.outputs_undefined );
    check( 1, 'x, t.outputs_undefined );
    check( 1, 1 );
    check( 1, 1 );
    check( 0, 1 );
    check( 0, 1 );

    t.test_case_end();
  endtask

  task test_case_4_directed();
    t.test_case_begin("test_case_4_directed");

    //     d   q
    check( 1, 'x, t.outputs_undefined );
    check( 1, 'x, t.outputs_undefined );
    check( 0, 1 );
    check( 1, 1 );
    check( 0, 0 );
    check( 1, 1 );
    check( 0, 0 );
    check( 1, 1 );

    t.test_case_end();
  endtask

  task test_case_5_directed();
    t.test_case_begin("test_case_5_directed");

    //     d   q
    check( 1, 'x, t.outputs_undefined );
    check( 0, 'x, t.outputs_undefined );
    check( 1, 'x, t.outputs_undefined );
    check( 0, 'x, t.outputs_undefined );
    check( 0, 'x, t.outputs_undefined );
    check( 0, 0 );
    check( 0, 0 );

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_random
  //----------------------------------------------------------------------
  logic prev1, prev2;
  logic d_rand, q_exp;

  task test_case_random();
  t.test_case_begin("test_case_random");

  prev1 = 'x;
  prev2 = 'x;

  for (int i = 0; i < 24; i++) begin
    d_rand = 1'($urandom(t.seed)); 

    if (i < 2) begin
      q_exp = 'x;
      check( d_rand, q_exp, t.outputs_undefined );
    end
    else begin
      q_exp = prev2;
      check( d_rand, q_exp );
    end

    prev2 = prev1;
    prev1 = d_rand;
  end

  t.test_case_end();
endtask

  //----------------------------------------------------------------------
  // test_case_xprop
  //----------------------------------------------------------------------

  task test_case_xprop();
  t.test_case_begin("test_case_xprop");

  check( 'x, 'x, t.outputs_undefined );
  check( 'x, 'x, t.outputs_undefined );

  check( 0, 'x, t.outputs_undefined );
  check( 0, 'x, t.outputs_undefined);

  check( 1, 0 );
  check( 1, 0 );

  check( 'x, 1 );
  check( 'x, 'x, t.outputs_undefined );

  check( 0, 'x, t.outputs_undefined );
  check( 0, 'x, t.outputs_undefined );

  check( 1, 0 );
  check( 1, 0 );

  t.test_case_end();
endtask

  //----------------------------------------------------------------------
  // main
  //----------------------------------------------------------------------

  initial begin
    t.test_bench_begin();

    if ((t.n <= 0) || (t.n == 1)) test_case_1_basic();
    if ((t.n <= 0) || (t.n == 2)) test_case_2_directed();
    if ((t.n <= 0) || (t.n == 3)) test_case_3_directed();
    if ((t.n <= 0) || (t.n == 4)) test_case_4_directed();
    if ((t.n <= 0) || (t.n == 4)) test_case_5_directed();
    if ((t.n <= 0) || (t.n == 6)) test_case_random();
    if ((t.n <= 0) || (t.n == 7)) test_case_xprop();
    t.test_bench_end();
  end

endmodule
