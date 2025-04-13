`timescale 1ns / 1ps

module instruction_fetch
#(
    parameter   NB_DATA = 32,
    parameter   NB_BYTE = 8
)
(
    output  [NB_DATA - 1 : 0]   o_instruction               ,
    output  [NB_DATA - 1 : 0]   o_pc_value                  ,
    output                      o_is_end                    ,

    input   [NB_DATA - 1 : 0]   i_next_pc                   ,
    input   [NB_BYTE - 1 : 0]   i_load_program_byte         ,
    input                       i_load_program_write_enable ,
    input                       i_pc_reset                  ,
    input                       i_stall                     ,
    input                       i_reset                     ,
    input                       i_clock
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
        .o_read_instruction         (o_instruction              ),
        .o_is_program_end           (o_is_end                   ),

        .i_read_address_instruction (next_pc                    ),
        .i_write_data               (i_load_program_byte        ),
        .i_write_enable             (i_load_program_write_enable),
        .i_reset                    (i_reset                    ),
        .i_clock                    (i_clock                    )
    );

    assign o_pc_value = next_pc;

endmodule