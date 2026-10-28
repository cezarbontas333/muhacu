`timescale 1ns / 1ps
/*
    Module exists should its design change for
    optimization reasons.
*/

module pc_3x2(
    input [2:0] in_col,
    output out,
    output out_carry
    );
    
    fa i_fa_0x0 (
        .a(in_col[0]),
        .b(in_col[1]),
        .c_in(in_col[2]),
        .out(out),
        .c_out(out_carry)
    );
    
endmodule
