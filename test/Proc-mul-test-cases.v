//========================================================================
// Proc-mul-test-cases
//========================================================================

//------------------------------------------------------------------------
// test_case_1_basic
//------------------------------------------------------------------------

task test_case_1_basic();
  t.test_case_begin( "test_case_1_basic" );

  // Write assembly program into memory

  asm( 'h000, "addi x1, x0, 2"  );
  asm( 'h004, "addi x2, x0, 3"  );
  asm( 'h008, "mul  x3, x1, x2" );

  // Check each executed instruction
  //           addr   en reg   data
  check_trace( 'h000, 1, 5'd1, 32'h0000_0002 ); // addi x1, x0, 2
  check_trace( 'h004, 1, 5'd2, 32'h0000_0003 ); // addi x2, x0, 3
  check_trace( 'h008, 1, 5'd3, 32'h0000_0006 ); // mul  x3, x1, x2

  t.test_case_end();
endtask

//------------------------------------------------------------------------
// directed test cases 
//------------------------------------------------------------------------

// multiply by zero and by one
task test_case_2_directed();
  t.test_case_begin("test_case_2_directed");

  // Write assembly program into memory
  asm('h000, "addi x4, x0, 123"   );
  asm('h004, "mul  x5, x4, x0"    );
  asm('h008, "addi x1, x0, 1"     );
  asm('h00C, "mul  x6, x4, x1"    );

  // Check each executed instruction
  //           addr   en reg   data
  check_trace('h000, 1, 5'd4, 32'h0000_007B ); // addi x4, x0, 123
  check_trace('h004, 1, 5'd5, 32'h0000_0000 ); // mul  x5, x4, x0
  check_trace('h008, 1, 5'd1, 32'h0000_0001 ); // addi x1, x0, 1
  check_trace('h00C, 1, 5'd6, 32'h0000_007B ); // mul  x6, x4, x1

  t.test_case_end();
endtask

// multiply in place w/ negatives & multiple rf's
task test_case_3_directed();
  t.test_case_begin("test_case_3_directed");

  // Write assembly program into memory
  asm('h000, "addi x7, x0, -3"    );
  asm('h004, "addi x8, x0, 4"     );
  asm('h008, "mul  x7, x7, x8"    );
  asm('h00C, "addi x9, x0, -2"    );
  asm('h010, "mul  x10, x9, x7"   );
  asm('h014, "mul  x11, x8, x10"  );

  // Check each executed instruction
  //           addr   en reg   data
  check_trace('h000, 1, 5'd7,  32'hFFFF_FFFD ); // addi x7, x0, -3
  check_trace('h004, 1, 5'd8,  32'h0000_0004 ); // addi x8, x0, 4
  check_trace('h008, 1, 5'd7,  32'hFFFF_FFF4 ); // mul  x7, x7, x8 = -12
  check_trace('h00C, 1, 5'd9,  32'hFFFF_FFFE ); // addi x9, x0, -2
  check_trace('h010, 1, 5'd10, 32'h0000_0018 ); // mul  x10, x9, x7 = 24
  check_trace('h014, 1, 5'd11, 32'h0000_0060 ); // mul  x11, x8, x10 = 96

  t.test_case_end();
endtask

// boundary magnitudes and mixed in regular values
task test_case_4_directed();
  t.test_case_begin("test_case_4_directed");

  // Write assembly program into memory
  asm('h000, "addi x9,  x0, 2047" );
  asm('h004, "addi x10, x0, -2048");
  asm('h008, "mul  x11, x9,  x9"  );
  asm('h00C, "mul  x12, x10, x10" );
  asm('h010, "addi x13, x0, 2"    );
  asm('h014, "mul  x14, x12, x13" );
  asm('h018, "mul  x15, x11, x13" );

  // Check each executed instruction
  //           addr   en reg   data
  check_trace('h000, 1, 5'd9,  32'h0000_07FF ); // addi x9, x0, 2047
  check_trace('h004, 1, 5'd10, 32'hFFFF_F800 ); // addi x10, x0, -2048
  check_trace('h008, 1, 5'd11, 32'h003F_F001 ); // mul  x11, x9, x9
  check_trace('h00C, 1, 5'd12, 32'h0040_0000 ); // mul  x12, x10, x10
  check_trace('h010, 1, 5'd13, 32'h0000_0002 ); // addi x13, x0, 2
  check_trace('h014, 1, 5'd14, 32'h0080_0000 ); // mul  x14, x12, x13
  check_trace('h018, 1, 5'd15, 32'h007F_E002 ); // mul  x15, x11, x13

  t.test_case_end();
endtask

// writing to x0, with mixed signs 
task test_case_5_directed();
  t.test_case_begin("test_case_5_directed");

  // Write assembly program into memory
  asm('h000, "addi x9,  x0, 12"   );
  asm('h004, "addi x10, x0, -9"   );
  asm('h008, "mul  x13, x10, x9"  );
  asm('h00C, "mul  x0,  x9,  x9"  );
  asm('h010, "addi x14, x0, 7"    );
  asm('h014, "mul  x15, x14, x13" );

  // Check each executed instruction
  //           addr   en reg   data
  check_trace('h000, 1, 5'd9,  32'h0000_000C ); // addi x9, x0, 12
  check_trace('h004, 1, 5'd10, 32'hFFFF_FFF7 ); // addi x10, x0, -9
  check_trace('h008, 1, 5'd13, 32'hFFFF_FF94 ); // mul  x13, x10, x9 = -108
  check_trace('h00C, 1, 5'd0,  32'h0000_0090 ); // mul  x0, x9, x9 = 144
  check_trace('h010, 1, 5'd14, 32'h0000_0007 ); // addi x14, x0, 7
  check_trace('h014, 1, 5'd15, 32'hFFFF_FD0C ); // mul  x15, x14, x13 = -756

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
