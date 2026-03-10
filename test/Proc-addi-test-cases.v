//========================================================================
// Proc-addi-test-cases
//========================================================================

//------------------------------------------------------------------------
// test_case_1_basic
//------------------------------------------------------------------------

task test_case_1_basic();
  t.test_case_begin( "test_case_1_basic" );

  // Write assembly program into memory

  asm( 'h000, "addi x1, x0, 2"   );
  asm( 'h004, "addi x2, x1, 2"   );

  // Check each executed instruction
  //           addr   en reg   data
  check_trace( 'h000, 1, 5'd1, 32'h0000_0002 ); // addi x1, x0, 2
  check_trace( 'h004, 1, 5'd2, 32'h0000_0004 ); // addi x2, x1, 2

  t.test_case_end();
endtask

//------------------------------------------------------------------------
// test_case_directed 
//------------------------------------------------------------------------

// adding in place and see if that updates
task test_case_2_directed();
  t.test_case_begin( "test_case_2_directed" );

  // Write assembly program into memory

  asm( 'h000, "addi x1, x0, 3"   );
  asm( 'h004, "addi x1, x1, 5"   );

  // Check each executed instruction
  //           addr   en reg   data
  check_trace( 'h000, 1, 5'd1, 32'h0000_0003 ); // addi x1, x0, 3
  check_trace( 'h004, 1, 5'd1, 32'h0000_0008 ); // addi x1, x1, 8

  t.test_case_end();
endtask

// tests all the boundary extremes (pos and neg)
task test_case_3_directed();
  t.test_case_begin("test_case_3_directed");

  // Write assembly program into memory

  asm('h000, "addi x1, x0, 2047"   );
  asm('h004, "addi x2, x0, -2048"  );
  asm('h008, "addi x3, x1, 1"      );
  asm('h00C, "addi x4, x2, -1"     );
  
  // Check each executed instruction
  //           addr   en reg   data
  check_trace('h000, 1, 5'd1, 32'h0000_07FF ); // addi x1, x0, 2047
  check_trace('h004, 1, 5'd2, 32'hFFFF_F800 ); // addi x2, x0, -2048
  check_trace('h008, 1, 5'd3, 32'h0000_0800 ); // addi x3, x1, 1
  check_trace('h00C, 1, 5'd4, 32'hFFFF_F7FF ); // addi x4, x2, -1

  t.test_case_end();
endtask

// writing to x0 and using x0 after trying to write it
task test_case_4_directed();
  t.test_case_begin("test_case_4_directed");

  // Write assembly program into memory
  asm('h000, "addi x0, x0, 5"     );
  asm('h004, "addi x1, x0, 1"     );
  asm('h008, "addi x2, x0, -1"    );
  asm('h00C, "addi x3, x1, 0"     );
  asm('h010, "addi x0, x3, 7"     );
  asm('h014, "addi x4, x0, 2"     );

  // Check each executed instruction
  //           addr   en reg   data
  check_trace('h000, 1, 5'd0, 32'h0000_0000 ); // addi x0, x0, 5
  check_trace('h004, 1, 5'd1, 32'h0000_0001 ); // addi x1, x0, 1
  check_trace('h008, 1, 5'd2, 32'hFFFF_FFFF ); // addi x2, x0, -1
  check_trace('h00C, 1, 5'd3, 32'h0000_0001 ); // addi x3, x1, 0
  check_trace('h010, 1, 5'd0, 32'h0000_0000 ); // addi x0, x3, 7
  check_trace('h014, 1, 5'd4, 32'h0000_0002 ); // addi x4, x0, 2

  t.test_case_end();
endtask

// checks wrap around or overflow 
task test_case_5_directed();
  t.test_case_begin("test_case_5_directed");

  // Write assembly program into memory
  asm('h000, "addi x10, x0, -1"   );
  asm('h004, "addi x11, x10, 2"   );

  // Check each executed instruction
  //           addr   en reg   data
  check_trace('h000, 1, 5'd10, 32'hFFFF_FFFF ); // addi x10, x0, -1
  check_trace('h004, 1, 5'd11, 32'h0000_0001 ); // addi x11, x10, 2

  t.test_case_end();
endtask

// incrementing by 16 to cross 32-bit edges and wraps around
task test_case_6_directed();
  t.test_case_begin("test_case_6_directed");

  // Write assembly program into memory
  asm('h000, "addi x1, x0, -16"   );
  asm('h004, "addi x2, x1, 16"    );
  asm('h008, "addi x3, x2, 16"    );
  asm('h00C, "addi x4, x3, -32"   );

  // Check each executed instruction
  //           addr   en reg   data
  check_trace('h000, 1, 5'd1, 32'hFFFF_FFF0 ); // addi x1, x0, -16
  check_trace('h004, 1, 5'd2, 32'h0000_0000 ); // addi x2, x1, 16
  check_trace('h008, 1, 5'd3, 32'h0000_0010 ); // addi x3, x2, 16
  check_trace('h00C, 1, 5'd4, 32'hFFFF_FFF0 ); // addi x4, x3, -32

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

