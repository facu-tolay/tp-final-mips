// --------------------------------------------------
// Assertions
// --------------------------------------------------
`define assert(value) \
    if (value == 0) begin \
        $display("ASSERTION EXPECTED TO BE TRUE"); \
        $display("############# Test [FAILED] ############"); \
        $finish; \
    end \

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
// Valid block
// --------------------------------------------------
reg valid;


// --------------------------------------------------
// Test startup
// --------------------------------------------------
task test_startup;
    begin
        reset = 1'b0;
        clock = 1'b1;

        reset_dut();

        valid = 1'b1;
    end
endtask


