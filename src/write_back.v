`timescale 1ns / 1ps

module write_back
#(
    parameter NB_DATA           = 32,
    parameter NB_REG_ADDRESS    = 5
)
(
    //datos
    input  [NB_DATA         -1 : 0] i_dato_de_mem   ,

    //direcciones
    input  [NB_REG_ADDRESS  -1 : 0] i_direc_reg     ,

    //seniales de control
    input                           i_j_return_dest ,

    output [NB_DATA         -1 : 0] o_dato          ,
    output [NB_REG_ADDRESS  -1 : 0] o_direccion
);

    assign o_dato = i_dato_de_mem;

    mux
    #(
        .BITS_ENABLES   (1                      ),
        .BUS_SIZE       (NB_REG_ADDRESS         )
    )
    u_mux_de_direc_o_gprx
    (
        .i_en           (i_j_return_dest        ),
        .i_data         ({5'd31,i_direc_reg}    ),
        .o_data         (o_direccion            )
    );

endmodule
