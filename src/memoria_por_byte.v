`timescale 1ns / 1ps

module memoria_por_byte
#(
    parameter NB_DATA       = 32               ,
    parameter NB_BYTE       = 8                ,
    parameter NUM_ENABLES   = NB_DATA / 8      ,
    parameter NUM_SLOTS     = 32*4             ,
    parameter NUM_DIREC     = $clog2(NUM_SLOTS)
)
(
    input  wire                         i_write_enable,
    input  wire [NUM_ENABLES    -1 : 0] i_byte_enb    ,
    input  wire [NUM_DIREC      -1 : 0] i_direcc      ,
    input  wire [NB_DATA        -1 : 0] i_data        ,

    input  wire [NUM_DIREC      -1 : 0] i_direcc_debug,

    output wire [NB_DATA        -1 : 0] o_data_debug  ,

    output wire [NB_DATA        -1 : 0] o_data        ,

    input  wire                         i_reset       ,
    input  wire                         i_clock
);

    reg [NB_BYTE -1 : 0] byte_0;
    reg [NB_BYTE -1 : 0] byte_1;
    reg [NB_BYTE -1 : 0] byte_2;
    reg [NB_BYTE -1 : 0] byte_3;

    reg [NB_DATA-1 : 0] data_read      ;
    reg [NB_DATA-1 : 0] data_debug_read;

    reg [NB_BYTE -1 : 0] data_memory [NUM_SLOTS-1 : 0];
    integer              i                            ;

    // --------------------------------------------------
    // Write data memory block
    // --------------------------------------------------
    always @(posedge i_clock) begin
        if (i_reset) begin
            for (i=0; i<NUM_SLOTS; i=i+1) begin
                data_memory[i] <= 0;
            end
        end
        else if (i_write_enable) begin
            if(i_direcc != 0 && i_direcc != 1 && i_direcc != 2 && i_direcc != 3) begin // FIXME checkear esta condicion
                data_memory[i_direcc+0] <= byte_0;
                data_memory[i_direcc+1] <= byte_1;
                data_memory[i_direcc+2] <= byte_2;
                data_memory[i_direcc+3] <= byte_3;
            end
        end
    end

    // --------------------------------------------------
    // Read data memory block
    // --------------------------------------------------
    always @(negedge i_clock) begin
        data_read[0 * NB_BYTE +: NB_BYTE] <= i_byte_enb[0] ? data_memory[i_direcc + 0] : 0;
        data_read[1 * NB_BYTE +: NB_BYTE] <= i_byte_enb[1] ? data_memory[i_direcc + 1] : 0;
        data_read[2 * NB_BYTE +: NB_BYTE] <= i_byte_enb[2] ? data_memory[i_direcc + 2] : 0;
        data_read[3 * NB_BYTE +: NB_BYTE] <= i_byte_enb[3] ? data_memory[i_direcc + 3] : 0;
        data_debug_read                   <= {data_memory[i_direcc_debug+3], data_memory[i_direcc_debug+2], data_memory[i_direcc_debug+1], data_memory[i_direcc_debug+0]};
    end

    always @ (*) begin
        if (i_byte_enb[0]) begin
            byte_0 = i_data[0 * NB_BYTE +: NB_BYTE];
        end
        else begin
            byte_0 = data_memory[i_direcc+0];
        end
    end

    always @ (*) begin
        if (i_byte_enb[1]) begin
            byte_1 = i_data[1 * NB_BYTE +: NB_BYTE];
        end
        else begin
            byte_1 = data_memory[i_direcc+1];
        end
    end

    always @ (*) begin
        if (i_byte_enb[2]) begin
            byte_2 = i_data[2 * NB_BYTE +: NB_BYTE];
        end
        else begin
            byte_2 = data_memory[i_direcc+2];
        end
    end

    always @ (*) begin
        if (i_byte_enb[3]) begin
            byte_3 = i_data[3 * NB_BYTE +: NB_BYTE];
        end
        else begin
            byte_3 = data_memory[i_direcc+3];
        end
    end

    // --------------------------------------------------
    // Output assignments
    // --------------------------------------------------
    assign o_data       = data_read      ;
    assign o_data_debug = data_debug_read;

endmodule