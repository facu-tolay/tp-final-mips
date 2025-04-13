`timescale 1ns / 1ps

module signator // FIXME cambiar nombre
#(
    parameter NB_DATA   = 32,
    parameter NB_MASK   = 2
)
(
    output wire [NB_DATA     -1 : 0] o_dato,

    input  wire [NB_DATA     -1 : 0] i_dato,
    input  wire [NB_MASK     -1 : 0] i_mascara,
    input  wire                      i_is_unsigned
);
    reg [NB_DATA-1 : 0] reg_data_out;

    // --------------------------------------------------
    // Main signator logic
    // --------------------------------------------------
    // FIXME hacer un case
    always@(*) begin
        if(i_mascara == 2'b01 && ~i_is_unsigned) begin
            reg_data_out = (i_dato[15] == 1) ? {16'b1111111111111111        , i_dato[15:0]} : {16'b0, i_dato[15:0]};
        end
        else if(i_mascara == 2'b00 && ~i_is_unsigned) begin
            reg_data_out = (i_dato[ 7] == 1) ? {24'b111111111111111111111111, i_dato[7:0] } : {24'b0, i_dato[7:0] };
        end
        else begin
            reg_data_out = i_dato;
        end
    end

    // --------------------------------------------------
    // Output assignments
    // --------------------------------------------------
    assign o_dato = reg_data_out;

endmodule
