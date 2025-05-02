`timescale 1ns / 1ps

module instruction_memory
#(
    parameter NB_DATA           = 32                        ,
    parameter NB_BYTE           = 8                         ,
    parameter N_INSTRUCTIONS    = 32                        ,
    parameter N_BYTE_REGISTERS  = N_INSTRUCTIONS * 4        ,
    parameter NB_ADDRESS        = 7
)
(
    output wire [NB_DATA    -1 : 0]     o_read_instruction          ,
    output                              o_is_program_end            ,

    input  wire [NB_ADDRESS -1 : 0]     i_read_address_instruction  ,
    input  wire [NB_BYTE    -1 : 0]     i_write_data                ,
    input  wire                         i_write_enable              ,
    input  wire                         i_is_jump_or_branch         ,
    input  wire                         i_reset                     ,
    input  wire                         i_clock
);

    reg [NB_BYTE    -1 : 0] instr_memory [N_BYTE_REGISTERS -1 : 0];
    reg [NB_ADDRESS -1 : 0] write_address;
    reg [NB_DATA    -1 : 0] read_instruction;
    integer                 i;
    reg                     halt_program;
    wire                    is_halt_instruction;
    wire                    program_halted;

    assign is_halt_instruction = {instr_memory[i_read_address_instruction + 0],
                                  instr_memory[i_read_address_instruction + 1],
                                  instr_memory[i_read_address_instruction + 2],
                                  instr_memory[i_read_address_instruction + 3]} == 32'h40000000;

    assign program_halted      = is_halt_instruction && ~i_is_jump_or_branch;

    // --------------------------------------------------
    // Write pointer block
    // --------------------------------------------------
    always @(posedge i_clock) begin
        if (i_reset) begin
            write_address <= 0;
        end
        else if (i_write_enable) begin
            write_address <= write_address + 1;
        end
    end

    // --------------------------------------------------
    // Write pointer block
    // --------------------------------------------------
    always @(posedge i_clock) begin
        if (i_reset) begin
            halt_program <= 1'b0;
        end
        else if (program_halted) begin
            halt_program <= 1'b1;
        end
    end

    // aca se podria agregar un mux que meta nops en lugar de seguir leyendo el programa cuando detecte que la instruccion leida es un halt
    // otra opcion es modificar el write_pointer para que lo setee desde el punto en el que encuentra un halt y asi hace cumplir la condicion de +12 y eso

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
            instr_memory[write_address] <= i_write_data;
        end
    end

    // --------------------------------------------------
    // Instruction memory read block
    // --------------------------------------------------
    always @ (negedge i_clock) begin
        if (is_halt_instruction || halt_program) begin
            read_instruction <= 32'h0;
        end
        else begin
            read_instruction <= {instr_memory[i_read_address_instruction + 0],
                                 instr_memory[i_read_address_instruction + 1],
                                 instr_memory[i_read_address_instruction + 2],
                                 instr_memory[i_read_address_instruction + 3]};
        end
    end

    // --------------------------------------------------
    // Output assignments
    // --------------------------------------------------
    assign o_is_program_end   = (write_address+12 <= i_read_address_instruction) || ({NB_ADDRESS{1'b1}}-3 == i_read_address_instruction);
    assign o_read_instruction = read_instruction;

endmodule

