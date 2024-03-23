`timescale 1ns / 1ps

// Verifica que a cada ciclo con valid incremente el PC en 1

`define assert(value) \
    if (!value) begin \
        $display("ASSERTION EXPECTED TO BE TRUE"); \
        $display("############# Test [FAILED] ############"); \
        $finish; \
    end \

module tb_fetch_00();

    localparam NB_DATA       = 32;
    localparam NB_REGISTER   = 5;

    // wire        tx_data;
    // reg [7:0]   alu_A;
    // reg [7:0]   alu_B;
    // reg [5:0]   alu_OPCODE;
    // reg [5:0]   array_OPCODE [0:7];

    wire [NB_DATA       -1 : 0] out_pc_next     ;
    reg  [NB_DATA       -1 : 0] last_pc         ;
    wire [NB_DATA       -1 : 0] out_instruction ;
    wire [NB_REGISTER   -1 : 0] out_rt          ;
    wire [NB_REGISTER   -1 : 0] out_rs          ;
    reg  [NB_DATA       -1 : 0] input_pc_next   ;
    reg input_stall;
    reg input_pc_source;

    // --------------------------------------------------
    // Valid block
    // --------------------------------------------------
    reg valid;

    // --------------------------------------------------
    // Clock block
    // --------------------------------------------------
    reg clock;
    always #1 clock = ~clock;

    // --------------------------------------------------
    // Reset block
    // --------------------------------------------------
    reg reset;
    task reset_dut;
        begin
            reset = 1'b1;
            repeat (5) begin
                @(posedge clock);
            end
            reset = 1'b0;
        end
    endtask

    // --------------------------------------------------
    // Data Send UART block
    // --------------------------------------------------
    reg rx_data;
    integer i;
    task send_one_bit_uart;
        input wire bit_to_send;
        begin
            // segun un baudrate de 9600 y haciendo de cuenta que el clock es de 100mhz,
            // el tiempo de cada bit es por cada N clocks x M ticks (N=650, M=16)
            rx_data = bit_to_send;
            repeat (650*16) begin
                @(posedge clock);
            end
        end
    endtask

    task send_data_to_rx;
        input [7:0] i_data;

        begin
            send_one_bit_uart(1'b0); // start bit
            for(i=0; i<8; i=i+1) begin
                send_one_bit_uart(i_data[i]);
            end
            send_one_bit_uart(1'b1); // stop bit
        end
    endtask

    // --------------------------------------------------
    // DUT Instantiation
    // --------------------------------------------------
    fetch_stage
    #(
    )
    u_fetch_stage
    (
        .o_pc_next          (out_pc_next        ),
        .o_instruction      (out_instruction    ),
        .o_rs               (out_rs             ),
        .o_rt               (out_rt             ),

        .i_pc_next          (input_pc_next      ),
        .i_stall            (input_stall        ),
        .i_pc_src           (input_pc_source    ),
        .i_valid            (valid              ),
        .i_clock            (clock              ),
        .i_reset            (reset              )
    );

    initial begin

        //Definicion OPCODE
        // array_OPCODE[0] = 6'b100000;    //ADD
        // array_OPCODE[1] = 6'b100010;    //SUB
        // array_OPCODE[2] = 6'b100100;    //AND
        // array_OPCODE[3] = 6'b100101;    //OR
        // array_OPCODE[4] = 6'b100110;    //XOR
        // array_OPCODE[5] = 6'b000011;    //SRA
        // array_OPCODE[6] = 6'b000010;    //SRL
        // array_OPCODE[7] = 6'b100111;    //NOR

        i = 0;

        valid           = 1'b0;
        input_stall     = 1'b0;
        input_pc_source = 1'b0;
        last_pc         = 32'b0;

        //Generacion de numeros random
        // alu_A = $random();
        // alu_B = $urandom();
        // alu_OPCODE = array_OPCODE[$urandom()%8];

        //Comienzo de test
        $display("############# Test START ############\n");
        reset = 1'b0;
        clock = 1'b0;

        reset_dut();
        valid = 1'b1;

        repeat(10) begin
            @(posedge clock);

            $display("checking assertion | PC = <%h> | last = <%h>", out_pc_next, last_pc);
            `assert(out_pc_next == last_pc+1);

            last_pc = out_pc_next;
        end

        // send_one_bit_uart(1'b1);

        // send_data_to_rx(alu_A);

        // send_one_bit_uart(1'b1); // stop bit

        // send_data_to_rx(alu_B);

        // send_one_bit_uart(1'b1); // stop bit

        // send_data_to_rx(alu_OPCODE);

        // espera que termine de transmitir el resultado
        // @(posedge tx_done);

        #10

        // if(tx_buffer != alu_data) begin
        //     $error("error!");
        //     $display("############# FAILED Test ############");
        //     $finish();
        // end
        // else begin
        //     $display("############# SUCCESS Test ############");
        //     $finish();
        // end
        $display("############# Test [PASSED] ############");
        $finish();
    end
endmodule