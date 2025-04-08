`timescale 1ns / 1ps

module sign_extender
#(
    parameter NB_DATA   = 32,
    parameter NB_WORD   = 16
)
(
    input  [NB_WORD     -1 : 0] data_in ,
    output [NB_DATA     -1 : 0] data_out
);

    wire is_number_negative;

    // --------------------------------------------------
    // Output logic
    // --------------------------------------------------
    assign is_number_negative = data_in[NB_WORD-1] == 1;
    assign data_out           = is_number_negative ? {16'b1111111111111111, data_in} : {16'b0000000000000000, data_in};

endmodule