`timescale 1ns / 1ps

// TB_FETCH_01
//      Verifica que cada ciclo con valid 1 se incremente el PC en 1.
//      Variar el estado de la señal stall y verificar que si stall = 0 el PC incrementa.
//      En caso contrario el PC se mantiene constante.

`define assert(value) \
    if (value == 0) begin \
        $display("ASSERTION EXPECTED TO BE TRUE"); \
        $display("############# Test [FAILED] ############"); \
        $finish; \
    end \

module tb_fetch_01();

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
        last_pc         = 32'b0;

        // Comienzo de test
        $display("############# Test START ############\n");
        reset = 1'b0;
        clock = 1'b1;

        reset_dut();
        valid = 1'b1;

        repeat(10) begin

            input_stall = 1'b0;
            repeat(10) begin
                @(posedge clock);

                $display("with stall 0 | PC = <%h> | last = <%h>", out_pc_next, last_pc);
                `assert(out_pc_next == last_pc+1);
                last_pc = out_pc_next;
            end

            input_stall = 1'b1;
            repeat(10) begin
                @(posedge clock);

                $display("with stall 1 | PC = <%h> | last = <%h>", out_pc_next, last_pc);
                `assert(out_pc_next == last_pc);
            end
        end

        #10

        $display("############# Test [PASSED] ############");
        $finish();
    end
endmodule