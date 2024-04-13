module top_pipeline
#(
    parameter N_BITS = 32,
    parameter NB_REG = 5
)
(
    input wire i_clk, i_reset, i_valid,
    
    input wire i_exec_mode, //si es continuo o paso a paso
    input wire i_step,      //ejecutar un paso
    
    output wire [N_BITS-1:0]        o_pc,
    output wire [N_BITS*N_BITS-1:0] o_registros,
    output wire [N_BITS-1:0]        o_registro,
    output wire [N_BITS-1:0]        o_data_memory,
    output wire [N_BITS-1:0]        o_ciclos,
    output wire [4:0]               o_n_reg,
    output wire                     o_halt
);

//    wire clk_out, locked;
    
    reg  [31:0] pc_salto;
    wire [31:0] pc_4;
    wire [31:0] pc_4_d;
    wire [31:0] pc_4_e;
    wire [31:0] pc_4_m;
    
    wire [31:0] instruccion;
    wire [4:0]  rs;
    wire [4:0]  rs_d;  
    wire [4:0]  rt;
    wire [4:0]  rt_d;  
    wire [4:0]  rd; 
    wire [4:0]  sa;
    wire [25:0] instr_index;
    wire [5:0]  opcode;
    wire [5:0]  opcode_e;
    wire [31:0] extended;
    wire [4:0]  write_reg;	
    wire [31:0] write_data;
    wire [4:0]  write_reg_wb;	
    wire [31:0] write_data_wb;
    wire [31:0] pc_branch;
    wire [31:0] pc_jump;
    wire [31:0] read_data_1;
    wire [31:0] read_data_2;
    wire [31:0] read_data_2_e;
    reg  [31:0] datoB;
    wire [4:0]  rt_rd;
    wire [4:0]  rt_rd_m;
    wire [31:0] aluResult;
    wire [31:0] alu_result;
    wire        zero;
    wire [31:0] data_memory;
    wire [31:0] count;
    
    wire [2:0] aluop;
    wire       alusrc;
    wire       regdst;
    wire       branch;
    wire       memrd;
    wire       memwr;
    wire       memtoreg;
    wire       regwr;
    wire [1:0] jump;
    wire [1:0] jump_e;
    wire [1:0] jump_m;
    wire       flush;
    wire       flush_d;
    wire       flush_m;
    wire       pc_src;
    
    wire branch_e;
    wire memrd_e;
    wire memwr_e;
    wire memtoreg_e;
    wire regwr_e;
    wire memtoreg_m;
    wire regwr_m;
    wire memtoreg_w;
    
    wire halt;
    wire halt_f;
    wire halt_d;
    wire halt_e;
    wire halt_m;
    wire stop;
    wire stall;
    
    wire [1:0] muxA;
    wire [1:0] muxB;
    
    wire [1023:0] registros;
    
    assign flush = flush_d || flush_m;
    
    always@(*)begin
        if(i_valid)
        begin
            if(pc_src)
                pc_salto = pc_branch;
            else 
                pc_salto = pc_jump;
        end
    end 
    
    //FETCH
    fetch u_fetch
    (
        .i_clock(i_clk)             ,
        .i_reset(i_reset)           ,
        .i_valid(i_valid)           ,
        // .i_exec_mode(i_exec_mode),
        // .i_step(i_step)  ,
        // .i_pc_salto(pc_salto)    ,
        .i_pc_src(flush)            ,
        // .i_halt(halt)    ,
        .i_stall(stall)             ,
        .o_pc_next(pc_next)         ,
        .o_instruccion(instruccion) ,
        // .o_halt(halt_f)  ,
        .o_rs(rs)                   ,
        .o_rt(rt)
    );
    
    //DECODE
    decode u_decode
    (
        .i_clock(i_clk)               ,
        .i_reset(i_reset)           ,
        .i_valid(i_valid)           ,
        // .i_halt(halt_f)             ,
        .i_instruccion(instruccion) ,
        .i_pc_next(pc_next)               ,
        .i_write_data(write_data)   ,
        .i_write_reg_enable(write_reg)     ,
        .i_reg_write(regwr_w)       ,
        .i_mem_read_idex(memrd)     ,
        // .i_rt_idex(rt)              ,
        // .i_flush(flush)             ,
        // .i_exec_mode(i_exec_mode)   ,
        // .i_step(i_step)             ,
        // .o_alu_op(aluop)            ,
        // .o_alu_src(alusrc)          ,
        // .o_reg_dst(regdst)          ,
        // .o_branch(branch)           ,
        // .o_jump(jump)               ,
        // .o_mem_read(memrd)          ,
        // .o_mem_write(memwr)         ,
        // .o_mem_to_reg(memtoreg)     ,
        // .o_reg_write(regwr)         ,
        // .o_halt(halt_d)             ,
        //.o_rt_stall(rt_stall),
        .o_pc_next(pc_4_d)             ,
        .o_data_read_0(read_data_0) ,
        .o_data_read_1(read_data_1) , 
        .o_extended(extended)       ,
        .o_instruction_index(instr_index) ,
        // .o_pc_jump(pc_jump)         ,
        .o_rs(rs_d)                 ,
        .o_rd(rd)                   ,
        .o_rt(rt_d)                 ,
        .o_sa(sa)                   ,
        .o_opcode(opcode)           ,
        // .o_stall(stall)             ,
        // .o_flush(flush_d)           ,
        // .o_registros(registros)
    );
    
    //rt
    //EXECUTE
    // execute u_exe
    // (
    //     .i_clk(i_clk)                   ,
    //     .i_reset(i_reset)               ,
    //     .i_valid(i_valid)               ,
    //     .i_halt(halt_d)                 ,
    //     .i_alu_op(aluop)                ,
    //     .i_alu_src(alusrc)              ,
    //     .i_reg_dst(regdst)              ,
    //     .i_branch(branch)               ,
    //     .i_mem_read(memrd)              ,
    //     .i_mem_write(memwr)             ,
    //     .i_mem_to_reg(memtoreg)         ,
    //     .i_jump(jump)                   ,
    //     .i_reg_write(regwr)             ,
    //     .i_pc_4(pc_4_d)                 ,
    //     .i_read_data_1(read_data_1)     ,
    //     .i_read_data_2(read_data_2)     ,
    //     .i_extended(extended)           ,
    //     .i_opcode(opcode)               ,
    //     .i_alu_result(aluResult)        ,
    //     .i_data_memory(write_data)      ,
    //     .i_exec_mode(i_exec_mode)       ,
    //     .i_step(i_step)                 ,
    //     .i_rd(rd)                       ,
    //     .i_rt(rt_d)                     ,
    //     .i_sa(sa)                       ,
    //     .i_mux_A(muxA)                  ,
    //     .i_mux_B(muxB)                  ,
    //     .i_flush(flush_m)               ,
    //     .o_branch(branch_e)             ,
    //     .o_mem_read(memrd_e)            ,
    //     .o_mem_write(memwr_e)           ,
    //     .o_jump(jump_e)                 ,
    //     .o_mem_to_reg(memtoreg_e)       ,
    //     .o_reg_write(regwr_e)           ,
    //     .o_pc_branch(pc_branch)         ,
    //     .o_alu_result(aluResult)        ,
    //     .o_halt(halt_e)                 ,
    //     .o_opcode(opcode_e)             ,
    //     .o_pc_4(pc_4_e)                 ,
    //     .o_read_data_2(read_data_2_e)   ,
    //     .o_rt_rd(rt_rd)                 ,
    //     .o_zero(zero)
    // );
    
    // //MEMORY
    // memory u_mem
    // (
    //     .i_clk(i_clk)                   ,
    //     .i_reset(i_reset)               ,
    //     .i_valid(i_valid)               ,
    //     .i_halt(halt_e)                 ,
    //     .i_branch(branch_e)             ,
    //     .i_mem_read(memrd_e)            ,
    //     .i_jump(jump_e)                 ,
    //     .i_pc_4(pc_4_e)                 ,
    //     .i_mem_write(memwr_e)           ,
    //     .i_mem_to_reg(memtoreg_e)       ,
    //     .i_reg_write(regwr_e)           ,
    //     .i_opcode(opcode_e)             ,
    //     .i_pc_branch(pc_branch)         ,
    //     .i_zero(zero)                   ,
    //     .i_alu_result(aluResult)        ,
    //     .i_read_data_2(read_data_2_e)   ,
    //     .i_rt_rd(rt_rd)                 ,
    //     .i_exec_mode(i_exec_mode)       ,
    //     .i_step(i_step)                 ,
    //     .o_mem_to_reg(memtoreg_m)       ,
    //     .o_reg_write(regwr_m)           ,
    //     .o_read_data(data_memory)       ,
    //     .o_alu_result(alu_result)       ,
    //     .o_rt_rd(rt_rd_m)               ,
    //     .o_pc_src(pc_src)               ,
    //     .o_halt(halt_m)                 ,
    //     .o_jump(jump_m)                 ,
    //     .o_pc_4(pc_4_m)                 ,
    //     .o_flush(flush_m)
    // );
    
    // //WRITEBACK
    // writeback u_wb
    // (
    //     .i_clk(i_clk),
    //     .i_reset(i_reset),
    //     .i_valid(i_valid),
    //     .i_halt(halt_m),
    //     .i_jump(jump_m),
    //     .i_mem_to_reg(memtoreg_m),
    //     .i_reg_write(regwr_m),
    //     .i_read_data(data_memory),
    //     .i_pc_4(pc_4_m),
    //     .i_alu_result(alu_result),
    //     .i_rd_rt(rt_rd_m),
    //     .o_stop(stop),
    //     .i_exec_mode(i_exec_mode),
    //     .i_step(i_step),
    //     .o_mem_to_reg(memtoreg_w),
    //     .o_reg_write(regwr_w),
    //     .o_write_data(write_data),
    //     .o_rd_rt(write_reg)
    // );
    
    // //Contador de ciclos
    // clk_cntr u_clk_cntr
    // (
    //     .i_clk(i_clk), .i_reset(i_reset), .i_valid(i_valid), 
    //     .i_exec_mode(i_exec_mode), .i_step(i_step),
    //     .i_instruccion(instruccion), .i_stop(stop),
    //     .o_halt(halt), .o_count(count) 
    // );
    
    // //Fowarding Unit
    // fowarding_unit u_fw
    // (
    //     .i_rs_idex(rs_d), .i_rt_idex(rt_d), .i_rd_exmem(rt_rd), 
    //     .i_rd_memwb(rt_rd_m), .i_reg_write_exmem(regwr_e), .i_reg_write_memwb(regwr_m), 
    //     .o_mux_A(muxA), .o_mux_B(muxB)
    // );
    
    // reg [4:0]  i = 5'b0;
    // reg [31:0] old_count = 32'b0;
    
    // always@(negedge i_clk)begin:print_reg
    //     if(i_exec_mode == 1'b0 || (i_exec_mode && i_step))
    //     begin
    //         if(old_count == count && count != 1) 
    //             i <= i + 1;
    //         else 
    //             old_count <= count;
    //     end

    // end
    
    assign o_pc = pc_4 - 1'b1;
    assign o_registros = registros;
    assign o_n_reg = i;  
    assign o_registro = registros[N_BITS*i+:N_BITS];
    assign o_data_memory = data_memory;
    assign o_ciclos = count;
    assign o_halt = halt;

endmodule