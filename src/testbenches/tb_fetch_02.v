`timescale 1ns / 1ps

// TB_FETCH_02
//      Verifica que cada ciclo con valid 1 se incremente el PC en 1.
//      Setear input_pc_source=1 y input_pc_next=rand y verificar que se mantenga el valor
//      Luego setear input_pc_source=0 y verificar que se incremente desde el valor random
//      Repetir con N valores random

`define assert(value) \
    if (value == 0) begin \
        $display("ASSERTION EXPECTED TO BE TRUE"); \
        $display("############# Test [FAILED] ############"); \
        $finish; \
    end \

module tb_fetch_02();

    localparam NB_DATA       = 32;
    localparam NB_REGISTER   = 5;

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
            // delayed reset
            repeat (2) begin
                @(posedge clock);
            end

            reset = 1'b1;
            repeat (5) begin
                @(posedge clock);
            end
            reset = 1'b0;
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

        valid           = 1'b0;
        input_stall     = 1'b0;
        input_pc_source = 1'b0;
        input_pc_next   = 31'b0;
        last_pc         = 32'b0;

        // Comienzo de test
        $display("############# Test START ############\n");
        reset = 1'b0;
        clock = 1'b1;

        reset_dut();
        valid = 1'b1;

        // initial transitions
        repeat(10) begin
            @(posedge clock);

            `assert(out_pc_next == last_pc+1);
            last_pc = out_pc_next;
        end

        repeat(10) begin

            // set pc_src=1 y pc_next=rand --> verificar que se mantiene en ese valor
            input_pc_source = 1'b1;
            input_pc_next = $urandom();
            last_pc = input_pc_next;
            $display("setting pc_src = 1 | pc_next = <%h>", input_pc_next);

            repeat(10) begin
                @(posedge clock);

                `assert(out_pc_next == last_pc);
            end

            // set pc_src=1 --> verificar que se incrementa desde el valor random
            input_pc_source = 1'b0;
            $display("setting pc_src = 0");

            repeat(10) begin
                @(posedge clock);

                `assert(out_pc_next == last_pc+1);
                last_pc = out_pc_next;
            end
        end

        #10

        $display("############# Test [PASSED] ############");
        $finish();
    end
endmodule