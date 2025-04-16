`timescale 1ns / 1ps

module alu_control
#(
    parameter NB_OP_FIELD       = 6,
    parameter NB_ALU_OP_FIELD   = 3
)
(
    input  wire [NB_ALU_OP_FIELD    -1 : 0] i_alu_operation ,
    input  wire [NB_OP_FIELD        -1 : 0] i_alu_function  ,
    output wire [NB_OP_FIELD        -1 : 0] o_alu_opcode
);

    // Control ALU opcodes
    localparam EXECUTION_ALU_OP_ADD      = 3'b000;
    localparam EXECUTION_ALU_OP_AND      = 3'b100;
    localparam EXECUTION_ALU_OP_OR       = 3'b101;
    localparam EXECUTION_ALU_OP_XOR      = 3'b110;
    localparam EXECUTION_ALU_OP_SHIFTLUI = 3'b111;
    localparam EXECUTION_ALU_OP_SLTI     = 3'b010;

    // ALU opcodes
    localparam ALU_OPCODE_ADD      = 6'b110001;
    localparam ALU_OPCODE_AND      = 6'b100100;
    localparam ALU_OPCODE_OR       = 6'b100101;
    localparam ALU_OPCODE_XOR      = 6'b100110;
    localparam ALU_OPCODE_SHIFTLUI = 6'b101011;
    localparam ALU_OPCODE_SLT      = 6'b101010;

    reg [NB_OP_FIELD -1 : 0] alu_opcode;

    // --------------------------------------------------
    // Main logic block
    // --------------------------------------------------
    always @(*) begin
        case (i_alu_operation)
            EXECUTION_ALU_OP_ADD      : alu_opcode = ALU_OPCODE_ADD;
            EXECUTION_ALU_OP_AND      : alu_opcode = ALU_OPCODE_AND;
            EXECUTION_ALU_OP_OR       : alu_opcode = ALU_OPCODE_OR;
            EXECUTION_ALU_OP_XOR      : alu_opcode = ALU_OPCODE_XOR;
            EXECUTION_ALU_OP_SHIFTLUI : alu_opcode = ALU_OPCODE_SHIFTLUI;
            EXECUTION_ALU_OP_SLTI     : alu_opcode = ALU_OPCODE_SLT;
            default                   : alu_opcode = i_alu_function;
        endcase
    end

    // --------------------------------------------------
    // Output assignments
    // --------------------------------------------------
    assign o_alu_opcode = alu_opcode;

endmodule
