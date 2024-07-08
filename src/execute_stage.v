module execute#
#(
    parameter NB_DATA        = 32  ,
    parameter NB_REGISTER    = 5
)
(
    // --------------------------------------------------
    // MEM - Señales de control para acceso a memoria
    // --------------------------------------------------
    output reg                     o_branch      ,
    output reg [1             : 0] o_jump        ,
    output reg                     o_mem_read    ,
    output reg                     o_mem_write   ,

    // --------------------------------------------------
    // WB  - Señales de control para write-back
    // --------------------------------------------------
    output reg                     o_mem_to_reg  ,
    output reg                     o_reg_write   ,
    output reg                     o_halt        ,

    output reg [NB_DATA    -1 : 0] o_pc_4        ,
    output reg [NB_DATA    -1 : 0] o_pc_branch   ,
    output reg [NB_DATA    -1 : 0] o_alu_result  ,
    output reg [NB_DATA    -1 : 0] o_read_data_2 ,
    output reg [NB_REGISTER   : 0] o_opcode      ,
    output reg [NB_REGISTER-1 : 0] o_rt_rd       ,
    output reg                     o_zero

    // --------------------------------------------------
    // EX  - Señales de control para ejecucion
    // --------------------------------------------------
    input wire [2             : 0] i_alu_op      ,
    input wire                     i_alu_src     ,
    input wire                     i_reg_dst     ,

    // --------------------------------------------------
    // MEM - Señales de control para acceso a memoria
    // --------------------------------------------------
    input wire   i_branch,
    input wire [1            : 0]  i_jump        ,
    input wire                     i_mem_read    ,
    input wire                     i_mem_write   ,

    // --------------------------------------------------
    // WB  - Señales de control para write-back
    // --------------------------------------------------
    input wire                     i_mem_to_reg  ,
    input wire                     i_reg_write   ,
    input wire                     i_halt        ,

    input wire [NB_DATA    -1 : 0] i_pc_4        ,
    input wire [NB_DATA    -1 : 0] i_alu_result  ,
    input wire [NB_DATA    -1 : 0] i_data_memory ,
    input wire [NB_DATA    -1 : 0] i_read_data_1 ,
    input wire [NB_DATA    -1 : 0] i_read_data_2 ,
    input wire [NB_DATA    -1 : 0] i_extended    ,
    input wire [NB_REGISTER   : 0] i_opcode      ,
    input wire [NB_REGISTER-1 : 0] i_rd          ,
    input wire [NB_REGISTER-1 : 0] i_rt          ,
    input wire [NB_REGISTER-1 : 0] i_sa          ,

    input wire                     i_flush       ,
    input wire                     i_exec_mode   ,
    input wire                     i_step        ,
    
    // --------------------------------------------------
    // Señales de control a la ALU
    // --------------------------------------------------
    input wire [1             : 0] i_mux_A       ,
    input wire [1             : 0] i_mux_B       ,

    input wire                     i_clock       ,
    input wire                     i_reset       ,
    input wire                     i_valid
);

    wire [4         : 0]    aluctrl;
    wire [NB_DATA-1 : 0]    alu_result;
    wire                    zero;

    reg  [NB_DATA-1     : 0]    dato_a;
    reg  [NB_DATA-1     : 0]    dato_b;
    reg  [NB_DATA-1     : 0]    dato_b_fowarding;
    reg  [NB_DATA-1     : 0]    pc_branch;
    reg  [NB_DATA-1     : 0]    pc_4;
    reg  [NB_DATA-1     : 0]    read_data_2; 
    reg  [NB_REGISTER :   0]    opcode;
    reg  [NB_REGISTER-1 : 0]    rt_rd;

    reg  [1 : 0]    jump;
    reg             branch;
    reg             mem_read;
    reg             mem_write;
    reg             mem_to_reg;
    reg             reg_write;
    reg             halt;

    //MUX dato A forwarding
    always@(*) begin
        if(i_valid) begin
            case(aluctrl)
                4'b0110: begin
                    dato_a = i_read_data_2;
                end
                4'b1011: begin
                    dato_a = i_read_data_2;
                end
                4'b1010: begin
                    dato_a = i_read_data_2;
                end
                default: begin
                    case(i_mux_A)
                      2'b00: begin
                          dato_a = i_read_data_1;
                      end
                      2'b01: begin
                          dato_a = i_data_memory;
                      end
                      2'b10: begin
                          dato_a = i_alu_result;
                      end
                      default: begin
                          dato_a = {NB_DATA{1'b0}};
                      end
                    endcase
                end
            endcase
        end
    end

  //MUX dato B forwarding
    always @(*) begin
      if (i_valid) begin
        case(i_mux_B)
          2'b00: begin
              dato_b_fowarding = i_read_data_2;
          end
          2'b01: begin
              dato_b_fowarding = i_data_memory;
          end
          2'b10: begin
              dato_b_fowarding = i_alu_result;
          end
          default: begin
              dato_b_fowarding = {NB_DATA{1'b0}};
          end
        endcase
      end
    end

  //MUX 3 decide el valor de entrada del dato B a la ALU
    always@(*) begin
        if(i_valid) begin
            if(i_alu_src) begin
                dato_b = i_extended;
            end
            else begin
                case(aluctrl)
                    4'b0110: begin
                        dato_b = i_sa;
                    end
                    4'b1011: begin
                        dato_b = i_sa;
                    end
                    4'b1010: begin//sll,sra,srl
                        dato_b = i_sa;
                    end
                    default: begin
                        dato_b = dato_b_fowarding;
                    end
                endcase
            end 
        end
    end

    //MUX 2 decide el valor de i_write_reg (si es rt o rd)
    always@(*) begin
        if (i_reset) begin
            rt_rd = {NB_REGISTER{1'b0}};
        end
        if (i_valid) begin
            if (i_reg_dst) begin
                rt_rd = i_rd;
            end
            else begin
                rt_rd = i_rt;
            end
        end
    end

    always @(posedge i_clock) begin : lectura
        if(i_reset) begin
            halt          <= 1'b0;
            branch        <= 1'b0;
            mem_read      <= 1'b0;
            mem_write     <= 1'b0;
            mem_to_reg    <= 1'b0;
            reg_write     <= 1'b0;
            jump          <= 2'b0;        
            pc_4          <= {NB_DATA{1'b0}};
            pc_branch     <= {NB_DATA{1'b0}};
            opcode        <= {NB_REGISTER+1{1'b0}};
            read_data_2   <= {NB_DATA{1'b0}};
        end

//         dato_a        <= {NB_DATA{1'b0}};
//         dato_b        <= {NB_DATA{1'b0}};
//         rt_rd         <= {NB_REGISTER{1'b0}};
//         dato_b_fowarding <= {NB_DATA{1'b0}};

        else if(i_valid) begin
            halt        <= i_halt;
            branch      <= i_branch;
            mem_read    <= i_mem_read;
            mem_write   <= i_mem_write;
            mem_to_reg  <= i_mem_to_reg;
            reg_write   <= i_reg_write;
            read_data_2 <= i_read_data_2;
            jump        <= i_jump;
            pc_4        <= i_pc_4;
            pc_branch   <= i_pc_4 + i_extended; //-----�������PC BRANCH ACA!!!!!!!-------
            opcode      <= i_opcode;
        end
    end

    always @ (negedge i_clock) begin : esc
        if(i_reset) begin
            o_branch      <= 1'b0;
            o_mem_read    <= 1'b0;
            o_mem_write   <= 1'b0;
            o_mem_to_reg  <= 1'b0;
            o_reg_write   <= 1'b0;
            o_jump        <= 2'b0;
            o_halt        <= 1'b0;

            o_opcode      <= {NB_REGISTER+1{1'b0}};
            o_pc_4        <= {NB_DATA{1'b0}};
            o_pc_branch   <= {NB_DATA{1'b0}};
            o_alu_result  <= {NB_DATA{1'b0}};
            o_read_data_2 <= {NB_DATA{1'b0}};
            o_rt_rd       <= {NB_REGISTER{1'b0}};
            o_zero        <= {NB_REGISTER{1'b0}};
        end
        else if(i_valid && ~i_flush) begin
            o_pc_4        <= pc_4;
            o_halt        <= halt;
            o_branch      <= branch;
            o_jump        <= jump;
            o_mem_read    <= mem_read;
            o_mem_write   <= mem_write;
            o_mem_to_reg  <= mem_to_reg;
            o_reg_write   <= reg_write;
            o_pc_branch   <= pc_branch;
            o_alu_result  <= alu_result;
            o_read_data_2 <= read_data_2;
            o_opcode      <= opcode;
            o_rt_rd       <= rt_rd;
            o_zero        <= zero;
        end
        else begin
            o_jump        <= 2'b0;
            o_branch      <= 1'b0;
            o_mem_read    <= 1'b0;
            o_mem_write   <= 1'b0;
            o_mem_to_reg  <= 1'b0;
            o_reg_write   <= 1'b0;
            o_halt        <= 1'b0;

            o_pc_4        <= {NB_DATA{1'b0}};
            o_alu_result  <= {NB_DATA{1'b0}};
            o_read_data_2 <= {NB_DATA{1'b0}};
            o_rt_rd       <= {NB_REGISTER{1'b0}};
            o_zero        <= {NB_REGISTER{1'b0}};
            o_opcode      <= {NB_REGISTER+1{1'b0}}; 
        end
    end

    // --------------------------------------------------
    // ALU
    // --------------------------------------------------
    alu u_alu1
    (
        .i_dato_A(dato_a), .i_dato_B(dato_b), .i_alu_ctrl(aluctrl),
        .o_alu_result(alu_result), .o_alu_zero(zero)
    );

    // --------------------------------------------------
    // ALU Control
    // --------------------------------------------------
    alu_ctrl u_alu_ctrl1
    (
        .i_funcion(opcode), .i_alu_op(i_alu_op),
        .o_alu_ctrl(aluctrl)
    );

endmodule





