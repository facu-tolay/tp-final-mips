`timescale 1ns / 1ps

module baud_rate_generator
#(
    parameter   DATA_BITS   = 10        ,
    parameter   BAUD_RATE   = 9600      ,
    parameter   CLOCK_RATE  = 100000000
)
(
    input wire              i_clock     ,
    input wire              i_reset     ,

    output wire             o_clock_tick
);

    localparam NUM_TICKS        = 16;
    localparam CLOCK_RATE_TICK  = CLOCK_RATE / (BAUD_RATE * NUM_TICKS);

    reg     [DATA_BITS - 1 : 0] counter;
    wire    [DATA_BITS - 1 : 0] next_count;

    // --------------------------------------------------
    // Counter block
    // --------------------------------------------------
    assign next_count = counter < CLOCK_RATE_TICK ? counter + {{DATA_BITS-1{1'b0}}, 1'b1} : {DATA_BITS{1'b0}};

    always@(posedge i_clock) begin
        if(i_reset) begin
            counter <= {DATA_BITS{1'b0}};
        end
        else begin
            counter <= next_count;
        end
    end

    // --------------------------------------------------
    // Output tick block
    // --------------------------------------------------
    assign o_clock_tick = (counter == CLOCK_RATE_TICK);

endmodule