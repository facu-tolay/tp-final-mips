`timescale 1ns / 1ps

//  Xilinx Single Port No Change RAM
//  This code implements a parameterizable single-port no-change memory where when data is written
//  to the memory, the output remains unchanged.  This is the most power efficient write mode.
//  If a reset or enable is not necessary, it may be tied off or removed from the code.

module ram_memory
#(
    parameter RAM_WIDTH = 32,                                   // Specify RAM data width
    parameter RAM_DEPTH = 2048,                                 // Specify RAM depth (number of entries)
    parameter INIT_FILE = "" // Specify name/location of RAM initialization file if using one (leave blank if not)
)
(
    input  wire [RAM_WIDTH-1:0] i_address   ,   // Address bus
    input  wire                 i_valid     ,
    input                       i_reset     ,
    input                       i_clock     ,   // Clock

    output wire [RAM_WIDTH-1:0] o_instruction   // RAM output data
);

    reg [RAM_WIDTH  -1 : 0] mem [0 : RAM_DEPTH];
    // reg [RAM_WIDTH  -1:0] ram_data = {RAM_DEPTH{1'b0}};

    always @(i_clock) begin
        if(i_reset) begin
            mem[0]  = 32'hCCDDEEFF;
            mem[1]  = 32'h11223344;
            mem[2]  = 32'hAABBCCDD;
            mem[3]  = 32'h55667788;
            mem[4]  = 32'hCCDDEEFF;
            mem[5]  = 32'h11223344;
            mem[6]  = 32'hAABBCCDD;
            mem[7]  = 32'h55667788;
            mem[8]  = 32'hCCDDEEFF;
            mem[9]  = 32'h11223344;
            mem[10] = 32'hAABBCCDD;
            mem[11] = 32'h55667788;
            mem[12] = 32'hCCDDEEFF;
            mem[13] = 32'h11223344;
            mem[14] = 32'hAABBCCDD;
            mem[15] = 32'h55667788;
            mem[16] = 32'hCCDDEEFF;
            mem[17] = 32'h11223344;
            mem[18] = 32'hAABBCCDD;
            mem[19] = 32'h55667788;
            mem[20] = 32'hCCDDEEFF;
            mem[21] = 32'h11223344;
            mem[22] = 32'hAABBCCDD;
            mem[23] = 32'h55667788;
            mem[24] = 32'hCCDDEEFF;
            mem[25] = 32'h11223344;
            mem[26] = 32'hAABBCCDD;
            mem[27] = 32'h55667788;
            mem[28] = 32'hCCDDEEFF;
            mem[29] = 32'h11223344;
            mem[30] = 32'hAABBCCDD;
            mem[31] = 32'h55667788;
        end
    end

    // always @(*) begin
    //     ram_data <= mem[i_address];
    // end

    assign o_instruction = mem[i_address];


    // ##############

    // wire                 enable       = 1; // RAM Enable, for additional power savings, disable port when not in use
    // wire [RAM_WIDTH-1:0] input_data   = 0; // RAM input data
    // wire                 reset        = 0; // Output reset (does not affect memory contents)
    // wire                 reg_enable   = 1; // Output register enable

    // reg [RAM_WIDTH  -1:0] PRAM [RAM_DEPTH -1:0];
    // reg [RAM_WIDTH  -1:0] ram_data = {RAM_WIDTH{1'b0}};
    // reg load_done = 1'b0;

    // always@(*) begin: load_data_file
    //     if(i_valid) begin
    //         if (~load_done && INIT_FILE != "") begin
    //             $readmemb(INIT_FILE, PRAM, 0, RAM_DEPTH-1);
    //             load_done = 1'b1;
    //         end
    //     end
    // end

    // always @(*) begin
    //     if (enable && i_valid) begin
    //         ram_data <= PRAM[i_address];
    //     end
    // end

    // // The following is a 1 clock cycle read latency at the cost of a longer clock-to-out timing
    // assign o_instruction = ram_data;

    // //  The following function calculates the address width based on specified RAM depth
    // function integer clogb2;
    //     input integer depth;
    //         for (clogb2=0; depth>0; clogb2=clogb2+1) begin
    //             depth = depth >> 1;
    //         end
    // endfunction

endmodule