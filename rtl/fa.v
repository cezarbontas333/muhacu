`timescale 1ns / 1ps
/*
    Full adder used for bit reduction tree (multiplier).
    Written form as such because compiler can decide for optimizations.
*/

module fa(
    input a,
    input b,
    input c_in,
    output out,
    output c_out
    );
    
    assign {c_out, out} = a + b + c_in;
    
endmodule
