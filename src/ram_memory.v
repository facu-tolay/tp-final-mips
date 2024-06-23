`timescale 1ns / 1ps

module ram_memory
#(
    parameter NB_DATA       = 32        ,
    parameter RAM_DEPTH     = 256       ,   // RAM depth (number of entries)
    parameter NB_ADDRESS    = 8             // Address bus length (depends on RAM_DEPTH)
)
(
    output wire [NB_DATA        -1 : 0] o_data              ,

    input  wire [NB_ADDRESS     -1 : 0] i_address           ,
    input  wire [NB_DATA        -1 : 0] i_write_data        ,
    input  wire                         i_write_enable      , // cada vez que hay un flanco positivo, se comienza a escribir desde la posicion 0
    input  wire                         i_write_data_next   , // esta entrada recibe un pulso cada vez que se tiene que escribir en la proxima direccion
    input                               i_reset             ,
    input                               i_clock
);

    reg [NB_DATA    -1 : 0] memory [0 : RAM_DEPTH-1];
    reg [NB_ADDRESS -1 : 0] write_address;
    reg                     write_enable;

    // --------------------------------------------------
    // Incremental write address block
    // --------------------------------------------------
    always @(posedge i_clock) begin : wr_enable_block
        if(i_reset) begin
            write_enable <= 1'b0;
        end
        else begin
            write_enable <= i_write_enable;
        end
    end

    always @(posedge i_clock) begin : incremental_wr_addr_block
        if(i_reset || (~write_enable && i_write_enable)) begin
            write_address <= 8'h0;
        end
        else if (write_enable && i_write_data_next) begin
            write_address <= write_address + 8'h1;
        end
    end

    // --------------------------------------------------
    // Memory block
    // --------------------------------------------------
    always @(posedge i_clock) begin : wr_data_block
        if(i_reset) begin
            memory[0] <= 32'h0;
        end
        else if (write_enable && i_write_data_next) begin
            memory[write_address] <= i_write_data;
        end
    end


    // --------------------------------------------------
    // Output assignments
    // --------------------------------------------------
    assign o_data = memory[i_address];

endmodule