`timescale 1ns / 1ps


module tb_memory_stage_00();

    localparam NB_DATA       = 32;
    localparam NB_BYTE       = 8;

    `include "common_defs.v"

    // --------------------------------------------------
    // DUT Instantiation
    // --------------------------------------------------

    memory_stage u_memory_stage
    (
        .o_pc_4             (),
        .o_jump             (),
        .o_flush            (),
        .o_mem_to_reg       (),
        .o_reg_write        (),
        .o_halt             (),
        .o_pc_src           (),
        .o_read_data        (),
        .o_alu_result       (),
        .o_rt_rd            (),

        .i_branch           (),
        .i_jump             (),
        .i_mem_read         (),
        .i_mem_write        (),
        .i_mem_to_reg       (),
        .i_reg_write        (),
        .i_halt             (1'b0               ),
        .i_exec_mode        (1'b0               ),
        .i_step             (1'b0               ),
        .i_pc_4             (),
        .i_opcode           (),
        .i_pc_branch        (),
        .i_zero             (),
        .i_alu_result       (),
        .i_read_data_2      (),
        .i_rt_rd            (),
        .i_valid            (1'b1               ),
        .i_reset            (reset              ),
        .i_clock            (clock              )
    );

    initial begin

        $display("############# Test START ############\n");
        test_startup();

        repeat(200) begin
            @(posedge clock);
        end

        #10

        $display("############# Test [PASSED] ############");
        $finish();
    end
endmodule
