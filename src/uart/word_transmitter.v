
/* Module: word_transmitter
    This module is used to transmit a 32 bit word in pieces of 8 bits.
    It also supports sending only 8 bits.

    o_tx_data           - 8 bits slice of data to be sent.
    o_tx_start          - Start transmission pulse.
    o_tx_done_8b        - 8 bit transmission done pulse.
    o_tx_done_32b       - 32 bit transmission done pulse.
    i_tx_data           - 32 bit word to transmit.
    i_tx_done           - Indication that 1 byte has been sent.
    i_tx_8b_start       - Starts an 8 bit transmission.
    i_tx_32b_start      - Starts a 32 bit transmission.
*/

module word_transmitter
#(
    parameter   NB_DATA_OUT             = 8                         ,
    parameter   N_DATA_OUT              = 4                         ,
    parameter   NB_STATE                = 2                         ,
    parameter   NB_BYTE_COUNT           = 3                         ,
    parameter   NB_DATA_IN              = NB_DATA_OUT * N_DATA_OUT
)
(
    output  wire [NB_DATA_OUT    - 1 : 0]   o_tx_data               ,
    output  wire                            o_tx_start              ,
    output  wire                            o_tx_done_8b            ,
    output  wire                            o_tx_done_32b           ,

    input   wire [NB_DATA_IN    - 1 : 0]    i_tx_data               ,
    input   wire                            i_tx_done               ,
    input   wire                            i_tx_8b_start           ,
    input   wire                            i_tx_32b_start          ,
    input   wire                            i_reset                 ,
    input   wire                            i_clock
);

    localparam [NB_STATE    -1 : 0] IDLE            = 2'b00;
    localparam [NB_STATE    -1 : 0] SEND_BYTE       = 2'b01;
    localparam [NB_STATE    -1 : 0] WAIT_TX_DONE    = 2'b10;

    reg  [NB_STATE      -1 : 0] state;
    reg  [NB_STATE      -1 : 0] next_state;
    reg  [NB_DATA_IN    -1 : 0] whole_word_data;
    reg  [NB_DATA_OUT   -1 : 0] data_output;
    reg  [NB_BYTE_COUNT -1 : 0] n_bytes_to_send;
    reg  [NB_BYTE_COUNT -1 : 0] byte_index;
    reg                         enable_transmit;
    reg                         tx_start_output;
    reg                         tx_start_signal;
    reg                         tx_done_8b_signal;
    reg                         tx_done_32b_signal;
    reg                         tx_done_8b_output;
    reg                         tx_done_32b_output;
    wire                        start_transmit;

    // --------------------------------------------------
    // N bytes to send block
    // --------------------------------------------------
    always @(posedge i_clock) begin : n_bytes_tx_block
        if (i_reset) begin
            n_bytes_to_send <= 3'h0;
        end
        else if (i_tx_8b_start) begin
            n_bytes_to_send <= 3'h1;
        end
        else if (i_tx_32b_start) begin
            n_bytes_to_send <= N_DATA_OUT;
        end
    end

    // --------------------------------------------------
    // Enable transmit block
    // --------------------------------------------------
    assign start_transmit = i_tx_8b_start || i_tx_32b_start; // FIXME ver si agregar (&& ~enable_transmit) para evitar que empiece otra transmision sin terminar una.
                                                             // lo mismo arrina en n_bytes_to_send

    always @(posedge i_clock) begin : enable_tx_block
        if (i_reset || (enable_transmit && state == IDLE)) begin
            enable_transmit <= 1'b0;
        end
        else if (start_transmit) begin
            enable_transmit <= 1'b1;
        end
    end

    // --------------------------------------------------
    // Hold up whole word block
    // --------------------------------------------------
    always @(posedge i_clock) begin : whole_word_data_block
        if (i_reset) begin
            whole_word_data <= 32'b0;
        end
        else if (start_transmit) begin
            whole_word_data <= i_tx_data;
        end
    end

    // --------------------------------------------------
    // Byte pointer and buffer selection blocks
    // --------------------------------------------------
    always @(posedge i_clock) begin : byte_index_block
        if (i_reset || state == IDLE) begin
            byte_index <= 3'h0;
        end
        else if (enable_transmit && tx_start_signal) begin
            byte_index <= byte_index + 3'h1;
        end
    end

    always @(posedge i_clock) begin : output_data_block
        if (i_reset) begin
            data_output <= 8'h0;
        end
        else if (start_transmit || (enable_transmit && tx_start_signal)) begin
            data_output <= whole_word_data[NB_DATA_IN - (byte_index * NB_DATA_OUT) -1 -: NB_DATA_OUT];
        end
    end

    // --------------------------------------------------
    // Transmit start block
    // --------------------------------------------------
    always @(posedge i_clock) begin : tx_start_block
        if (i_reset || tx_start_output) begin
            tx_start_output <= 1'b0;
        end
        else begin
            tx_start_output <= tx_start_signal;
        end
    end

    // --------------------------------------------------
    // TX done 8 bits block
    // --------------------------------------------------
    always @(posedge i_clock) begin : tx_done_8b_block
        if (i_reset || tx_done_8b_output) begin
            tx_done_8b_output <= 1'b0;
        end
        else begin
            tx_done_8b_output <= tx_done_8b_signal;
        end
    end

    // --------------------------------------------------
    // TX done 32 bits block
    // --------------------------------------------------
    always @(posedge i_clock) begin : tx_done_32b_block
        if (i_reset || tx_done_32b_output) begin
            tx_done_32b_output <= 1'b0;
        end
        else begin
            tx_done_32b_output <= tx_done_32b_signal;
        end
    end

    // --------------------------------------------------
    // FSM
    // --------------------------------------------------
    always @(posedge i_clock) begin : state_block
        if(i_reset) begin
            state <= IDLE;
        end
        else begin
            state <= next_state;
        end
    end

    always @(*) begin : state_machine
        next_state          = state;
        tx_start_signal     = 1'b0;
        tx_done_8b_signal   = 1'b0;
        tx_done_32b_signal  = 1'b0;

        case(state)
            IDLE: begin
                tx_start_signal     = 1'b0;
                tx_done_8b_signal   = 1'b0;
                tx_done_32b_signal  = 1'b0;

                if(start_transmit) begin
                    next_state = SEND_BYTE;
                end
                else begin
                    next_state = IDLE;
                end
            end

            SEND_BYTE: begin
                tx_start_signal     = 1'b1;
                tx_done_8b_signal   = 1'b0;
                tx_done_32b_signal  = 1'b0;
                next_state          = WAIT_TX_DONE;
            end

            WAIT_TX_DONE: begin
                tx_start_signal     = 1'b0;

                if(i_tx_done) begin
                    if(byte_index < n_bytes_to_send) begin
                        tx_done_8b_signal   = 1'b0;
                        tx_done_32b_signal  = 1'b0;
                        next_state          = SEND_BYTE;
                    end
                    else begin
                        case (n_bytes_to_send)
                            3'd1: begin
                                tx_done_8b_signal   = 1'b1;
                                tx_done_32b_signal  = 1'b0;
                            end

                            3'd4: begin
                                tx_done_8b_signal   = 1'b0;
                                tx_done_32b_signal  = 1'b1;
                            end

                            default: begin
                                tx_done_8b_signal   = 1'b0;
                                tx_done_32b_signal  = 1'b0;
                            end
                        endcase
                        next_state = IDLE;
                    end
                end
            end

            default: begin
                tx_start_signal     = 1'b0;
                tx_done_8b_signal   = 1'b0;
                tx_done_32b_signal  = 1'b0;
                next_state          = IDLE;
            end
        endcase
    end

    // --------------------------------------------------
    // Output assignments
    // --------------------------------------------------
    assign o_tx_start       = tx_start_output;
    assign o_tx_data        = data_output;
    assign o_tx_done_8b     = tx_done_8b_output;
    assign o_tx_done_32b    = tx_done_32b_output;

endmodule
