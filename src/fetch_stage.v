
module fetch_stage
#(
    parameter NB_DATA       = 32,
    parameter NB_REGISTER   = 5
)
(
    output reg [NB_DATA     -1 : 0] o_pc_next           , // FIXME cambiar todo esto a wires
    output reg [NB_DATA     -1 : 0] o_instruction       ,
    output reg [NB_REGISTER -1 : 0] o_rs                ,
    output reg [NB_REGISTER -1 : 0] o_rt                ,
    output reg                      o_halt              ,

    input wire [NB_DATA     -1 : 0] i_pc_next           ,
    input wire                      i_pc_src            ,
    input wire                      i_stall             ,
    input wire                      i_halt              ,
    input wire                      i_execution_mode    ,
    input wire                      i_step              ,
    input wire                      i_valid             ,
    input wire                      i_reset             ,
    input wire                      i_clock
);

    reg  [NB_DATA -1 : 0]   pc;
    wire [NB_DATA -1 : 0]   instruction;
    wire                    fetch_new_instruction;
    reg                     valid_d;

    assign fetch_new_instruction = ~i_execution_mode || (i_execution_mode && i_step);

    // --------------------------------------------------
    // Program memory
    // --------------------------------------------------
    ram_memory
    #(
        .NB_DATA            (32             ),
        .RAM_DEPTH          (256            ),
        .NB_ADDRESS         (8              )
    )
    u_program_memory
    (
        .o_read_data        (instruction    ),

        .i_read_address     (pc             ),
        .i_write_data       (               ),
        .i_write_enable     (1'b0           ),
        .i_write_data_next  (1'b0           ),
        .i_clock            (i_clock        ),
        .i_reset            (i_reset        )
    );

    // --------------------------------------------------
    // PC update block
    // --------------------------------------------------
    always @(posedge i_clock) begin: pc_update
        if(i_reset) begin
            pc <= {NB_DATA {1'b0}};
        end
        // else if(i_valid) begin
        else if(valid_d) begin
            if(fetch_new_instruction) begin
                if(i_pc_src) begin // FIXME mejorar usando un switch
                    pc <= i_pc_next;
                end
                else if(~i_halt && ~i_stall) begin
                    pc <= pc + 32'h1;
                end
                else begin
                    pc <= pc;
                end
            end
        end
    end

    // --------------------------------------------------
    // Valid delay
    // --------------------------------------------------
    always @(negedge i_clock) begin
        if(i_reset) begin
            valid_d <= 1'b0;
        end
        else begin
            valid_d <= i_valid;
        end
    end

    // --------------------------------------------------
    // Output PC next
    // --------------------------------------------------
    always @(negedge i_clock) begin
        if(i_reset) begin
            o_pc_next <= {NB_DATA {1'b0}};
        end
        else if(i_valid) begin
            if(~i_stall && fetch_new_instruction) begin
                o_pc_next <= pc;
            end
        end
    end

    // --------------------------------------------------
    // Output instruction read
    // --------------------------------------------------
    always @(negedge i_clock) begin
        if(i_reset) begin
            o_instruction <= {NB_DATA {1'b0}};
        end
        else if(i_valid) begin
            if(~i_stall && fetch_new_instruction) begin
                o_instruction <= instruction;
            end
        end
    end

    // --------------------------------------------------
    // Output RS
    // --------------------------------------------------
    always @(negedge i_clock) begin
        if(i_reset) begin
            o_rs <= {NB_REGISTER {1'b0}};
        end
        else if(i_valid) begin
            if(~i_stall && fetch_new_instruction) begin
                o_rs <= instruction[25:21];
            end
        end
    end

    // --------------------------------------------------
    // Output RT
    // --------------------------------------------------
    always @(negedge i_clock) begin
        if(i_reset) begin
            o_rt <= {NB_REGISTER {1'b0}};
        end
        else if(i_valid) begin
            if(~i_stall && fetch_new_instruction) begin
                o_rt <= instruction[20:16];
            end
        end
    end

    // --------------------------------------------------
    // Output halt
    // --------------------------------------------------
    always @(negedge i_clock) begin
        if(i_reset) begin
            o_halt <= {NB_REGISTER {1'b0}};
        end
        else if(i_valid) begin
            if(~i_stall && fetch_new_instruction) begin
                o_halt <= i_halt;
            end
        end
    end

endmodule