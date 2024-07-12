`timescale 1ns / 1ps

// prueba TX solo con i_halt = true

module tb_pipeline_top_00();

    localparam NB_DATA       = 32;
    localparam NB_REGISTER   = 5;
    localparam NB_STATE      = 4;
    localparam NB_BYTE       = 8;
    localparam N_CLOCKS_BETWEEN_DATA = 4;

    `include "../common_defs.v"

    // --------------------------------------------------
    // DUT Instantiation
    // --------------------------------------------------
    reg execution_mode;
    reg step;

    pipeline_top u_pipeline_top
    (
        .o_pc                   (                   ),
        .o_registros            (                   ),
        .o_registro             (                   ),
        .o_data_memory          (                   ),
        .o_ciclos               (                   ),
        .o_n_reg                (                   ),
        .o_halt                 (                   ),

        .i_execution_mode       (execution_mode     ),
        .i_step                 (step               ),
        .i_valid                (valid              ),
        .i_reset                (reset              ),
        .i_clock                (clock              )
    );

    initial begin

        valid           = 1'b1;
        execution_mode  = 1'b0;
        step            = 1'b0;

        $display("############# Test START ############\n");
        test_startup();

        repeat(650*16) begin
            @(posedge clock);
        end

        @(posedge clock);
        @(posedge clock);
        @(posedge clock);
        @(posedge clock);
        @(posedge clock);
        @(posedge clock);

        #10

        $display("############# Test [PASSED] ############");
        $finish();
    end
endmodule
