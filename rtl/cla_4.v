`timescale 1ns / 1ps
/*
    4-bit carry look-ahead adder.
    This can be used hierarchically to construct higher-radix adders.
*/


module cla_4(
    input [3:0] a,
    input [3:0] b,
    input c_in,
    output [3:0] out,
    output c_out,
    output p_out,
    output g_out
    );
    
    wire [4:0] p, g;
    wire [3:0] carry;
    
    pg_4 i_pg (
        .a(a),
        .b(b),
        .p(p),
        .g(g)
    );
    
    c_gen_4 i_carry_gen (
        .p(p[3:0]),
        .g(g[3:0]),
        .c_in(c_in),
        .c_out(carry)
    );
    
    assign out = p[3:0] ^ {carry[2:0], c_in};
    assign c_out = carry[3];
    assign p_out = p[4];
    assign g_out = g[4];
    
endmodule
