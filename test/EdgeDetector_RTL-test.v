//========================================================================
// EdgeDetector_RTL-test
//========================================================================

`include "ece2300/ece2300-misc.v"
`include "ece2300/ece2300-test.v"

// ece2300-lint
`include "lab4/EdgeDetector_RTL.v"

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
  logic pos_edge;

  EdgeDetector_RTL dut
  (
    .clk      (clk),
    .d        (d),
    .pos_edge (pos_edge)
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
    input logic pos_edge_,
    input logic outputs_undefined = 0
  );
    if ( !t.failed ) begin
      t.num_checks += 1;

      d = d_;

      #8;

      if ( t.n != 0 )
        $display( "%3d: %b %b | %b", t.cycles, rst, d, pos_edge );

      if ( !outputs_undefined )
        `ECE2300_CHECK_EQ( pos_edge, pos_edge_ );

      #2;

    end
  endtask

  //----------------------------------------------------------------------
  // test_case_1_basic
  //----------------------------------------------------------------------

  task test_case_1_basic();
    t.test_case_begin( "test_case_1_basic" );

    //     d  pos_edge
    check( 0, 'x, t.outputs_undefined );
    check( 0, 0 );
    check( 0, 0 );

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_directed
  //----------------------------------------------------------------------

  task test_case_2_directed();
    t.test_case_begin( "test_case_2_directed" );
    
    //     d  pos_edge
    check( 1, 'x, t.outputs_undefined );
    check( 1, 0 ); 
    check( 1, 0 );
    check( 1, 0 );
    check( 1, 0 ); // checks constant 1 

    check( 0, 0 );
    check( 0, 0 ); 
    check( 0, 0 );
    check( 0, 0 ); // constant 0 

    check( 1, 1 ); //alternating 1 & 0 for d 
    check( 0, 0 );
    check( 1, 1 ); 
    check( 0, 0 );

    check( 0, 0 ); // extra long 0's but no 1's
    check( 0, 0 );
    check( 1, 1 );
    check( 1, 0 );
    check( 1, 0 );

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_random
  //----------------------------------------------------------------------
  logic prev_d_rand;
  logic pos_edge_rand;
  logic d_rand;

  task test_case_random();
    t.test_case_begin("test_case_random");

    prev_d_rand = 1'b0;

    // first cycle per specs
    d_rand        = 1'b0;
    pos_edge_rand = 'x;
    check( d_rand, pos_edge_rand, t.outputs_undefined );

    for (int i = 1; i < 50; i++) begin
      d_rand        = 1'($urandom(t.seed));
      pos_edge_rand = (~prev_d_rand & d_rand);
      check( d_rand, pos_edge_rand );
      prev_d_rand   = d_rand;
    end

    t.test_case_end();
  endtask
  
  //----------------------------------------------------------------------
  // test_case_xprop
  //----------------------------------------------------------------------

   task test_case_xprop();
    t.test_case_begin( "test_case_xprop" );

    //     d  pos_edge
    check( 'x, 'x, t.outputs_undefined );
    check( 'x, 'x, t.outputs_undefined );
    check( 0, 0 );
    check( 'x, 'x, t.outputs_undefined );
    check( 1, 'x );
    check( 'x, 'x, t.outputs_undefined );
    check( 1, 'x );
    check( 'x, 'x, t.outputs_undefined );
    check( 0, 0 );
    check( 'x, 'x, t.outputs_undefined );

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
