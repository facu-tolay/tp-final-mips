`timescale 1ns / 1ps

module memory_access
#(
    parameter NUM_BYTES = 4     ,
    parameter TAM_MASK  = 2     ,
    parameter TAM_DATA  = 32    ,
    parameter NUM_DIREC = 7
)
(
    input                       i_clk,
    input                       i_reset,
    input                       i_wr_mem,
    input                       i_is_unsigned,
    input                       i_mem_to_reg,
    input  [TAM_MASK    -1 : 0] i_data_mask,
    input  [TAM_DATA    -1 : 0] i_direc_mem,
    input  [TAM_DATA    -1 : 0] i_data,
    input  [NUM_DIREC   -1 : 0] i_debug_pointer,
    output [TAM_DATA    -1 : 0] o_debug_read,
    output [TAM_DATA    -1 : 0] o_data
);

    wire [NUM_BYTES -1 : 0] bits_de_mascara_a_memoria;
    wire [TAM_DATA  -1 : 0] dato_de_memoria_a_signador;
    wire [TAM_DATA  -1 : 0] dato_signado;

    // --------------------------------------------------
    // Masking for bytes in memory
    // --------------------------------------------------
    assign bits_de_mascara_a_memoria[3 : 2] = {i_data_mask[1], i_data_mask[1]};
    assign bits_de_mascara_a_memoria[1    ] = i_data_mask[0];
    assign bits_de_mascara_a_memoria[0    ] = 1'b1;

    // --------------------------------------------------
    // Data memory
    // --------------------------------------------------
    // data_memory u_data_memory // FIXME probarrr
    memoria_por_byte u_data_memory
    (
        .i_clock            (i_clk                          ),
        .i_reset            (i_reset                        ),
        .i_write_enable     (i_wr_mem                       ),
        .i_byte_enb         (bits_de_mascara_a_memoria      ), //es una entrada, indicamos que bytes queremos
        .i_direcc           (i_direc_mem                    ),
        .i_data             (i_data                         ),
        .i_direcc_debug     (i_debug_pointer                ),
        .o_data_debug       (o_debug_read                   ),
        .o_data             (dato_de_memoria_a_signador     )
    );

    // --------------------------------------------------
    // Signator
    // --------------------------------------------------
    signator u_signator
    (
        .i_is_unsigned      (i_is_unsigned                  ),
        .i_mascara          (i_data_mask                    ),
        .i_dato             (dato_de_memoria_a_signador     ), //toma como entrada la salida de la mascarita
        .o_dato             (dato_signado                   )
    );

    // --------------------------------------------------
    // Write data to register selection
    // --------------------------------------------------
    mux
    #(
        .BITS_ENABLES       (1                              ),
        .BUS_SIZE           (TAM_DATA                       )
    )
    u_mux_de_mem_o_reg
    (
        .i_en               (i_mem_to_reg                   ),
        .i_data             ({dato_signado,i_direc_mem}     ),
        .o_data             (o_data                         )
    );

endmodule