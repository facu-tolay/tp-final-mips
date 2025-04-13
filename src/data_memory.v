`timescale 1ns / 1ps

module data_memory
#(
    parameter NB_DATA       = 32,
    parameter NB_BYTE       = 8,
    parameter NUM_ENABLES   = NB_DATA / 8,
    parameter NUM_SLOTS     = 32*4,
    parameter NUM_DIREC     = $clog2(NUM_SLOTS)
)
(
    input  wire                         i_write_enable,
    input  wire [NUM_ENABLES    -1 : 0] i_byte_enb,
    input  wire [NUM_DIREC      -1 : 0] i_direcc,
    input  wire [NB_DATA        -1 : 0] i_data,

    input  wire [NUM_DIREC      -1 : 0] i_direcc_debug,

    output wire [NB_DATA        -1 : 0] o_data_debug,

    output wire [NB_DATA        -1 : 0] o_data,

    input  wire                         i_reset,
    input  wire                         i_clock
);

    reg [NB_BYTE -1 : 0] data_memory_regs [NUM_SLOTS-1 : 0];

    reg [NB_DATA-1 : 0] data_read;
    reg [NB_DATA-1 : 0] data_debug_read;

    integer i;

    // --------------------------------------------------
    // Escritura en la memoria
    // --------------------------------------------------
    always @(posedge i_clock) begin
        if (i_reset) begin
            for (i=0; i<NUM_SLOTS; i=i+1) begin
                data_memory_regs[i] <= 0;
            end
        end
        else if (i_write_enable) begin
            if (i_direcc >= 7'h4) begin
                if (i_byte_enb[0]) data_memory_regs[i_direcc + 7'h0] <= i_data[NB_BYTE * 0 +: NB_BYTE]; // FIXME hacer un for
                if (i_byte_enb[1]) data_memory_regs[i_direcc + 7'h1] <= i_data[NB_BYTE * 1 +: NB_BYTE];
                if (i_byte_enb[2]) data_memory_regs[i_direcc + 7'h2] <= i_data[NB_BYTE * 2 +: NB_BYTE];
                if (i_byte_enb[3]) data_memory_regs[i_direcc + 7'h3] <= i_data[NB_BYTE * 3 +: NB_BYTE];
            end
        end
    end

    // --------------------------------------------------
    // Lectura de la memoria
    // --------------------------------------------------
    always @(negedge i_clock) begin
        data_read[NB_BYTE * 0 +: NB_BYTE] <= i_byte_enb[0] ? data_memory_regs[i_direcc + 7'h0] : 0; // FIXME hacer un for
        data_read[NB_BYTE * 1 +: NB_BYTE] <= i_byte_enb[1] ? data_memory_regs[i_direcc + 7'h1] : 0;
        data_read[NB_BYTE * 2 +: NB_BYTE] <= i_byte_enb[2] ? data_memory_regs[i_direcc + 7'h2] : 0;
        data_read[NB_BYTE * 3 +: NB_BYTE] <= i_byte_enb[3] ? data_memory_regs[i_direcc + 7'h3] : 0;
        data_debug_read <= {data_memory_regs[i_direcc_debug + 3], data_memory_regs[i_direcc_debug + 2], data_memory_regs[i_direcc_debug + 1], data_memory_regs[i_direcc_debug + 0]};
    end

    // --------------------------------------------------
    // Asignaciones de salida
    // --------------------------------------------------
    assign o_data       = data_read;
    assign o_data_debug = data_debug_read;

endmodule
