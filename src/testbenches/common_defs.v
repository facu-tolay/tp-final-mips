`define assert(value) \
    if (value == 0) begin \
        $display("ASSERTION EXPECTED TO BE TRUE"); \
        $display("############# Test [FAILED] ############"); \
        $finish; \
    end \

