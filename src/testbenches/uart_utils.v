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
