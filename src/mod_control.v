`timescale 1ns / 1ps

module mod_control
#(
    parameter NB_FUNCTION = 6   ,
    parameter NB_CONTROL  = 18
)
(
    output  [NB_CONTROL     - 1 : 0] o_control          ,

    input   [NB_FUNCTION    - 1 : 0] i_function         ,
    input   [NB_FUNCTION    - 1 : 0] i_operation        ,
    input                            i_enable_control
);

    reg [NB_CONTROL - 1 : 0] o_control_data;

    // --------------------------------------------------
    // Main block
    // --------------------------------------------------

    //  17	    16	    15	      14	 13	     12   11	10	  9	      8	      7	      6	       5	    4	     3	       2	      1        0
    //RegDst MemToReg MemRead	Branch MemWrite	Ope2 Ope1 Ope0 ALUSrc RegWrite ShiftSrc JmpSrc JReturnDst EQorNE DataMask1 DataMask0 IsUnsigned JmpOrBrch
    always @(*) begin
        if(~i_enable_control) begin
            casez({i_operation, i_function})
                12'b1?0?????????: o_control_data = {14'b11100000110000, i_operation[1], i_operation[0], i_operation[2], 1'b0};
                12'b1?1?????????: o_control_data = {14'b00001000100000, i_operation[1], i_operation[0], i_operation[2], 1'b0};
                12'b0?1?????????: o_control_data = {5'b10000, i_operation[2], i_operation[1], i_operation[0], 10'b1100001100};
                12'b0?01????????: o_control_data = {13'b0001000000010, i_operation[0], 4'b1100}                              ;
                12'b0?001???????: o_control_data = {9'b000000000, i_operation[0], 2'b01, i_operation[0], 5'b01101}           ;
                12'b0?000?0?1???: o_control_data = {9'b000000000, i_function[0], 8'b00001101}                                ;
                default:          o_control_data = {10'b0000000101,~(i_function[5] | i_function[2]),7'b0001100}              ; // 001 Para que la Alu Control use el campo FUNC
            endcase
        end
        else begin
            o_control_data = 18'b0;
        end
    end

    // --------------------------------------------------
    // Output assignments
    // --------------------------------------------------
    assign o_control = o_control_data;
endmodule
