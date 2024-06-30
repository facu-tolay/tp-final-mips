module branch_pc_calculator
#(
    NB_DATA     = 32
)
(
    output wire [NB_DATA    -1  : 0]    o_pc_jump           ,

    input  wire [2          -1  : 0]    i_jump              ,
    input  wire [NB_DATA    -13 : 0]    i_instruction_index ,
    input  wire [NB_DATA    -1  : 0]    i_read_data         ,
    input  wire [NB_DATA    -1  : 0]    i_pc_next
);

    reg [NB_DATA    -1 : 0] pc_jump;

    always @(*) begin : branch_pc_calculation_block
        case(i_jump)
            2'b00,
            2'b01: begin //J, JAL
                pc_jump = {i_pc_next[31:26], i_instruction_index};
            end

            2'b10,
            2'b11: begin //JALR, JR
                pc_jump = i_read_data;
            end
        endcase
    end

    // Output assignment
    assign o_pc_jump = pc_jump;
endmodule
