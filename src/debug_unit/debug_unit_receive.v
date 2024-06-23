module debug_unit_receive
#(
    parameter N_BITS            = 8     ,
    parameter N_BITS_REG        = 5     ,
    parameter N_BITS_INSTR      = 32    ,
    parameter NB_STATE          = 3
)
(
    output wire                         o_execution_mode        ,
    output wire                         o_execution_step        ,
    output wire                         o_enable_write_memory   ,
    output wire                         o_done_write_memory     ,
    output wire [N_BITS_INSTR   -1 : 0] o_data_memory           ,
    output wire [NB_STATE       -1 : 0] o_state                 ,

    input wire  [N_BITS         -1 : 0] i_rx_data               ,
    input wire                          i_rx_done               ,
    input wire                          i_reset                 ,
    input wire                          i_clock
);

    localparam [N_BITS_INSTR    -1 : 0] HALT_INSTRUCTION    = {N_BITS_INSTR {1'b1}};
    localparam [NB_STATE        -1 : 0] IDLE                = 3'b000;
    localparam [NB_STATE        -1 : 0] INSTRUCTIONS        = 3'b001;
    localparam [NB_STATE        -1 : 0] EXEC_MODE           = 3'b010;
    localparam [NB_STATE        -1 : 0] STEP                = 3'b011;

    reg [N_BITS_INSTR   -1 : 0] data_memory = 32'b0;
    reg [NB_STATE       -1 : 0] state;
    reg [NB_STATE       -1 : 0] next_state;
    reg [NB_STATE       -1 : 0] instr_byte_count;
    reg                         rx_done;
    wire                        done_write_memory;
    reg                         step;
    reg                         enable_write_memory;
    reg                         execution_step;
    reg                         execution_mode;
    reg                         execution_mode_d;


    // --------------------------------------------------
    // Control signals blocks
    // --------------------------------------------------
    always @(posedge i_clock) begin : rx_done_block
        if(i_reset) begin
            rx_done <= 1'b0;
        end
        else begin
            rx_done <= i_rx_done;
        end
    end

    always @(posedge i_clock) begin : execution_mode_block
        if(i_reset) begin
            execution_mode_d <= 1'b0;
        end
        else if(~execution_mode_d) begin
            execution_mode_d <= execution_mode;
        end
    end

    always @(negedge i_clock) begin : exec_step_block
        if(i_reset | execution_step) begin
            execution_step <= 1'b0;
        end
        else begin
            execution_step <= step;
        end
    end

    // --------------------------------------------------
    // 4 byte buffer for instructions
    // --------------------------------------------------
    assign done_write_memory = instr_byte_count >= 4 && enable_write_memory;

    always @(posedge i_clock) begin : instruction_receive
        if(i_reset) begin
            data_memory <= 32'b0;
        end
        else if(enable_write_memory && i_rx_done) begin
            data_memory <= {data_memory[N_BITS_INSTR - N_BITS -1 : 0], i_rx_data};
        end
    end

    always @(posedge i_clock) begin : instruction_byte_count
        if(i_reset) begin
            instr_byte_count <= 3'b0;
        end
        else if(instr_byte_count >= 4) begin
            instr_byte_count <= i_rx_done ? 3'b1 : 3'b0; // esto indica que si van a seguir viniendo datos, que inicialice la cuenta en 1
        end
        else if(enable_write_memory && i_rx_done) begin
            instr_byte_count <= instr_byte_count + 3'b1;
        end
    end

    // --------------------------------------------------
    // RX Finite State Machine
    // --------------------------------------------------
    always @(posedge i_clock) begin : state_block
        if(i_reset) begin
            state <= IDLE;
        end
        else begin
            state <= next_state;
        end
    end

    always @(*) begin : rx_state_machine
        case(state)
            IDLE: begin
                execution_mode  = 1'b0;
                step            = 1'b0;

                if(rx_done && i_rx_data == 8'h55) begin
                    enable_write_memory = 1'b1;
                    next_state = INSTRUCTIONS;
                end
                else begin
                    enable_write_memory = 1'b0;
                    next_state = IDLE;
                end
            end

            INSTRUCTIONS: begin
                enable_write_memory = 1'b1;
                execution_mode      = 1'b0;
                step                = 1'b0;

                if(rx_done && data_memory == HALT_INSTRUCTION) begin
                    next_state = EXEC_MODE;
                end
                else begin
                    next_state = INSTRUCTIONS;
                end
            end

            EXEC_MODE: begin
                enable_write_memory = 1'b0;
                step                = 1'b0;

                if(rx_done && i_rx_data != HALT_INSTRUCTION[N_BITS-1 : 0]) begin // verificar que no sea el halt del estado anterior
                    execution_mode = i_rx_data[0];
                    next_state = STEP;
                end
                else begin
                    execution_mode = 1'b0;
                    next_state = EXEC_MODE;
                end
            end

            STEP: begin
                enable_write_memory = 1'b0;
                execution_mode      = 1'b0;
                next_state          = STEP;

                if(rx_done) begin // se genera un step por cada byte recibido
                    step = i_rx_data[0];
                end
                else begin
                    step = 1'b0;
                end
            end

            default: begin
                enable_write_memory = 1'b0;
                execution_mode      = 1'b0;
                step                = 1'b0;
                next_state          = IDLE;
            end
       endcase
    end

    // --------------------------------------------------
    // Output block
    // --------------------------------------------------

    assign o_state                  = state;
    assign o_execution_step         = execution_step;
    assign o_execution_mode         = execution_mode || execution_mode_d;
    assign o_enable_write_memory    = enable_write_memory;
    assign o_done_write_memory      = done_write_memory;
    assign o_data_memory            = done_write_memory ? data_memory : {N_BITS_INSTR {1'b0}};

endmodule