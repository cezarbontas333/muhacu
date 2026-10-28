`timescale 1ns / 1ps
/*
    Module can be scaled ad-nauseam, but for 16-bit multiplier
    this size is the maximum needed for bit reduction on the same column.
    This is because there would be 16 partial products, another balanced 
    delay tree would have 18 entries (unnecessary resources added).
*/

module pc_11x9(
    input [10:0] in_col,
    input [7:0] in_carry,
    output out,
    output [8:0] out_carry
    );
    
    wire[4:0] transport;
    
    // instantiate rank 0 and 1 parallel counters
    pc_6x4 i_pc_lvl_0x1 (
        .in_col(in_col[5:0]),
        .in_carry(in_carry[2:0]),
        .out(transport[0]),
        .out_carry(out_carry[3:0])
    );
    
    // COLUMN 2
    fa i_fa_2x0 (
        .a(in_col[6]),
        .b(in_col[7]),
        .c_in(in_col[8]),
        .out(transport[1]),
        .c_out(out_carry[4])
    );
    
    fa i_fa_2x1 (
        .a(in_col[9]),
        .b(transport[1]),
        .c_in(in_carry[4]),
        .out(transport[2]),
        .c_out(out_carry[5])
    );
    
    fa i_fa_2x2 (
        .a(in_col[10]),
        .b(transport[2]),
        .c_in(in_carry[5]),
        .out(transport[3]),
        .c_out(out_carry[6])
    );
    
    fa i_fa_2x3 (
        .a(transport[3]),
        .b(in_carry[3]),
        .c_in(in_carry[6]),
        .out(transport[4]),
        .c_out(out_carry[7])
    );
    
    fa i_fa_2x4 (
        .a(transport[0]),
        .b(transport[4]),
        .c_in(in_carry[7]),
        .out(out),
        .c_out(out_carry[8])
    );
    
endmodule
