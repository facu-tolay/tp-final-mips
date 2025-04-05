`timescale 1ns / 1ps

module alu_control
#(
    parameter NB_OP_FIELD       = 6,
    parameter NB_ALU_OP_FIELD   = 3
)
(
    input  wire [NB_ALU_OP_FIELD    -1 : 0] i_alu_op    ,
    input  wire [NB_OP_FIELD        -1 : 0] i_func      ,
    output wire [NB_OP_FIELD        -1 : 0] o_alu_func
);

    // Control ALU opcodes
    localparam EXE_ALUOP_ADD      = 3'b000;
    localparam EXE_ALUOP_AND      = 3'b100;
    localparam EXE_ALUOP_OR       = 3'b101;
    localparam EXE_ALUOP_XOR      = 3'b110;
    localparam EXE_ALUOP_SHIFTLUI = 3'b111;
    localparam EXE_ALUOP_SLTI     = 3'b010;

    // ALU opcodes
    localparam ADD      = 6'b110001;
    localparam AND      = 6'b100100;
    localparam OR       = 6'b100101;
    localparam XOR      = 6'b100110;
    localparam SHIFTLUI = 6'b101011;
    localparam SLT      = 6'b101010;

    reg[NB_OP_FIELD-1 : 0] reg_alu_func; // FIXME si no funca es por esto

    always @(*) begin
        case (i_alu_op)
            EXE_ALUOP_ADD      : reg_alu_func = ADD;
            EXE_ALUOP_AND      : reg_alu_func = AND;
            EXE_ALUOP_OR       : reg_alu_func = OR;
            EXE_ALUOP_XOR      : reg_alu_func = XOR;
            EXE_ALUOP_SHIFTLUI : reg_alu_func = SHIFTLUI;
            EXE_ALUOP_SLTI     : reg_alu_func = SLT;
            default            : reg_alu_func = i_func;
        endcase
    end

    assign o_alu_func = reg_alu_func;

endmodule
