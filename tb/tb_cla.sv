`timescale 1ns / 1ps

module tb_cla ();

  reg [31:0] a, b;
  reg c_in;
  // wire g_out, p_out;
  wire [31:0] sum;
  wire c_out;

  cla_ripple_adder #(
      .len(2)
  ) i_cla_32 (
      .a(a),
      .b(b),
      .c_in(c_in),
      .out(sum),
      .c_out(c_out)
  );

  initial begin
    string wavefile;

    if (!$value$plusargs("wavefile=%s", wavefile)) wavefile = "waveform.fst";

    a = 32'd595;
    b = 32'd123;
    c_in = 1'b0;

    #2;

    for (int i = 0; i < 100; i = i + 1) begin
      a = $urandom_range(0, 2 ** 32 - 1);
      b = $urandom_range(0, 2 ** 32 - 1);
      c_in = $urandom_range(0, 1);

      #2;
    end
    $finish;


  end

endmodule
