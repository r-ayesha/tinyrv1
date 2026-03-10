//========================================================================
// Proc-bne-test-cases
//========================================================================

//------------------------------------------------------------------------
// test_case_1_basic
//------------------------------------------------------------------------

task test_case_1_basic();
  t.test_case_begin( "test_case_1_basic" );

  // Write assembly program into memory

  asm( 'h000, "addi x1, x0, 1" );
  asm( 'h004, "bne  x1, x0, 0x00c" );
  asm( 'h008, "addi x1, x0, 2" );
  asm( 'h00c, "addi x1, x0, 3" );

  // Check each executed instruction
  //           addr   en reg   data
  check_trace( 'h000, 1, 5'd1, 32'h0000_0001 ); // addi x1, x0, 1
  check_trace( 'h004, 0, 5'dx, 32'hxxxx_xxxx ); // bne  x1, x0, 0x00c
  check_trace( 'h00c, 1, 5'd1, 32'h0000_0003 ); // addi x1, x0, 3

  t.test_case_end();
endtask

//------------------------------------------------------------------------
// test_case_2_directed
//------------------------------------------------------------------------

// Regular case where the BNE is not taken
task test_case_2_directed();
  t.test_case_begin( "test_case_2_directed" );

  asm( 'h000, "addi x1, x0, 4" );
  asm( 'h004, "addi x2, x0, 4" );
  asm( 'h008, "bne  x1, x2, 0x010" );
  asm( 'h00c, "addi x3, x0, 9" );
  asm( 'h010, "addi x3, x0, 7" );

  check_trace( 'h000, 1, 5'd1, 32'h0000_0004 );
  check_trace( 'h004, 1, 5'd2, 32'h0000_0004 );
  check_trace( 'h008, 0, 5'dx, 32'hxxxx_xxxx ); // bne is not taken
  check_trace( 'h00c, 1, 5'd3, 32'h0000_0009 ); 

  t.test_case_end();
endtask

//------------------------------------------------------------------------
// test_case_3_directed
//------------------------------------------------------------------------

// BNE looping forward
task test_case_3_directed();
  t.test_case_begin( "test_case_3_directed" );

  asm( 'h000, "addi x1, x0, 5" );
  asm( 'h004, "addi x2, x0, 6" );
  asm( 'h008, "bne  x1, x2, 0x014" );
  asm( 'h00c, "addi x3, x0, 0" );
  asm( 'h010, "addi x3, x0, 0" );
  asm( 'h014, "addi x3, x0, 1" );

  check_trace( 'h000, 1, 5'd1, 32'h0000_0005 );
  check_trace( 'h004, 1, 5'd2, 32'h0000_0006 );
  check_trace( 'h008, 0, 5'dx, 32'hxxxx_xxxx ); // branch taken
  check_trace( 'h014, 1, 5'd3, 32'h0000_0001 );

  t.test_case_end();
endtask

//------------------------------------------------------------------------
// test_case_4_directed
//------------------------------------------------------------------------

// BNE looping backwards
task test_case_4_directed();
  t.test_case_begin( "test_case_4_directed" );

  asm( 'h000, "addi x1, x0, 3" );
  asm( 'h004, "addi x2, x0, 2" );
  asm( 'h008, "add  x3, x1, x2" );
  asm( 'h00c, "bne  x3, x1, 0x000" ); 
  asm( 'h010, "addi x4, x0, 9" );

  check_trace( 'h000, 1, 5'd1, 32'h0000_0003 );
  check_trace( 'h004, 1, 5'd2, 32'h0000_0002 );
  check_trace( 'h008, 1, 5'd3, 32'h0000_0005 );
  check_trace( 'h00c, 0, 5'dx, 32'hxxxx_xxxx ); // branch taken
  check_trace( 'h000, 1, 5'd1, 32'h0000_0003 ); 

  t.test_case_end();
endtask

//------------------------------------------------------------------------
// test_case_5_directed
//------------------------------------------------------------------------

// Comparing to x0
task test_case_5_directed();
  t.test_case_begin( "test_case_5_directed" );

  asm( 'h000, "addi x1, x0, 0" );
  asm( 'h004, "bne  x1, x0, 0x00c" );
  asm( 'h008, "addi x2, x0, 4" );
  asm( 'h00c, "addi x3, x0, 5" );

  check_trace( 'h000, 1, 5'd1, 32'h0000_0000 );
  check_trace( 'h004, 0, 5'dx, 32'hxxxx_xxxx ); // branch taken
  check_trace( 'h008, 1, 5'd2, 32'h0000_0004 );

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

  t.test_bench_end();
end
