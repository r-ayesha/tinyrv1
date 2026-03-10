//========================================================================
// Proc-lw-test-cases
//========================================================================

//------------------------------------------------------------------------
// test_case_1_basic
//------------------------------------------------------------------------

task test_case_1_basic();
  t.test_case_begin( "test_case_1_basic" );

  // Write assembly program into memory

  asm( 'h000, "addi x1, x0, 0x100" );
  asm( 'h004, "lw   x2, 0(x1)"     );

  // Write data into memory

  data( 'h100, 'hdead_beef );

  // Check each executed instruction
  //           addr   en reg   data
  check_trace( 'h000, 1, 5'd1, 32'h0000_0100 ); // addi x1, x0, 0x100
  check_trace( 'h004, 1, 5'd2, 32'hdead_beef ); // lw   x2, 0(x1)

  t.test_case_end();
endtask

//------------------------------------------------------------------------
// test_case_2_directed
//------------------------------------------------------------------------

// Case where non-zero number are loaded after zero
task test_case_2_directed();
  t.test_case_begin( "test_case_2_directed" );

  asm('h000, "addi x1, x0, 0x120" );
  asm('h004, "lw   x2, 0(x1)"     );
  asm('h008, "addi x3, x0, 0x24"  );
  asm('h00c, "lw   x4, 4(x1)"     );

  // Write memory manually
  data('h120, 32'h0000_0000 );
  data('h124, 32'h0000_0024 );

  check_trace('h000, 1, 5'd1, 32'h0000_0120 ); // addi
  check_trace('h004, 1, 5'd2, 32'h0000_0000 ); // lw
  check_trace('h008, 1, 5'd3, 32'h0000_0024 ); // addi
  check_trace('h00c, 1, 5'd4, 32'h0000_0024 ); // lw
  t.test_case_end();
endtask

//------------------------------------------------------------------------
// test_case_3_directed
//------------------------------------------------------------------------

task test_case_3_directed();
  t.test_case_begin( "test_case_3_directed" );

  asm('h000, "addi x1, x0, 0x1C0" );
  asm('h004, "lw   x2, 0(x1)"     );
  asm('h008, "lw   x3, 4(x1)"     );

  data('h1C0, 32'h1111_1111 );
  data('h1C4, 32'h2222_2222 );

  check_trace('h000, 1, 5'd1, 32'h0000_01C0 );
  check_trace('h004, 1, 5'd2, 32'h1111_1111 );
  check_trace('h008, 1, 5'd3, 32'h2222_2222 );

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

  t.test_bench_end();
end

