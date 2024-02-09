`timescale 1ns / 1ps

module tb_fetch();

    // INPUTS
    reg         clk;
    reg         reset;
    reg         valid;
    reg         halt;
    reg         pc_salto;
    reg         stall;
    reg         pc_src;
    
    initial begin
        clk   = 1'b0;
        halt  = 1'b0;
        reset = 1'b1;
        pc_salto = 1'b0;
        stall = 1'b0;
        pc_src = 1'b0;
        valid = 1'b0;

        #20
        reset = 1'b0; 
        
        #40 
        valid = 1'b1;
        
        #100
        halt = 1'b1;
        #20
        $finish;
    end
 
    always #10 clk = ~clk;  // Simulacion de clock 100MHz

    fetch u_fetch
    (
        .i_clk(clk), .i_reset(reset), .i_valid(valid), 
        .i_halt(halt), .i_pc_salto(pc_salto), .i_stall(stall),
        .i_pc_src(pc_src),
        .o_pc_4(o_pc_4)
    );

endmodule