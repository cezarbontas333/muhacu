`timescale 1ns / 1ps
/*
    Multiplicator using Baugh-Wooley scheme for tree reduction of
    partial sums. For this, a carry-save adder scheme is used for 
    reducing each partial sum, 
*/

module mult_bw_16x16(
    input [15:0] a,
    input [15:0] x,
    output [31:0] y,
    output c_out
    );
    
    /*
        Generate parital sums. For the first and last sum, an extra bit
        will need to be taken into account when bit reduction is done.
    */
    wire[15:0] partial [0:15];
    assign partial[0] = a & {16{x[0]}};
    generate
        genvar i;
        for (i = 1; i < 15; i = i + 1) begin
            assign partial[i] = {a[15] & ~x[i], a[14:0] & {15{x[i]}}};
        end
    endgenerate
    assign partial[15] = {a[15] & x[15], a[14:0] & {15{~x[15]}}};
    
    // Final results can be composed paritally before last addition.
    wire[31:0] final_sums [0:1];
    assign final_sums[0][1:0] = partial[0][1:0];
    assign final_sums[1][1] = partial[1][1];
    /*
        Baugh-Wooley reduction tree. For the first stage, additional 
        1s are added on the first and last partial sums.
        Partial stages will be declared as wires of length of the final 
        result. This is because the compiler should make the optimizations 
        necessary to remove unconnected wires in synthesis and because
        it makes it easier to track the connections on each reduction
        stage.
        STAGE 1
    */
    wire[31:0] partial_stage1 [0:7];
    wire[31:0] carry_stage1 [0:7] /*verilator split_var*/; 
    pc_3x2 i_pc_st1_col2 (
        .in_col({partial[0][2], partial[1][1], partial[2][0]}),
        .out(final_sums[0][2]),
        .out_carry(partial_stage1[1][3])
    );
    
    pc_3x2 i_pc_st1_col3 (
        .in_col({partial[0][3], partial[1][2], partial[2][1]}),
        .out(partial_stage1[0][3]),
        .out_carry(partial_stage1[1][4])
    );
    
    pc_3x2 i_pc_st1_col4 (
        .in_col({partial[0][4], partial[1][3], partial[2][2]}),
        .out(partial_stage1[0][4]),
        .out_carry(carry_stage1[1][4])
    );
    
    // Half adders move one of the bits to the next order.
    assign {carry_stage1[1][5], partial_stage1[2][4]} = partial[3][1] + partial[4][0];
    
    pc_6x4 i_pc_st1_col5 (
        .in_col({partial[0][5], partial[1][4], partial[2][3], partial[3][2], partial[4][1], partial[5][0]}),
        .in_carry({carry_stage1[1][4], carry_stage1[1][5], 1'b0}),
        .out(final_sums[0][5]),
        .out_carry({carry_stage1[0][6], carry_stage1[1][6], carry_stage1[2][6], partial_stage1[1][6]})
    );
    
    pc_6x4 i_pc_st1_col6 (
        .in_col({partial[0][6], partial[1][5], partial[2][4], partial[3][3], partial[4][2], partial[5][1]}),
        .in_carry({carry_stage1[0][6], carry_stage1[1][6], carry_stage1[2][6]}),
        .out(partial_stage1[0][6]),
        .out_carry({carry_stage1[0][7], carry_stage1[1][7], carry_stage1[2][7], partial_stage1[1][7]})
    );
    
    pc_6x4 i_pc_st1_col7 (
        .in_col({partial[0][7], partial[1][6], partial[2][5], partial[3][4], partial[4][3], partial[5][2]}),
        .in_carry({carry_stage1[0][7], carry_stage1[1][7], carry_stage1[2][7]}),
        .out(partial_stage1[0][7]),
        .out_carry({carry_stage1[0][8], carry_stage1[1][8], carry_stage1[2][8], partial_stage1[1][8]})
    );
    
    pc_6x4 i_pc_st1_col8_1 (
        .in_col({partial[0][8], partial[1][7], partial[2][6], partial[3][5], partial[4][4], partial[5][3]}),
        .in_carry({carry_stage1[0][8], carry_stage1[1][8], carry_stage1[2][8]}),
        .out(partial_stage1[0][8]),
        .out_carry({carry_stage1[0][9], carry_stage1[1][9], carry_stage1[2][9], partial_stage1[1][9]})
    );
    
    pc_3x2 i_pc_st1_col8_2 (
        .in_col({partial[6][2], partial[7][1], partial[8][0]}),
        .out(partial_stage1[2][8]),
        .out_carry(partial_stage1[3][9])
    );
    
    pc_6x4 i_pc_st1_col9_1 (
        .in_col({partial[0][9], partial[1][8], partial[2][7], partial[3][6], partial[4][5], partial[5][4]}),
        .in_carry({carry_stage1[0][9], carry_stage1[1][9], carry_stage1[2][9]}),
        .out(partial_stage1[0][9]),
        .out_carry({carry_stage1[0][10], carry_stage1[1][10], carry_stage1[2][10], carry_stage1[3][10]})
    );
    
    pc_3x2 i_pc_st1_col9_2 (
        .in_col({partial[6][3], partial[7][2], partial[8][1]}),
        .out(partial_stage1[2][9]),
        .out_carry(carry_stage1[4][10])
    );

    pc_11x9 i_pc_st1_col10 (
        .in_col({partial[0][10], partial[1][9], partial[2][8], partial[3][7], partial[4][6], partial[5][5], partial[6][4], partial[7][3], partial[8][2], partial[9][1], partial[10][0]}),
        .in_carry({carry_stage1[0][10], carry_stage1[1][10], carry_stage1[2][10], carry_stage1[3][10], carry_stage1[4][10], 3'b000}),
        .out(partial_stage1[0][10]),
        .out_carry({carry_stage1[0][11], carry_stage1[1][11], carry_stage1[2][11], carry_stage1[3][11], carry_stage1[4][11], carry_stage1[5][11], carry_stage1[6][11], carry_stage1[7][11], partial_stage1[1][11]})
    );

    pc_11x9 i_pc_st1_col11 (
        .in_col({partial[0][11], partial[1][10], partial[2][9], partial[3][8], partial[4][7], partial[5][6], partial[6][5], partial[7][4], partial[8][3], partial[9][2], partial[10][1]}),
        .in_carry({carry_stage1[0][11], carry_stage1[1][11], carry_stage1[2][11], carry_stage1[3][11], carry_stage1[4][11], carry_stage1[5][11], carry_stage1[6][11], carry_stage1[7][11]}),
        .out(partial_stage1[0][11]),
        .out_carry({carry_stage1[0][12], carry_stage1[1][12], carry_stage1[2][12], carry_stage1[3][12], carry_stage1[4][12], carry_stage1[5][12], carry_stage1[6][12], carry_stage1[7][12], partial_stage1[1][12]})
    );

    pc_11x9 i_pc_st1_col12 (
        .in_col({partial[0][12], partial[1][11], partial[2][10], partial[3][9], partial[4][8], partial[5][7], partial[6][6], partial[7][5], partial[8][4], partial[9][3], partial[10][2]}),
        .in_carry({carry_stage1[0][12], carry_stage1[1][12], carry_stage1[2][12], carry_stage1[3][12], carry_stage1[4][12], carry_stage1[5][12], carry_stage1[6][12], carry_stage1[7][12]}),
        .out(partial_stage1[0][12]),
        .out_carry({carry_stage1[0][13], carry_stage1[1][13], carry_stage1[2][13], carry_stage1[3][13], carry_stage1[4][13], carry_stage1[5][13], carry_stage1[6][13], carry_stage1[7][13], partial_stage1[1][13]})
    );

    pc_11x9 i_pc_st1_col13_1 (
        .in_col({partial[0][13], partial[1][12], partial[2][11], partial[3][10], partial[4][9], partial[5][8], partial[6][7], partial[7][6], partial[8][5], partial[9][4], partial[10][3]}),
        .in_carry({carry_stage1[0][13], carry_stage1[1][13], carry_stage1[2][13], carry_stage1[3][13], carry_stage1[4][13], carry_stage1[5][13], carry_stage1[6][13], carry_stage1[7][13]}),
        .out(partial_stage1[0][13]),
        .out_carry({carry_stage1[0][14], carry_stage1[1][14], carry_stage1[2][14], carry_stage1[3][14], carry_stage1[4][14], carry_stage1[5][14], carry_stage1[6][14], carry_stage1[7][14], partial_stage1[1][14]})
    );

    pc_3x2 i_pc_st1_col13_2 (
        .in_col({partial[11][2], partial[12][1], partial[13][0]}),
        .out(partial_stage1[2][13]),
        .out_carry(partial_stage1[3][14])
    );

    pc_11x9 i_pc_st1_col14_1 (
        .in_col({partial[0][14], partial[1][13], partial[2][12], partial[3][11], partial[4][10], partial[5][9], partial[6][8], partial[7][7], partial[8][6], partial[9][5], partial[10][4]}),
        .in_carry({carry_stage1[0][14], carry_stage1[1][14], carry_stage1[2][14], carry_stage1[3][14], carry_stage1[4][14], carry_stage1[5][14], carry_stage1[6][14], carry_stage1[7][14]}),
        .out(partial_stage1[0][14]),
        .out_carry({carry_stage1[0][15], carry_stage1[1][15], carry_stage1[2][15], carry_stage1[3][15], carry_stage1[4][15], carry_stage1[5][15], carry_stage1[6][15], carry_stage1[7][15], partial_stage1[1][15]})
    );

    pc_3x2 i_pc_st1_col14_2 (
        .in_col({partial[11][3], partial[12][2], partial[13][1]}),
        .out(partial_stage1[2][14]),
        .out_carry(partial_stage1[3][15])
    );

    pc_11x9 i_pc_st1_col15_1 (
        .in_col({partial[0][15], partial[1][14], partial[2][13], partial[3][12], partial[4][11], partial[5][10], partial[6][9], partial[7][8], partial[8][7], partial[9][6], partial[10][5]}),
        .in_carry({carry_stage1[0][15], carry_stage1[1][15], carry_stage1[2][15], carry_stage1[3][15], carry_stage1[4][15], carry_stage1[5][15], carry_stage1[6][15], carry_stage1[7][15]}),
        .out(partial_stage1[0][15]),
        .out_carry({carry_stage1[0][16], carry_stage1[1][16], carry_stage1[2][16], carry_stage1[3][16], carry_stage1[4][16], carry_stage1[5][16], carry_stage1[6][16], carry_stage1[7][16], partial_stage1[1][16]})
    );

    pc_3x2 i_pc_st1_col15_2 (
        .in_col({partial[11][4], partial[12][3], partial[13][2]}),
        .out(partial_stage1[2][15]),
        .out_carry(partial_stage1[3][16])
    );

    // Completed with 1 bit for the Baugh-Wooley scheme.
    pc_11x9 i_pc_st1_col16_1 (
        .in_col({1'b1, partial[1][15], partial[2][14], partial[3][13], partial[4][12], partial[5][11], partial[6][10], partial[7][9], partial[8][8], partial[9][7], partial[10][6]}),
        .in_carry({carry_stage1[0][16], carry_stage1[1][16], carry_stage1[2][16], carry_stage1[3][16], carry_stage1[4][16], carry_stage1[5][16], carry_stage1[6][16], carry_stage1[7][16]}),
        .out(partial_stage1[0][16]),
        .out_carry({carry_stage1[0][17], carry_stage1[1][17], carry_stage1[2][17], carry_stage1[3][17], carry_stage1[4][17], carry_stage1[5][17], carry_stage1[6][17], carry_stage1[7][17], partial_stage1[1][17]})
    );

    pc_3x2 i_pc_st1_col16_2 (
        .in_col({partial[11][5], partial[12][4], partial[13][3]}),
        .out(partial_stage1[2][16]),
        .out_carry(partial_stage1[3][17])
    );

    pc_11x9 i_pc_st1_col17_1 (
        .in_col({partial[2][15], partial[3][14], partial[4][13], partial[5][12], partial[6][11], partial[7][10], partial[8][9], partial[9][8], partial[10][7], partial[11][6], partial[12][5]}),
        .in_carry({carry_stage1[0][17], carry_stage1[1][17], carry_stage1[2][17], carry_stage1[3][17], carry_stage1[4][17], carry_stage1[5][17], carry_stage1[6][17], carry_stage1[7][17]}),
        .out(partial_stage1[0][17]),
        .out_carry({carry_stage1[0][18], carry_stage1[1][18], carry_stage1[2][18], carry_stage1[3][18], carry_stage1[4][18], carry_stage1[5][18], carry_stage1[6][18], carry_stage1[7][18], partial_stage1[1][18]})
    );

    pc_3x2 i_pc_st1_col17_2 (
        .in_col({partial[13][4], partial[14][3], partial[15][2]}),
        .out(partial_stage1[2][17]),
        .out_carry(partial_stage1[2][18])
    );

    pc_11x9 i_pc_st1_col18 (
        .in_col({partial[3][15], partial[4][14], partial[5][13], partial[6][12], partial[7][11], partial[8][10], partial[9][9], partial[10][8], partial[11][7], partial[12][6], partial[13][5]}),
        .in_carry({carry_stage1[0][18], carry_stage1[1][18], carry_stage1[2][18], carry_stage1[3][18], carry_stage1[4][18], carry_stage1[5][18], carry_stage1[6][18], carry_stage1[7][18]}),
        .out(partial_stage1[0][18]),
        .out_carry({carry_stage1[0][19], carry_stage1[1][19], carry_stage1[2][19], carry_stage1[3][19], carry_stage1[4][19], carry_stage1[5][19], carry_stage1[6][19], carry_stage1[7][19], partial_stage1[1][19]})
    );

    pc_11x9 i_pc_st1_col19 (
        .in_col({partial[4][15], partial[5][14], partial[6][13], partial[7][12], partial[8][11], partial[9][10], partial[10][9], partial[11][8], partial[12][7], partial[13][6], partial[14][5]}),
        .in_carry({carry_stage1[0][19], carry_stage1[1][19], carry_stage1[2][19], carry_stage1[3][19], carry_stage1[4][19], carry_stage1[5][19], carry_stage1[6][19], carry_stage1[7][19]}),
        .out(partial_stage1[0][19]),
        .out_carry({carry_stage1[0][20], carry_stage1[1][20], carry_stage1[2][20], partial_stage1[3][20], partial_stage1[4][20], partial_stage1[5][20], partial_stage1[6][20], partial_stage1[7][20], partial_stage1[1][20]})
    );

    pc_6x4 i_pc_st1_col20_1 (
        .in_col({partial[5][15], partial[6][14], partial[7][13], partial[8][12], partial[9][11], partial[10][10]}),
        .in_carry({carry_stage1[0][20], carry_stage1[1][20], carry_stage1[2][20]}),
        .out(partial_stage1[0][20]),
        .out_carry({carry_stage1[0][21], carry_stage1[1][21], carry_stage1[2][21], partial_stage1[1][21]})
    );

    pc_3x2 i_pc_st1_col20_2 (
        .in_col({partial[11][9], partial[12][8], partial[13][7]}),
        .out(partial_stage1[2][20]),
        .out_carry(partial_stage1[2][21])
    );

    pc_6x4 i_pc_st1_col21_1 (
        .in_col({partial[6][15], partial[7][14], partial[8][13], partial[9][12], partial[10][11], partial[11][10]}),
        .in_carry({carry_stage1[0][21], carry_stage1[1][21], carry_stage1[2][21]}),
        .out(partial_stage1[0][21]),
        .out_carry({carry_stage1[0][22], carry_stage1[1][22], carry_stage1[2][22], partial_stage1[1][22]})
    );

    pc_3x2 i_pc_st1_col21_2 (
        .in_col({partial[12][9], partial[13][8], partial[14][7]}),
        .out(partial_stage1[3][21]),
        .out_carry(partial_stage1[3][22])
    );

    pc_6x4 i_pc_st1_col22_1 (
        .in_col({partial[7][15], partial[8][14], partial[9][13], partial[10][12], partial[11][11], partial[12][10]}),
        .in_carry({carry_stage1[0][22], carry_stage1[1][22], carry_stage1[2][22]}),
        .out(partial_stage1[0][22]),
        .out_carry({carry_stage1[0][23], carry_stage1[1][23], carry_stage1[2][23], partial_stage1[1][23]})
    );

    pc_3x2 i_pc_st1_col22_2 (
        .in_col({partial[13][9], partial[14][8], partial[15][7]}),
        .out(partial_stage1[2][22]),
        .out_carry(partial_stage1[2][23])
    );

    pc_6x4 i_pc_st1_col23 (
        .in_col({partial[8][15], partial[9][14], partial[10][13], partial[11][12], partial[12][11], partial[13][10]}),
        .in_carry({carry_stage1[0][23], carry_stage1[1][23], carry_stage1[2][23]}),
        .out(partial_stage1[0][23]),
        .out_carry({carry_stage1[0][24], carry_stage1[1][24], carry_stage1[2][24], partial_stage1[1][24]})
    );

    pc_6x4 i_pc_st1_col24 (
        .in_col({partial[9][15], partial[10][14], partial[11][13], partial[12][12], partial[13][11], partial[14][10]}),
        .in_carry({carry_stage1[0][24], carry_stage1[1][24], carry_stage1[2][24]}),
        .out(partial_stage1[0][24]),
        .out_carry({carry_stage1[0][25], carry_stage1[1][25], carry_stage1[2][25], partial_stage1[1][25]})
    );

    pc_6x4 i_pc_st1_col25 (
        .in_col({partial[10][15], partial[11][14], partial[12][13], partial[13][12], partial[14][11], partial[15][10]}),
        .in_carry({carry_stage1[0][25], carry_stage1[1][25], carry_stage1[2][25]}),
        .out(partial_stage1[0][25]),
        .out_carry({partial_stage1[1][26], partial_stage1[2][26], partial_stage1[3][26], partial_stage1[4][26]})
    );

    pc_3x2 i_pc_st1_col26 (
        .in_col({partial[11][15], partial[12][14], partial[13][13]}),
        .out(partial_stage1[0][26]),
        .out_carry(partial_stage1[1][27])
    );

    pc_3x2 i_pc_st1_col27 (
        .in_col({partial[12][15], partial[13][14], partial[14][13]}),
        .out(partial_stage1[0][27]),
        .out_carry(partial_stage1[1][28])
    );

    pc_3x2 i_pc_st1_col28 (
        .in_col({partial[13][15], partial[14][14], partial[15][13]}),
        .out(partial_stage1[0][28]),
        .out_carry(partial_stage1[1][29])
    );

    /*
        The rest of the bits which are not propagated using parallel counters will be
        used in stage 2 of the reduction tree. This approach is borrowed from Dadda trees,
        since these bits can be used later in bigger parallel counters, thus reducing the 
        initial resource usage.

        MSB from the last partial product is completed with 1, which can be directly
        added to the final sum since it won't be propagated.
    */
    assign final_sums[0][31] = 1'b1;

    // STAGE 2
    wire[31:0] partial_stage2 [0:6];
    wire[31:0] carry_stage2 [0:3] /*verilator split_var*/;

    pc_3x2 i_pc_st2_col3 (
        .in_col({partial_stage1[0][3], partial_stage1[1][3], partial[3][0]}),
        .out(final_sums[0][3]),
        .out_carry(final_sums[1][4])
    );

    pc_3x2 i_pc_st2_col4 (
        .in_col({partial_stage1[0][4], partial_stage1[1][4], partial_stage1[2][4]}),
        .out(final_sums[0][4]),
        .out_carry(final_sums[1][5])
    );

    pc_3x2 i_pc_st2_col6 (
        .in_col({partial_stage1[0][6], partial_stage1[1][6], partial[6][0]}),
        .out(final_sums[0][6]),
        .out_carry(partial_stage2[1][7])
    );

    pc_3x2 i_pc_st2_col7 (
        .in_col({partial_stage1[0][7], partial_stage1[1][7], partial[6][1]}),
        .out(partial_stage2[0][7]),
        .out_carry(partial_stage2[1][8])
    );

    pc_3x2 i_pc_st2_col8 (
        .in_col({partial_stage1[0][8], partial_stage1[1][8], partial_stage1[2][8]}),
        .out(partial_stage2[0][8]),
        .out_carry(partial_stage2[1][9])
    );

    pc_3x2 i_pc_st2_col9 (
        .in_col({partial_stage1[0][9], partial_stage1[1][9], partial_stage1[2][9]}),
        .out(partial_stage2[0][9]),
        .out_carry(partial_stage2[1][10])
    );

    assign {partial_stage2[2][10], partial_stage2[2][9]} = partial_stage1[3][9] + partial[9][0];

    pc_3x2 i_pc_st2_col11 (
        .in_col({partial_stage1[0][11], partial_stage1[1][11], partial[11][0]}),
        .out(final_sums[0][11]),
        .out_carry(partial_stage2[1][12])
    );

    pc_3x2 i_pc_st2_col12 (
        .in_col({partial_stage1[0][12], partial_stage1[1][12], partial[11][1]}),
        .out(partial_stage2[0][12]),
        .out_carry(partial_stage2[1][13])
    );

    pc_3x2 i_pc_st2_col13 (
        .in_col({partial_stage1[0][13], partial_stage1[1][13], partial_stage1[2][13]}),
        .out(partial_stage2[0][13]),
        .out_carry(partial_stage2[1][14])
    );

    pc_3x2 i_pc_st2_col14 (
        .in_col({partial_stage1[0][14], partial_stage1[1][14], partial_stage1[2][14]}),
        .out(partial_stage2[0][14]),
        .out_carry(carry_stage2[1][15])
    );

    assign {carry_stage2[2][15], partial_stage2[2][14]} = partial_stage1[3][14] + partial[14][0];

    pc_6x4 i_pc_st2_col15 (
        .in_col({partial_stage1[0][15], partial_stage1[1][15], partial_stage1[2][15], partial_stage1[3][15], partial[14][1], partial[15][0]}), 
        .in_carry({carry_stage2[1][15], carry_stage2[2][15], 1'b0}),
        .out(final_sums[0][15]),
        .out_carry({carry_stage2[1][16], carry_stage2[2][16], carry_stage2[3][16], final_sums[1][16]})
    );

    pc_6x4 i_pc_st2_col16 (
        .in_col({partial_stage1[0][16], partial_stage1[1][16], partial_stage1[2][16], partial_stage1[3][16], partial[14][2], partial[15][1]}), 
        .in_carry({carry_stage2[1][16], carry_stage2[2][16], carry_stage2[3][16]}),
        .out(final_sums[0][16]),
        .out_carry({partial_stage2[1][17], partial_stage2[2][17], partial_stage2[3][17], partial_stage2[4][17]})
    ); 

    pc_3x2 i_pc_st2_col17 (
        .in_col({partial_stage1[0][17], partial_stage1[1][17], partial_stage1[2][17]}),
        .out(partial_stage2[0][17]),
        .out_carry(partial_stage2[1][18])
    );

    pc_3x2 i_pc_st2_col18 (
        .in_col({partial_stage1[0][18], partial_stage1[1][18], partial_stage1[2][18]}),
        .out(partial_stage2[0][18]),
        .out_carry(partial_stage2[1][19])
    );

    assign {partial_stage2[2][19], partial_stage2[1][18]} = partial[14][4] + partial[15][3];

    pc_6x4 i_pc_st2_col20_1 (
        .in_col({partial_stage1[0][20], partial_stage1[1][20], partial_stage1[2][20], partial_stage1[3][20], partial_stage1[4][20], partial_stage1[5][20]}),
        .in_carry(3'b000),
        .out(partial_stage2[0][20]),
        .out_carry({partial_stage2[1][21], partial_stage2[2][21], partial_stage2[3][21], partial_stage2[4][21]})
    );

    pc_3x2 i_pc_st2_col20_2 (
        .in_col({partial_stage1[6][20], partial_stage1[7][20], partial[14][6]}),
        .out(partial_stage2[1][20]),
        .out_carry(partial_stage2[5][21])
    );

    pc_3x2 i_pc_st2_col21 (
        .in_col({partial_stage1[0][21], partial_stage1[1][21], partial_stage1[2][21]}),
        .out(partial_stage2[0][21]),
        .out_carry(partial_stage2[1][22])
    );

    assign {partial_stage2[2][22], partial_stage2[6][21]} = partial_stage1[3][21] + partial[15][6];

    pc_3x2 i_pc_st2_col22 (
        .in_col({partial_stage1[1][22], partial_stage1[2][22], partial_stage1[3][22]}),
        .out(partial_stage2[0][22]),
        .out_carry(partial_stage2[1][23])
    );

    pc_3x2 i_pc_st2_col23 (
        .in_col({partial[14][9], partial[15][8], partial_stage1[0][23]}),
        .out(partial_stage2[0][23]),
        .out_carry(partial_stage2[1][24])
    );

    pc_3x2 i_pc_st2_col24 (
        .in_col({partial_stage1[0][24], partial_stage1[1][24], partial[15][9]}),
        .out(partial_stage2[0][24]),
        .out_carry(partial_stage2[1][25])
    );

    pc_6x4 i_pc_st2_col26 (
        .in_col({partial_stage1[0][26], partial_stage1[1][26], partial_stage1[2][26], partial_stage1[3][26], partial_stage1[4][26], partial_stage1[5][26]}),
        .in_carry(3'b000),
        .out(partial_stage2[0][26]),
        .out_carry({partial_stage2[1][27], partial_stage2[2][27], partial_stage2[3][27], partial_stage2[4][27]})
    );

    pc_3x2 i_pc_st2_col27 (
        .in_col({partial_stage1[0][27], partial_stage1[1][27], partial[15][12]}),
        .out(partial_stage2[0][27]),
        .out_carry(partial_stage2[1][28])
    );

    pc_3x2 i_pc_st2_col29 (
        .in_col({partial_stage1[1][29], partial[14][15], partial[15][14]}),
        .out(partial_stage2[0][29]),
        .out_carry(partial_stage2[1][30])
    );

    // STAGE 3
    wire[31:0] partial_stage3 [0:6];
    // Not needing carry_stage intermediate variables since only full adders will be used.

    pc_3x2 i_pc_st3_col7 (
        .in_col({partial_stage2[0][7], partial_stage2[1][7], partial[7][0]}),
        .out(final_sums[0][7]),
        .out_carry(final_sums[1][8])
    );

    assign {final_sums[1][9], final_sums[0][8]} = partial_stage2[0][8] + partial_stage2[1][8];

    pc_3x2 i_pc_st3_col9 (
        .in_col({partial_stage2[0][9], partial_stage2[1][9], partial_stage2[2][9]}),
        .out(final_sums[0][9]),
        .out_carry(final_sums[1][10])
    );

    pc_3x2 i_pc_st3_col10 (
        .in_col({partial_stage1[0][10], partial_stage2[1][10], partial_stage2[2][10]}),
        .out(final_sums[0][10]),
        .out_carry(final_sums[1][11])
    );

    pc_3x2 i_pc_st3_col12 (
        .in_col({partial_stage2[0][12], partial_stage2[1][12], partial[12][0]}),
        .out(final_sums[0][12]),
        .out_carry(final_sums[1][13])
    );

    assign {final_sums[1][14], final_sums[0][13]} = partial_stage2[0][13] + partial_stage2[1][13];

    pc_3x2 i_pc_st3_col14 (
        .in_col({partial_stage2[0][14], partial_stage2[1][14], partial_stage2[2][14]}),
        .out(final_sums[0][14]),
        .out_carry(final_sums[1][15])
    );

    pc_3x2 i_pc_st3_col17_1 (
        .in_col({partial_stage2[0][17], partial_stage2[1][17], partial_stage2[2][17]}),
        .out(final_sums[0][17]),
        .out_carry(partial_stage3[1][18])
    );

    pc_3x2 i_pc_st3_col17_2 (
        .in_col({partial_stage2[3][17], partial_stage2[4][17], partial_stage1[3][17]}),
        .out(final_sums[1][17]),
        .out_carry(partial_stage3[2][18])
    );

    pc_3x2 i_pc_st3_col18 (
        .in_col({partial_stage2[0][18], partial_stage2[1][18], partial_stage2[2][18]}),
        .out(partial_stage3[0][18]),
        .out_carry(partial_stage3[1][19])
    );

    pc_3x2 i_pc_st3_col19 (
        .in_col({partial_stage1[1][19], partial_stage1[0][19], partial_stage2[2][19]}),
        .out(partial_stage3[0][19]),
        .out_carry(partial_stage3[1][20])
    );

    pc_3x2 i_pc_st3_col20 (
        .in_col({partial_stage2[0][20], partial_stage2[1][20], partial[15][5]}),
        .out(partial_stage3[0][20]),
        .out_carry(partial_stage3[1][21])
    );

    pc_3x2 i_pc_st3_col21_1 (
        .in_col({partial_stage2[0][21], partial_stage2[1][21], partial_stage2[2][21]}),
        .out(partial_stage3[0][21]),
        .out_carry(partial_stage3[1][22])
    );

    pc_3x2 i_pc_st3_col21_2 (
        .in_col({partial_stage2[3][21], partial_stage2[4][21], partial_stage2[5][21]}),
        .out(partial_stage3[2][21]),
        .out_carry(partial_stage3[3][22])
    );

    pc_3x2 i_pc_st3_col22 (
        .in_col({partial_stage2[0][22], partial_stage2[1][22], partial_stage1[0][22]}),
        .out(partial_stage3[0][22]),
        .out_carry(partial_stage3[1][23])
    );

    pc_3x2 i_pc_st3_col23 (
        .in_col({partial_stage2[0][23], partial_stage1[1][23], partial_stage1[2][23]}),
        .out(partial_stage3[0][23]),
        .out_carry(partial_stage3[1][24])
    );

    pc_3x2 i_pc_st3_col25 (
        .in_col({partial_stage1[0][25], partial_stage1[1][25], partial_stage2[1][25]}),
        .out(partial_stage3[0][25]),
        .out_carry(partial_stage3[1][26])
    );

    pc_3x2 i_pc_st3_col27 (
        .in_col({partial_stage2[0][27], partial_stage1[1][27], partial_stage1[2][27]}),
        .out(partial_stage3[0][27]),
        .out_carry(partial_stage3[1][28])
    );

    pc_3x2 i_pc_st3_col28 (
        .in_col({partial_stage1[0][28], partial_stage1[1][28], partial_stage2[1][28]}),
        .out(partial_stage3[0][28]),
        .out_carry(partial_stage3[1][29])
    );

    // STAGE 4
    wire[31:0] partial_stage4 [0:2];

    pc_3x2 i_pc_st4_col18 (
        .in_col({partial_stage3[0][18], partial_stage3[1][18], partial_stage3[2][18]}),
        .out(final_sums[0][18]),
        .out_carry(partial_stage4[1][19])
    );

    pc_3x2 i_pc_st4_col19 (
        .in_col({partial_stage3[0][19], partial_stage3[1][19], partial[15][4]}),
        .out(partial_stage4[0][19]),
        .out_carry(partial_stage4[1][20])
    );

    assign {partial_stage4[1][21], partial_stage4[0][20]} = partial_stage3[0][20] + partial_stage3[1][20];

    pc_3x2 i_pc_st4_col21 (
        .in_col({partial_stage3[0][21], partial_stage3[1][21], partial_stage3[2][21]}),
        .out(partial_stage4[0][21]),
        .out_carry(partial_stage4[1][22])
    );

    pc_3x2 i_pc_st4_col22 (
        .in_col({partial_stage3[0][22], partial_stage3[1][22], partial_stage3[2][22]}),
        .out(partial_stage4[0][22]),
        .out_carry(partial_stage4[1][23])
    );

    pc_3x2 i_pc_st4_col23 (
        .in_col({partial_stage3[0][23], partial_stage3[1][23], partial_stage2[1][23]}),
        .out(partial_stage4[0][23]),
        .out_carry(partial_stage4[1][24])
    );

    pc_3x2 i_pc_st4_col24 (
        .in_col({partial_stage3[1][24], partial_stage2[0][24], partial_stage2[1][24]}),
        .out(partial_stage4[0][24]),
        .out_carry(partial_stage4[1][25])
    );

    pc_3x2 i_pc_st4_col26 (
        .in_col({partial_stage3[1][26], partial_stage2[0][26], partial[15][11]}),
        .out(final_sums[0][26]),
        .out_carry(final_sums[1][27])
    );

    pc_3x2 i_pc_st4_col27 (
        .in_col({partial_stage3[0][27], partial_stage2[3][27], partial_stage2[4][27]}),
        .out(final_sums[0][27]),
        .out_carry(final_sums[1][28])
    );

    assign {final_sums[1][29], final_sums[0][28]} = partial_stage3[0][28] + partial_stage3[1][28];

    assign {final_sums[1][30], final_sums[0][29]} = partial_stage3[1][29] + partial_stage2[0][29];

    assign {final_sums[1][31], final_sums[0][30]} = partial_stage2[1][30] + partial[0][15];

    // STAGE 4; no more partial products as all ranks will contain only 2 bits

    pc_3x2 i_pc_st5_col19 (
        .in_col({partial_stage4[0][19], partial_stage4[1][19], partial_stage2[1][19]}),
        .out(final_sums[0][19]),
        .out_carry(final_sums[1][20])
    );

    assign {final_sums[1][21], final_sums[0][20]} = partial_stage4[0][20] + partial_stage4[1][20];

    pc_3x2 i_pc_st5_col22 (
        .in_col({partial_stage4[0][22], partial_stage4[1][22], partial_stage3[2][22]}),
        .out(final_sums[0][22]),
        .out_carry(final_sums[1][23])
    );

    assign {final_sums[1][24], final_sums[0][23]} = partial_stage4[0][23] + partial_stage4[1][23];

    assign {final_sums[1][25], final_sums[0][24]} = partial_stage4[0][24] + partial_stage4[1][24];

    assign {final_sums[1][26], final_sums[0][25]} = partial_stage4[0][25] + partial_stage4[1][25];

    assign {final_sums[1][27], final_sums[0][26]} = partial_stage4[1][26] + partial_stage3[0][26];    

    /*
        Last stage is final sum using carry-lookahead adder. Latency
        between 16-bit groups should be smaller than tree reduction stages.
    */
    cla_ripple_adder #(
        .len(2)) i_final_add_32x32 (
        .a(final_sums[0]),
        .b(final_sums[1]),
        .c_in(1'b1),
        .out(y),
        .c_out(c_out)
    );
endmodule
