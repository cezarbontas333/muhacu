`timescale 1ns / 1ps
/*
    Bit reduction balanced delay tree based on the indications provided by
    Behrooz Parhami in "Computer Arithmetic, Algorithms and Hardware Designs"
    This parallel counter takes bits on the same rank (column) and computes 
    same result and shifts the carry bits to the next rank. Chaining multiple
    PCs would result in a carry-save adder design, since the carry moves diagonally
    to the next rank instead of in chain to the last order of the same sum.
    
    This is to be used on maximum 8-bit multiplier.
*/

module pc_6x4(
    input [5:0] in_col,
    input [2:0] in_carry,
    output out,
    output [3:0] out_carry
    );
    
    wire[2:0] transport;
    /*
        When instantiating FA_ixj, i means column of FAs, 
        and j is the level on that column, which has to be correlated
        with the carry from previous column.
    */
    // COLUMN 0
    fa i_fa_0x0 (
        .a(in_col[0]),
        .b(in_col[1]),
        .c_in(in_col[2]),
        .out(transport[0]),
        .c_out(out_carry[0])
    );
    // COLUMN 1
    fa i_fa_1x0 (
        .a(in_col[3]),
        .b(in_col[4]),
        .c_in(in_col[5]),
        .out(transport[1]),
        .c_out(out_carry[1])
    );
    
    fa i_fa_1x1 (
        .a(transport[1]),
        .b(in_carry[0]),
        .c_in(in_carry[1]),
        .out(transport[2]),
        .c_out(out_carry[2])
    );
    
    fa i_fa_1x2 (
        .a(transport[0]),
        .b(transport[2]),
        .c_in(in_carry[2]),
        .out(out),
        .c_out(out_carry[3])
    );
    
endmodule
