module fetch
#(
	//Parameters
	parameter N_BITS     = 32,
	parameter N_BITS_REG = 5
)
(
	//inputs
	input wire                   i_clk, i_reset, i_valid,
	input wire [N_BITS-1:0]      i_pc_salto,
	input wire                   i_halt,
	input wire                   i_stall,
	input wire                   i_pc_src,    //señal de control
    input wire                   i_step,      //ejecutar un paso
    
	//output
	output reg [N_BITS-1:0]     o_pc_4,
	output reg                  o_halt,
	output reg [N_BITS-1:0]     o_instruccion,
	output reg [N_BITS_REG-1:0] o_rs,
	output reg [N_BITS_REG-1:0] o_rt
);

    reg [N_BITS-1:0]     pc;
    
    wire [N_BITS-1:0] instruccion;
    
    always@(posedge i_clk)begin:lectura
        if(i_reset)
        begin
            pc <= {N_BITS{1'b0}};
        end
        else if(i_valid)// decide el valor del PC
        begin
                if(i_pc_src)
                    pc <= i_pc_salto;
                else if(~i_halt && ~i_stall)
                    pc <= pc + 1;
                else
                    pc <= pc;
        end 
        
    end
    
    always@(negedge i_clk)begin:escritura
        if(i_reset)
            o_pc_4 <= 1'b1;
        else if(i_valid && ~i_stall)
        begin
                o_pc_4        <= pc + 1;
                o_instruccion <= instruccion;
                o_halt        <= i_halt;
                o_rs          <= instruccion[25:21];
                o_rt          <= instruccion[20:16];
        end
    end

endmodule