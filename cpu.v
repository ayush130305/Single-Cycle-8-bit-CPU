`timescale 1ns / 1ps
// cpu.v - 3-stage pipelined 8-bit CPU
// Flush zeros both IF/ID and ID/EX to kill wrongly-fetched instructions

module cpu (
    input clk,
    input rst
);

    wire [7:0]  pc_out;
    wire [15:0] instr;

    wire flush;
    wire load_use_hazard;

    // IF/ID register
    reg [7:0]  IF_ID_pc;
    reg [15:0] IF_ID_instr;

    always @(posedge clk) begin
        if (rst || flush) begin
            IF_ID_pc    <= 8'b0;
            IF_ID_instr <= 16'b0;
        end else if (!load_use_hazard) begin
            IF_ID_pc    <= pc_out;
            IF_ID_instr <= instr;
        end
    end

    // Decode fields
    wire [3:0] opcode = IF_ID_instr[15:12];
    wire [1:0] rs     = IF_ID_instr[11:10];
    wire [1:0] rd     = IF_ID_instr[9:8];
    wire [7:0] imm    = IF_ID_instr[7:0];
    wire [7:0] imm_ext;

    wire reg_write, alu_src, mem_read, mem_write, branch, branch_ne, mem_to_reg;
    wire [3:0] alu_op;
    wire [1:0] write_addr;
    assign write_addr = alu_src ? rs : rd;

    wire [7:0] read_src, read_dest;

    // ID/EX register
    reg [7:0]  ID_EX_pc;
    reg [7:0]  ID_EX_read_src;
    reg [7:0]  ID_EX_read_dest;
    reg [7:0]  ID_EX_imm_ext;
    reg [1:0]  ID_EX_rs, ID_EX_rd, ID_EX_write_addr;
    reg        ID_EX_reg_write, ID_EX_alu_src;
    reg [3:0]  ID_EX_alu_op;
    reg        ID_EX_mem_read, ID_EX_mem_write;
    reg        ID_EX_branch, ID_EX_branch_ne, ID_EX_mem_to_reg;

    always @(posedge clk) begin
        if (rst || flush) begin
            // reset OR flush - zero all control signals 
            ID_EX_reg_write<=0;
            ID_EX_alu_src<=0; 
            ID_EX_alu_op<=0;
            ID_EX_mem_read<=0; 
            ID_EX_mem_write<=0; 
            ID_EX_branch<=0;
            ID_EX_branch_ne<=0; 
            ID_EX_mem_to_reg<=0; 
            ID_EX_read_src<=0;
            ID_EX_read_dest<=0; 
            ID_EX_imm_ext<=0; 
            ID_EX_rs<=0;
            ID_EX_rd<=0; 
            ID_EX_write_addr<=0; 
            ID_EX_pc<=0;
        end else if (load_use_hazard) begin
            // stall - zero control signals only
            ID_EX_reg_write<=0; 
            ID_EX_mem_read<=0; 
            ID_EX_mem_write<=0;
            ID_EX_branch<=0; 
            ID_EX_branch_ne<=0; 
            ID_EX_mem_to_reg<=0;
            ID_EX_alu_src<=0; 
            ID_EX_alu_op<=0;
        end else begin
            // normal latch
            ID_EX_pc<=IF_ID_pc; 
            ID_EX_read_src<=read_src;
            ID_EX_read_dest<=read_dest; 
            ID_EX_imm_ext<=imm_ext;
            ID_EX_rs<=rs; ID_EX_rd<=rd; 
            ID_EX_write_addr<=write_addr;
            ID_EX_reg_write<=reg_write; 
            ID_EX_alu_src<=alu_src;
            ID_EX_alu_op<=alu_op; 
            ID_EX_mem_read<=mem_read;
            ID_EX_mem_write<=mem_write; 
            ID_EX_branch<=branch;
            ID_EX_branch_ne<=branch_ne; 
            ID_EX_mem_to_reg<=mem_to_reg;
        end
    end

    // Execute wires
    wire [7:0] alu_result, rd_data, wb_data, branch_target;
    wire       zero, branch_taken;

    // EX/WB register - holds settled result for forwarding
    reg [7:0]  EX_WB_result;
    reg [1:0]  EX_WB_write_addr;
    reg        EX_WB_reg_write;

    always @(posedge clk) begin
        if (rst) begin
            EX_WB_result<=0; EX_WB_write_addr<=0; EX_WB_reg_write<=0;
        end else begin
            EX_WB_result     <= wb_data;
            EX_WB_write_addr <= ID_EX_write_addr;
            EX_WB_reg_write  <= ID_EX_reg_write;
        end
    end

    // Hazard detection
    wire [1:0] dec_rs = IF_ID_instr[11:10];
    wire [1:0] dec_rd = IF_ID_instr[9:8];

    wire forward_A = EX_WB_reg_write &&
                     (EX_WB_write_addr != 2'b00) &&
                     (EX_WB_write_addr == dec_rd);

    wire forward_B = EX_WB_reg_write &&
                     (EX_WB_write_addr != 2'b00) &&
                     (EX_WB_write_addr == dec_rs);

    assign load_use_hazard = ID_EX_mem_read &&
                             ((ID_EX_write_addr == dec_rs) ||
                              (ID_EX_write_addr == dec_rd));

    assign flush = branch_taken;

    // ALU inputs
    wire [7:0] alu_a_fwd = forward_A ? EX_WB_result : ID_EX_read_dest;
    wire [7:0] alu_a     = ID_EX_alu_src ? 8'b0 : alu_a_fwd;
    wire [7:0] alu_b;
    assign alu_b = ID_EX_alu_src ? ID_EX_imm_ext
                                 : (forward_B ? EX_WB_result : ID_EX_read_src);

    assign wb_data       = ID_EX_mem_to_reg ? rd_data : alu_result;
    assign branch_target = ID_EX_pc + ID_EX_imm_ext;
    assign branch_taken  = (ID_EX_branch & zero) | (ID_EX_branch_ne & ~zero);
    wire reg_write_gated = ID_EX_reg_write & ~rst;

    PC u_pc (
        .clk(clk),.rst(rst),.stall(load_use_hazard),.flush(flush),
        .branch_taken(branch_taken),.branch_target(branch_target),.pc_out(pc_out)
    );
    imem   u_imem(.addr(pc_out),.instr(instr));
    control u_ctrl(
        .opcode(opcode),
        .reg_write(reg_write),
        .alu_src(alu_src),
        .alu_op(alu_op),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .branch(branch),
        .branch_ne(branch_ne),
        .mem_to_reg(mem_to_reg)
    );
    reg_file u_rf(
        .clk(clk),
        .rs(rs),
        .rd(rd),
        .write_addr(ID_EX_write_addr),
        .write_en(reg_write_gated),
        .write(wb_data),
        .read_src(read_src),
        .read_dest(read_dest)
    );
    sign_ext u_sext(
    .imm(imm),
    .imm_ext(imm_ext)
    );
    alu u_alu(
        .a(alu_a),
        .b(alu_b),
        .alu_op(ID_EX_alu_op),
        .result(alu_result),
        .zero(zero),
        .carry(),
        .negative(),
        .overflow()
    );
    dmem u_dmem(
        .clk(clk),
        .mem_read(ID_EX_mem_read),
        .mem_write(ID_EX_mem_write),
        .addr(alu_result),
        .wr_data(ID_EX_read_src),
        .rd_data(rd_data)
    );

endmodule