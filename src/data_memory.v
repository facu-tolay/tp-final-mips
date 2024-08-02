module data_memory
#(
    parameter NB_DATA     = 32  ,
    parameter RAM_DEPTH   = 256
)
(
    output wire [NB_DATA    -1 : 0] o_read_data     ,

    input  wire [NB_DATA    -1 : 0] i_address       ,
    input  wire [NB_DATA    -1 : 0] i_write_data    , // RAM input data
    input  wire                     i_read_enable   ,
    input  wire                     i_write_enable  ,
    input  wire                     i_valid         ,
    input  wire                     i_clock
);

    // FIXME ver este bloque como se puede sincronizar la memoria al leer

    reg [NB_DATA    -1 : 0] DRAM [RAM_DEPTH-1 : 0];
    reg [NB_DATA    -1 : 0] ram_data = {NB_DATA{1'b0}};

    // generate
    //     reg [NB_DATA-1:0] ram_index;
    //     initial begin
    //          for (ram_index = 0; ram_index < RAM_DEPTH; ram_index = ram_index + 1)
    //             DRAM[ram_index] = 3;//32'b0;//{ram_index};
    //     end
    // endgenerate

    // always @(*) begin : read_block
    //     if (i_valid && i_read_enable) begin
    //         ram_data <= DRAM[i_address];
    //     end
    // end

    always @(posedge i_clock) begin : write_block
        if (i_valid && i_write_enable) begin
            DRAM[i_address] <= i_write_data;
        end
    end

    // --------------------------------------------------
    // Output assignment
    // --------------------------------------------------
    assign o_read_data = (i_valid && i_read_enable) ? DRAM[i_address] : {NB_DATA{1'b0}};

endmodule