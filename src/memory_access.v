`timescale 1ns / 1ps

module memory_access
#(
    parameter NB_DATA           = 32                ,
    parameter NB_BYTE           = 8                 ,
    parameter NB_HALFWORD       = NB_DATA / 2       ,
    parameter N_BYTES_IN_32B    = NB_DATA / NB_BYTE ,
    parameter NB_MASK           = 2                 ,
    parameter NB_MEM_ADDRESS    = 7
)
(
    output wire [NB_DATA        -1 : 0] o_data                      ,
    output wire [NB_DATA        -1 : 0] o_debug_read_mem            ,

    input  wire [NB_DATA        -1 : 0] i_data_write                ,
    input  wire [NB_MASK        -1 : 0] i_data_mask                 ,
    input  wire [NB_DATA        -1 : 0] i_memory_address            ,
    input  wire [NB_MEM_ADDRESS -1 : 0] i_debug_read_mem_address    ,
    input  wire                         i_write_enable              ,
    input  wire                         i_is_unsigned               ,
    input  wire                         i_memory_to_register        ,
    input  wire                         i_reset                     ,
    input  wire                         i_clock
);

    wire [N_BYTES_IN_32B -1 : 0] memory_mask_bits;
    wire [NB_DATA        -1 : 0] data_to_sign;
    reg  [NB_DATA        -1 : 0] signed_data;

    // --------------------------------------------------
    // Masking for bytes in memory
    // --------------------------------------------------
    assign memory_mask_bits[3 : 2] = {i_data_mask[1], i_data_mask[1]};
    assign memory_mask_bits[1    ] = i_data_mask[0];
    assign memory_mask_bits[0    ] = 1'b1;

    // --------------------------------------------------
    // Data memory
    // --------------------------------------------------
    data_memory u_data_memory
    (
        .i_data_write               (i_data_write               ),
        .i_write_enable             (i_write_enable             ),
        .i_byte_mask                (memory_mask_bits           ), // indicates which bytes to select
        .i_address                  (i_memory_address           ), // FIXME checkear tamanios
        .o_data_read                (data_to_sign               ),

        .i_debug_read_mem_address   (i_debug_read_mem_address   ),
        .o_debug_read_mem           (o_debug_read_mem           ),

        .i_reset                    (i_reset                    ),
        .i_clock                    (i_clock                    )
    );

    // --------------------------------------------------
    // Sign extender for memory data
    // --------------------------------------------------
    always @(*) begin
        casez ({i_data_mask, i_is_unsigned})
            3'b01_0: signed_data = {{NB_HALFWORD     {data_to_sign[NB_HALFWORD-1]}}, data_to_sign[NB_HALFWORD-1 : 0]}; // Extensión de signo para 16 bits
            3'b00_0: signed_data = {{NB_DATA-NB_BYTE {data_to_sign[NB_BYTE    -1]}}, data_to_sign[NB_BYTE    -1 : 0]}; // Extensión de signo para 8 bits
            default: signed_data = data_to_sign;                                                                       // Sin cambios
        endcase
    end

    // --------------------------------------------------
    // Write data to register selection
    // --------------------------------------------------
    assign o_data = i_memory_to_register ? signed_data : i_memory_address;

endmodule