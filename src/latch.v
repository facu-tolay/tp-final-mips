`timescale 1ns / 1ps

module latch
#(
    parameter BUS_DATA = 8
)
(
    output  [BUS_DATA - 1 : 0]  o_data      ,

    input   [BUS_DATA - 1 : 0]  i_data      ,
    input                       i_enable    , // FIXME cambiar a i_valid
    input                       i_reset     ,
    input                       i_clock
);

    reg [BUS_DATA - 1 : 0] data_d;

    always @(posedge i_clock) begin
        if (i_reset) begin
            data_d <= 0;
        end
        else if (i_enable) begin
            data_d <= i_data;
        end
    end

    assign o_data = data_d;

endmodule
