`timescale 1ns / 1ps


module tb_ram_memory_00();

    localparam NB_DATA       = 32;
    localparam NB_BYTE       = 8;
    localparam NB_ADDRESS    = 8;
    localparam RAM_DEPTH     = 256;

    `include "common_defs.v"

    // --------------------------------------------------
    // Simulate storing data in memory
    // --------------------------------------------------
    task write_32b_data_to_memory;
        input [NB_DATA-1 : 0] data_word_to_write;

        begin
            memory_data_in  = data_word_to_write;
            write_data_next = 1'b1;
            @(posedge clock);
            write_data_next = 1'b0;

            @(posedge clock);
            @(posedge clock);
            @(posedge clock);
            @(posedge clock);
            @(posedge clock);
            @(posedge clock);
        end
    endtask

    // --------------------------------------------------
    // DUT Instantiation
    // --------------------------------------------------
    wire [NB_DATA       -1 : 0] memory_data_out;
    reg  [NB_DATA       -1 : 0] memory_data_in;
    reg  [NB_ADDRESS    -1 : 0] memory_adrress;
    reg                         write_enable;
    reg                         write_data_next;

    ram_memory u_ram_memory
    (
        .o_data                 (memory_data_out    ),

        .i_address              (memory_adrress     ),
        .i_write_data           (memory_data_in     ),
        .i_write_enable         (write_enable       ),
        .i_write_data_next      (write_data_next    ),
        .i_reset                (reset              ),
        .i_clock                (clock              )
    );

    initial begin

        memory_data_in  = 32'h0;
        memory_adrress  = 8'h0;
        write_enable    = 1'b0;
        write_data_next = 1'b0;

        $display("############# Test START ############\n");
        test_startup();

        write_enable = 1'b1;
        @(posedge clock);

        write_32b_data_to_memory(32'hAABBCC55);
        write_32b_data_to_memory(32'h11223344);
        write_32b_data_to_memory(32'h89ABCDEF);
        write_32b_data_to_memory(32'h00AA00BB);
        write_32b_data_to_memory(32'h5555AAAA);
        write_32b_data_to_memory(32'h11001100);

        write_enable = 1'b0;
        @(posedge clock);
        @(posedge clock);
        @(posedge clock);
        write_enable = 1'b1;
        @(posedge clock);

        write_32b_data_to_memory(32'h00AA00BB);
        write_32b_data_to_memory(32'h5555AAAA);
        write_32b_data_to_memory(32'h11001100);

        #10

        $display("############# Test [PASSED] ############");
        $finish();
    end
endmodule
