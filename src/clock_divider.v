`timescale 1ns / 1ps

module clock_divider
#(
    parameter DIVIDER    = 2, // Debe ser un número par para asegurar el 50% duty cycle
    parameter NB_COUNTER = 1
)
(
    output wire             o_clock_div,
    input  wire             i_clock    ,
    input  wire             i_reset
);

    reg [NB_COUNTER -1 : 0] counter        = {NB_COUNTER{1'b0}};
    reg                     internal_clock = 1'b0              ;

    // --------------------------------------------------
    // Clock divider main block
    // --------------------------------------------------
    always @(posedge i_clock) begin
        if (i_reset) begin
            counter        <= {NB_COUNTER{1'b0}};
            internal_clock <= 1'b0              ;
        end
        else begin
            if (counter == (DIVIDER / 2) - 1) begin
                internal_clock <= ~internal_clock   ;
                counter        <= {NB_COUNTER{1'b0}};
            end
            else begin
                counter <= counter + {{NB_COUNTER-1{1'b0}}, 1'b1};
            end
        end
    end

    // --------------------------------------------------
    // Output clock
    // --------------------------------------------------
    assign o_clock_div = internal_clock;

endmodule
