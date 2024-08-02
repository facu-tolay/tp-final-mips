`timescale 1ns / 1ps

module alu
#(
    parameter       NB_DATA         = 32,
    parameter       N_BITS_CONTROL  = 5
)
(
    output wire [NB_DATA        -1 : 0] o_alu_result    ,
    output wire                         o_alu_zero      ,

    input wire  [NB_DATA        -1 : 0] i_data_a        ,
    input wire  [NB_DATA        -1 : 0] i_data_b        ,
    input wire  [N_BITS_CONTROL -1 : 0] i_alu_opcode
);

    reg [NB_DATA-1 : 0] alu_result;

    always @(*) begin : alu_calculate
        case(i_alu_opcode)
            5'b00000: alu_result = i_data_a & i_data_b;                                       // and
            5'b00001: alu_result = i_data_a | i_data_b;                                       // or
            5'b00010: alu_result = i_data_a + i_data_b;                                       // suma con signo
            5'b00011: alu_result = $unsigned(i_data_a) + $unsigned(i_data_b);                 // suma sin signo
            5'b00100: alu_result = ~(i_data_a | i_data_b);                                    // nor
            5'b00101: alu_result = i_data_a ^ i_data_b;                                       // xor
            5'b00110: alu_result = i_data_a << i_data_b;                                      // sll
            5'b00111: alu_result = i_data_a - i_data_b;                                       // resta con signo - beq
            5'b01000: alu_result = $unsigned(i_data_a) - $unsigned(i_data_b);                 // resta sin signo - bne
            5'b01001: alu_result = i_data_a < i_data_b;                                       // slt
            5'b01010: alu_result = i_data_a >> i_data_b;                                      // SRL  (logic): inserta 0
            5'b01011: alu_result = i_data_a >>> i_data_b;                                     // SRA  (arithmetic): extiende el signo
            5'b01100: alu_result = i_data_b << 16;                                            // LUI
            5'b01101: alu_result = (i_data_a + i_data_b) & 32'h0xff;                          // carga un byte (signed)
            5'b01110: alu_result = (i_data_a + i_data_b) & 32'h0xffff;                        // carga media palabra (signed)
            5'b01111: alu_result = ($unsigned(i_data_a) + $unsigned(i_data_b)) & 32'h0xff;    // carga un byte (unsigned)
            5'b10000: alu_result = ($unsigned(i_data_a) + $unsigned(i_data_b)) & 32'h0xffff;  // carga media palabra (unsigned)
            5'b10001: alu_result = i_data_b >>> i_data_a;                                     // SRAV (arithmetic): extiende el signo
            5'b10010: alu_result = i_data_b << i_data_a;                                      // sllv
            5'b10011: alu_result = i_data_b >> i_data_a;                                      // SRLV  (logic): inserta 0
            default:  alu_result = {NB_DATA{1'b0}};
        endcase
    end

    // --------------------------------------------------
    // Output assignments
    // --------------------------------------------------
    assign o_alu_result   = alu_result;
    assign o_alu_zero     = alu_result == 0;
endmodule