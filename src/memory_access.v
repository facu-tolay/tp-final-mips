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
    output wire [NB_DATA        -1 : 0] o_data         ,
    output wire [NB_DATA        -1 : 0] o_debug_read   ,

    input  wire [NB_DATA        -1 : 0] i_data         ,
    input  wire [NB_MASK        -1 : 0] i_data_mask    ,
    input  wire [NB_DATA        -1 : 0] i_direc_mem    ,
    input  wire [NB_MEM_ADDRESS -1 : 0] i_debug_pointer,
    input  wire                         i_wr_mem       ,
    input  wire                         i_is_unsigned  ,
    input  wire                         i_mem_to_reg   ,
    input  wire                         i_reset        ,
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
        .i_clock            (i_clock                ),
        .i_reset            (i_reset                ),
        .i_write_enable     (i_wr_mem               ),
        .i_byte_enb         (memory_mask_bits       ), // indicates which bytes to select
        .i_direcc           (i_direc_mem            ),
        .i_data             (i_data                 ),
        .i_direcc_debug     (i_debug_pointer        ),
        .o_data_debug       (o_debug_read           ),
        .o_data             (data_to_sign           )
    );

    // --------------------------------------------------
    // Sign extender for memory data
    // --------------------------------------------------
    // signator u_signator
    // (
    //     .i_is_unsigned      (i_is_unsigned                  ),
    //     .i_mascara          (i_data_mask                    ),
    //     .i_dato             (data_to_sign     ), //toma como entrada la salida de la mascarita
    //     .o_dato             (signed_data                    )
    // );
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
    assign o_data = i_mem_to_reg ? signed_data : i_direc_mem;

endmodule