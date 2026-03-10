//========================================================================
// ALU_32b-test
//========================================================================

`include "ece2300/ece2300-test.v"

// ece2300-lint
`include "lab4/ALU_32b.v"

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
  logic        op;
  logic [31:0] out;

  ALU_32b dut
  (
    .in0 (in0),
    .in1 (in1),
    .op  (op),
    .out (out)
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
    input logic        op_,
    input logic [31:0] out_
  );
    if ( !t.failed ) begin
      t.num_checks += 1;

      in0 = in0_;
      in1 = in1_;
      op  = op_;

      #8;

      if ( t.n != 0 ) begin
        if ( op == 0 )
          $display( "%3d: %h +  %h (%10d +  %10d) > %h (%10d)", t.cycles,
                    in0, in1, in0, in1, out, out );
        else
          $display( "%3d: %h == %h (%10d == %10d) > %h (%10d)", t.cycles,
                    in0, in1, in0, in1, out, out );
      end

      `ECE2300_CHECK_EQ( out, out_ );

      #2;

    end
  endtask

  //----------------------------------------------------------------------
  // test_case_1_basic
  //----------------------------------------------------------------------

  task test_case_1_basic();
    t.test_case_begin( "test_case_1_basic" );

    //     in0    in1    op out
    check( 32'd0, 32'd0, 0, 32'd0 );
    check( 32'd0, 32'd1, 0, 32'd1 );
    check( 32'd1, 32'd0, 0, 32'd1 );
    check( 32'd1, 32'd1, 0, 32'd2 );

    check( 32'd0, 32'd0, 1, 32'd1 );
    check( 32'd0, 32'd1, 1, 32'd0 );
    check( 32'd1, 32'd0, 1, 32'd0 );
    check( 32'd1, 32'd1, 1, 32'd1 );

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_2_directed
  //----------------------------------------------------------------------

  task test_case_2_directed();
    t.test_case_begin("test_case_2_directed");

    // edge cases and typical cases for add and eq
    // adding with 0
    check(32'b00000000000000000000000000000000, 32'b00000000000000000111100010010000, 
          0, 32'b00000000000000000111100010010000);
    check(32'b00000000000000001111001100100110, 32'b00000000000000000000000000000000, 
          0, 32'b00000000000000001111001100100110);

    // adding max 32 bit values
    check(32'b11111111111111111111111111111111, 32'b00000000000000000000000000000001, 
          0, 32'b00000000000000000000000000000000);
    check(32'b01111111111111111111111111111111, 32'b00000000000000000000000000000001, 
          0, 32'b10000000000000000000000000000000);

    check(32'b11111111111111111111111111111111, 32'b11111111111111111111111111111111, 
          1, 32'b00000000000000000000000000000001);
    check(32'b11111111111111111111111111111111, 32'b00000000000000000000000000000000, 
          1, 32'b00000000000000000000000000000000);

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_3_random
  //----------------------------------------------------------------------

  logic [31:0] rand_in0;
  logic [31:0] rand_in1;
  logic        rand_op;
  logic [31:0] expected_out;
  
  task test_case_3_random();
    t.test_case_begin("test_case_3_random");

    for ( int i = 0; i < 100; i++ ) begin
      rand_in0 = $urandom(t.seed);
      rand_in1 = $urandom(t.seed);
      rand_op  = 1'( $urandom(t.seed) );

      if ( rand_op == 0 )
        expected_out = rand_in0 + rand_in1;
      else
        expected_out = (rand_in0 == rand_in1) ? 
              32'b00000000000000000000000000000001 : 32'b00000000000000000000000000000000;

      check( rand_in0, rand_in1, rand_op, expected_out );
    end

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_4_xprop
  //----------------------------------------------------------------------

  task test_case_4_xprop();
    t.test_case_begin("test_case_4_xprop");

    check(32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx, 32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx, 
          1'bx, 32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx);
    check(32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx, 32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx, 
          1'b0, 32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx);

    check(32'b00000000000000000000000000000000, 32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx, 1'b0, 
          32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx);
    check(32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx, 32'b00000000000000000000000000000000, 1'b0, 
          32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx);

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

