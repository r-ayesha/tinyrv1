//========================================================================
// Adder_32b_GL-test
//========================================================================

`include "ece2300/ece2300-test.v"

// ece2300-lint
`include "lab4/Adder_32b_GL.v"

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
  logic [31:0] sum;

  Adder_32b_GL dut
  (
    .in0 (in0),
    .in1 (in1),
    .sum (sum)
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
    input logic [31:0] sum_
  );
    if ( !t.failed ) begin
      t.num_checks += 1;

      in0 = in0_;
      in1 = in1_;

      #8;

      if ( t.n != 0 )
        $display( "%3d: %h + %h (%10d + %10d) > %h (%10d)", t.cycles,
                  in0, in1, in0, in1, sum, sum );

      `ECE2300_CHECK_EQ( sum, sum_ );

      #2;

    end
  endtask

  //----------------------------------------------------------------------
  // test_case_1_basic
  //----------------------------------------------------------------------

  task test_case_1_basic();
    t.test_case_begin( "test_case_1_basic" );

    //     in0    in1    sum
    check( 32'd0, 32'd0, 32'd0 );
    check( 32'd0, 32'd1, 32'd1 );
    check( 32'd1, 32'd0, 32'd1 );
    check( 32'd1, 32'd1, 32'd2 );

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_2_directed
  //----------------------------------------------------------------------

  task test_case_2_directed();
    t.test_case_begin("test_case_2_directed");

    check( 32'b0000_0000_0000_0000_0000_0000_0000_0000,
          32'b0000_0000_0000_0000_0000_0000_0000_0001,
          32'b0000_0000_0000_0000_0000_0000_0000_0001 );

    check( 32'b0000_0000_0000_0000_1111_1111_1111_1111,
          32'b0000_0000_0000_0000_0000_0000_0000_0001,
          32'b0000_0000_0000_0001_0000_0000_0000_0000 );

    check( 32'b1111_1111_1111_1111_0000_0000_0000_0000,
          32'b0000_0000_0000_0000_1111_1111_1111_1111,
          32'b1111_1111_1111_1111_1111_1111_1111_1111 );

    check( 32'b1111_1111_1111_1111_1111_1111_1111_1111,
          32'b0000_0000_0000_0000_0000_0000_0000_0001,
          32'b0000_0000_0000_0000_0000_0000_0000_0000 );

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_3_random
  //----------------------------------------------------------------------

  logic [31:0] rand_in0;
  logic [31:0] rand_in1;
  logic        rand_cout;
  logic [31:0] rand_sum;
  logic [32:0] rand_result;

  task test_case_3_random();
    t.test_case_begin("test_case_3_random");

    for (int i = 0; i < 100; i = i + 1) begin
      rand_in0 = 32'( $urandom(t.seed) );
      rand_in1 = 32'( $urandom(t.seed) );

      rand_result = {1'b0, rand_in0} + {1'b0, rand_in1};

      rand_cout = rand_result[32];      // carry-out bit when adding both
      rand_sum  = rand_result[31:0];

      check( rand_in0, rand_in1, rand_sum );
    end

    t.test_case_end();
  endtask

  `ECE2300_UNUSED( rand_cout );


  //----------------------------------------------------------------------
  // test_case_4_xprop
  //----------------------------------------------------------------------

  task test_case_4_xprop();
    t.test_case_begin("test_case_4_xprop");

    check( 32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx,
          32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx,
          32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx );

    check( 32'b0000_0000_0000_0000_0000_0000_0111_1011,
          32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx,
          32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx );

    check( 32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx,
          32'b0000_0000_0000_0000_0000_0000_0111_1011,
          32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx );

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // main
  //----------------------------------------------------------------------

  initial begin
    t.test_bench_begin();

    if ((t.n <= 0) || (t.n == 1)) test_case_1_basic();
    if ((t.n <= 0) || (t.n == 2)) test_case_2_directed();
    if ((t.n <= 0) || (t.n == 3)) test_case_3_random();
    if ((t.n <= 0) || (t.n == 4)) test_case_4_xprop();

    t.test_bench_end();
  end

endmodule

