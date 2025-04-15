`timescale 1ns / 1ps

module stage_transition
#(
    parameter NB_DATA = 32
)
(
    output [NB_DATA -1 : 0] o_data      ,

    input  [NB_DATA -1 : 0] i_data      ,
    input                   i_valid     ,
    input                   i_reset     ,
    input                   i_clock
);

    reg [NB_DATA -1 : 0] data_d;

    // --------------------------------------------------
    // Main block
    // --------------------------------------------------
    always @(posedge i_clock) begin
        if (i_reset) begin
            data_d <= {NB_DATA {1'b0}};
        end
        else if (i_valid) begin
            data_d <= i_data;
        end
    end

    // --------------------------------------------------
    // Output assignments
    // --------------------------------------------------
    assign o_data = data_d;

endmodule
