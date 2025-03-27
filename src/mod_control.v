`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.12.2022 14:59:38
// Design Name: 
// Module Name: mod_control
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module mod_control #(
    parameter FUN_SIZE = 6,
    parameter SIGNALS_SIZE = 18
)
(
    input   [FUN_SIZE - 1 : 0]      i_function,
    input   [FUN_SIZE - 1 : 0]      i_operation,
    input                           i_enable_control,
    output  [SIGNALS_SIZE - 1 : 0]  o_control
);

    reg [SIGNALS_SIZE - 1 : 0] o_control_data;
//  17	    16	    15	      14	 13	     12   11	10	  9	      8	      7	      6	       5	    4	     3	       2	      1        0
//RegDst MemToReg MemRead	Branch MemWrite	Ope2 Ope1 Ope0 ALUSrc RegWrite ShiftSrc JmpSrc JReturnDst EQorNE DataMask1 DataMask0 IsUnsigned JmpOrBrch
    always @(*)  
    begin
        if(~i_enable_control)
        begin        
            casez({i_operation, i_function})
                12'b1?0?????????:
                    o_control_data = {14'b11100000110000,i_operation[1],i_operation[0],i_operation[2],1'b0}; 
                12'b1?1?????????: 
                    o_control_data = {14'b00001000100000,i_operation[1],i_operation[0],i_operation[2],1'b0};
                12'b0?1?????????:  
                    o_control_data = {5'b10000, i_operation[2],i_operation[1],i_operation[0], 10'b1100001100};
                12'b0?01????????: 
                    o_control_data = {13'b0001000000010, i_operation[0], 4'b1100};
                12'b0?001???????: 
                    o_control_data = {9'b000000000,i_operation[0],2'b01,i_operation[0],5'b01101};
                12'b0?000?0?1???: 
                    o_control_data = {9'b000000000, i_function[0],8'b00001101};
                default: // 001 Para que la Alu Control use el campo FUNC
                    o_control_data = {10'b0000000101,~(i_function[5] | i_function[2]),7'b0001100};
            endcase
        end
        else
            o_control_data = 18'b0;
    end
    
    assign o_control = o_control_data;
endmodule
