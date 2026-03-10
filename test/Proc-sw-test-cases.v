//========================================================================
// Proc-sw-test-cases
//========================================================================

//------------------------------------------------------------------------
// test_case_1_basic
//------------------------------------------------------------------------

task test_case_1_basic();
  t.test_case_begin( "test_case_1_basic" );

  // Write assembly program into memory

  asm( 'h000, "addi x1, x0, 0x100" );
  asm( 'h004, "addi x2, x0, 0x42"  );
  asm( 'h008, "sw   x2, 0(x1)"     );
  asm( 'h00c, "lw   x3, 0(x1)"     );

  // Check each executed instruction
  //           addr   en reg   data
  check_trace( 'h000, 1, 5'd1, 32'h0000_0100 ); // addi x1, x0, 0x100
  check_trace( 'h004, 1, 5'd2, 32'h0000_0042 ); // addi x2, x0, 0x42
  check_trace( 'h008, 0, 5'dx, 32'hxxxx_xxxx ); // sw   x2, 0(x1)
  check_trace( 'h00c, 1, 5'd3, 32'h0000_0042 ); // lw   x3, 0(x1)

  t.test_case_end();
endtask

//------------------------------------------------------------------------
// directed test cases 
//------------------------------------------------------------------------

// stores 0 and then a normal nonzero number
task test_case_2_directed();
  t.test_case_begin("test_case_2_directed");

  asm('h000, "addi x1, x0, 0x118" );
  asm('h004, "sw   x0, 0(x1)"     );
  asm('h008, "lw   x2, 0(x1)"     );
  asm('h00c, "addi x3, x0, 0x24"  );
  asm('h010, "sw   x3, 4(x1)"     );
  asm('h014, "lw   x4, 4(x1)"     );

  check_trace('h000, 1, 5'd1, 32'h0000_0118 ); // addi x1, x0, 0x118
  check_trace('h004, 0, 5'dx, 32'hxxxx_xxxx ); // sw   x0, 0(x1)
  check_trace('h008, 1, 5'd2, 32'h0000_0000 ); // lw   x2, 0(x1)
  check_trace('h00c, 1, 5'd3, 32'h0000_0024 ); // addi x3, x0, 0x24
  check_trace('h010, 0, 5'dx, 32'hxxxx_xxxx ); // sw   x3, 4(x1)
  check_trace('h014, 1, 5'd4, 32'h0000_0024 ); // lw   x4, 4(x1)

  t.test_case_end();
endtask

// uses two negative immediate offsets at addresses below the base
task test_case_3_directed();
  t.test_case_begin("test_case_3_directed");

  asm('h000, "addi x6, x0, 0x120" );
  asm('h004, "addi x7, x0, 0x6BC" );
  asm('h008, "addi x8, x0, 0x44"  );
  asm('h00c, "sw   x7, -8(x6)"    );
  asm('h010, "sw   x8, -16(x6)"   );
  asm('h014, "lw   x9, -8(x6)"    );
  asm('h018, "lw   x10,-16(x6)"   );

  check_trace('h000, 1, 5'd6,  32'h0000_0120 ); // addi x6, x0, 0x120
  check_trace('h004, 1, 5'd7,  32'h0000_06BC ); // addi x7, x0, 0x6BC
  check_trace('h008, 1, 5'd8,  32'h0000_0044 ); // addi x8, x0, 0x44
  check_trace('h00c, 0, 5'dx,  32'hxxxx_xxxx ); // sw   x7, -8(x6)
  check_trace('h010, 0, 5'dx,  32'hxxxx_xxxx ); // sw   x8, -16(x6)
  check_trace('h014, 1, 5'd9,  32'h0000_06BC ); // lw   x9, -8(x6)
  check_trace('h018, 1, 5'd10, 32'h0000_0044 ); // lw   x10,-16(x6)

  t.test_case_end();
endtask

// writing same value over the same data mem address
task test_case_4_directed();
  t.test_case_begin("test_case_4_directed");

  asm('h000, "addi x1, x0, 0x100" );
  asm('h004, "addi x2, x0, 0x111" );
  asm('h008, "addi x3, x0, 0x108" );
  asm('h00c, "addi x4, x0, 0x222" );
  asm('h010, "sw  x2, 8(x1)"     );
  asm('h014, "sw  x4, 0(x3)"     );
  asm('h018, "lw  x5, 8(x1)"     );

  check_trace('h000, 1, 5'd1, 32'h00000100 ); // addi x1, x0, 0x100
  check_trace('h004, 1, 5'd2, 32'h00000111 ); // addi x2, x0, 0x111
  check_trace('h008, 1, 5'd3, 32'h00000108 ); // addi x3, x0, 0x108
  check_trace('h00c, 1, 5'd4, 32'h00000222 ); // addi x4, x0, 0x222
  check_trace('h010, 0, 5'dx, 32'hxxxxxxxx ); // sw  x2, 8(x1)
  check_trace('h014, 0, 5'dx, 32'hxxxxxxxx ); // sw  x4, 0(x3)
  check_trace('h018, 1, 5'd5, 32'h00000222 ); // lw  x5, 8(x1)

  t.test_case_end();
endtask

// uses boundary immediates +2044 and -2048
task test_case_5_directed();
  t.test_case_begin("test_case_5_directed");

  asm('h000, "addi x1, x0, -2048" );
  asm('h004, "addi x1, x1, 0x104" );
  asm('h008, "addi x2, x0, 0x5A5" );
  asm('h00c, "sw   x2, 2044(x1)"  );

  asm('h010, "addi x3, x0, 0x400" );
  asm('h014, "addi x3, x3, 0x400" );
  asm('h018, "addi x3, x3, 0x100" );
  asm('h01c, "addi x4, x0, 0x234" );
  asm('h020, "addi x3, x3, 0x4"   );
  asm('h024, "sw   x4, -2048(x3)" );

  asm('h028, "lw   x5, 2044(x1)"  );
  asm('h02c, "lw   x6, -2048(x3)" );

  check_trace('h000, 1, 5'd1, 32'hffff_f800 ); // addi x1, x0, -2048
  check_trace('h004, 1, 5'd1, 32'hffff_f904 ); // addi x1, x1, 0x104
  check_trace('h008, 1, 5'd2, 32'h0000_05a5 ); // addi x2, x0, 0x5A5
  check_trace('h00c, 0, 5'dx, 32'hxxxx_xxxx ); // sw   x2, 2044(x1)

  check_trace('h010, 1, 5'd3, 32'h0000_0400 ); // addi x3, x0, 0x400
  check_trace('h014, 1, 5'd3, 32'h0000_0800 ); // addi x3, x3, 0x400
  check_trace('h018, 1, 5'd3, 32'h0000_0900 ); // addi x3, x3, 0x100
  check_trace('h01c, 1, 5'd4, 32'h0000_0234 ); // addi x4, x0, 0x234
  check_trace('h020, 1, 5'd3, 32'h0000_0904 ); // addi x3, x3, 0x4
  check_trace('h024, 0, 5'dx, 32'hxxxx_xxxx ); // sw   x4, -2048(x3)

  check_trace('h028, 1, 5'd5, 32'h0000_05a5 ); // lw   x5, 2044(x1)
  check_trace('h02c, 1, 5'd6, 32'h0000_0234 ); // lw   x6, -2048(x3)

  t.test_case_end();
endtask

// storing and then changing and then loading it back in rs2
task test_case_6_directed();
  t.test_case_begin("test_case_6_directed");

  asm('h000, "addi x1, x0, 0x1C0" );
  asm('h004, "addi x2, x0, 0x77"  );
  asm('h008, "sw   x2, 0(x1)"     );
  asm('h00c, "addi x2, x0, 0x11"  );
  asm('h010, "lw   x3, 0(x1)"     );
  asm('h014, "sw   x2, 4(x1)"     );
  asm('h018, "lw   x4, 4(x1)"     );

  check_trace('h000, 1, 5'd1, 32'h0000_01C0 ); // addi x1, x0, 0x1C0
  check_trace('h004, 1, 5'd2, 32'h0000_0077 ); // addi x2, x0, 0x77
  check_trace('h008, 0, 5'dx, 32'hxxxx_xxxx ); // sw   x2, 0(x1)
  check_trace('h00c, 1, 5'd2, 32'h0000_0011 ); // addi x2, x0, 0x11
  check_trace('h010, 1, 5'd3, 32'h0000_0077 ); // lw   x3, 0(x1)
  check_trace('h014, 0, 5'dx, 32'hxxxx_xxxx ); // sw   x2, 4(x1)
  check_trace('h018, 1, 5'd4, 32'h0000_0011 ); // lw   x4, 4(x1)

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
