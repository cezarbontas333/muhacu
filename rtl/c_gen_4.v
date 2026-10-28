`timescale 1ns / 1ps
/*
    Reusable carry generator block for 4-bit CLA.
    Last carry is used on the next level.
*/

module c_gen_4(
    input [3:0] p,
    input [3:0] g,
    input c_in,
    output [3:0] c_out
    );
    
    assign c_out[0] = g[0] | (p[0] & c_in);
    assign c_out[1] = g[1] | (p[1] & g[0]) | (p[1] & p[0] & c_in);
    assign c_out[2] = g[2] | (p[2] & g[1]) | (p[2] & p[1] & g[0]) 
                      | (p[2] & p[1] & p[0] & c_in);
    assign c_out[3] = g[3] | (p[3] & g[2]) | (p[3] & p[2] & g[1]) 
                      | (p[3] & p[2] & p[1] & g[0]) | (p[3] & p[2] & p[1] & p[0] & c_in);
    
endmodule
