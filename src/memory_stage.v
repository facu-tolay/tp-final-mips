module memory_stage
#(
    parameter NB_DATA       = 32    ,
    parameter NB_REGISTER   = 5
)
(
    output wire [NB_DATA        -1 : 0] o_pc_4          ,

    output wire [2              -1 : 0] o_jump          ,
    output wire                         o_flush         ,
    output wire                         o_mem_to_reg    ,
    output wire                         o_reg_write     ,
    output wire                         o_halt          ,
    output wire                         o_pc_src        ,
    output wire [NB_DATA        -1 : 0] o_read_data     ,
    output wire [NB_DATA        -1 : 0] o_alu_result    ,
    output wire [NB_REGISTER    -1 : 0] o_rt_rd         ,

    //MEM - señales de control para acceso a memoria
    input wire                          i_branch        ,
    input wire [1                  : 0] i_jump          ,
    input wire                          i_mem_read      ,
    input wire                          i_mem_write     ,

    //WB  - señales de control para write-back
    input wire                          i_mem_to_reg    ,
    input wire                          i_reg_write     ,
    input wire                          i_halt          ,

    input wire                          i_exec_mode     ,
    input wire                          i_step          ,

    input wire [NB_DATA         -1 : 0] i_pc_4          ,
    input wire [NB_REGISTER        : 0] i_opcode        ,
    input wire [NB_DATA         -1 : 0] i_pc_branch     ,
    input wire                          i_zero          ,
    input wire [NB_DATA         -1 : 0] i_alu_result    ,
    input wire [NB_DATA         -1 : 0] i_read_data_2   ,
    input wire [NB_REGISTER     -1 : 0] i_rt_rd         ,

    input wire                          i_valid         ,
    input wire                          i_reset         ,
    input wire                          i_clock
);

    wire [NB_DATA   -1 : 0] read_data;

    reg                     halt;
    reg                     mem_to_reg;
    reg                     reg_write;
    reg [2          -1 : 0] jump;
    reg [NB_DATA    -1 : 0] alu_result;
    reg [NB_DATA    -1 : 0] pc_4;
    reg [NB_REGISTER-1 : 0] rt_rd;

    reg                     out_mem_to_reg;
    reg                     out_reg_write;
    reg                     out_halt;
    reg [2          -1 : 0] out_jump;
    reg [NB_DATA    -1 : 0] out_alu_result;
    reg [NB_DATA    -1 : 0] out_pc_4;
    reg [NB_DATA    -1 : 0] out_read_data;
    reg [NB_REGISTER-1 : 0] out_rt_rd;

    // always @(posedge i_clock) begin : reg_inputs
    //     if(i_reset) begin
    //         halt        <= 1'b0;
    //         mem_to_reg  <= 1'b0;
    //         reg_write   <= 1'b0;
    //         jump        <= 2'b0;
    //         alu_result  <= {NB_DATA{1'b0}};
    //         pc_4        <= {NB_DATA{1'b0}};
    //         rt_rd       <= {NB_REGISTER{1'b0}};
    //     end
    //     else if(i_valid && (i_exec_mode == 1'b0 || (i_exec_mode && i_step))) begin
    //         halt        <= i_halt;
    //         jump        <= i_jump;
    //         mem_to_reg  <= i_mem_to_reg;
    //         reg_write   <= i_reg_write;
    //         alu_result  <= i_alu_result;
    //         pc_4        <= i_pc_4;
    //         rt_rd       <= i_rt_rd;
    //     end
    // end

    // --------------------------------------------------
    // Memory to register block
    // --------------------------------------------------
    always @(posedge i_clock) begin : mem_to_reg_block
        if(i_reset) begin
            mem_to_reg <= 1'b0;
        end
        else if(i_valid && (i_exec_mode == 1'b0 || (i_exec_mode && i_step))) begin
            mem_to_reg <= i_mem_to_reg;
        end
    end

    // --------------------------------------------------
    // Register write block
    // --------------------------------------------------
    always @(posedge i_clock) begin : reg_write_block
        if(i_reset) begin
            reg_write <= 1'b0;
        end
        else if(i_valid && (i_exec_mode == 1'b0 || (i_exec_mode && i_step))) begin
            reg_write <= i_reg_write;
        end
    end

    // --------------------------------------------------
    // Halt block
    // --------------------------------------------------
    always @(posedge i_clock) begin : halt_block
        if(i_reset) begin
            halt <= 1'b0;
        end
        else if(i_valid && (i_exec_mode == 1'b0 || (i_exec_mode && i_step))) begin
            halt <= i_halt;
        end
    end

    // --------------------------------------------------
    // Jump block
    // --------------------------------------------------
    always @(posedge i_clock) begin : jump_block
        if(i_reset) begin
            jump <= 2'b0;
        end
        else if(i_valid && (i_exec_mode == 1'b0 || (i_exec_mode && i_step))) begin
            jump <= i_jump;
        end
    end

    // --------------------------------------------------
    // ALU result block
    // --------------------------------------------------
    always @(posedge i_clock) begin : alu_result_block
        if(i_reset) begin
            alu_result <= {NB_DATA{1'b0}};
        end
        else if(i_valid && (i_exec_mode == 1'b0 || (i_exec_mode && i_step))) begin
            alu_result <= i_alu_result;
        end
    end

    // --------------------------------------------------
    // PC_4 block
    // --------------------------------------------------
    always @(posedge i_clock) begin : pc_4_block
        if(i_reset) begin
            pc_4 <= {NB_DATA{1'b0}};
        end
        else if(i_valid && (i_exec_mode == 1'b0 || (i_exec_mode && i_step))) begin
            pc_4 <= i_pc_4;
        end
    end

    // --------------------------------------------------
    // RT_RD block
    // --------------------------------------------------
    always @(posedge i_clock) begin : rt_rd_block
        if(i_reset) begin
            rt_rd <= {NB_REGISTER{1'b0}};
        end
        else if(i_valid && (i_exec_mode == 1'b0 || (i_exec_mode && i_step))) begin
            rt_rd <= i_rt_rd;
        end
    end


    // always @(negedge i_clock) begin : reg_outputs
    //     if(i_reset) begin
    //         out_mem_to_reg <= 1'b0;
    //         out_reg_write  <= 1'b0;
    //         out_halt       <= 1'b0;
    //         out_jump       <= 2'b0;
    //         out_alu_result <= {NB_DATA{1'b0}};
    //         out_pc_4       <= {NB_DATA{1'b0}};
    //         out_read_data  <= {NB_DATA{1'b0}};
    //         out_rt_rd      <= {NB_REGISTER{1'b0}};
    //     end
    //     else if(i_valid && (i_exec_mode == 1'b0 || (i_exec_mode && i_step))) begin
    //         out_mem_to_reg <= mem_to_reg;
    //         out_reg_write  <= reg_write;
    //         out_halt       <= halt;
    //         out_jump       <= jump;
    //         out_alu_result <= alu_result;
    //         out_pc_4       <= pc_4;
    //         out_read_data  <= read_data;
    //         out_rt_rd      <= rt_rd;
    //     end
    // end

    always @(negedge i_clock) begin : mem_to_reg_out_block
        if(i_reset) begin
            out_mem_to_reg <= 1'b0;
        end
        else if(i_valid && (i_exec_mode == 1'b0 || (i_exec_mode && i_step))) begin
            out_mem_to_reg <= mem_to_reg;
        end
    end

    always @(negedge i_clock) begin : reg_write_out_block
        if(i_reset) begin
            out_reg_write <= 1'b0;
        end
        else if(i_valid && (i_exec_mode == 1'b0 || (i_exec_mode && i_step))) begin
            out_reg_write <= reg_write;
        end
    end

    always @(negedge i_clock) begin : halt_out_block
        if(i_reset) begin
            out_halt <= 1'b0;
        end
        else if(i_valid && (i_exec_mode == 1'b0 || (i_exec_mode && i_step))) begin
            out_halt <= halt;
        end
    end

    always @(negedge i_clock) begin : jump_out_block
        if(i_reset) begin
            out_jump <= 2'b0;
        end
        else if(i_valid && (i_exec_mode == 1'b0 || (i_exec_mode && i_step))) begin
            out_jump <= jump;
        end
    end

    always @(negedge i_clock) begin : alu_result_out_block
        if(i_reset) begin
            out_alu_result <= {NB_DATA{1'b0}};
        end
        else if(i_valid && (i_exec_mode == 1'b0 || (i_exec_mode && i_step))) begin
            out_alu_result <= alu_result;
        end
    end

    always @(negedge i_clock) begin : pc_4_out_block
        if(i_reset) begin
            out_pc_4 <= {NB_DATA{1'b0}};
        end
        else if(i_valid && (i_exec_mode == 1'b0 || (i_exec_mode && i_step))) begin
            out_pc_4 <= pc_4;
        end
    end

    always @(negedge i_clock) begin : read_data_out_block
        if(i_reset) begin
            out_read_data <= {NB_DATA{1'b0}};
        end
        else if(i_valid && (i_exec_mode == 1'b0 || (i_exec_mode && i_step))) begin
            out_read_data <= read_data;
        end
    end

    always @(negedge i_clock) begin : rt_rd_out_block
        if(i_reset) begin
            out_rt_rd <= {NB_REGISTER{1'b0}};
        end
        else if(i_valid && (i_exec_mode == 1'b0 || (i_exec_mode && i_step))) begin
            out_rt_rd <= rt_rd;
        end
    end


    // --------------------------------------------------
    // Branch logic
    // --------------------------------------------------
    branch_control u_branch_control
    (
        .o_pc_src       (o_pc_src       ),
        .o_flush        (o_flush        ),

        .i_branch       (i_branch       ),
        .i_zero         (i_zero         ),
        .i_opcode       (i_opcode       )
    );

    // --------------------------------------------------
    // Data memory
    // --------------------------------------------------
    data_memory u_data_memory
    (
        .o_read_data    (read_data      ),

        .i_address      (alu_result     ),
        .i_write_data   (i_read_data_2  ),
        .i_read_enable  (i_mem_read     ),
        .i_write_enable (i_mem_write    ),
        .i_valid        (i_valid        ),
        .i_clock        (i_clock        )
    );

    // --------------------------------------------------
    // Outputs assignments
    // --------------------------------------------------
    assign o_mem_to_reg    = out_mem_to_reg;
    assign o_reg_write     = out_reg_write;
    assign o_halt          = out_halt;
    assign o_jump          = out_jump;
    assign o_alu_result    = out_alu_result;
    assign o_pc_4          = out_pc_4;
    assign o_read_data     = out_read_data;
    assign o_rt_rd         = out_rt_rd;

endmodule