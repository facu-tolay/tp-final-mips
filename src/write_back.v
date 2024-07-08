module writeback
#(
    parameter NB_DATA        = 32    ,
    parameter NB_REGISTER    = 5
)
(
    //WB  - Señales de control para write-back
    output reg                      o_mem_to_reg    ,
    output reg                      o_reg_write     ,

    output wire                     o_stop          ,

    output reg [NB_DATA-1     : 0]  o_write_data    ,

    output reg [NB_REGISTER-1 : 0]  o_rd_rt         ,

    input wire                      i_clock         ,
    input wire                      i_reset         ,
    input wire                      i_valid         ,

    input wire [NB_DATA-1     : 0]  i_pc_4          ,

    //WB  - Señales de control para write-back
    input wire                      i_mem_to_reg    ,
    input wire                      i_reg_write     ,
    input wire                      i_halt          ,
    input wire [1             : 0]  i_jump          ,

    input wire [NB_DATA-1     : 0]  i_read_data     ,
    input wire [NB_DATA-1     : 0]  i_alu_result    ,

    input wire [NB_REGISTER-1 : 0]  i_rd_rt         ,

    input wire                      i_exec_mode     ,
    input wire                      i_step
);

    reg                         mem_to_reg;
    reg                         reg_write;
    reg [NB_DATA-1      : 0]    read_data;
    reg [NB_DATA-1      : 0]    write_data;
    reg [NB_REGISTER-1  : 0]    rd_rt;
    
    reg                         stop = 1'b0;

    //MUX 4 decide entre el dato leido y el resultado de la alu
    always @ (*) begin
        if(i_valid) begin
            if(i_mem_to_reg) begin
                write_data = read_data;
            end
            else begin
                write_data = i_alu_result;
            end
        end
    end
    
    //MUX 5 decide el valor a escribir en el registro, ya que
    //JAL y JALR escriben en los registros
    always @ (*) begin
        if(i_valid) begin
            case(i_jump)
                2'b01: begin
                    o_write_data = i_pc_4;
                    rd_rt        = 5'b11111;
                end
                2'b10: begin
                    o_write_data = i_pc_4;
                    rd_rt        = i_rd_rt;
                end
                default: begin
                    o_write_data = write_data;
                    rd_rt        = i_rd_rt;
                end
            endcase
        end
    end
    
    always @ (posedge i_clock) begin : lectura
        if(i_reset) begin
            mem_to_reg <= 1'b0;
            reg_write  <= 1'b0;
            read_data  <= {NB_DATA{1'b0}};
        end
        else if(i_valid) begin
            mem_to_reg <= i_mem_to_reg;
            reg_write  <= i_reg_write;
            read_data  <= i_read_data;
        end
    end
    
    always @ (negedge i_clock) begin : escritura
        if(i_reset) begin
            o_mem_to_reg <= 1'b0;
            o_reg_write  <= 1'b0;
            o_rd_rt      <= {NB_REGISTER{1'b0}};
        end
        else if(i_valid) begin
            o_mem_to_reg <= mem_to_reg;
            o_reg_write  <= reg_write;
            o_rd_rt      <= rd_rt;
        end
    end

    //lógica para el contador de ciclos
    always @ (*) begin
        if(i_halt) begin
            stop = 1'b1;
        end
    end

    assign o_stop = stop;

endmodule