//========================================================================
// RegfileZ2r1w_32x32b_RTL-test
//========================================================================

`include "ece2300/ece2300-misc.v"
`include "ece2300/ece2300-test.v"

// ece2300-lint
`include "lab4/RegfileZ2r1w_32x32b_RTL.v"

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

  logic        wen;
  logic  [4:0] waddr;
  logic [31:0] wdata;
  logic  [4:0] raddr0;
  logic [31:0] rdata0;
  logic  [4:0] raddr1;
  logic [31:0] rdata1;

  RegfileZ2r1w_32x32b_RTL dut
  (
    .clk    (clk),
    .wen    (wen),
    .waddr  (waddr),
    .wdata  (wdata),
    .raddr0 (raddr0),
    .rdata0 (rdata0),
    .raddr1 (raddr1),
    .rdata1 (rdata1)
  );

  //----------------------------------------------------------------------
  // check
  //----------------------------------------------------------------------
  // The ECE 2300 test framework adds a 1 tau delay with respect to the
  // rising clock edge at the very beginning of the test bench. So if we
  // immediately set the inputs this will take effect 1 tau after the clock
  // edge. Then we wait 8 tau, check the outputs, and wait 2 tau which
  // means the next check will again start 1 tau after the rising clock
  // edge.

  task check
  (
    input logic        wen_,
    input logic  [4:0] waddr_,
    input logic [31:0] wdata_,
    input logic  [4:0] raddr0_,
    input logic [31:0] rdata0_,
    input logic  [4:0] raddr1_,
    input logic [31:0] rdata1_
  );
    if ( !t.failed ) begin
      t.num_checks += 1;

      wen    = wen_;
      waddr  = waddr_;
      wdata  = wdata_;
      raddr0 = raddr0_;
      raddr1 = raddr1_;

      #8;

      if ( t.n != 0 )
        $display( "%3d: %b %2d %h | %2d %2d > %h %h", t.cycles,
                  wen, waddr, wdata, raddr0, raddr1, rdata0, rdata1 );

      `ECE2300_CHECK_EQ( rdata0, rdata0_ );
      `ECE2300_CHECK_EQ( rdata1, rdata1_ );

      #2;

    end
  endtask

  //----------------------------------------------------------------------
  // test_case_1_basic
  //----------------------------------------------------------------------

  task test_case_1_basic();
    t.test_case_begin( "test_case_1_basic" );

    //    wen wa wdata  ra0 rdata0 ra1 rdata1
    check( 1, 1, 32'h0, 0,  32'h0, 0,  32'h0 );
    check( 1, 1, 32'h1, 1,  32'h0, 1,  32'h0 );
    check( 0, 1, 32'h0, 1,  32'h1, 1,  32'h1 );

    t.test_case_end();
  endtask


  //----------------------------------------------------------------------
  // test_case_2_directed
  //----------------------------------------------------------------------
  task test_case_2_directed();
    t.test_case_begin("test_case_2_directed");
    
    //    wen wa wdata           ra0 rdata0        ra1 rdata1
    check( 1, 3, 32'hAAAA_AAAA,  0, 32'h0,         0, 32'h0         );
    check( 1, 7, 32'h5555_5555,  3, 32'hAAAA_AAAA, 0, 32'h0         );
    check( 0, 0, 32'h0,          3, 32'hAAAA_AAAA, 7, 32'h5555_5555 );

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_3_directed
  //----------------------------------------------------------------------
  // Testing that Register 0 should always equal 0 
  task test_case_3_directed();
    t.test_case_begin("test_case_3_directed");

    //    wen wa wdata  ra0 rdata0 ra1 rdata1
    check( 1, 0, 32'h12, 0,  32'h0, 0, 32'h0 );
    check( 1, 1, 32'h13, 0,  32'h0, 0, 32'h0 );

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_4_random
  //----------------------------------------------------------------------

  logic        rand_wen;
  logic  [4:0] rand_waddr;
  logic [31:0] rand_wdata;
  logic  [4:0] rand_raddr0;
  logic [31:0] rand_rdata0;
  logic  [4:0] rand_raddr1;
  logic [31:0] rand_rdata1;
  logic [31:0] rand_mem [32];

  task test_case_4_random();
    t.test_case_begin("test_case_4_random");

    for ( int i = 0; i < 32; i++ ) 
      rand_mem[i] = '0;

    for ( int i = 0; i < 32; i++ ) begin
      check(1'b1, 5'(i), 32'h0000_0000,
          5'd0, 32'h0000_0000,
          5'd0, 32'h0000_0000);
      if (i != 0) rand_mem[i] = 32'h0000_0000;
    end

    for ( int i = 0; i < 200; i++ ) begin
      rand_wen    = 1'($urandom(t.seed));
      rand_waddr  = 5'($urandom(t.seed));
      rand_wdata  = 32'($urandom(t.seed));
      rand_raddr0 = 5'($urandom(t.seed));
      rand_raddr1 = 5'($urandom(t.seed));

    rand_rdata0 = (rand_raddr0 == 5'd0) ? 32'h0000_0000 : rand_mem[rand_raddr0];
    rand_rdata1 = (rand_raddr1 == 5'd0) ? 32'h0000_0000 : rand_mem[rand_raddr1];

    check( rand_wen, rand_waddr, rand_wdata, rand_raddr0, rand_rdata0, rand_raddr1, 
      rand_rdata1 );

    if ( rand_wen && (rand_waddr != 5'd0) )
      rand_mem[rand_waddr] = rand_wdata;
  end

  t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_4_xprop
  //----------------------------------------------------------------------

  task test_case_4_xprop();
    t.test_case_begin( "test_case_4_xprop" );
    
    check( 'x, 'x, 'x, 'x,  'x, 'x, 'x ); 

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
    if ((t.n <= 0) || (t.n == 5)) test_case_4_xprop();

    t.test_bench_end();
  end

endmodule

