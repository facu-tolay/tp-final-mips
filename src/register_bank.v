module register_bank
#(
    parameter   NB_DATA     = 32,
    parameter   N_REGISTERS = 32,
    parameter   NB_REGISTER = 5
)
(
    output reg [NB_DATA     -1 : 0] o_data_read_reg_0   ,
    output reg [NB_DATA     -1 : 0] o_data_read_reg_1   ,

    // INPUTS
    input wire [NB_REGISTER -1 : 0] i_read_reg_sel_0    ,
    input wire [NB_REGISTER -1 : 0] i_read_reg_sel_1    ,
    input wire [NB_REGISTER -1 : 0] i_write_reg_sel     ,
    input wire [NB_DATA     -1 : 0] i_write_reg_data    ,
    input wire                      i_write_reg_enable  ,
    input wire                      i_valid             ,
    input wire                      i_reset             ,
    input wire                      i_clock
);

    reg [NB_DATA -1 : 0] registers[0 : N_REGISTERS-1];
    integer              i                           ;

    // --------------------------------------------------
    // Write block
    // --------------------------------------------------
    always @(negedge i_clock) begin : write_reg
        if(i_reset) begin
            for(i=0; i<N_REGISTERS; i=i+1) begin
                registers[i] <= {NB_DATA{1'b0}};
            end
        end
        if(i_valid) begin
            if(i_write_reg_enable && i_write_reg_sel != 5'b0) begin
                registers[i_write_reg_sel] <= i_write_reg_data;
            end
        end
    end

    // --------------------------------------------------
    // Output block 0
    // --------------------------------------------------
    always @(*) begin : read_reg_0
        if(i_reset) begin
            o_data_read_reg_0 = {NB_DATA{1'b0}};
        end
        else if(i_valid) begin
            o_data_read_reg_0 = registers[i_read_reg_sel_0];
        end
    end

    // --------------------------------------------------
    // Output block 1
    // --------------------------------------------------
    always @(*) begin : read_reg_1
        if(i_reset) begin
            o_data_read_reg_1 = {NB_DATA{1'b0}};
        end
        else if(i_valid) begin
            o_data_read_reg_1 = registers[i_read_reg_sel_1];
        end
    end

endmodule
