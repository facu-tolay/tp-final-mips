module debug_unit_transmit
#
(
    parameter NB_DATA       = 32    ,
    parameter NB_STATE      = 4
)
(
    output wire [NB_DATA                -1 : 0]     o_uart_data_to_send ,
    output wire                                     o_uart_tx_8b_start  ,
    output wire                                     o_uart_tx_32b_start ,
    output wire                                     o_done              ,

    input wire  [NB_DATA                -1 : 0]     i_pc                ,
    input wire  [NB_DATA * NB_DATA      -1 : 0]     i_registers         ,
    input wire  [NB_DATA                -1 : 0]     i_data_memory       ,
    input wire  [NB_DATA                -1 : 0]     i_cycles            ,
    input wire                                      i_uart_tx_done      ,
    input wire                                      i_uart_tx_32b_done  ,
    input wire                                      i_uart_tx_8b_done   ,
    input wire                                      i_execution_mode    ,
    input wire                                      i_step              ,
    input wire                                      i_halt              ,
    input wire                                      i_reset             ,
    input wire                                      i_clock
);

    localparam [NB_STATE    -1 : 0] IDLE_STATE                  = 4'b0000;
    localparam [NB_STATE    -1 : 0] SEND_PC_STATE               = 4'b0001;
    localparam [NB_STATE    -1 : 0] SEND_REGISTERS_STATE        = 4'b0010;
    localparam [NB_STATE    -1 : 0] SEND_MEMORY_STATE           = 4'b0011;
    localparam [NB_STATE    -1 : 0] SEND_CYCLES_STATE           = 4'b0100;
    localparam [NB_STATE    -1 : 0] WAIT_PC_SEND_DONE_STATE     = 4'b0101;
    localparam [NB_STATE    -1 : 0] WAIT_REG_SEND_DONE_STATE    = 4'b0110;
    localparam [NB_STATE    -1 : 0] WAIT_MEM_SEND_DONE_STATE    = 4'b0111;
    localparam [NB_STATE    -1 : 0] WAIT_CYC_SEND_DONE_STATE    = 4'b1000;

    reg [NB_STATE       -1 : 0] state;
    reg [NB_STATE       -1 : 0] next_state;
    reg [NB_DATA        -1 : 0] data_to_send;
    reg [NB_DATA        -1 : 0] data_to_send_output;
    reg                         tx_start_8b_signal;
    reg                         tx_start_32b_signal;
    reg                         tx_start_8b_output;
    reg                         tx_start_32b_output;
    reg                         done_signal;
    reg                         done_output;


    // --------------------------------------------------
    // Done block
    // --------------------------------------------------
    always @(posedge i_clock) begin : done_block
        if (i_reset) begin
            done_output <= 1'b0;
        end
        else begin
            done_output <= done_signal;
        end
    end

    // --------------------------------------------------
    // TX start 8 bits block
    // --------------------------------------------------
    always @(posedge i_clock) begin : tx_start_8b_block
        if (i_reset | tx_start_8b_output) begin
            tx_start_8b_output <= 1'b0;
        end
        else begin
            tx_start_8b_output <= tx_start_8b_signal;
        end
    end

    // --------------------------------------------------
    // TX start 32 bits block
    // --------------------------------------------------
    always @(posedge i_clock) begin : tx_start_32b_block
        if (i_reset | tx_start_32b_output) begin
            tx_start_32b_output <= 1'b0;
        end
        else begin
            tx_start_32b_output <= tx_start_32b_signal;
        end
    end

    // --------------------------------------------------
    // Data to send block
    // --------------------------------------------------
    always @(posedge i_clock) begin : data_to_send_block
        if (i_reset) begin
            data_to_send_output <= 32'b0;
        end
        else begin
            data_to_send_output <= data_to_send;
        end
    end

    // --------------------------------------------------
    // TX Finite State Machine
    // --------------------------------------------------
    always @(posedge i_clock) begin : state_block
        if (i_reset) begin
            state  <= IDLE_STATE;
        end
        else begin
            state <= next_state;
        end
    end

    always @(*) begin : tx_state_machine
        case(state)
            IDLE_STATE: begin
                data_to_send        = 32'b0;
                tx_start_8b_signal  = 1'b0;
                tx_start_32b_signal = 1'b0;
                done_signal         = 1'b0;

                if (i_halt || (i_execution_mode && i_step)) begin
                    next_state = SEND_PC_STATE;
                end
                else begin
                    next_state = IDLE_STATE;
                end
            end

            SEND_PC_STATE: begin
                data_to_send        = i_pc;
                tx_start_8b_signal  = 1'b0;
                tx_start_32b_signal = 1'b1;
                done_signal         = 1'b0;
                next_state          = WAIT_PC_SEND_DONE_STATE;
            end

            WAIT_PC_SEND_DONE_STATE: begin
                data_to_send        = 32'b0;
                tx_start_8b_signal  = 1'b0;
                tx_start_32b_signal = 1'b0;
                done_signal         = 1'b0;

                if (i_uart_tx_32b_done) begin
                    next_state = SEND_REGISTERS_STATE;
                end
                else begin
                    next_state = WAIT_PC_SEND_DONE_STATE;
                end
            end

            SEND_REGISTERS_STATE: begin // manda los regs uno por uno sin usar un for
                data_to_send        = 32'hFFFFFFFF; // FIXMEEEE
                tx_start_8b_signal  = 1'b0;
                tx_start_32b_signal = 1'b1;
                done_signal         = 1'b0;
                next_state          = WAIT_REG_SEND_DONE_STATE;
            end

            WAIT_REG_SEND_DONE_STATE: begin
                data_to_send        = 32'b0;
                tx_start_8b_signal  = 1'b0;
                tx_start_32b_signal = 1'b0;
                done_signal         = 1'b0;

                if (i_uart_tx_32b_done) begin
                    next_state = SEND_MEMORY_STATE;
                end
                else begin
                    next_state = WAIT_REG_SEND_DONE_STATE;
                end
            end

            SEND_MEMORY_STATE: begin
                data_to_send        = i_data_memory;
                tx_start_8b_signal  = 1'b0;
                tx_start_32b_signal = 1'b1;
                done_signal         = 1'b0;
                next_state          = WAIT_MEM_SEND_DONE_STATE;
            end

            WAIT_MEM_SEND_DONE_STATE: begin
                data_to_send        = 32'b0;
                tx_start_8b_signal  = 1'b0;
                tx_start_32b_signal = 1'b0;
                done_signal         = 1'b0;

                if (i_uart_tx_32b_done) begin
                    next_state = SEND_CYCLES_STATE;
                end
                else begin
                    next_state = WAIT_MEM_SEND_DONE_STATE;
                end
            end

            SEND_CYCLES_STATE: begin
                data_to_send        = i_cycles;
                tx_start_8b_signal  = 1'b0;
                tx_start_32b_signal = 1'b1;
                done_signal         = 1'b0;
                next_state          = WAIT_CYC_SEND_DONE_STATE;
            end

            WAIT_CYC_SEND_DONE_STATE: begin
                data_to_send        = 32'b0;
                tx_start_8b_signal  = 1'b0;
                tx_start_32b_signal = 1'b0;

                if (i_uart_tx_32b_done) begin
                    done_signal = 1'b1;
                    next_state  = IDLE_STATE;
                end
                else begin
                    done_signal = 1'b0;
                    next_state  = WAIT_CYC_SEND_DONE_STATE;
                end
            end

            default: begin
                data_to_send        = 32'b0;
                tx_start_8b_signal  = 1'b0;
                tx_start_32b_signal = 1'b0;
                done_signal         = 1'b0;
                next_state          = IDLE_STATE;
            end
        endcase
    end

    // --------------------------------------------------
    // Output block
    // --------------------------------------------------
    assign o_done               = done_output;
    assign o_uart_data_to_send  = data_to_send_output;
    assign o_uart_tx_8b_start   = tx_start_8b_output;
    assign o_uart_tx_32b_start  = tx_start_32b_output;

endmodule
