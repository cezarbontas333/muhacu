`timescale 1ns / 1ps
/*
    Carry look-ahead adder of 16-bits using 4 4-bit CLAs.
    Carries are computed based on the group propagate and generate on
    each 4-bit adder.
*/

module cla_16(
    input [15:0] a,
    input [15:0] b,
    input c_in,
    output [15:0] out,
    output c_out,
    output p_out,
    output g_out
    );
    
    wire[3:0] carry, p, g;
    assign carry[0] = c_in;
    
    generate
        genvar i;
        for(i = 0; i < 4; i = i + 1) begin        
            cla_4 i_cla_4x4 (
                .a(a[4*i+3 : 4*i]),
                .b(b[4*i+3 : 4*i]),
                .c_in(carry[i]),
                .out(out[4*i+3 : 4*i]),
                .c_out(/*carry is done by group p & g*/),
                .p_out(p[i]),
                .g_out(g[i])
            );
        end
    endgenerate
    
    c_gen_4 i_carry_gen_16 (
        .p(p[3:0]),
        .g(g[3:0]),
        .c_in(c_in),
        .c_out({c_out, carry[3:1]})
    );
    
    assign p_out = &p[3:0];
    assign g_out = g[3] |
                  (p[3] & g[2]) |
                  (p[3] & p[2] & g[1]) |
                  (p[3] & p[2] & p[1] & g[0]);
                  
endmodule
