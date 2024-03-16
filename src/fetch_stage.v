
module fetch_stage
#(
    parameter N_BITS        = 32,
    parameter N_BITS_REG    = 5
)
(
    input wire [N_BITS      -1:0]   i_pc_salto      ,
    input wire                      i_halt          ,
    input wire                      i_stall         ,
    input wire                      i_pc_src        ,
    input wire                      i_clock         ,
    input wire                      i_reset         ,
    input wire                      i_valid         ,

    output reg [N_BITS      -1:0]   o_pc_next       ,
    output reg                      o_halt          ,
    output reg [N_BITS      -1:0]   o_instruction   ,
    output reg [N_BITS_REG  -1:0]   o_rs            ,
    output reg [N_BITS_REG  -1:0]   o_rt
);

    reg  [N_BITS-1:0] pc;
    wire [N_BITS-1:0] instruction;

    ram_memory
    #(
        .RAM_WIDTH       (32            ),
        .RAM_DEPTH       (2048          )
    )
    u_program_memory
    (
        .o_instruction  (instruction    ),
        .i_address      (pc             ),
        .i_clock        (i_clock        ),
        .i_reset        (i_reset        ),
        .i_valid        (i_valid        )
    );

    always @(posedge i_clock) begin: pc_update
        if(i_reset) begin
            pc <= {N_BITS{1'b0}};
        end
        else if(i_valid) begin // decide el valor del PC
            if(i_pc_src) begin
                pc <= i_pc_salto;
            end
            else if(~i_halt && ~i_stall) begin
                pc <= pc + 1;
            end
            else begin
                pc <= pc;
            end
        end
    end

    // FIXME mejorar este always
    always @(negedge i_clock) begin: output_block
        if(i_reset) begin
            o_pc_next <= 1'b1;
        end
        else if(i_valid && ~i_stall) begin
            o_pc_next     <= pc;
            o_instruction <= instruction;
            o_halt        <= i_halt;
            o_rs          <= instruction[25:21];
            o_rt          <= instruction[20:16];
        end
    end

endmodule