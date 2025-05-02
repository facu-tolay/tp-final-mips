`timescale 1ns / 1ps

module instruction_fetch
#(
    parameter NB_DATA                   = 32,
    parameter NB_BYTE                   = 8,
    parameter NB_INSTRUCTION_ADDRESS    = 7
)
(
    output wire [NB_DATA -1 : 0]    o_instruction               ,
    output wire [NB_DATA -1 : 0]    o_pc_value                  ,
    output wire                     o_is_end                    ,

    input  wire [NB_DATA -1 : 0]    i_next_pc                   ,
    input  wire [NB_BYTE -1 : 0]    i_load_program_byte         ,
    input  wire                     i_load_program_write_enable ,
    input  wire                     i_pc_reset                  ,
    input  wire                     i_stall                     ,
    input  wire                     i_is_jump_or_branch         ,
    input  wire                     i_reset                     ,
    input  wire                     i_clock
);

    reg [NB_DATA -1 : 0] next_pc;

    // --------------------------------------------------
    // Next PC block
    // --------------------------------------------------
    always @(posedge i_clock) begin
        if (i_reset || i_pc_reset) begin
            next_pc <= 0;
        end
        else if (i_stall) begin
            next_pc <= i_next_pc;
        end
    end

    // --------------------------------------------------
    // Instruction memory
    // --------------------------------------------------
    instruction_memory u_instruction_memory
    (
        .o_read_instruction         (o_instruction                          ),
        .o_is_program_end           (o_is_end                               ),

        .i_read_address_instruction (next_pc[NB_INSTRUCTION_ADDRESS -1 : 0] ),
        .i_is_jump_or_branch        (i_is_jump_or_branch                    ),
        .i_write_data               (i_load_program_byte                    ),
        .i_write_enable             (i_load_program_write_enable            ),
        .i_reset                    (i_reset                                ),
        .i_clock                    (i_clock                                )
    );

    assign o_pc_value = next_pc;

endmodule