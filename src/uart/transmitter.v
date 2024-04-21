`timescale 1ns / 1ps

module transmitter
#(
    parameter   NB_DATA                 = 8                     , //data bits
    parameter   N_TICKS                 = 16                      //ticks for STOP_STATE bits
)
(
    input   wire  [NB_DATA   - 1 : 0]   i_tx_data                  ,
    input   wire                        i_tx_start              ,
    input   wire                        i_signal_tick           ,
    input   wire                        i_clock                 ,
    input   wire                        i_reset                 ,

    output  wire                        o_tx                    ,
    output  reg                         o_tx_done
);

    localparam                      NB_STATE        = 4         ;
    localparam                      NB_BITS         = 3         ;

    localparam  [NB_STATE - 1 : 0]  IDLE_STATE      = 4'b0001   ;
    localparam  [NB_STATE - 1 : 0]  START_STATE     = 4'b0010   ;
    localparam  [NB_STATE - 1 : 0]  DATA_STATE      = 4'b0100   ;
    localparam  [NB_STATE - 1 : 0]  STOP_STATE      = 4'b1000   ;

    reg [NB_STATE   - 1 : 0]        state                       ;
    reg [NB_STATE   - 1 : 0]        next_state                  ;

    reg [NB_STATE   - 1 : 0]        sticks                      ;
    reg [NB_STATE   - 1 : 0]        sticks_next                 ; //sampling ticks

    reg [NB_BITS    - 1 : 0]        nbits                       ;
    reg [NB_BITS    - 1 : 0]        nbits_next                  ; //number of data bits received

    reg [NB_DATA    - 1 : 0]        buffer                      ;
    reg [NB_DATA    - 1 : 0]        buffer_next                 ;

    reg                             tx                          ;
    reg                             tx_next                     ;

    // --------------------------------------------------
    // FSM block
    // --------------------------------------------------
    always @(posedge i_clock) begin
        if(i_reset) begin
            state <= IDLE_STATE;
        end
        else begin
            state <= next_state;
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
    // TX block
    // --------------------------------------------------
    always @(posedge i_clock) begin
        if(i_reset) begin
            tx <= 0;
        end
        else begin
            tx <= tx_next;
        end
    end

    // --------------------------------------------------
    // FSM block
    // --------------------------------------------------
    always @(*) begin
        next_state  = state;
        o_tx_done = 1'b0;
        sticks_next = sticks;
        nbits_next  = nbits;
        buffer_next = buffer;
        tx_next     = tx;

        case(state)
            IDLE_STATE:
            begin
                tx_next = 1'b1;
                if(i_tx_start) begin
                    next_state = START_STATE;
                    sticks_next = 0;
                    buffer_next = i_tx_data;
                end
            end

            START_STATE:
            begin
                tx_next = 1'b0;
                if(i_signal_tick) begin
                    if(sticks == 15) begin
                        next_state = DATA_STATE;
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
                tx_next = buffer[0];
                if(i_signal_tick) begin
                    if(sticks == 15) begin
                        sticks_next = 0;
                        buffer_next = buffer >> 1;
                        if(nbits == (NB_DATA - 1)) begin
                            next_state = STOP_STATE;
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
                tx_next = 1'b1;
                if(i_signal_tick) begin
                    if(sticks == (N_TICKS - 1)) begin
                        next_state = IDLE_STATE;
                        o_tx_done = 1'b1;
                    end
                    else begin
                        sticks_next = sticks + 1'b1;
                    end
                end
            end

            default:
            begin
                next_state  = IDLE_STATE;
                sticks_next = 0;
                nbits_next  = 0;
                buffer_next = 0;
                tx_next     = 1'b1;
            end
        endcase
    end

    // --------------------------------------------------
    // Output block
    // --------------------------------------------------
    assign o_tx = tx;

endmodule