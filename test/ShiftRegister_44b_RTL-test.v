//========================================================================
// ShiftRegister_RTL-test
//========================================================================

`include "ece2300/ece2300-test.v"

// ece2300-lint
`include "lab4/ShiftRegister_44b_RTL.v"

module Top();

  //----------------------------------------------------------------------
  // Setup
  //----------------------------------------------------------------------

  logic clk;
  logic rst_utils;

  TestUtilsClkRst t
  (
    .clk (clk),
    .rst (rst_utils)
  );

  //----------------------------------------------------------------------
  // Instantiate design under test
  //----------------------------------------------------------------------

  logic        rst;
  logic        en;
  logic        sin;
  logic [43:0] pout;

  ShiftRegister_44b_RTL dut
  (
    .clk  (clk),
    .rst  (rst | rst_utils),
    .en   (en),
    .sin  (sin),
    .pout (pout)
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
    input logic        rst_,
    input logic        en_,
    input logic        sin_,
    input logic [43:0] pout_
  );
    if ( !t.failed ) begin
      t.num_checks += 1;

      rst = rst_;
      en  = en_;
      sin = sin_;

      #8;

      if ( t.n != 0 ) begin
        if ( en )
          $display( "%3d: %b < %b", t.cycles, pout, sin );
        else
          $display( "%3d: %b", t.cycles, pout );
      end

      `ECE2300_CHECK_EQ( pout, pout_ );

      #2;

    end
  endtask

  //----------------------------------------------------------------------
  // test_case_1_basic
  //----------------------------------------------------------------------

  task test_case_1_basic();
    t.test_case_begin( "test_case_1_basic" );

    //     rst en sin pout
    check( 0,  0, 0,  44'b0000_0000 );
    check( 0,  1, 1,  44'b0000_0000 );
    check( 0,  0, 1,  44'b0000_0001 );
    check( 0,  1, 0,  44'b0000_0001 );
    check( 0,  1, 1,  44'b0000_0010 );
    check( 0,  1, 0,  44'b0000_0101 );
    check( 0,  1, 0,  44'b0000_1010 );
    check( 0,  1, 1,  44'b0001_0100 );
    check( 0,  1, 1,  44'b0010_1001 );
    check( 0,  0, 0,  44'b0101_0011 );

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_2_directed
  //----------------------------------------------------------------------
  
  task test_case_2_directed();
    t.test_case_begin("test_case_2_directed");

    //     rst en sin pout
    check( 1,  0, 0,  44'b0000_0000 ); // reset

    check( 0,  0, 0,  44'b0000_0000 ); // hold

    check( 0,  1, 1,  44'b0000_0000 );
    check( 0,  1, 1,  44'b0000_0001 );
    check( 0,  1, 0,  44'b0000_0011 );
    check( 0,  1, 1,  44'b0000_0110 );
    check( 0,  1, 0,  44'b0000_1101 );
    check( 0,  1, 0,  44'b0001_1010 );
    check( 0,  1, 1,  44'b0011_0100 );
    check( 0,  1, 1,  44'b0110_1001 );

    check( 0,  0, 0,  44'b1101_0011 ); // en = 0
    check( 0,  0, 0,  44'b1101_0011 );
    check( 0,  0, 0,  44'b1101_0011 );
    check( 0,  0, 0,  44'b1101_0011 );

    check( 0,  1, 1,  44'b1101_0011 );
    check( 0,  1, 1,  44'b11010_0111 );
  
  
    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_3_directed
  //----------------------------------------------------------------------
 
  // testing reset and enable behavior 
  task test_case_3_directed();
    t.test_case_begin("test_case_3_directed");

    //     rst en sin pout
    check( 0,  0, 0,  44'b0000_0000 );
    check( 0,  1, 1,  44'b0000_0000 );
    check( 0,  0, 1,  44'b0000_0001 );
    check( 0,  1, 0,  44'b0000_0001 );
    check( 0,  1, 1,  44'b0000_0010 );

    check( 1,  1, 0,  44'b0000_0101 ); // rst = 1, next cycle all 0

    check( 0,  1, 0,  44'b0000_0000 );
    check( 0,  1, 1,  44'b0000_0000 );
    check( 0,  1, 1,  44'b0000_0001 );

    check( 1,  0, 0,  44'b0000_0011 );

    check( 0,  1, 1,  44'b0000_0000 );

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_4_random
  //----------------------------------------------------------------------
 
  logic        rand_rst;
  logic        rand_en;
  logic        rand_sin;
  logic [43:0] rand_pout;
  logic [43:0] rand_exp;

  task test_case_4_random();
    t.test_case_begin( "test_case_4_random" );

    rand_pout = '0;
 
    for (int i = 0; i < 100; i++) begin
      rand_rst = 1'($urandom(t.seed));
      rand_en  = 1'($urandom(t.seed));
      rand_sin = 1'($urandom(t.seed));
      
      rand_exp = rand_pout;

      if (rand_rst)
       rand_exp = '0;
      else if (rand_en) 
       rand_exp = {rand_pout[42:0], rand_sin};

      check( rand_rst, rand_en, rand_sin, rand_pout );

      rand_pout = rand_exp;
    end

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_5_xprop
  //----------------------------------------------------------------------
 
  task test_case_5_xprop();
    t.test_case_begin("test_case_5_xprop");

    //     rst en sin pout
    check( 'x,  'x, 'x,  '0 );
    check( 'x,   0,  0,  'x );
    check(  0,  'x,  0,  'x );

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
    if ((t.n <= 0) || (t.n == 4)) test_case_4_random();
    if ((t.n <= 0) || (t.n == 5)) test_case_5_xprop();

    t.test_bench_end();
  end

endmodule
