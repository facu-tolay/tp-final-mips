module debug_unit_transmit
#
(
    parameter N_BITS_INSTR  = 32,
    parameter N_BITS_UART   = 8,
    parameter N_BITS_REG    = 5,
    parameter NB_STATE      = 3
)
(
    output wire [N_BITS_UART                -1 : 0]     o_uart_data_to_send ,
    output reg                                          o_uart_tx_start     ,
    output reg                                          o_done              ,
    output wire [NB_STATE                   -1 : 0]     o_state             ,

    input wire                                          i_execution_mode    , // si es continuo o paso a paso
    input wire                                          i_step              , // ejecutar un paso
    input wire  [N_BITS_INSTR                -1 : 0]    i_pc                ,
    input wire  [N_BITS_INSTR * N_BITS_INSTR -1 : 0]    i_registers         ,
    input wire  [N_BITS_INSTR                -1 : 0]    i_data_memory       ,
    input wire  [N_BITS_INSTR                -1 : 0]    i_cycles            ,
    input wire                                          i_halt              ,
    input wire                                          i_uart_tx_done      ,
    input wire                                          i_reset             ,
    input wire                                          i_clock
);

    localparam [NB_STATE    -1 : 0] IDLE_STATE              = 3'b000;
    localparam [NB_STATE    -1 : 0] SEND_PC_STATE           = 3'b001;
    localparam [NB_STATE    -1 : 0] SEND_REGISTERS_STATE    = 3'b010;
    localparam [NB_STATE    -1 : 0] SEND_MEMORY_STATE       = 3'b011;
    localparam [NB_STATE    -1 : 0] SEND_CYCLES_STATE       = 3'b100;

    reg [N_BITS_REG     -1 : 0] i              = 5'b0;
    reg [N_BITS_REG     -1 : 0] register_index = 5'b0;
    reg [N_BITS_INSTR   -1 : 0] data_to_send;
    reg [NB_STATE       -1 : 0] state;
    reg [NB_STATE       -1 : 0] next_state;
    reg                         tx_done;

    // --------------------------------------------------
    // Control block
    // --------------------------------------------------
    always @(posedge i_clock) begin : tx_done_block
        // if (i_uart_tx_done == 1'b1) begin
        //     tx_done <= 1'b1;
        // end
        // else begin
        //     tx_done <= 1'b0;
        // end
        tx_done <= i_uart_tx_done;
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
        next_state = state;

        case(state)
            IDLE_STATE: begin //  O se hizo el step.
                data_to_send    = 32'b0;
                o_uart_tx_start = 1'b0;
                o_done          = 1'b0;

                if (i_halt || (i_execution_mode == 1'b1 && i_step)) begin // detectar la instruccion HALT
                    next_state = SEND_PC_STATE;
                end
            end

            SEND_PC_STATE: begin
                data_to_send    = i_pc;
                o_uart_tx_start = 1'b1;

                if (tx_done) begin
                    i = i + 1;

                    if (i == 4) begin
                        i = 5'b0;
                        next_state = SEND_REGISTERS_STATE;
                        o_uart_tx_start = 1'b0;
                    end
                end
            end

            SEND_REGISTERS_STATE: begin // manda los regs uno por uno sin usar un for
                data_to_send    = i_registers[(N_BITS_INSTR * register_index) +: N_BITS_INSTR];
                o_uart_tx_start = 1'b1;

                if (tx_done) begin
                    i = i + 1;
                    o_uart_tx_start = 1'b0;

                    if (i == 4) begin
                        i = 5'b0;

                        if (register_index == N_BITS_INSTR-1) begin
                            next_state = SEND_MEMORY_STATE;
                            register_index = 5'b0;
                        end
                        else begin
                            register_index = register_index + 1;
                        end
                    end
                end
            end

            SEND_MEMORY_STATE: begin
                data_to_send    = i_data_memory;
                o_uart_tx_start = 1'b1;

                if (tx_done) begin
                    i = i + 1;

                    if (i == 4) begin
                        i = 5'b0;
                        next_state = SEND_CYCLES_STATE;
                        o_uart_tx_start = 1'b0;
                    end
                end
            end

            SEND_CYCLES_STATE: begin
                data_to_send    = i_cycles;
                o_uart_tx_start = 1'b1;

                if (tx_done) begin
                    i = i + 1;

                    if (i == 4) begin
                        i = 5'b0;
                        next_state = IDLE_STATE;
                        o_done     = 1'b1;
                    end
                end
            end
        endcase
    end

    // --------------------------------------------------
    // Output block
    // --------------------------------------------------
    assign o_state              = state;
    assign o_uart_data_to_send  = data_to_send[(N_BITS_UART * i) +: N_BITS_UART];

endmodule
