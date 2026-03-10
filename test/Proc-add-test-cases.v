//========================================================================
// Proc-add-test-cases
//========================================================================

//------------------------------------------------------------------------
// test_case_1_basic
//------------------------------------------------------------------------

task test_case_1_basic();
  t.test_case_begin( "test_case_1_basic" );

  // Write assembly program into memory

  asm( 'h000, "addi x1, x0, 2"  );
  asm( 'h004, "addi x2, x0, 3"  );
  asm( 'h008, "add  x3, x1, x2" );

  // Check each executed instruction
  //           addr   en reg   data
  check_trace( 'h000, 1, 5'd1, 32'h0000_0002 ); // addi x1, x0, 2
  check_trace( 'h004, 1, 5'd2, 32'h0000_0003 ); // addi x2, x0, 3
  check_trace( 'h008, 1, 5'd3, 32'h0000_0005 ); // add  x3, x1, x2

  t.test_case_end();
endtask

//------------------------------------------------------------------------
// test_case_2_directed
//------------------------------------------------------------------------

// When the destination = source
task test_case_2_directed();
  t.test_case_begin( "test_case_2_directed" );

  asm( 'h000, "addi x1, x0, 5"  );
  asm( 'h004, "add  x1, x1, x1" );

  check_trace( 'h000, 1, 5'd1, 32'h0000_0005 );
  check_trace( 'h004, 1, 5'd1, 32'h0000_000A );

  t.test_case_end();
endtask

//------------------------------------------------------------------------
// test_case_3_directed
//------------------------------------------------------------------------

// Testing really low/high nums
task test_case_3_directed();
  t.test_case_begin( "test_case_3_directed" );

  asm( 'h000, "addi x1, x0, 2047"   );
  asm( 'h004, "addi x2, x0, -2048"  );
  asm( 'h008, "add  x3, x1, x2"     );

  check_trace( 'h000, 1, 5'd1, 32'h0000_07FF );
  check_trace( 'h004, 1, 5'd2, 32'hFFFF_F800 );
  check_trace( 'h008, 1, 5'd3, 32'hFFFF_FFFF ); 

  t.test_case_end();
endtask

//------------------------------------------------------------------------
// test_case_4_directed
//------------------------------------------------------------------------

// Testing with x0
task test_case_4_directed();
  t.test_case_begin( "test_case_4_directed" );

  asm( 'h000, "addi x1, x0, 4"   );
  asm( 'h004, "add  x0, x1, x1"  );
  asm( 'h008, "add  x2, x0, x1"  );

  check_trace( 'h000, 1, 5'd1, 32'h0000_0004 );
  check_trace( 'h004, 1, 5'd0, 32'h0000_0000 ); 
  check_trace( 'h008, 1, 5'd2, 32'h0000_0004 ); 

  t.test_case_end();
endtask

//------------------------------------------------------------------------
// test_case_5_directed
//------------------------------------------------------------------------

// Overflow testing
task test_case_5_directed();
  t.test_case_begin( "test_case_5_directed" );

  asm( 'h000, "addi x10, x0, -1"  );
  asm( 'h004, "addi x11, x0, 1"   );
  asm( 'h008, "add  x12, x10, x11" );

  check_trace( 'h000, 1, 5'd10, 32'hFFFF_FFFF );
  check_trace( 'h004, 1, 5'd11, 32'h0000_0001 );
  check_trace( 'h008, 1, 5'd12, 32'h0000_0000 ); 

  t.test_case_end();
endtask

//------------------------------------------------------------------------
// test_case_6_directed
//------------------------------------------------------------------------

// Adding positives and negatives
task test_case_6_directed();
  t.test_case_begin( "test_case_6_directed" );

  asm( 'h000, "addi x1, x0, -16" );
  asm( 'h004, "addi x2, x0, 32"  );
  asm( 'h008, "add  x3, x1, x2"  );
  asm( 'h00C, "add  x4, x3, x1"  );

  check_trace( 'h000, 1, 5'd1, 32'hFFFF_FFF0 );
  check_trace( 'h004, 1, 5'd2, 32'h0000_0020 );
  check_trace( 'h008, 1, 5'd3, 32'h0000_0010 ); 
  check_trace( 'h00C, 1, 5'd4, 32'h0000_0000 );

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
