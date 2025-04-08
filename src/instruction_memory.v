`timescale 1ns / 1ps

module instruction_memory
#(
    parameter NB_DATA           = 32                        ,
    parameter NB_BYTE           = 8                         ,
    parameter N_INSTRUCTIONS    = 64                        ,
    parameter N_BYTE_REGISTERS  = N_INSTRUCTIONS * 4        ,
    parameter NB_ADDRESS        = $clog2(N_BYTE_REGISTERS)
)
(
    output wire [NB_DATA    -1 : 0]     o_read_instruction          ,
    output                              o_is_program_end            ,

    input  wire [NB_ADDRESS -1 : 0]     i_read_address_instruction  ,
    input  wire [NB_BYTE    -1 : 0]     i_write_data                ,
    input  wire                         i_write_enable              ,
    input  wire                         i_reset                     ,
    input  wire                         i_clock
);

    reg [NB_BYTE    -1 : 0] instr_memory [N_BYTE_REGISTERS -1 : 0];
    reg [NB_ADDRESS -1 : 0] reg_write_ptr                         ;
    reg [NB_ADDRESS -1 : 0] next_write_ptr                        ;
    reg [NB_ADDRESS -1 : 0] succ_write_ptr                        ;
    reg [NB_DATA    -1 : 0] reg_intruccion                        ;
    integer                 i                                     ;

    // --------------------------------------------------
    // Next pointer block
    // --------------------------------------------------
    always @(*) begin
        succ_write_ptr = reg_write_ptr + 1; // successive pointer values
        next_write_ptr = reg_write_ptr; // default: keep old values
        if(i_write_enable) begin
            next_write_ptr = succ_write_ptr;
        end
    end

    // --------------------------------------------------
    // Write pointer block
    // --------------------------------------------------
    always @(posedge i_clock) begin
        if (i_reset) begin
            reg_write_ptr <= 0;
        end
        else begin
            reg_write_ptr <= next_write_ptr;
        end
    end

    // --------------------------------------------------
    // Instruction memory write block
    // --------------------------------------------------
    always @ (posedge i_clock) begin
        if (i_reset) begin
            for (i=0; i<N_BYTE_REGISTERS; i=i+1) begin
                instr_memory[i] <= 0;
            end
        end
        else if (i_write_enable) begin
            instr_memory[reg_write_ptr] <= i_write_data;
        end
    end

    // --------------------------------------------------
    // Instruction memory read block
    // --------------------------------------------------
    always @ (negedge i_clock) begin
        reg_intruccion <= { instr_memory[i_read_address_instruction + 0],
                            instr_memory[i_read_address_instruction + 1],
                            instr_memory[i_read_address_instruction + 2],
                            instr_memory[i_read_address_instruction + 3]};
    end

    // --------------------------------------------------
    // Output assignments
    // --------------------------------------------------
    assign o_is_program_end   = (reg_write_ptr+12 <= i_read_address_instruction) || ({NB_ADDRESS{1'b1}}-3 == i_read_address_instruction);
    assign o_read_instruction = reg_intruccion;

endmodule