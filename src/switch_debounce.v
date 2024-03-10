
module switch_debounce
#(
    parameter DEBOUNCE_TIME_MS      = 50,
    parameter CLOCK_FREQ_HZ         = 100000000
)
(
    input wire                      i_switch        ,
    input wire                      i_clock         ,
    input wire                      i_reset         ,

    output wire                     o_signal
);

    // por ahora solo funciona en "modo pulldown"

    localparam NB_COUNT                 = 40;
    localparam N_DEBOUNCE_TIME_COUNT    = (CLOCK_FREQ_HZ/1000) * DEBOUNCE_TIME_MS;

    reg  [NB_COUNT - 1 : 0] debounce_count;
    wire [NB_COUNT - 1 : 0] next_debounce_count;

    always @(posedge i_clock) begin
        if(i_reset | ~i_switch) begin
            debounce_count <= {NB_COUNT{1'b0}};
        end
        else if(i_switch && debounce_count < N_DEBOUNCE_TIME_COUNT) begin
            debounce_count <= next_debounce_count;
        end
    end
    assign next_debounce_count = debounce_count + {{NB_COUNT-1{1'b0}}, 1'b1};

    // --------------------------------------------------
    // Output assignments
    // --------------------------------------------------
    assign o_signal     = debounce_count >= N_DEBOUNCE_TIME_COUNT;

endmodule