
module fetch_stage
#(
    parameter NB_DATA       = 32,
    parameter NB_REGISTER   = 5
)
(
    output reg [NB_DATA     -1 : 0] o_pc_next       ,
    output reg [NB_DATA     -1 : 0] o_instruction   ,
    output reg [NB_REGISTER -1 : 0] o_rs            ,
    output reg [NB_REGISTER -1 : 0] o_rt            ,

    input wire [NB_DATA     -1 : 0] i_pc_next       ,
    input wire                      i_stall         ,
    input wire                      i_pc_src        ,
    input wire                      i_valid         ,
    input wire                      i_reset         ,
    input wire                      i_clock
);

    reg  [NB_DATA -1 : 0] pc;
    wire [NB_DATA -1 : 0] instruction;

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
            pc <= {NB_DATA {1'b0}};
        end
        else if(i_valid) begin // decide el valor del PC
            if(i_pc_src) begin
                pc <= i_pc_next;
            end
            else if(~i_stall) begin
                pc <= pc + 1;
            end
            else begin
                pc <= pc;
            end
        end
    end

    always @(negedge i_clock) begin
        if(i_reset) begin
            o_pc_next <= {NB_DATA {1'b0}};
        end
        else if(i_valid && ~i_stall) begin
            o_pc_next <= pc;
        end
    end

    always @(negedge i_clock) begin
        if(i_reset) begin
            o_instruction <= {NB_DATA {1'b0}};
        end
        else if(i_valid && ~i_stall) begin
            o_instruction <= instruction;
        end
    end

    always @(negedge i_clock) begin
        if(i_reset) begin
            o_rs <= {NB_REGISTER {1'b0}};
        end
        else if(i_valid && ~i_stall) begin
            o_rs <= instruction[25:21];
        end
    end

    always @(negedge i_clock) begin
        if(i_reset) begin
            o_rt <= {NB_REGISTER {1'b0}};
        end
        else if(i_valid && ~i_stall) begin
            o_rt <= instruction[20:16];
        end
    end

endmodule