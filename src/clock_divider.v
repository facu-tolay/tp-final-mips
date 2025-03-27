`timescale 1ns / 1ps

module clock_divider
#(
    parameter NB_CLOCK = 1      // output frequency is given by f = 1/(2*(2^NB_CLOCK))
)
(
    output wire         o_clock_div,
    input  wire         i_clock,
    input  wire         i_reset
);

    reg [NB_CLOCK - 1 : 0]  count       = 0;
    reg                     clock_pulse = 1'b0;
    wire                    clock_transition;

    assign clock_transition = count == 0;

    always @(posedge i_clock) begin
        if(i_reset) begin
            count <= {NB_CLOCK{1'b0}};
        end
        else begin
            count <= count + {{NB_CLOCK-1{1'b0}}, 1'b1};
        end
    end

    always @(posedge i_clock) begin
        if(i_reset) begin
            clock_pulse <= 1'b0;
        end
        else if (clock_transition) begin
            clock_pulse <= ~clock_pulse;
        end
    end

    assign o_clock_div = clock_pulse;
endmodule