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

module tb_register_bank_00();

    localparam NB_DATA      = 32;
    localparam N_REGISTERS  = 32;
    localparam NB_REGISTER  = 5;

    wire [NB_DATA       -1 : 0] data_read_reg_0     ;
    wire [NB_DATA       -1 : 0] data_read_reg_1     ;
    reg  [NB_REGISTER   -1 : 0] reg_sel_0           ;
    reg  [NB_REGISTER   -1 : 0] reg_sel_1           ;
    reg  [NB_REGISTER   -1 : 0] data_reg_write_sel  ;
    reg  [NB_DATA       -1 : 0] data_reg_write      ;
    reg                         write_reg_enable    ;

    reg  [NB_DATA       -1 : 0] registers [0 : N_REGISTERS-1];
    integer                     i;

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

    task write_register_bank;
        begin
            write_reg_enable = 1'b1;
            i = 0; // register 0 is not writable and contains all 0's
            repeat(N_REGISTERS) begin
                data_reg_write_sel = i;
                data_reg_write = registers[i];
                i = i + 1;
                @(posedge clock);
            end
            write_reg_enable = 1'b0;
        end
    endtask


    task fill_registers;
        begin
            for(i=0; i<N_REGISTERS; i=i+1) begin
                registers[i] = $urandom();
            end
        end
    endtask

    // --------------------------------------------------
    // DUT Instantiation
    // --------------------------------------------------
    register_bank u_register_bank
    (
        .o_data_read_reg_0  (data_read_reg_0        ),
        .o_data_read_reg_1  (data_read_reg_1        ),

        .i_read_reg_sel_0   (reg_sel_0              ),
        .i_read_reg_sel_1   (reg_sel_1              ),
        .i_write_reg_sel    (data_reg_write_sel     ),
        .i_write_reg_data   (data_reg_write         ),
        .i_write_reg_enable (write_reg_enable       ),
        .i_valid            (valid                  ),
        .i_reset            (reset                  ),
        .i_clock            (clock                  )
    );

    initial begin

        valid               = 1'b0;
        reg_sel_0           = 5'b0;
        reg_sel_1           = 5'b0;
        data_reg_write_sel  = 5'b0;
        data_reg_write      = 32'b0;
        write_reg_enable    = 1'b0;

        // Comienzo de test
        $display("############# Test START ############\n");
        reset = 1'b0;
        clock = 1'b1;

        reset_dut();
        valid = 1'b1;

        // initial transitions
        repeat(10) begin
            @(posedge clock);
        end

        repeat(10) begin
            fill_registers();

            for(i=0; i<N_REGISTERS; i=i+1) begin
                $display("REG %d\t= %h", i, registers[i]);
            end

            write_register_bank();

            // check written data
            i = 1;
            repeat(N_REGISTERS-1) begin
                reg_sel_0 = i;
                reg_sel_1 = i;

                @(posedge clock);

                $display("checking register %d | %h | %h", i, data_read_reg_0, registers[i]);
                `assert(data_read_reg_0 == registers[i]);
                `assert(data_read_reg_1 == registers[i]);

                i = i + 1;
            end

            #10;
        end

        $display("############# Test [PASSED] ############");
        $finish();
    end
endmodule