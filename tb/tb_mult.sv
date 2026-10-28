`timescale 1ns / 1ps

module tb_mult ();

  reg [15:0] a, b;
  wire [31:0] prod;
  reg [31:0] test_prod;
  wire c_out;

  mult_bw_16x16 #(
      .sign(1)
  ) i_mult_16x16 (
      .a(a),
      .x(b),
      .y(prod),
      .c_out(c_out)
  );

  string waveform_file;

  initial begin
    if (!$value$plusargs("WAVEFORM=%s", waveform_file)) waveform_file = "wave.fst";

    $dumpfile(waveform_file);
    $dumpvars(0, tb_mult);

    a = 16'd595;
    b = 16'd123;
    #5;

    a = 16'd32767;
    b = 16'd1;
    #5;

    b = 16'd32767;
    a = 16'd1;
    #5;

    b = 16'd16383;
    a = 16'd1;
    #5;

    for (int i = 0; i < 100; i = i + 1) begin
      /* verilator lint_off WIDTHTRUNC */
      a = $urandom_range(0, 2 ** 16 - 1);
      b = $urandom_range(0, 2 ** 16 - 1);
      /* verilator lint_on WIDTHTRUNC */

      #5;
      assert (prod == (a * b))
      else $error("Mismatch: a=%0d, b=%0d, expected=%0d, got=%0d", a, b, (a * b), prod);
    end
    $finish;
  end

  always @(*) begin
    test_prod = a * b;
  end

endmodule
