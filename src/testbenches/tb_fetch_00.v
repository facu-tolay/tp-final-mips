`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/24/2020 04:26:09 PM
// Design Name: 
// Module Name: tb_interface
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module tb_interface();

    wire        tx_data;
    reg [7:0]   alu_A;
    reg [7:0]   alu_B;
    reg [5:0]   alu_OPCODE;
    reg [5:0]   array_OPCODE [0:7];

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
    top
    #(
    )
    u_top
    (
        .i_rx                   (rx_data    ),
        .i_clock                (clock      ),
        .i_reset                (reset      ),
        .o_data                 (data_out   ),
        .o_tx                   (tx_data    ),
        .o_tx_done_tick         (tx_done    ),
        .o_rx_done_tick         (rx_done    )
    );

    initial begin

        //Definicion OPCODE
        array_OPCODE[0] = 6'b100000;    //ADD
        array_OPCODE[1] = 6'b100010;    //SUB
        array_OPCODE[2] = 6'b100100;    //AND
        array_OPCODE[3] = 6'b100101;    //OR
        array_OPCODE[4] = 6'b100110;    //XOR
        array_OPCODE[5] = 6'b000011;    //SRA
        array_OPCODE[6] = 6'b000010;    //SRL
        array_OPCODE[7] = 6'b100111;    //NOR

        i = 0;

        //Generacion de numeros random
        alu_A = $random();
        alu_B = $urandom();
        alu_OPCODE = array_OPCODE[$urandom()%8];

        //Comienzo de test
        $display("############# Test START ############");
        reset = 1'b0;
        clock = 1'b0;
        rx_data = 1'b1; // idle state for RX is 1'b1

        reset_dut();

        send_one_bit_uart(1'b1);

        send_data_to_rx(alu_A);

        send_one_bit_uart(1'b1); // stop bit

        send_data_to_rx(alu_B);

        send_one_bit_uart(1'b1); // stop bit

        send_data_to_rx(alu_OPCODE);

        // espera que termine de transmitir el resultado
        @(posedge tx_done);

        #10000

        // if(tx_buffer != alu_data) begin
        //     $error("error!");
        //     $display("############# FAILED Test ############");
        //     $finish();
        // end
        // else begin
        //     $display("############# SUCCESS Test ############");
        //     $finish();
        // end
        $display("############# END Test ############");
        $finish();
    end
endmodule