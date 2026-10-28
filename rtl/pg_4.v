`timescale 1ns / 1ps
/*
    Propagate and generate block for 4 bit CLA.
    Limited to small fan-in as to be technology-flexible.
    Last bit of propagate and generate are useful to signal 4-bit group
    propagate and generate bits which are used in higher radix adders.
*/


module pg_4(
    input [3:0] a,
    input [3:0] b,
    output [4:0] p,
    output [4:0] g
    );
    
    // Propagate and generate used on the same level.
    assign g[3:0] = a & b;
    assign p[3:0] = a ^ b;
    // Propagate and generate used on the nigher level.
    assign p[4] = &p[3:0];
    assign g[4] = g[3] |
                  (p[3] & g[2]) |
                  (p[3] & p[2] & g[1]) |
                  (p[3] & p[2] & p[1] & g[0]);
    
endmodule
