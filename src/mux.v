`timescale 1ns / 1ps

module mux
#(
    parameter BITS_ENABLES  = 2                 ,
    parameter BUS_SIZE      = 8                 ,
    parameter NUM_SLICES    = 2**BITS_ENABLES
)
(
    input   [BITS_ENABLES        - 1 : 0] i_en      ,
    input   [NUM_SLICES*BUS_SIZE - 1 : 0] i_data    ,
    output  [BUS_SIZE            - 1 : 0] o_data
);

    assign o_data = i_data[i_en * BUS_SIZE +: BUS_SIZE];

endmodule
