module suodv2
#(
    parameter NUM_LATCH         = 5     ,
    parameter TAM_ORDEN         = 8     ,
    parameter TAM_DATA          = 32    ,
    parameter TAM_DIREC_REG     = 5     ,
    parameter TAM_DIREC_MEM     = 7     ,
    parameter N_REGISTERS       = 32    ,    // N registros de 32 bits
    parameter N_MEMORY_BYTES    = 128       // N bytes de memoria separados en 32 bits
)
(
    input                       i_clk, i_reset, i_is_end, i_tx_done_32b_word,

    // Comunicacion con UART
    input   [TAM_ORDEN-1:0]     i_orden,
    output                      o_enable_enviada_data,
    output  [TAM_DATA-1:0]      o_data_enviada,

    // Enable para los latch
    output  [NUM_LATCH-1 : 0]   o_enable_latch,

    // Lectura en registros
    input   [TAM_DATA-1:0]      i_debug_read_reg,
    output  [TAM_DIREC_REG-1:0] o_debug_direcc_reg,

    // Lectura en memoria
    input   [TAM_DATA-1:0]      i_debug_read_mem,
    output  [TAM_DIREC_MEM-1:0] o_debug_direcc_mem,

    // interaccion con el pc
    input   [TAM_DATA-1:0]          i_read_pc,
    output                          o_pc_reset,
    output                          o_borrar_programa,

    // Escritura de la memoria de boot
    input                           i_fifo_empty,
    output                          o_read_enable,
     
    output                          o_bootload_write,
    output   [TAM_ORDEN-1:0]        o_bootload_byte,
     
    output                          o_programa_cargado,
    output                          o_programa_no_cargado,
    output  [TAM_DATA/2 - 1 : 0]    o_leds
);

    // states declaration
    localparam [3:0]
        idle          =   4'b0000,
        next          =   4'b0001,
        read_reg      =   4'b0010,
        inc_point_reg =   4'b0011,
        dec_point_reg =   4'b0100,
        read_mem      =   4'b0101,
        inc_point_mem =   4'b0110,
        dec_point_mem =   4'b0111,
        read_pc       =   4'b1000,
        reset_pc      =   4'b1001,
        bootloader    =   4'b1010,
        run           =   4'b1011,
        flush_prog    =   4'b1100;


    reg  [3:0]               state_reg, state_next;
    reg  [3:0]               substate_reg, substate_next;
    
    reg  [NUM_LATCH-1 : 0]   enable_latch_reg, enable_latch_next;
    
    reg                      enable_enviada_data_reg, enable_enviada_data_next;
    reg  [TAM_DATA-1:0]      data_enviada_reg, data_enviada_next;
    
    reg  [TAM_DIREC_REG-1:0] debug_direcc_reg_reg, debug_direcc_reg_next;
    
    reg  [TAM_DIREC_MEM-1:0] debug_direcc_mem_reg, debug_direcc_mem_next;
    
    reg                      pc_reset_reg, pc_reset_next;
    reg                      flush_programa_reg, flush_programa_next;

    reg                      bootload_write_reg, bootload_write_next;
    reg  [TAM_ORDEN-1:0]     bootload_byte_reg, bootload_byte_next;
    reg                      read_enable_reg;
    reg                      programa_cargado_reg,   programa_cargado_next;
    reg  [1:0]               instruccion_counter_reg, instruccion_counter_next;
    reg  [TAM_DATA/2-1:0]      led_reg, led_next;

    // body
    // FSMD state & data registers
    always @(posedge i_clk) begin
        if (i_reset) begin
            state_reg               <= idle;
            substate_reg            <= 0;
            enable_latch_reg        <= 0;
            enable_enviada_data_reg <= 0;

            data_enviada_reg        <= 0;

            debug_direcc_reg_reg    <= 1;

            debug_direcc_mem_reg    <= 4;

            pc_reset_reg            <= 0;
            flush_programa_reg      <= 0;

            instruccion_counter_reg <= 0;
            bootload_write_reg      <= 0;
            bootload_byte_reg       <= 0;

            programa_cargado_reg    <= 0;
            led_reg                 <= 0;
        end
        else begin
            state_reg               <= state_next;
            substate_reg            <= substate_next;
            enable_latch_reg        <= enable_latch_next;
            enable_enviada_data_reg <= enable_enviada_data_next;
            data_enviada_reg        <= data_enviada_next;

            debug_direcc_reg_reg    <= debug_direcc_reg_next;

            debug_direcc_mem_reg    <= debug_direcc_mem_next;

            pc_reset_reg            <= pc_reset_next;
            flush_programa_reg      <= flush_programa_next;

            instruccion_counter_reg <= instruccion_counter_next;
            bootload_write_reg      <= bootload_write_next;
            bootload_byte_reg       <= bootload_byte_next;
                
            programa_cargado_reg    <= programa_cargado_next;
            led_reg                 <= led_next;
        end
    end

    // FSMD next-state logic
    always @(*) begin
        state_next               = state_reg;
        substate_next            = substate_reg;
        enable_latch_next        = enable_latch_reg;
        enable_enviada_data_next = enable_enviada_data_reg;
        data_enviada_next        = data_enviada_reg;

        debug_direcc_reg_next    = debug_direcc_reg_reg;

        debug_direcc_mem_next    = debug_direcc_mem_reg;

        pc_reset_next            = pc_reset_reg;
        flush_programa_next      = flush_programa_reg;

        instruccion_counter_next = instruccion_counter_reg;
        bootload_write_next      = bootload_write_reg;
        bootload_byte_next       = bootload_byte_reg;

        programa_cargado_next    = programa_cargado_reg;
        led_next                 = led_reg;

        read_enable_reg          = 0;

        case (state_reg)
            idle: begin
                enable_latch_next        = 0;
                enable_enviada_data_next = 0;
                pc_reset_next            = 0;
                bootload_write_next      = 0;
                instruccion_counter_next = 0;
                flush_programa_next      = 0;
                substate_next            = 0;

                if(~i_fifo_empty) begin
                    case(i_orden)
                        "S"     : state_next = next;
                        "R"     : state_next = read_reg;
                        "M"     : state_next = read_mem;
                        "C"     : state_next = reset_pc;
                        "F"     : state_next = flush_prog;
                        "P"     : state_next = read_pc;
                        "B"     : state_next = bootloader;
                        "G"     : state_next = run;
                        default : state_next = idle;
                    endcase
                    read_enable_reg = 1;
                end
            end

            next: begin
                if (~i_is_end) begin
                    enable_latch_next = {NUM_LATCH{1'b1}};
                end
                state_next = idle;
            end

            read_reg: begin
                case (substate_reg)
                    4'h0: begin // seteo inicial
                        enable_enviada_data_next = 1'b0;
                        debug_direcc_reg_next    = 5'h0;
                        led_next                 = 16'hFFFF;
                        substate_next            = substate_reg + 4'h1;
                        state_next               = read_reg;
                    end

                    4'h1: begin // leer y enviar registro
                        enable_enviada_data_next = 1'b1;
                        data_enviada_next        = i_debug_read_reg;
                        led_next                 = i_debug_read_reg;
                        state_next               = read_reg;
                        substate_next            = substate_reg + 4'h1;
                    end

                    4'h2: begin // esperar fin TX registro
                        enable_enviada_data_next = 1'b0;
                        if (i_tx_done_32b_word) begin // si termino de enviar, me voy a incrementar
                            state_next      = read_reg;
                            substate_next   = substate_reg + 4'h1;
                        end
                    end

                    4'h3: begin // incremento direccion de registro
                        enable_enviada_data_next = 1'b0;
                        if(debug_direcc_reg_reg >= (N_REGISTERS-1)) begin
                            debug_direcc_reg_next = 5'h0;
                            state_next            = idle;
                            substate_next         = 4'h0;
                        end
                        else begin
                            debug_direcc_reg_next = debug_direcc_reg_reg + 5'h1;
                            state_next            = read_reg;
                            substate_next         = 4'h1;
                        end
                    end

                    default: begin
                        enable_enviada_data_next = 1'b0;
                        substate_next            = 4'h0;
                        state_next               = idle;
                    end
                endcase
            end

            read_mem: begin
                case (substate_reg)
                    4'h0: begin // seteo inicial
                        enable_enviada_data_next = 1'b0;
                        debug_direcc_mem_next    = 7'h0;
                        led_next                 = 16'hAAAA;
                        state_next               = read_mem;
                        substate_next            = substate_reg + 4'h1;
                    end

                    4'h1: begin // leer y enviar registro
                        enable_enviada_data_next = 1'b1;
                        data_enviada_next        = i_debug_read_mem;
                        led_next                 = i_debug_read_mem;
                        state_next               = read_mem;
                        substate_next            = substate_reg + 4'h1;
                    end

                    4'h2: begin // esperar fin TX registro
                        enable_enviada_data_next = 1'b0;
                        if (i_tx_done_32b_word) begin // si termino de enviar, me voy a incrementar
                            state_next      = read_mem;
                            substate_next   = substate_reg + 4'h1;
                        end
                    end

                    4'h3: begin // incremento direccion de memoria
                        enable_enviada_data_next = 1'b0;
                        if(debug_direcc_mem_reg >= (N_MEMORY_BYTES-4)) begin
                            debug_direcc_mem_next = 7'h0;
                            state_next            = idle;
                            substate_next         = 4'h0;
                        end
                        else begin
                            debug_direcc_mem_next = debug_direcc_mem_reg + 7'h4;
                            state_next            = read_mem;
                            substate_next         = 4'h1;
                        end
                    end

                    default: begin
                        enable_enviada_data_next = 1'b0;
                        substate_next            = 4'h0;
                        state_next               = idle;
                    end
                endcase
            end

            reset_pc: begin
                pc_reset_next = 1;
                state_next    = idle;
            end

            flush_prog: begin
                pc_reset_next           =   1;
                flush_programa_next     =   1;
                programa_cargado_next   =   0;
                state_next              =   idle;
            end

            read_pc: begin
                enable_enviada_data_next    =   1;
                data_enviada_next           =   i_read_pc;
                led_next                    =   i_read_pc;
                state_next                  =   idle;
            end

            bootloader:
            begin
                if(programa_cargado_reg)
                     state_next              =   idle;
                else
                begin
                     if(~i_fifo_empty)
                     begin
                          bootload_byte_next  =   i_orden;
                          led_next            =   i_orden;

                          bootload_write_next =   1;
                          read_enable_reg     =   1;
                          if(instruccion_counter_reg == 0 && i_orden[6]==1)
                          begin
                                bootload_write_next     =   0; 
                                programa_cargado_next   =   1;
                                state_next              =   idle;
                          end    
                          instruccion_counter_next   =   instruccion_counter_reg + 1;
                     end
                     else
                          bootload_write_next =   0;
                end
            end

            run: begin
                if (~i_is_end) begin
                    enable_latch_next = {NUM_LATCH{1'b1}};
                end
                else begin
                    state_next = idle;
                end
            end
        endcase
    end
    // output
     assign  o_read_enable           =   read_enable_reg;
     assign  o_enable_enviada_data   =   enable_enviada_data_reg;
     assign  o_data_enviada          =   data_enviada_reg;
     //Enable para los latch
     assign  o_enable_latch          =   enable_latch_reg;
     // Lectura en registros
     assign  o_debug_direcc_reg      =   debug_direcc_reg_reg;
     // Lectura en memoria
     assign  o_debug_direcc_mem      =   debug_direcc_mem_reg;
     // interaccion con el pc
     assign  o_pc_reset              =   pc_reset_reg;
     assign  o_borrar_programa       =   flush_programa_reg;

     // Escritura de la memoria de boot
     assign  o_bootload_write        =   bootload_write_reg;
     assign  o_bootload_byte         =   bootload_byte_reg;
     
     assign  o_programa_cargado      =   programa_cargado_reg;
     assign  o_programa_no_cargado   =   ~programa_cargado_reg;
     assign  o_leds                  =   led_reg;

endmodule
