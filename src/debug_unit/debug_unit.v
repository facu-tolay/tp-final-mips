module debug_unit
#(
    parameter NB_DATA                   = 32    ,
    parameter NB_BYTE                   = 8     ,
    parameter NB_REG_ADDRESS            = 5     ,
    parameter NB_MEM_ADDRESS            = 7     ,
    parameter NB_STATE                  = 4     ,
    parameter N_STAGES_TRANSITIONS      = 5     ,
    parameter N_REGISTERS               = 32    ,
    parameter N_MEMORY_BYTES            = 128 // N bytes de memoria separados en 32 bits
)
(
    // UART communication
    input  wire [NB_BYTE              -1 : 0]   i_uart_receive_byte         ,
    input  wire                                 i_uart_receive_byte_done    ,
    input  wire                                 i_uart_tx_done              ,
    output wire [NB_DATA              -1 : 0]   o_uart_data_to_send         ,
    output wire                                 o_uart_enable_send_data     ,

    // Stages transitions
    output wire [N_STAGES_TRANSITIONS -1 : 0]   o_enable_stages_transitions ,

    // Registers read
    input  wire [NB_DATA              -1 : 0]   i_debug_read_reg            ,
    output wire [NB_REG_ADDRESS       -1 : 0]   o_debug_read_reg_address    ,

    // Memory read
    input  wire [NB_DATA              -1 : 0]   i_debug_read_mem            ,
    output wire [NB_MEM_ADDRESS       -1 : 0]   o_debug_read_mem_address    ,

    // PC operations
    input  wire [NB_DATA              -1 : 0]   i_debug_read_pc             ,
    output wire                                 o_pc_reset                  ,

    // Program operations
    output wire [NB_BYTE  -1:0]                 o_load_program_byte         ,
    output wire                                 o_load_program_write_enable ,
    output wire                                 o_program_loaded            ,
    output wire                                 o_delete_program            ,
    input  wire                                 i_mips_program_ended        ,

    // Status
    output wire [NB_DATA /2 - 1 : 0]            o_leds                      ,

    input  wire                                 i_reset                     ,
    input  wire                                 i_clock
);

    // Serial commands definition
    localparam RUN_COMMAND          = "E";
    localparam NEXT_COMMAND         = "N";
    localparam READ_REG_COMMAND     = "R";
    localparam READ_MEM_COMMAND     = "M";
    localparam READ_PC_COMMAND      = "P";
    localparam RESET_PC_COMMAND     = "C";
    localparam FLUSH_PROG_COMMAND   = "D";
    localparam LOAD_PROGRAM_COMMAND = "L";

    // FSM states definition
    localparam [NB_STATE -1 : 0]  IDLE_STATE         = 4'b0000;
    localparam [NB_STATE -1 : 0]  RUN_STATE          = 4'b0001;
    localparam [NB_STATE -1 : 0]  NEXT_STATE         = 4'b0010;
    localparam [NB_STATE -1 : 0]  READ_REG_STATE     = 4'b0011;
    localparam [NB_STATE -1 : 0]  READ_MEM_STATE     = 4'b0100;
    localparam [NB_STATE -1 : 0]  READ_PC_STATE      = 4'b0101;
    localparam [NB_STATE -1 : 0]  RESET_PC_STATE     = 4'b0110;
    localparam [NB_STATE -1 : 0]  FLUSH_PROG_STATE   = 4'b0111;
    localparam [NB_STATE -1 : 0]  LOAD_PROGRAM_STATE = 4'b1000;

    // FSM registers
    reg  [NB_STATE             -1 : 0]  state;
    reg  [NB_STATE             -1 : 0]  state_next;
    reg  [NB_STATE             -1 : 0]  substate;
    reg  [NB_STATE             -1 : 0]  substate_next;

    // Stage transitions flip-flops
    reg  [N_STAGES_TRANSITIONS -1 : 0]  enable_stages_transitions;
    reg  [N_STAGES_TRANSITIONS -1 : 0]  enable_stages_transitions_next;

    reg                                 enable_uart_send_data;
    reg                                 enable_uart_send_data_next;
    reg  [NB_DATA              -1 : 0]  data_to_send;
    reg  [NB_DATA              -1 : 0]  data_to_send_next;

    // Debug read register address
    reg  [NB_REG_ADDRESS       -1 : 0]  debug_read_reg_address;
    reg  [NB_REG_ADDRESS       -1 : 0]  debug_read_reg_address_next;

    // Debug read memory address
    reg  [NB_MEM_ADDRESS       -1 : 0]  debug_read_mem_address;
    reg  [NB_MEM_ADDRESS       -1 : 0]  debug_read_mem_address_next;

    // Program control
    reg                                 pc_reset;
    reg                                 pc_reset_next;
    reg                                 delete_program;
    reg                                 delete_program_next;

    // Program loading
    reg                                 load_program_write_enable;
    reg                                 load_program_write_next;
    reg  [NB_BYTE              -1 : 0]  load_program_byte;
    reg  [NB_BYTE              -1 : 0]  load_program_byte_next;
    reg                                 is_program_loaded;
    reg                                 is_program_loaded_next;
    reg  [2                    -1 : 0]  instruction_counter;
    reg  [2                    -1 : 0]  instruction_counter_next;

    // Debug LEDs output
    reg  [NB_DATA/2            -1 : 0]  leds;
    reg  [NB_DATA/2            -1 : 0]  led_next;

    // --------------------------------------------------
    // Main FSM registers
    // --------------------------------------------------
    always @(posedge i_clock) begin
        if (i_reset) begin
            state                     <= IDLE_STATE;
            substate                  <= 0;

            is_program_loaded         <= 1'b0;
            pc_reset                  <= 1'b0;
            delete_program            <= 1'b0;

            debug_read_reg_address    <= 1;
            debug_read_mem_address    <= 4;

            enable_stages_transitions <= 0;

            enable_uart_send_data     <= 1'b0;
            data_to_send              <= 0;

            load_program_write_enable <= 1'b0;
            load_program_byte         <= 0;
            instruction_counter       <= 0;

            leds                      <= 16'h0;
        end
        else begin
            state                     <= state_next;
            substate                  <= substate_next;

            is_program_loaded         <= is_program_loaded_next;
            pc_reset                  <= pc_reset_next;
            delete_program            <= delete_program_next;

            debug_read_reg_address    <= debug_read_reg_address_next;
            debug_read_mem_address    <= debug_read_mem_address_next;

            enable_stages_transitions <= enable_stages_transitions_next;

            enable_uart_send_data     <= enable_uart_send_data_next;
            data_to_send              <= data_to_send_next;

            load_program_write_enable <= load_program_write_next;
            load_program_byte         <= load_program_byte_next;
            instruction_counter       <= instruction_counter_next;

            leds                      <= led_next;
        end
    end

    // --------------------------------------------------
    // Main FSM next state logic
    // --------------------------------------------------
    always @(*) begin
        state_next                     = state;
        substate_next                  = substate;

        is_program_loaded_next         = is_program_loaded;
        pc_reset_next                  = pc_reset;
        delete_program_next            = delete_program;

        debug_read_reg_address_next    = debug_read_reg_address;
        debug_read_mem_address_next    = debug_read_mem_address;

        enable_stages_transitions_next = enable_stages_transitions;

        enable_uart_send_data_next     = enable_uart_send_data;
        data_to_send_next              = data_to_send;

        load_program_write_next        = load_program_write_enable;
        load_program_byte_next         = load_program_byte;
        instruction_counter_next       = instruction_counter;

        led_next                       = leds;

        case (state)
            IDLE_STATE: begin
                substate_next                  = 0;
                pc_reset_next                  = 1'b0;
                delete_program_next            = 1'b0;
                enable_stages_transitions_next = 0;
                enable_uart_send_data_next     = 1'b0;
                load_program_write_next        = 1'b0;
                instruction_counter_next       = 0;

                if(i_uart_receive_byte_done) begin
                    case(i_uart_receive_byte)
                        RUN_COMMAND          : state_next = RUN_STATE;
                        NEXT_COMMAND         : state_next = NEXT_STATE;
                        READ_REG_COMMAND     : state_next = READ_REG_STATE;
                        READ_MEM_COMMAND     : state_next = READ_MEM_STATE;
                        READ_PC_COMMAND      : state_next = READ_PC_STATE;
                        RESET_PC_COMMAND     : state_next = RESET_PC_STATE;
                        FLUSH_PROG_COMMAND   : state_next = FLUSH_PROG_STATE;
                        LOAD_PROGRAM_COMMAND : state_next = LOAD_PROGRAM_STATE;
                        default              : state_next = IDLE_STATE;
                    endcase
                end
            end

            RUN_STATE: begin
                if (~i_mips_program_ended) begin
                    enable_stages_transitions_next = {N_STAGES_TRANSITIONS{1'b1}};
                end
                else begin
                    state_next = IDLE_STATE;
                end
            end

            NEXT_STATE: begin
                if (~i_mips_program_ended) begin
                    enable_stages_transitions_next = {N_STAGES_TRANSITIONS{1'b1}};
                end
                state_next = IDLE_STATE;
            end

            READ_REG_STATE: begin
                case (substate)
                    4'h0: begin // seteo inicial
                        enable_uart_send_data_next  = 1'b0;
                        debug_read_reg_address_next = 5'h0;
                        led_next                    = 16'hFFFF;
                        state_next                  = READ_REG_STATE;
                        substate_next               = substate + 4'h1;
                    end

                    4'h1: begin // leer y enviar registro
                        enable_uart_send_data_next = 1'b1;
                        data_to_send_next          = i_debug_read_reg;
                        led_next                   = i_debug_read_reg;
                        state_next                 = READ_REG_STATE;
                        substate_next              = substate + 4'h1;
                    end

                    4'h2: begin // esperar fin TX registro
                        enable_uart_send_data_next = 1'b0;
                        if (i_uart_tx_done) begin // si termino de enviar, me voy a incrementar
                            state_next    = READ_REG_STATE;
                            substate_next = substate + 4'h1;
                        end
                    end

                    4'h3: begin // incremento direccion de registro
                        enable_uart_send_data_next = 1'b0;
                        if(debug_read_reg_address >= (N_REGISTERS-1)) begin
                            debug_read_reg_address_next = 5'h0;
                            state_next                  = IDLE_STATE;
                            substate_next               = 4'h0;
                        end
                        else begin
                            debug_read_reg_address_next = debug_read_reg_address + 5'h1;
                            state_next                  = READ_REG_STATE;
                            substate_next               = 4'h1;
                        end
                    end

                    default: begin
                        enable_uart_send_data_next = 1'b0;
                        state_next                 = IDLE_STATE;
                        substate_next              = 4'h0;
                    end
                endcase
            end

            READ_MEM_STATE: begin
                case (substate)
                    4'h0: begin // seteo inicial
                        enable_uart_send_data_next  = 1'b0;
                        debug_read_mem_address_next = 7'h0;
                        led_next                    = 16'hAAAA;
                        state_next                  = READ_MEM_STATE;
                        substate_next               = substate + 4'h1;
                    end

                    4'h1: begin // leer y enviar posicion de memoria
                        enable_uart_send_data_next = 1'b1;
                        data_to_send_next          = i_debug_read_mem;
                        led_next                   = i_debug_read_mem;
                        state_next                 = READ_MEM_STATE;
                        substate_next              = substate + 4'h1;
                    end

                    4'h2: begin // esperar fin TX posicion de memoria
                        enable_uart_send_data_next = 1'b0;
                        if (i_uart_tx_done) begin // si termino de enviar, me voy a incrementar
                            state_next    = READ_MEM_STATE;
                            substate_next = substate + 4'h1;
                        end
                    end

                    4'h3: begin // incremento direccion de memoria
                        enable_uart_send_data_next = 1'b0;
                        if(debug_read_mem_address >= (N_MEMORY_BYTES-4)) begin
                            debug_read_mem_address_next = 7'h0;
                            state_next                  = IDLE_STATE;
                            substate_next               = 4'h0;
                        end
                        else begin
                            debug_read_mem_address_next = debug_read_mem_address + 7'h4;
                            state_next                  = READ_MEM_STATE;
                            substate_next               = 4'h1;
                        end
                    end

                    default: begin
                        enable_uart_send_data_next = 1'b0;
                        state_next                 = IDLE_STATE;
                        substate_next              = 4'h0;
                    end
                endcase
            end

            READ_PC_STATE: begin
                enable_uart_send_data_next = 1'b1;
                data_to_send_next          = i_debug_read_pc;
                led_next                   = i_debug_read_pc;
                state_next                 = IDLE_STATE;
            end

            RESET_PC_STATE: begin
                pc_reset_next = 1'b1;
                state_next    = IDLE_STATE;
            end

            FLUSH_PROG_STATE: begin
                pc_reset_next          = 1'b1;
                delete_program_next    = 1'b1;
                is_program_loaded_next = 1'b0;
                state_next             = IDLE_STATE;
            end

            LOAD_PROGRAM_STATE: begin
                if(is_program_loaded) begin
                    state_next = IDLE_STATE;
                end
                else begin
                    if(i_uart_receive_byte_done) begin
                        load_program_write_next = 1'b1;
                        load_program_byte_next  = i_uart_receive_byte;
                        led_next                = i_uart_receive_byte;

                        // if(instruction_counter == 0 && i_uart_receive_byte[6] == 1) begin
                        if(instruction_counter == 0 && i_uart_receive_byte == 8'hF4) begin
                            load_program_write_next = 1'b0;
                            is_program_loaded_next  = 1'b1;
                            state_next              = IDLE_STATE;
                        end
                        instruction_counter_next = instruction_counter + 2'h1;
                    end
                    else begin
                        load_program_write_next = 1'b0;
                    end
                end
            end

            default: begin
                state_next    = IDLE_STATE;
            end
        endcase
    end

    // --------------------------------------------------
    // Output assignments
    // --------------------------------------------------

    // Control y estado
    assign o_program_loaded             = is_program_loaded;
    assign o_pc_reset                   = pc_reset;
    assign o_delete_program             = delete_program;
    assign o_leds                       = leds;

    // Lectura de registros y memoria
    assign o_debug_read_reg_address     = debug_read_reg_address;
    assign o_debug_read_mem_address     = debug_read_mem_address;

    // Enable para los registros de transicion entre etapas
    assign o_enable_stages_transitions  = enable_stages_transitions;

    // TX data
    assign o_uart_enable_send_data      = enable_uart_send_data;
    assign o_uart_data_to_send          = data_to_send;

    // Escritura de la memoria de instrucciones
    assign o_load_program_write_enable  = load_program_write_enable;
    assign o_load_program_byte          = load_program_byte;

endmodule
