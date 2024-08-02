`timescale 1ns / 1ps

module branch_control
(
    output wire             o_pc_src    ,
    output wire             o_flush     ,

    input  wire             i_branch    ,
    input  wire             i_zero      ,
    input  wire [6  -1 : 0] i_opcode
);

    reg pc_src;
    reg flush;

    always @(*) begin : output_logic
        case(i_opcode)
            6'b100011: begin // BEQ
                if (i_branch && i_zero) begin
                    pc_src = 1'b1;
                    flush  = 1'b1;
                end
            end

            6'b100010: begin // BNE
                if (i_branch && ~i_zero) begin
                    pc_src = 1'b1;
                    flush  = 1'b1;
                end
            end

            default: begin
                pc_src = 1'b0;
                flush  = 1'b0;
            end
        endcase
    end

    // --------------------------------------------------
    // Output assignments
    // --------------------------------------------------
    assign o_pc_src = pc_src;
    assign o_flush  = flush;

endmodule
