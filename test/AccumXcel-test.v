//========================================================================
// AccumXcel-test.v
//========================================================================

`include "ece2300/ece2300-test.v"

// ece2300-lint
`include "lab4/AccumXcel.v"
`include "lab4/test/TestMemory.v"

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

  //----------------------------------------------------------------------
  // Instantiate design under test
  //----------------------------------------------------------------------

  logic        mem_val;
  logic [31:0] mem_addr;
  logic [31:0] mem_rdata;

  logic        in_val;
  logic        in_rdy;
  logic  [6:0] in_size;

  logic [31:0] result;

  AccumXcel dut
  (
    .*
  );

  logic        mem0_wait;
  logic [31:0] mem0_rdata;
  logic        mem1_wait;

  TestMemory mem
  (
    .clk        (clk),
    .rst        (rst),

    .mem0_val   ('0),
    .mem0_wait  (mem0_wait),
    .mem0_type  ('x),
    .mem0_addr  ('x),
    .mem0_wdata ('x),
    .mem0_rdata (mem0_rdata),

    .mem1_val   (mem_val),
    .mem1_wait  (mem1_wait),
    .mem1_type  (1'b0),
    .mem1_addr  (mem_addr),
    .mem1_wdata ('x),
    .mem1_rdata (mem_rdata)
  );

  `ECE2300_UNUSED( mem0_wait );
  `ECE2300_UNUSED( mem0_rdata );
  `ECE2300_UNUSED( mem1_wait );

  //----------------------------------------------------------------------
  // check
  //----------------------------------------------------------------------
  // The ECE 2300 test framework adds a 1 tau delay with respect to the
  // rising clock edge at the very beginning of the test bench. So if we
  // immediately set the inputs this will take effect 1 tau after the clock
  // edge. Then we wait 8 tau, check the outputs, and wait 2 tau which
  // means the next check will again start 1 tau after the rising clock
  // edge.

  localparam IGNORE_OUTPUTS = 1;

  task check
  (
    input logic        in_val_,
    input logic        in_rdy_,
    input logic  [6:0] in_size_,
    input logic [31:0] result_,
    input logic        ignore_outputs = 0
  );
    if ( !t.failed ) begin
      t.num_checks += 1;

      in_val  = in_val_;
      in_size = in_size_;

      #8

      if ( t.n != 0 ) begin

        $write( "%3d: ", t.cycles );

        if      (  in_val &&  in_rdy ) $write( "%d", in_size );
        else if (  in_val && !in_rdy ) $write( "  #" );
        else if ( !in_val &&  in_rdy ) $write( "   " );
        else if ( !in_val && !in_rdy ) $write( "  ." );

        $write( " (" );

        $write( ") " );

        if ( in_rdy )
          $write( "%x", result );
        else
          $write( "        " );

        $write( " | " );

        if ( mem_val )
          $write( "rd:%x:%x", mem_addr, mem_rdata );

        $write( "\n" );

      end

      if ( !ignore_outputs ) begin
        `ECE2300_CHECK_EQ( in_rdy, in_rdy_ );
        `ECE2300_CHECK_EQ( result, result_ );
      end

      #2;

    end
  endtask

  //----------------------------------------------------------------------
  // data
  //----------------------------------------------------------------------

  logic [31:0] data_addr_unused;

  task data
  (
    input logic [31:0] addr,
    input logic [31:0] data_
  );
    mem.write( addr, data_ );
    data_addr_unused = addr;
  endtask

  //----------------------------------------------------------------------
  // test_case_1_basic
  //----------------------------------------------------------------------
  task test_case_1_basic();
    t.test_case_begin( "test_case_1_basic" );

    // Load test data into test memory (remember, accelerator always
    // starts accumulating from address 0x000!)

    data( 'h000, 1 );
    data( 'h004, 2 );
    data( 'h008, 3 );
    data( 'h00c, 4 );

    // Send message to accumulate 4 elements

    //     ---- in ----
    //     val rdy size result
    check( 1,  1,  4,   0 );

    // Simulate for 20 cycles

    for ( int i = 0; i < 20; i = i+1 )
      check( 0, 0, 0, 0, IGNORE_OUTPUTS );

    // Check result is correct

    //     ---- in ----
    //     val rdy size result
    check( 0,  1,  0,   10 );

    t.test_case_end();
  endtask
  
  //----------------------------------------------------------------------
  // test_case_directed_1
  //----------------------------------------------------------------------
  // test case of 1 memory element 
  task test_case_directed_1();
    t.test_case_begin( "test_case_directed_1" );

    // Load one element
    data( 'h000, 7 );

    // Send message to accumulate 1 element

    //     ---- in ----
    //     val rdy size result
    check( 1,  1,  1,   0 );

    // Simulate for 10 cycles

    for ( int i = 0; i < 10; i = i+1 )
      check( 0, 0, 0, 0, IGNORE_OUTPUTS );

    // Expected result = 7

    //     ---- in ----
    //     val rdy size result
    check( 0,  1,  0,   7 );

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_directed_2
  //----------------------------------------------------------------------
  // test case with no memory elements 
  task test_case_directed_2();
    t.test_case_begin( "test_case_directed_2" );

    // Send message with size = 0

    //     ---- in ----
    //     val rdy size result
    check( 1,  1,  0,   0 );

    // Simulate for 5 cycles

    for ( int i = 0; i < 5; i = i+1 )
      check( 0, 0, 0, 0, IGNORE_OUTPUTS );

    // Result should remain zero

    //     ---- in ----
    //     val rdy size result
    check( 0,  1,  0,   0 );

    t.test_case_end();
    endtask

  // random mixed values 

  //----------------------------------------------------------------------
  // test_case_directed_3
  //----------------------------------------------------------------------
  task test_case_directed_3();
    t.test_case_begin( "test_case_directed_3" );

    // Load mixed test data
    data( 'h000, 5  );
    data( 'h004, 10 );
    data( 'h008, 20 );
    data( 'h00c, 1  );

    // Send message to accumulate 4 elements

    //     ---- in ----
    //     val rdy size result
    check( 1,  1,  4,   0 );

    // Simulate for 20 cycles

    for ( int i = 0; i < 20; i = i+1 )
      check( 0, 0, 0, 0, IGNORE_OUTPUTS );

    // Expected result = 36

    //     ---- in ----
    //     val rdy size result
    check( 0,  1,  0,   36 );

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_directed_4
  //----------------------------------------------------------------------
  task test_case_directed_4();
    t.test_case_begin( "test_case_directed_4" );

    // Load test array
    data( 'h000, 1 );
    data( 'h004, 2 );
    data( 'h008, 3 );
    data( 'h00c, 4 );

    // First request (should be accepted)

    //     ---- in ----
    //     val rdy size result
    check( 1,  1,  4,   0 );

    // Accelerator is now busy
    // Try to send a second request; should NOT be accepted

    //     ---- in ----
    //     val rdy size result
    check( 1,  0,  2,   0 );

    // Simulate for 20 cycles

    for ( int i = 0; i < 20; i = i+1 )
      check( 0, 0, 0, 0, IGNORE_OUTPUTS );

    // Expected result = 10

    //     ---- in ----
    //     val rdy size result
    check( 0,  1,  0,   10 );

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_directed_5
  //----------------------------------------------------------------------
  // back-to-back accepting
  task test_case_directed_5();
    t.test_case_begin( "test_case_directed_5" );

    // First array
    data( 'h000, 1 );
    data( 'h004, 1 );
    data( 'h008, 1 );
    data( 'h00c, 1 );

    // First request

    //     ---- in ----
    //     val rdy size result
    check( 1,  1,  4,   0 );

    // Simulate 20 cycles
    for ( int i = 0; i < 20; i = i+1 )
      check( 0, 0, 0, 0, IGNORE_OUTPUTS );

    // Expected result = 4

    //     ---- in ----
    //     val rdy size result
    check( 0,  1,  0,   4 );

    // Second array
    data( 'h000, 2 );
    data( 'h004, 2 );

    // Second request

    //     ---- in ----
    //     val rdy size result
    check( 1,  1,  2,   4 );

    // Simulate 10 cycles
    for ( int i = 0; i < 10; i = i+1 )
      check( 0, 0, 0, 0, IGNORE_OUTPUTS );

    // Expected result = 4

    //     ---- in ----
    //     val rdy size result
    check( 0,  1,  0,   4 );

    t.test_case_end();
  endtask

  // staff tests 
  //----------------------------------------------------------------------
  // Helper Tasks
  //----------------------------------------------------------------------

  // Task for sending a message to accumulate accelerator

  int send_msg_timeout;
  task send_msg( input logic [6:0] size );
    send_msg_timeout = 0;
    while ( !in_rdy && ( send_msg_timeout < 100 ) ) begin
      check( 1, 0, size, 0, IGNORE_OUTPUTS );
      send_msg_timeout = send_msg_timeout + 1;
    end
    check( 1, 1, size, 0, IGNORE_OUTPUTS );
  endtask

  // Task for initializing 64 element array where element i is value i+1

  task init_data_plus1();
    for ( int i = 0; i < 64; i++ )
      data( i*4, i+1 );
  endtask

  // Generic task for checking result

  int check_result_timeout;
  task check_result( input logic [31:0] result );
    check_result_timeout = 0;
    while ( !in_rdy && ( check_result_timeout < 100 ) ) begin
      check( 0, 0, 0, 0, IGNORE_OUTPUTS );
      check_result_timeout = check_result_timeout + 1;
    end
    check( 0, 1, 0, result );
  endtask

  // Task for checking result from plus1 data

  int check_result_plus1_result;
  task check_result_plus1( input logic [6:0] size );
    check_result_plus1_result = 0;
    for ( int i = 1; i <= size; i++ )
      check_result_plus1_result = check_result_plus1_result + i;
    check_result( check_result_plus1_result );
  endtask

  // Task for initializing 64 element array with random data

  logic [31:0] random_data;
  logic [31:0] random_ref_mem [64];

  task init_data_random();
    for ( int i = 0; i < 64; i++ ) begin
      random_data = { 8'b0, 24'($urandom(t.seed)) };
      random_ref_mem[i] = random_data;
      data( i*4, random_data );
    end
  endtask

  // Task for checking result from random data

  int check_result_random_result;
  task check_result_random( input logic [6:0] size );
    check_result_random_result = 0;
    for ( int i = 0; i < size; i++ )
      check_result_random_result = check_result_random_result + random_ref_mem[i];
    check_result( check_result_random_result );
  endtask

  //----------------------------------------------------------------------
  // test_case_2_size1
  //----------------------------------------------------------------------

  task test_case_2_size1();
    t.test_case_begin( "test_case_2_size1" );

    init_data_plus1();
    send_msg(1);
    check_result_plus1(1);

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_3_size7
  //----------------------------------------------------------------------

  task test_case_3_size7();
    t.test_case_begin( "test_case_3_size7" );

    init_data_plus1();
    send_msg(7);
    check_result_plus1(7);

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_4_size20
  //----------------------------------------------------------------------

  task test_case_4_size20();
    t.test_case_begin( "test_case_4_size20" );

    init_data_plus1();
    send_msg(20);
    check_result_plus1(20);

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_5_size63
  //----------------------------------------------------------------------

  task test_case_5_size63();
    t.test_case_begin( "test_case_5_size63" );

    init_data_plus1();
    send_msg(63);
    check_result_plus1(63);

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_6_nmsgs2
  //----------------------------------------------------------------------
  // This test case tests sending two consecutive messages to the
  // accelerator. The test bench will check the result and then send a
  // new message on the next cycle.

  task test_case_6_nmsgs2();
    t.test_case_begin( "test_case_6_nsmgs2" );

    init_data_plus1();
    send_msg(5);
    check_result_plus1(5);
    send_msg(3);
    check_result_plus1(3);

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_7_nmsgs3
  //----------------------------------------------------------------------
  // This test case tests sending three consecutive messages to the
  // accelerator. The test bench will check the result and then send a
  // new message on the next cycle.

  task test_case_7_nmsgs3();
    t.test_case_begin( "test_case_7_nsmgs3" );

    init_data_plus1();
    send_msg(5);
    check_result_plus1(5);
    send_msg(3);
    check_result_plus1(3);
    send_msg(13);
    check_result_plus1(13);

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_8_nmsgs7
  //----------------------------------------------------------------------
  // This test case tests sending seven consecutive messages to the
  // accelerator. The test bench will check the result and then send a
  // new message on the next cycle.

  task test_case_8_nmsgs7();
    t.test_case_begin( "test_case_8_nsmgs7" );

    init_data_plus1();

    for ( int i = 2; i <= 8; i++ ) begin
      send_msg(7'(i));
      check_result_plus1(7'(i));
    end

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_9_idle
  //----------------------------------------------------------------------
  // This test case tests if the accelerator can handle some "idle"
  // cycles before and after it is executing a transaction. An "idle"
  // cycle is when the accelerator is ready but the test bench is not
  // sending a valid message.

  task test_case_9_idle();
    t.test_case_begin( "test_case_9_idle" );

    init_data_plus1();

    for ( int i = 0; i < 3; i++ )
      check( 0, 1, 0, 0 );

    send_msg(5);
    check_result_plus1(5);

    for ( int i = 0; i < 7; i++ )
      check( 0, 1, 0, 0, IGNORE_OUTPUTS );

    send_msg(3);
    check_result_plus1(3);

    for ( int i = 0; i < 5; i++ )
      check( 0, 1, 0, 0, IGNORE_OUTPUTS );

    send_msg(13);
    check_result_plus1(13);

    for ( int i = 0; i < 3; i++ )
      check( 0, 1, 0, 0, IGNORE_OUTPUTS );

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_10_stream_v1
  //----------------------------------------------------------------------
  // This test case tests if the accumulate accelerator can handle a
  // stream of accumulate messages. In other words, the test bench sends
  // a message on the same cycle the accelerator is ready.

  int test_case_10_stream_v1_timeout;
  int test_case_10_stream_v1_result;

  task test_case_10_stream_v1();
    t.test_case_begin( "test_case_10_stream_v1" );

    init_data_plus1();

    check( 1, 1, 1, 0 );

    test_case_10_stream_v1_result = 0;
    for ( int i = 1; i <= 6; i++ ) begin

      test_case_10_stream_v1_result = test_case_10_stream_v1_result + i;

      test_case_10_stream_v1_timeout = 0;
      while ( !in_rdy && ( test_case_10_stream_v1_timeout < 100 ) ) begin
        check( 0, 0, 0, 0, IGNORE_OUTPUTS );
        test_case_10_stream_v1_timeout = test_case_10_stream_v1_timeout + 1;
      end

      check( 1, 1, 7'(i+1), test_case_10_stream_v1_result );

    end

    check_result_plus1(7);

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_11_stream_v2
  //----------------------------------------------------------------------
  // This test case is like the previous test case but now the test bench
  // tries to send a valid message even when the accelerator is busy, and
  // ultimately sends the message as soon as the accelerator is ready.

  int test_case_11_stream_v2_timeout;
  int test_case_11_stream_v2_result;

  task test_case_11_stream_v2();
    t.test_case_begin( "test_case_11_stream_v2" );

    init_data_plus1();

    check( 1, 1, 1, 0 );

    test_case_11_stream_v2_result = 0;
    for ( int i = 1; i <= 6; i++ ) begin

      test_case_11_stream_v2_result = test_case_11_stream_v2_result + i;

      test_case_11_stream_v2_timeout = 0;
      while ( !in_rdy && ( test_case_11_stream_v2_timeout < 100 ) ) begin
        check( 1, 0, 7'(i+1), 0, IGNORE_OUTPUTS );
        test_case_11_stream_v2_timeout = test_case_11_stream_v2_timeout + 1;
      end

      check( 1, 1, 7'(i+1), test_case_11_stream_v2_result );

    end

    check_result_plus1(7);

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_12_random_data
  //----------------------------------------------------------------------

  task test_case_12_random_data();
    t.test_case_begin( "test_case_12_random_data" );

    init_data_random();
    send_msg(17);
    check_result_random(17);

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // test_case_13_random_size
  //----------------------------------------------------------------------

  logic [6:0] random_size;

  task test_case_13_random_size();
    t.test_case_begin( "test_case_13_random_data" );

    init_data_random();

    for ( int i = 0; i < 10; i++ ) begin
      random_size = { 1'b0, 6'($urandom(t.seed)) };
      send_msg(random_size);
      check_result_random(random_size);
    end

    t.test_case_end();
  endtask

  //----------------------------------------------------------------------
  // main
  //----------------------------------------------------------------------

  initial begin
    t.test_bench_begin();

    if ((t.n <= 0) || (t.n == 1)) test_case_1_basic();
    if ((t.n <= 0) || (t.n == 2)) test_case_directed_1();
    if ((t.n <= 0) || (t.n == 3)) test_case_directed_2();
    if ((t.n <= 0) || (t.n == 4)) test_case_directed_3();
    if ((t.n <= 0) || (t.n == 5)) test_case_directed_4();
    if ((t.n <= 0) || (t.n == 6)) test_case_directed_5();

    // staff tests 
    if ((t.n <= 0) || (t.n == 7))  test_case_2_size1();
    if ((t.n <= 0) || (t.n == 8))  test_case_3_size7();
    if ((t.n <= 0) || (t.n == 9))  test_case_4_size20();
    if ((t.n <= 0) || (t.n == 10))  test_case_5_size63();
    if ((t.n <= 0) || (t.n == 11))  test_case_6_nmsgs2();
    if ((t.n <= 0) || (t.n == 12))  test_case_7_nmsgs3();
    if ((t.n <= 0) || (t.n == 13))  test_case_8_nmsgs7();
    if ((t.n <= 0) || (t.n == 14))  test_case_9_idle();
    if ((t.n <= 0) || (t.n == 15)) test_case_10_stream_v1();
    if ((t.n <= 0) || (t.n == 16)) test_case_11_stream_v2();
    if ((t.n <= 0) || (t.n == 17)) test_case_12_random_data();
    if ((t.n <= 0) || (t.n == 18)) test_case_13_random_size();

    t.test_bench_end();
  end

endmodule
