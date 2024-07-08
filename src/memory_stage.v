module memory
#(
    parameter NB_DATA     = 32  ,
    parameter NB_REGISTER = 5
)
(
    output reg [NB_DATA-1     : 0]  o_pc_4          ,

    output reg [1             : 0]  o_jump          ,
    output wire                     o_flush         ,
    output reg                      o_mem_to_reg    ,
    output reg                      o_reg_write     ,
    output reg                      o_halt          ,
    output wire                     o_pc_src        ,
    output reg [NB_DATA-1     : 0]  o_read_data     ,
    output reg [NB_DATA-1     : 0]  o_alu_result    ,
    output reg [NB_REGISTER-1 : 0]  o_rt_rd

    input wire                      i_clock         ,
    input wire                      i_reset         ,
    input wire                      i_valid         ,
    
    //MEM - se�ales de control para acceso a memoria
    input wire                      i_branch        ,
    input wire [1             : 0]  i_jump          ,
    input wire                      i_mem_read      ,
    input wire                      i_mem_write     ,

    //WB  - se�ales de control para write-back
    input wire                      i_mem_to_reg    ,
    input wire                      i_reg_write     ,
    input wire                      i_halt          ,

    input wire                      i_exec_mode     ,
    input wire                      i_step          ,

    input wire [NB_DATA-1     : 0]  i_pc_4          ,
    input wire [NB_REGISTER   : 0]  i_opcode        ,
    input wire [NB_DATA-1     : 0]  i_pc_branch     ,
    input wire                      i_zero          ,
    input wire [NB_DATA-1 :     0]  i_alu_result    ,
    input wire [NB_DATA-1 :     0]  i_read_data_2   ,
    input wire [NB_REGISTER-1 : 0]  i_rt_rd         ,
);

//    wire              pc_src;
    wire [NB_DATA-1    : 0]  read_data;

    reg                      halt;
    reg                      mem_to_reg;
    reg                      reg_write;
    reg [1             : 0]  jump;
    reg [NB_DATA-1     : 0]  alu_result;
    reg [NB_DATA-1     : 0]  pc_4;
    reg [NB_REGISTER-1 : 0]  rt_rd;

    always @ (posedge i_clock) begin : lectura
        if(i_reset) begin
            halt        <= 1'b0;
            mem_to_reg  <= 1'b0;
            reg_write   <= 1'b0;
            jump        <= 2'b0;
            alu_result  <= {NB_DATA{1'b0}};
            pc_4        <= {NB_DATA{1'b0}};
            rt_rd       <= {NB_REGISTER{1'b0}};
        end
        else if(i_valid) begin
            halt        <= i_halt;
            jump        <= i_jump;
            mem_to_reg  <= i_mem_to_reg;
            reg_write   <= i_reg_write;
            alu_result  <= i_alu_result;
            pc_4        <= i_pc_4;
            rt_rd       <= i_rt_rd;
        end
    end
    
    always @ (negedge i_clock) begin : escritura
        if(i_reset) begin
            o_mem_to_reg <= 1'b0;
            o_reg_write  <= 1'b0;
            o_halt       <= 1'b0;
            o_jump       <= 2'b0;
            o_alu_result <= {NB_DATA{1'b0}};
            o_pc_4       <= {NB_DATA{1'b0}};
            o_read_data  <= {NB_DATA{1'b0}};
            o_rt_rd      <= {NB_REGISTER{1'b0}};
        end
        else if(i_valid) begin
            o_halt       <= halt;
            o_jump       <= jump;
            o_mem_to_reg <= mem_to_reg;
            o_reg_write  <= reg_write;
            o_pc_4       <= pc_4;
            o_alu_result <= alu_result;
            o_rt_rd      <= rt_rd;
            o_read_data  <= read_data;
        end
    end

    // --------------------------------------------------
    // Branch logic
    // --------------------------------------------------
    branch_logic u_branch_logic
    (
        .o_pc_src   (o_pc_src   ),
        .o_flush    (o_flush    ),

        .i_branch   (i_branch   ),
        .i_zero     (i_zero     ),
        .i_opcode   (i_opcode   )
    );

    // --------------------------------------------------
    // Data memory
    // --------------------------------------------------
    data_memory u_data_mem1
    (
        .o_read_data    (read_data      ),

        .i_clock        (i_clock        ),
        .i_valid        (i_valid        ),
        .i_address      (alu_result     ),
        .i_write_data   (i_read_data_2  ),
        .i_read_enable  (i_mem_read     ),
        .i_write_enable (i_mem_write    )
    );

endmodule