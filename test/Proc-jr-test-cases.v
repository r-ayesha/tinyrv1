//========================================================================
// Proc-jr-test-cases
//========================================================================

//------------------------------------------------------------------------
// test_case_1_basic
//------------------------------------------------------------------------

task test_case_1_basic();
  t.test_case_begin( "test_case_1_basic" );

  // Write assembly program into memory

  asm( 'h000, "addi x1, x0, 0x00c" );
  asm( 'h004, "jr   x1" );
  asm( 'h008, "addi x1, x0, 2" );
  asm( 'h00c, "addi x1, x0, 3" );

  // Check each executed instruction
  //           addr   en reg   data
  check_trace( 'h000, 1, 5'd1, 32'h0000_000c ); // addi x1, x0, 0x00c
  check_trace( 'h004, 0, 5'dx, 32'hxxxx_xxxx ); // jr   x1
  check_trace( 'h00c, 1, 5'd1, 32'h0000_0003 ); // addi x1, x0, 3

  t.test_case_end();
endtask

//------------------------------------------------------------------------
// test case directed 
//------------------------------------------------------------------------

// jumps forward over two instructions 
task test_case_2_directed();
  t.test_case_begin("test_case_2_directed");

  asm('h000, "addi x2, x0, 0x10" );
  asm('h004, "addi x1, x0, 1" );
  asm('h008, "jr   x2" );
  asm('h00c, "addi x3, x0, 9" );
  asm('h010, "addi x4, x0, 0x55" );

  check_trace('h000, 1, 5'd2, 32'h00000010 ); // addi x2, x0, 0x10
  check_trace('h004, 1, 5'd1, 32'h00000001 ); // addi x1, x0, 1
  check_trace('h008, 0, 5'dx, 32'hxxxxxxxx ); // jr x2
  check_trace('h010, 1, 5'd4, 32'h00000055 ); // addi x4, x0, 0x55

  t.test_case_end();
endtask;

// jumps to address of three adds of the same reg
task test_case_3_directed();
  t.test_case_begin("test_case_3_directed");

  asm('h000, "addi x5, x0, 0x08" );
  asm('h004, "addi x5, x5, 0x08" );
  asm('h008, "addi x5, x5, 0x04" );
  asm('h00c, "jr   x5" );
  asm('h010, "addi x1, x0, 2" );
  asm('h014, "addi x2, x0, 7" );

  check_trace('h000, 1, 5'd5, 32'h00000008 ); // addi x5, x0, 0x08
  check_trace('h004, 1, 5'd5, 32'h00000010 ); // addi x5, x5, 0x08
  check_trace('h008, 1, 5'd5, 32'h00000014 ); // addi x5, x5, 0x04
  check_trace('h00c, 0, 5'dx, 32'hxxxxxxxx ); // jr x5
  check_trace('h014, 1, 5'd2, 32'h00000007 ); // addi x2, x0, 7

  t.test_case_end();
endtask;

// two jumps in one directed test case 
task test_case_4_directed();
  t.test_case_begin("test_case_4_directed");

  asm('h000, "addi x1, x0, 0x10" );
  asm('h004, "addi x2, x0, 0x18" );
  asm('h008, "jr   x1" );
  asm('h00c, "addi x3, x0, 1" );
  asm('h010, "jr   x2" );
  asm('h014, "addi x4, x0, 2" );
  asm('h018, "addi x5, x0, 3" );

  check_trace('h000, 1, 5'd1, 32'h00000010 ); // addi x1, x0, 0x10
  check_trace('h004, 1, 5'd2, 32'h00000018 ); // addi x2, x0, 0x18
  check_trace('h008, 0, 5'dx, 32'hxxxxxxxx ); // jr x1
  check_trace('h010, 0, 5'dx, 32'hxxxxxxxx ); // jr x2
  check_trace('h018, 1, 5'd5, 32'h00000003 ); // addi x5, x0, 3

  t.test_case_end();
endtask;

// tests the biggest address using -4 PC (wraps around) 32 
task test_case_5_directed();
  t.test_case_begin("test_case_5_directed");

  asm('h00000000, "addi x6, x0, -2048" );
  asm('h00000004, "addi x6, x6, 2044"  );
  asm('h00000008, "addi x7, x0, 0"     );
  asm('h0000000c, "jr   x6"            );

  asm('h0ffffffc, "addi x7, x7, 1"     );

  check_trace('h00000000, 1, 5'd6, 32'hfffff800 ); // addi x6, x0, -2048
  check_trace('h00000004, 1, 5'd6, 32'hfffffffc ); // addi x6, x6, 2044
  check_trace('h00000008, 1, 5'd7, 32'h00000000 ); // addi x7, x0, 0
  check_trace('h0000000c, 0, 5'dx, 32'hxxxxxxxx ); // jr x6
  check_trace('hfffffffc, 1, 5'd7, 32'h00000001 ); // addi x7, x7, 1

  t.test_case_end();
endtask

// jumps back to the smallest possible bit (0) becomes an infinite loop
task test_case_6_directed();
  t.test_case_begin("test_case_6_directed");

  asm('h000, "addi x1, x0, 0" );
  asm('h004, "addi x2, x0, 1" );
  asm('h008, "addi x3, x0, 2" );
  asm('h00c, "jr x1" );
  asm('h010, "addi x4, x0, 3" );
  asm('h014, "addi x5, x0, 4" );

  // first loop iteration
  check_trace('h000, 1, 5'd1, 32'h00000000 ); // addi x1, x0, 0
  check_trace('h004, 1, 5'd2, 32'h00000001 ); // addi x2, x0, 1
  check_trace('h008, 1, 5'd3, 32'h00000002 ); // addi x3, x0, 2
  check_trace('h00c, 0, 5'dx, 32'hxxxxxxxx ); // jr x1

  // second loop iteration
  check_trace('h000, 1, 5'd1, 32'h00000000 ); // addi x1, x0, 0
  check_trace('h004, 1, 5'd2, 32'h00000001 ); // addi x2, x0, 1
  check_trace('h008, 1, 5'd3, 32'h00000002 ); // addi x3, x0, 2
  check_trace('h00c, 0, 5'dx, 32'hxxxxxxxx ); // jr x1

  t.test_case_end();
endtask

// backward jumps & jump to itself
task test_case_7_directed();
  t.test_case_begin("test_case_7_directed");

  asm('h000, "addi x1, x0, 0x014" );
  asm('h004, "jr   x1"           );
  asm('h008, "addi x2, x0, 5"    );
  asm('h00c, "addi x3, x0, 6"    );
  asm('h010, "addi x4, x0, 7"    );
  asm('h014, "addi x5, x0, 0x14" );  // x5 = address 0x14
  asm('h018, "jr   x5"           );  // self-jump to 0x14
  asm('h01c, "addi x6, x0, 9"    );  // never executed

  //           addr   en  reg   data
  check_trace('h000, 1, 5'd1, 32'h00000014 ); // addi x1, x0, 0x14
  check_trace('h004, 0, 5'dx, 32'hxxxxxxxx ); // jr   x1  (backward jump)
  check_trace('h014, 1, 5'd5, 32'h00000014 ); // addi x5, x0, 0x14
  check_trace('h018, 0, 5'dx, 32'hxxxxxxxx ); // jr   x5  (self-jump)

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
  if ((t.n <= 0) || (t.n == 7)) test_case_7_directed();


  t.test_bench_end();
end
