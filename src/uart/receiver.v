`timescale 1ns / 1ps

module receiver
#(
    parameter   NB_DATA         = 8                 ,   // DATA_STATE bits
    parameter   N_TICKS         = 16                    // ticks for STOP_STATE bits
)
(
    input wire                      i_rx            ,
    input wire                      i_signal_tick   ,
    input wire                      i_clock         ,
    input wire                      i_reset         ,

    output reg                      o_rx_done       ,
    output wire [NB_DATA   - 1 : 0] o_data
);

    localparam                      NB_STATE        = 4  ;
    localparam                      NB_BITS         = 3  ;

    localparam  [NB_STATE - 1 : 0]  IDLE_STATE  = 4'b0001;
    localparam  [NB_STATE - 1 : 0]  START_STATE = 4'b0010;
    localparam  [NB_STATE - 1 : 0]  DATA_STATE  = 4'b0100;
    localparam  [NB_STATE - 1 : 0]  STOP_STATE  = 4'b1000;

    reg [NB_STATE   - 1 : 0]        state                ;
    reg [NB_STATE   - 1 : 0]        state_next           ;
    reg [NB_STATE   - 1 : 0]        sticks               ;
    reg [NB_STATE   - 1 : 0]        sticks_next          ; //sampling ticks
    reg [NB_BITS    - 1 : 0]        nbits                ;
    reg [NB_BITS    - 1 : 0]        nbits_next           ; //number of data bits received
    reg [NB_DATA    - 1 : 0]        buffer               ;
    reg [NB_DATA    - 1 : 0]        buffer_next          ;

    // --------------------------------------------------
    // FSM block
    // --------------------------------------------------
    always @(posedge i_clock) begin
        if(i_reset) begin
            state <= IDLE_STATE;
        end
        else begin
            state <= state_next;
        end
    end

    // --------------------------------------------------
    // sTicks block
    // --------------------------------------------------
    always @(posedge i_clock) begin
        if(i_reset) begin
            sticks <= 0;
        end
        else begin
            sticks <= sticks_next;
        end
    end

    // --------------------------------------------------
    // Nbits block
    // --------------------------------------------------
    always @(posedge i_clock) begin
        if(i_reset) begin
            nbits <= 0;
        end
        else begin
            nbits <= nbits_next;
        end
    end

    // --------------------------------------------------
    // Buffer block
    // --------------------------------------------------
    always @(posedge i_clock) begin
        if(i_reset) begin
            buffer <= 0;
        end
        else begin
            buffer <= buffer_next;
        end
    end

    // --------------------------------------------------
    // FSM block
    // --------------------------------------------------
    always @(*) begin
        state_next = state;
        o_rx_done = 1'b0;
        sticks_next = sticks;
        nbits_next = nbits;
        buffer_next = buffer;

        case(state)
            IDLE_STATE:
            begin
                if(~i_rx) begin
                    state_next = START_STATE;
                    sticks_next = 0;
                end
            end

            START_STATE:
            begin
                if(i_signal_tick) begin
                    if(sticks == 7) begin
                        state_next = DATA_STATE;
                        sticks_next = 0;
                        nbits_next = 0;
                    end
                    else begin
                        sticks_next = sticks + 1'b1;
                    end
                end
            end

            DATA_STATE:
            begin
                if(i_signal_tick) begin
                    if(sticks == (N_TICKS - 1)) begin
                        sticks_next = 0;
                        buffer_next = {i_rx, buffer[NB_DATA - 1 : 1]};
                        if(nbits == (NB_DATA - 1)) begin
                            state_next = STOP_STATE;
                        end
                        else begin
                            nbits_next = nbits + 1'b1;
                        end
                    end
                    else begin
                        sticks_next = sticks + 1'b1;
                    end
                end
            end

            STOP_STATE:
            begin
                if(i_signal_tick) begin
                    if(sticks == (N_TICKS - 1)) begin
                        state_next = IDLE_STATE;
                        o_rx_done = 1'b1;
                    end
                    else begin
                        sticks_next = sticks + 1'b1;
                    end
                end
            end

            default:
            begin
                state_next = IDLE_STATE;
                sticks_next = 0;
                nbits_next = 0;
                buffer_next = 0;
            end
        endcase
    end

    // --------------------------------------------------
    // Output block
    // --------------------------------------------------
    assign o_data = buffer;

endmodule
