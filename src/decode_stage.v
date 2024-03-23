
module decode_stage
#(
    parameter NB_DATA     = 32,
    parameter NB_REGISTER = 5
)
(
    output wire [NB_REGISTER -1 : 0] o_rs                   ,
    output wire [NB_REGISTER -1 : 0] o_rd                   ,
    output wire [NB_REGISTER -1 : 0] o_rt                   ,
    output wire [NB_REGISTER -1 : 0] o_sa                   ,
    output wire [NB_REGISTER    : 0] o_opcode               ,
    output wire [NB_DATA     -1 : 0] o_pc_next              ,
    output wire [NB_DATA     -1 : 0] o_data_read_reg_0      ,
    output wire [NB_DATA     -1 : 0] o_data_read_reg_1      ,
    output wire [NB_DATA     -1 : 0] o_extended             ,
    output wire [NB_DATA     -7 : 0] o_instruction_index    ,

    //INPUTS
    input wire [NB_DATA      -1 : 0] i_instruction          ,
    input wire [NB_DATA      -1 : 0] i_pc_next              ,
    input wire [NB_DATA      -1 : 0] i_data_reg_write       ,
    input wire [NB_REGISTER  -1 : 0] i_data_reg_write_sel   ,
    input wire                       i_write_reg_enable     ,
    input wire                       i_valid                ,
    input wire                       i_reset                ,
    input wire                       i_clock
);

    wire [NB_DATA       -1  : 0] data_read_reg_0;
    wire [NB_DATA       -1  : 0] data_read_reg_1;

    reg [NB_DATA        -1  : 0] instruction;
    reg [NB_DATA        -1  : 0] pc_next;
    reg [NB_REGISTER    -1  : 0] rs;
    reg [NB_REGISTER    -1  : 0] rt;
    reg [NB_REGISTER    -1  : 0] rd;
    reg [NB_REGISTER    -1  : 0] sa;
    reg [NB_DATA        -17 : 0] offset;
    reg [NB_DATA        -1  : 0] data_reg_write;
    reg [NB_DATA        -13 : 0] instruction_index;

    // --------------------------------------------------
    // Next PC delay
    // --------------------------------------------------
    always @(posedge i_clock) begin: reg_pc_next
        if(i_reset) begin
            pc_next <= 32'b0;
        end
        else if(i_valid) begin
            pc_next <= i_pc_next;
        end
    end

    // --------------------------------------------------
    // Instruction delay
    // --------------------------------------------------
    always @(posedge i_clock) begin: reg_instruction
        if(i_reset) begin
            instruction <= 32'b0;
        end
        else if(i_valid) begin
            instruction <= i_instruction;
        end
    end

    always @(negedge i_clock) begin : reg_rs
        if(i_reset) begin
            rs <= 5'b0;
        end
        if(i_valid) begin
            rs <= instruction[25:21];
        end
    end

    always @(negedge i_clock) begin : reg_rt
        if(i_reset) begin
            rt <= 5'b0;
        end
        if(i_valid) begin
            rt <= instruction[20:16];
        end
    end

    always @(negedge i_clock) begin : reg_rd
        if(i_reset) begin
            rd <= 5'b0;
        end
        if(i_valid) begin
            rd <= instruction[15:11];
        end
    end

    always @(negedge i_clock) begin : reg_sa
        if(i_reset) begin
            sa <= 5'b0;
        end
        if(i_valid) begin
            sa <= instruction[10:6];
        end
    end

    always @(negedge i_clock) begin : reg_offset
        if(i_reset) begin
            offset <= 16'b0;
        end
        if(i_valid) begin
            offset <= instruction[15:0];
        end
    end

    always @(negedge i_clock) begin : reg_instr_index
        if(i_reset) begin
            instruction_index <= 20'b0;
        end
        if(i_valid) begin
            instruction_index <= instruction[25:0];
        end
    end

    // --------------------------------------------------
    // Register data write
    // --------------------------------------------------
    always @(negedge i_clock) begin : data_reg_write
        if(i_reset) begin
            data_reg_write <= 32'b0;
        end
        if(i_valid) begin
            data_reg_write <= i_data_reg_write;
        end
    end

    // --------------------------------------------------
    // Register bank
    // --------------------------------------------------
    register_bank u_register_bank
    (
        .o_data_read_reg_0  (data_read_reg_0        ),
        .o_data_read_reg_1  (data_read_reg_1        ),

        .i_read_reg_sel_0   (rs                     ),
        .i_read_reg_sel_1   (rt                     ),
        .i_write_reg_sel    (i_data_reg_write_sel   ),
        .i_write_reg_data   (data_reg_write         ),
        .i_write_reg_enable (i_write_reg_enable     ),
        .i_valid            (i_valid                ),
        .i_reset            (i_reset                ),
        .i_clock            (i_clock                )
    );

    // --------------------------------------------------
    // Output assignments
    // --------------------------------------------------
    assign o_pc_next            = pc_next;

    assign o_rs                 = rs;
    assign o_rt                 = rt;
    assign o_rd                 = rd;
    assign o_sa                 = sa;
    assign o_instruction_index  = instruction_index;

    assign o_extended           = {{(NB_DATA-16){offset[15]}}, offset};

    assign o_data_read_reg_0    = data_read_reg_0;
    assign o_data_read_reg_1    = data_read_reg_1;

endmodule
