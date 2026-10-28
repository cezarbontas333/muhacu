`timescale 1ns / 1ps
/*
    This design uses 16-bit CLAs to create ripple-carry chains that
    create 32+ bit adders. This is because for len < 5, other operations where
    this can be used, like in Wallace multipliers, the lower order carry will be 
    computed and transfered before the higher order partial products are summed.
    
    len -> parameter which is the multiple of 16 for the terms used, NEVER 0
*/

module cla_ripple_adder #(
    parameter len = 2
    ) (
    input [16*len-1 : 0] a,
    input [16*len-1 : 0] b,
    input c_in,
    output [16*len-1 : 0] out,
    output c_out
    );
    
    wire [len : 0] carry;
    assign carry[0] = c_in;
    
    generate
        genvar i;
        for(i = 0; i < len; i = i + 1) begin
            cla_16 i_cla_16xlen (
                .a(a[i*16+15 : i*16]),
                .b(b[i*16+15 : i*16]),
                .c_in(carry[i]),
                .out(out[i*16+15 : i*16]),
                .c_out(carry[i+1]),
                // unconnected
                .p_out(),
                .g_out()
            );
        end
    endgenerate
    
    assign c_out = carry[len];
    
endmodule
