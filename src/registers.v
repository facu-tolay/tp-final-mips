`timescale 1ns/1ps

module registers
#(
    parameter NB_DATA           = 32,
    parameter N_REGISTERS       = 32,
    parameter NB_REG_ADDRESS    = 5
)
(
    output wire [NB_DATA        -1 : 0] o_read_reg_data_a       ,
    output wire [NB_DATA        -1 : 0] o_read_reg_data_b       ,

    input  wire [NB_REG_ADDRESS -1 : 0] i_read_reg_address_a    ,
    input  wire [NB_REG_ADDRESS -1 : 0] i_read_reg_address_b    ,
    input  wire [NB_DATA        -1 : 0] i_write_reg_data        ,
    input  wire [NB_REG_ADDRESS -1 : 0] i_write_reg_address     ,
    input  wire                         i_write_reg_enable      ,

    input  wire [NB_REG_ADDRESS -1 : 0] i_read_reg_address_debug,
    output wire [NB_DATA        -1 : 0] o_read_reg_data_debug   ,

    input  wire                         i_reset                 ,
    input  wire                         i_clock
);

    reg [NB_DATA    -1 : 0] registers_memory [N_REGISTERS-1 : 0];
    reg [NB_DATA    -1 : 0] read_reg_a;
    reg [NB_DATA    -1 : 0] read_reg_b;
    reg [NB_DATA    -1 : 0] read_reg_debug;
    integer                 i;

    // --------------------------------------------------
    // Write registers block
    // --------------------------------------------------
    always @ (posedge i_clock) begin
        if (i_reset) begin
            for (i=0; i<N_REGISTERS; i=i+1) begin
                registers_memory[i] <= 32'h0;
            end
        end
        else if (i_write_reg_enable) begin
            if(i_write_reg_address != 5'h0) begin // avoids writing on R0
                registers_memory[i_write_reg_address] <= i_write_reg_data;
            end
        end
    end

    // --------------------------------------------------
    // Read registers block
    // --------------------------------------------------
    always @ (negedge i_clock) begin
        read_reg_a     <= registers_memory[i_read_reg_address_a    ];
        read_reg_b     <= registers_memory[i_read_reg_address_b    ];
        read_reg_debug <= registers_memory[i_read_reg_address_debug];
    end

    // --------------------------------------------------
    // Output assignments
    // --------------------------------------------------
    assign o_read_reg_data_a     = read_reg_a;
    assign o_read_reg_data_b     = read_reg_b;
    assign o_read_reg_data_debug = read_reg_debug;

endmodule