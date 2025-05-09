`timescale 1ns / 1ps


module tb_top();

    localparam NB_DATA       = 32;
    localparam NB_BYTE       = 8;

    `include "common_defs.v"
    `include "uart_utils.v"

    // --------------------------------------------------------
    // Send program codified in string to the UART inside MIPS
    // --------------------------------------------------------
    string token;
    integer jj = 0;
    int val;
    bit [7:0] variable_byte;

    task parse_hex_string;
        input string hex_str;

        begin
            while (jj < hex_str.len()) begin
                if (hex_str[jj] == " ") begin
                  jj++;
                  continue;
                end

                // Tomar de a 2 caracteres (1 byte)
                if (jj + 1 < hex_str.len()) begin
                    token = hex_str.substr(jj, jj+1);
                    jj += 2;

                    $display("token = %s\n", token);
                    val = token.atohex(); // Convertir a entero

                    $display("val = %2x\n", val);
                    // $display("Byte = 0x%02x\n", variable_byte);
                    variable_byte = val[7:0];

                    send_data_to_rx(variable_byte);
                    @(posedge clock);
                end
            end
        end
    endtask

    // --------------------------------------------------
    // DUT Instantiation
    // --------------------------------------------------
    top mips_top
    (
        .o_leds             (               ),
        .o_uart_tx          (               ),
        .o_program_loaded   (               ),
        .o_program_ended    (               ),
        .o_test             (               ),
        .i_test             (1'b0           ),
        .i_uart_rx          (rx_data        ),
        .i_reset            (reset          ),
        .i_clock            (clock          )
    );

    initial begin
        string data_to_send;
        string data_ggg = "2001 0005 2002 0000 2003 0001 2004 003c 201f 0000 0061 282a 1005 0002 2063 0001 0800 0005 0043 1021 0c00 0011 2007 0045 2042 000a 0080 a009 0800 0013 2042 000a 0280 0008 2042 000a 03e0 0008 4000 0000 f400 0000 ";
        string data_hhh = "2001 0000 2002 000a 2003 0001 2004 0000 0022 282a 1005 0004 0083 2021 2886 000f 2021 0001 0800 0004 4000 0000 f400 0000 ";
        string data_iii = "2001 0005 2002 0000 2003 0001 2004 0040 201f 0000 0061 282a 1005 0002 2063 0001 0800 0005 0043 1021 0c00 0012 2007 0045 2042 000a 4000 0000 0080 a009 0800 0014 2042 000a 0280 0008 2042 000a 03e0 0008 4000 0000 f400 0000 ";

        data_to_send = data_iii;

        $display("############# Test START ############\n");
        test_startup();

        send_data_to_rx("L");

        parse_hex_string(data_to_send);

        repeat(15) begin
            @(posedge clock);
        end

        send_data_to_rx("E");

        repeat(200) begin
            @(posedge clock);
        end

        $display("############# Test [PASSED] ############");
        $finish();
    end
endmodule
