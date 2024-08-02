module alu_controller
#(
    parameter       N_BITS          = 6,
    parameter       N_BITS_CTRL     = 5
)
(
    output wire [N_BITS_CTRL    -1 : 0] o_alu_opcode    ,

    input wire  [N_BITS         -1 : 0] i_function      ,
    input wire  [N_BITS_CTRL    -3 : 0] i_alu_operation // FIXME para que no tenga el -3
);

    reg [N_BITS_CTRL-1 : 0] alu_opcode;

    always @(*) begin : get_alu_opcode_block
        case(i_alu_operation)
            2'b00: begin
                case(i_function)
                    6'b100000: alu_opcode = 5'b01101; // lb
                    6'b100001: alu_opcode = 5'b01110; // lh
                    6'b100011: alu_opcode = 5'b00010; // lw
                    6'b100100: alu_opcode = 5'b01111; // lbu
                    6'b100101: alu_opcode = 5'b10000; // lhu
                    6'b100111: alu_opcode = 5'b00011; // lwu
                    default  : alu_opcode = 5'b01101; // invalid
                endcase
            end

            2'b01: alu_opcode = 4'b0110;

            2'b10: begin
                case(i_function)
                    6'b100100: alu_opcode = 5'b00000; // and
                    6'b100101: alu_opcode = 5'b00001; // or
                    6'b001000: alu_opcode = 5'b00010; // addi
                    6'b100001: alu_opcode = 5'b00011; // addu
                    6'b100111: alu_opcode = 5'b00100; // nor
                    6'b100110: alu_opcode = 5'b00101; // xor
                    6'b000000: alu_opcode = 5'b00110; // sll
                    6'b000100: alu_opcode = 5'b10010; // sllv
                    6'b100010: alu_opcode = 5'b00111; // sub
                    6'b100011: alu_opcode = 5'b01000; // subu
                    6'b101010: alu_opcode = 5'b01001; // slt
                    6'b000010: alu_opcode = 5'b01010; // srl
                    6'b000110: alu_opcode = 5'b10011; // srlv
                    6'b000011: alu_opcode = 5'b01011; // sra
                    6'b000111: alu_opcode = 5'b010001; // srav // FIXME
                    6'b001111: alu_opcode = 5'b01100; // LUI
                    default:   alu_opcode = 5'b01101; // invalid
                endcase
            end

            default: alu_opcode = 5'b1011; // invalid
        endcase
    end

    // --------------------------------------------------
    // Output assignments
    // --------------------------------------------------
    assign o_alu_opcode = alu_opcode;
endmodule