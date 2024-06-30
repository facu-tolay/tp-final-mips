module control_unit
#(
    parameter   NB_DATA         = 32    ,
    parameter   NB_OPCODE       = 6     ,
    parameter   NB_FUNCTION     = 6
)
(
    //EX  - señales de control para ejecución
    output wire [2           -1 : 0] o_alu_op        ,
    output wire                      o_alu_src       ,
    output wire                      o_reg_dst       ,

    //MEM - señales de control para acceso a memoria
    output wire                      o_branch        ,
    output wire                      o_mem_read      ,
    output wire                      o_mem_write     ,

    //WB  - señales de control para write-back
    output wire                      o_mem_to_reg    ,
    output wire                      o_reg_write     ,

    //posibles
    output wire                      o_flush         ,
    output wire [2           -1 : 0] o_jump          ,
    output wire [NB_OPCODE   -1 : 0] o_opcode        ,

    input  wire [NB_DATA    -1 : 0]  i_instruction   ,
    input  wire                      i_valid         ,
    input  wire                      i_reset         ,
    input  wire                      i_clock
);

    wire [NB_OPCODE     -1:0] instruction_opcode;
    wire [NB_FUNCTION   -1:0] instruction_function;

    reg                     reg_dst;
    reg                     branch;
    reg                     mem_read;
    reg                     mem_to_reg;
    reg [2          -1 : 0] alu_op;
    reg                     mem_write;
    reg                     alu_src;
    reg                     reg_write;
    reg [2          -1 : 0] jump;
    reg [NB_OPCODE  -1 : 0] opcode;
    reg                     flush;

    // --------------------------------------------------
    // Control signals assignments
    // --------------------------------------------------
    assign instruction_opcode   = i_valid ? i_instruction[31 : 26] : 6'b111111;
    assign instruction_function = i_valid ? i_instruction[5  : 0 ] : 6'b111111;

    always @(*) begin : control
        case(instruction_opcode)
            // tipo R
            6'b000000: begin
                case(instruction_function)
                    // tipo J
                    6'b001001: begin // jalr
                        reg_dst    = 1'b1;
                        branch     = 1'b0;
                        mem_read   = 1'b0;
                        mem_to_reg = 1'b0;
                        alu_op     = 1'b0;
                        mem_write  = 1'b0;
                        alu_src    = 1'b0;
                        reg_write  = 1'b1;
                        jump       = 2'b10;
                        flush      = 1'b1;
                        opcode     = instruction_function;
                    end

                    6'b001000: begin // jr
                        reg_dst    = 1'b0;
                        branch     = 1'b0;
                        mem_read   = 1'b0;
                        mem_to_reg = 1'b0;
                        alu_op     = 1'b0;
                        mem_write  = 1'b0;
                        alu_src    = 1'b0;
                        reg_write  = 1'b0;
                        jump       = 2'b11;
                        flush      = 1'b1;
                        opcode     = instruction_function;
                    end

                    // cualquier tipo R
                    default: begin
                        reg_dst    = 1'b1;
                        branch     = 1'b0;
                        mem_read   = 1'b0;
                        mem_to_reg = 1'b0;
                        alu_op     = 2'b10;
                        mem_write  = 1'b0;
                        alu_src    = 1'b0;
                        reg_write  = 1'b1;
                        jump       = 2'b0;
                        flush      = 1'b0;
                        opcode     = instruction_function;
                    end
                endcase
            end

            // tipo I
            6'b001000: begin // addi
                reg_dst    = 1'b0;
                branch     = 1'b0;
                mem_read   = 1'b0;
                mem_to_reg = 1'b0;
                alu_op     = 2'b10;
                mem_write  = 1'b0;
                alu_src    = 1'b1;
                reg_write  = 1'b1;
                jump       = 2'b0;
                flush      = 1'b0;
                opcode     = 6'b001000;
            end

            6'b001100: begin // andi
                reg_dst    = 1'b0;
                branch     = 1'b0;
                mem_read   = 1'b0;
                mem_to_reg = 1'b0;
                alu_op     = 2'b10;
                mem_write  = 1'b0;
                alu_src    = 1'b1;
                reg_write  = 1'b1;
                jump       = 2'b0;
                flush      = 1'b0;
                opcode     = 6'b100100;
            end

            6'b000100: begin // beq
                reg_dst    = 1'b0;
                branch     = 1'b1;
                mem_read   = 1'b0;
                mem_to_reg = 1'b0;
                alu_op     = 2'b01;
                mem_write  = 1'b0;
                alu_src    = 1'b0;
                reg_write  = 1'b0;
                jump       = 2'b0;
                flush      = 1'b0;
                opcode     = 6'b100011;
            end

            6'b000101: begin // bne
                reg_dst    = 1'b0;
                branch     = 1'b1;
                mem_read   = 1'b0;
                mem_to_reg = 1'b0;
                alu_op     = 2'b01;
                mem_write  = 1'b0;
                alu_src    = 1'b0;
                reg_write  = 1'b0;
                jump       = 2'b0;
                flush      = 1'b0;
                opcode     = 6'b100010;
            end

            6'b000011: begin // jal
                reg_dst    = 1'b1;
                branch     = 1'b0;
                mem_read   = 1'b0;
                mem_to_reg = 1'b0;
                alu_op     = 1'b0;
                mem_write  = 1'b0;
                alu_src    = 1'b0;
                reg_write  = 1'b1;
                jump       = 2'b01;
                flush      = 1'b1;
                opcode     = instruction_opcode;
            end

            6'b001101: begin // ori
                reg_dst    = 1'b0;
                branch     = 1'b0;
                mem_read   = 1'b0;
                mem_to_reg = 1'b0;
                alu_op     = 2'b10;
                mem_write  = 1'b0;
                alu_src    = 1'b1;
                reg_write  = 1'b1;
                jump       = 2'b0;
                flush      = 1'b0;
                opcode     = 6'b100101;
            end

            6'b001010: begin // slti
                reg_dst    = 1'b0;
                branch     = 1'b0;
                mem_read   = 1'b0;
                mem_to_reg = 1'b0;
                alu_op     = 2'b10;
                mem_write  = 1'b0;
                alu_src    = 1'b1;
                reg_write  = 1'b1;
                jump       = 2'b0;
                flush      = 1'b0;
                opcode     = 6'b101010;
            end

            6'b001110: begin // xori
                reg_dst    = 1'b0;
                branch     = 1'b0;
                mem_read   = 1'b0;
                mem_to_reg = 1'b0;
                alu_op     = 2'b10;
                mem_write  = 1'b0;
                alu_src    = 1'b1;
                reg_write  = 1'b1;
                jump       = 2'b0;
                flush      = 1'b0;
                opcode     = 6'b100110;
            end

            6'b000010: begin // j
                reg_dst    = 1'b0;
                branch     = 1'b0;
                mem_read   = 1'b0;
                mem_to_reg = 1'b0;
                alu_op     = 1'b0;
                mem_write  = 1'b0;
                alu_src    = 1'b0;
                reg_write  = 1'b0;
                jump       = 2'b0;
                flush      = 1'b1;
                opcode     = instruction_opcode;
            end

            // lb, lbu, lh, lhu, lw, lwu
            6'b100000, 6'b100100, 6'b100001, 6'b100101, 6'b100011, 6'b100111: begin
                reg_dst    = 1'b0;
                branch     = 1'b0;
                mem_read   = 1'b1;
                mem_to_reg = 1'b1;
                alu_op     = 2'b0;
                mem_write  = 1'b0;
                alu_src    = 1'b1;
                reg_write  = 1'b1;
                jump       = 2'b0;
                flush      = 1'b0;
                opcode     = instruction_opcode;
            end

            // lui
            6'b001111: begin
                reg_dst    = 1'b0;
                branch     = 1'b0;
                mem_read   = 1'b0;
                mem_to_reg = 1'b0;
                alu_op     = 2'b10;
                mem_write  = 1'b0;
                alu_src    = 1'b1;
                reg_write  = 1'b1;
                jump       = 2'b0;
                flush      = 1'b0;
                opcode     = instruction_opcode;
            end

            // tipo store
            // sb, sh, sw
            6'b101000, 6'b101001, 6'b101011: begin
                reg_dst    = 1'b0;
                branch     = 1'b0;
                mem_read   = 1'b0;
                mem_to_reg = 1'b0;
                alu_op     = 2'b0;
                mem_write  = 1'b1;
                alu_src    = 1'b1;
                reg_write  = 1'b0;
                jump       = 2'b0;
                flush      = 1'b0;
                opcode     = instruction_opcode;
            end

            default: begin // halt o no valida
                reg_dst    = 1'b0;
                branch     = 1'b0;
                mem_read   = 1'b0;
                mem_to_reg = 1'b0;
                alu_op     = 2'b0;
                mem_write  = 1'b0;
                alu_src    = 1'b0;
                reg_write  = 1'b0;
                jump       = 2'b0;
                flush      = 1'b0;
                opcode     = {NB_OPCODE{1'b0}};
            end
        endcase
    end

    // --------------------------------------------------
    // Output assignments
    // --------------------------------------------------
    assign o_reg_dst        = reg_dst;
    assign o_branch         = branch;
    assign o_mem_read       = mem_read;
    assign o_mem_to_reg     = mem_to_reg;
    assign o_alu_op         = alu_op;
    assign o_mem_write      = mem_write;
    assign o_alu_src        = alu_src;
    assign o_reg_write      = reg_write;
    assign o_jump           = jump;
    assign o_flush          = flush;
    assign o_opcode         = opcode;

endmodule
