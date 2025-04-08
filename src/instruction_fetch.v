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

    input   [NB_DATA - 1 : 0]   i_new_pc                    ,
    input   [NB_BYTE - 1 : 0]   i_byte_de_bootloader        ,
    input                       i_bootloader_write_enable   ,
    input                       i_pc_reset                  ,
    input                       i_stall                     ,
    input                       i_reset                     ,
    input                       i_clk
);

    wire [NB_DATA - 1 : 0] pc_value;

    latch
    #(
        .BUS_DATA   (NB_DATA                )
    )
    u_pc_unit
    (
        .i_valid   (i_stall                ),
        .i_data     (i_new_pc               ),
        .o_data     (pc_value               ),
        .i_reset    (i_reset || i_pc_reset  ),
        .i_clock    (i_clk                  )
    );

    // --------------------------------------------------
    // Instruction memory
    // --------------------------------------------------
    instruction_memory u_instruction_memory
    (
        .o_read_instruction         (o_instruction              ),
        .o_is_program_end           (o_is_end                   ),

        .i_read_address_instruction (pc_value                   ),
        .i_write_data               (i_byte_de_bootloader       ),
        .i_write_enable             (i_bootloader_write_enable  ),
        .i_reset                    (i_reset                    ),
        .i_clock                    (i_clk                      )
    );

    assign o_pc_value = pc_value;

endmodule