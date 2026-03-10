//========================================================================
// Proc-jal-test-cases
//========================================================================

//------------------------------------------------------------------------
// test_case_1_basic
//------------------------------------------------------------------------

task test_case_1_basic();
  t.test_case_begin( "test_case_1_basic" );

  // Write assembly program into memory

  asm( 'h000, "addi x1, x0, 1" );
  asm( 'h004, "jal  x2, 0x00c" );
  asm( 'h008, "addi x1, x0, 2" );
  asm( 'h00c, "addi x1, x0, 3" );

  // Check each executed instruction
  //           addr   en reg   data
  check_trace( 'h000, 1, 5'd1, 32'h0000_0001 ); // addi x1, x0, 1
  check_trace( 'h004, 1, 5'd2, 32'h0000_0008 ); // jal  x2, 0x00c
  check_trace( 'h00c, 1, 5'd1, 32'h0000_0003 ); // addi x1, x0, 3

  t.test_case_end();
endtask

//------------------------------------------------------------------------
// test_case_2_directed
//------------------------------------------------------------------------

// Regular jumping forward
task test_case_2_directed();
  t.test_case_begin( "test_case_2_directed" );

  // Write assembly program into memory

  asm( 'h000, "addi x1, x0, 5" );
  asm( 'h004, "jal  x2, 0x014" );
  asm( 'h008, "addi x3, x0, 0" );
  asm( 'h00c, "addi x4, x0, 0" );
  asm( 'h010, "addi x5, x0, 0" );
  asm( 'h014, "addi x3, x0, 9" );

  check_trace( 'h000, 1, 5'd1, 32'h0000_0005 );
  check_trace( 'h004, 1, 5'd2, 32'h0000_0008 ); 
  check_trace( 'h014, 1, 5'd3, 32'h0000_0009 );

  t.test_case_end();
endtask

//------------------------------------------------------------------------
// test_case_3_directed
//------------------------------------------------------------------------

// Jump backwards
task test_case_3_directed();
  t.test_case_begin( "test_case_3_directed" );

  asm( 'h000, "addi x1, x0, 1" );
  asm( 'h004, "addi x2, x0, 2" );
  asm( 'h008, "jal  x3, 0x000" ); 
  asm( 'h00c, "addi x4, x0, 9" );

  check_trace( 'h000, 1, 5'd1, 32'h0000_0001 );
  check_trace( 'h004, 1, 5'd2, 32'h0000_0002 );
  check_trace( 'h008, 1, 5'd3, 32'h0000_000C ); 
  check_trace( 'h000, 1, 5'd1, 32'h0000_0001 ); 

  t.test_case_end();
endtask

//------------------------------------------------------------------------
// test_case_4_directed
//------------------------------------------------------------------------

// Rewriting over registers
task test_case_4_directed();
  t.test_case_begin( "test_case_4_directed" );

  asm( 'h000, "jal  x1, 0x008" );
  asm( 'h004, "addi x1, x0, 5" ); 
  asm( 'h008, "addi x2, x1, 1" ); 
  asm( 'h00c, "addi x3, x0, 2" );

  check_trace( 'h000, 1, 5'd1, 32'h0000_0004 ); 
  check_trace( 'h008, 1, 5'd2, 32'h0000_0005 );
  check_trace( 'h00c, 1, 5'd3, 32'h0000_0002 );

  t.test_case_end();
endtask

//------------------------------------------------------------------------
// test_case_5_directed
//------------------------------------------------------------------------

// Jump to itself
task test_case_5_directed();
  t.test_case_begin( "test_case_5_directed" );

  asm( 'h000, "jal x1, 0x000" );

  check_trace( 'h000, 1, 5'd1, 32'h0000_0004 ); 
  check_trace( 'h000, 1, 5'd1, 32'h0000_0004 ); 

  t.test_case_end();
endtask

//------------------------------------------------------------------------
// test_case_6_directed
//------------------------------------------------------------------------

// Making sure x0 behavior works
task test_case_6_directed();
  t.test_case_begin( "test_case_6_directed" );

  asm( 'h000, "addi x1, x0, 1" );
  asm( 'h004, "jal  x0, 0x00c" );
  asm( 'h008, "addi x2, x0, 2" );
  asm( 'h00c, "addi x3, x0, 3" );

  check_trace( 'h000, 1, 5'd1, 32'h0000_0001 );
  check_trace( 'h004, 1, 5'd0, 32'h0000_0000 ); 
  check_trace( 'h00c, 1, 5'd3, 32'h0000_0003 );

  t.test_case_end();
endtask

//------------------------------------------------------------------------
// main
//------------------------------------------------------------------------

initial begin
  t.test_bench_begin();

  if ((t.n <= 0) || (t.n == 1)) test_case_1_basic();
  if ((t.n <= 0) || (t.n == 2)) test_case_2_directed();
  if ((t.n <= 0) || (t.n == 3)) test_case_3_directed();
  if ((t.n <= 0) || (t.n == 4)) test_case_4_directed();
  if ((t.n <= 0) || (t.n == 5)) test_case_5_directed();
  if ((t.n <= 0) || (t.n == 6)) test_case_6_directed();

  t.test_bench_end();
end
