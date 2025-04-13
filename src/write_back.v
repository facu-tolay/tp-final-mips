`timescale 1ns / 1ps

module write_back
#(
    parameter NB_DATA           = 32,
    parameter NB_REG_ADDRESS    = 5
)
(
    output wire [NB_DATA         -1 : 0] o_data_write_back           ,
    output wire [NB_REG_ADDRESS  -1 : 0] o_address_write_back        ,

    input  wire [NB_DATA         -1 : 0] i_data_from_memory          ,
    input  wire [NB_REG_ADDRESS  -1 : 0] i_jump_return_dest_register ,
    input  wire                          i_jump_return_dest
);

    // --------------------------------------------------
    // Output assignments
    // --------------------------------------------------
    assign o_address_write_back = i_jump_return_dest ? 5'd31 : i_jump_return_dest_register;
    assign o_data_write_back    = i_data_from_memory;

endmodule
