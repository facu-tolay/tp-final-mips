
module fetch_stage
#(
    parameter N_BITS        = 32,
    parameter N_BITS_REG    = 5
)
(
    input wire [N_BITS      -1:0]   i_pc_salto,
    input wire                      i_halt,
    input wire                      i_stall,
    input wire                      i_pc_src,    //señal de control
    input wire                      i_step,      //ejecutar un paso
    input wire                      i_clock,
    input wire                      i_reset,
    input wire                      i_valid,

    output reg [N_BITS      -1:0]   o_pc_4,
    output reg                      o_halt,
    output reg [N_BITS      -1:0]   o_instruction,
    output reg [N_BITS_REG  -1:0]   o_rs,
    output reg [N_BITS_REG  -1:0]   o_rt
);

    reg  [N_BITS-1:0] pc;
    wire [N_BITS-1:0] instruction;

    always@(posedge i_clock)begin: read_inst
        if(i_reset) begin
            pc <= {N_BITS{1'b0}};
        end
        else if(i_valid) begin // decide el valor del PC
            if(i_pc_src)
                pc <= i_pc_salto;
            else if(~i_halt && ~i_stall)
                pc <= pc + 1;
            else
                pc <= pc;
        end
    end

    always@(negedge i_clock)begin: write_inst
        if(i_reset) begin
            o_pc_4 <= 1'b1;
        end
        else if(i_valid && ~i_stall) begin
            o_pc_4        <= pc + 1;
            o_instruction <= instruction;
            o_halt        <= i_halt;
            o_rs          <= instruction[25:21];
            o_rt          <= instruction[20:16];
        end
    end

endmodule