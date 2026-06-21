`timescale 1ns / 1ps

module cpu (
    input clk,
    input rst
);
    // Fetch
    wire [7:0] pc_out;
    wire [15:0] instr;

    // Instruction fields
    wire [3:0] opcode;
    wire [1:0] rs, rd;
    wire [7:0] imm;
    wire [7:0] imm_ext;

    // Control signals
    wire       reg_write;
    wire       alu_src;
    wire [3:0] alu_op;
    wire       mem_read;
    wire       mem_write;
    wire       branch;
    wire       branch_ne;
    wire       mem_to_reg;

    // Datapath
    wire [7:0] read_src, read_dest;
    wire [7:0] alu_b;
    wire [7:0] alu_result;
    wire       zero;
    wire [7:0] rd_data;
    wire [7:0] wb_data;
    wire [7:0] branch_target;
    wire       branch_taken;
    wire [1:0] write_addr;
    wire [7:0] alu_a = alu_src ? 8'b0 : read_dest;
    assign write_addr = alu_src ? rs : rd;

    // Instructions
    assign opcode        = instr[15:12];
    assign rs            = instr[11:10];    
    assign rd            = instr[9:8];
    assign imm           = instr[7:0];

    // mux block
    assign alu_b         = alu_src ? imm_ext : read_src;
    assign wb_data       = mem_to_reg ? rd_data : alu_result;
    assign branch_target = pc_out + imm_ext;
    assign branch_taken = (branch & zero) | (branch_ne & ~zero);
    wire reg_write_gated = reg_write & ~rst;

    PC u_pc (
        .clk           (clk),
        .rst           (rst),
        .branch_taken  (branch_taken),
        .branch_target (branch_target),
        .pc_out        (pc_out)
    );

    imem u_imem (
        .addr  (pc_out),
        .instr (instr)
    );

    control u_ctrl (
        .opcode    (opcode),
        .reg_write (reg_write),
        .alu_src   (alu_src),
        .alu_op    (alu_op),
        .mem_read  (mem_read),
        .mem_write (mem_write),
        .branch    (branch),
        .branch_ne    (branch_ne), 
        .mem_to_reg(mem_to_reg)
    );

    reg_file u_rf (
        .clk      (clk),
        .rs       (rs),
        .rd       (rd),
        .write_addr (write_addr),
        .write_en (reg_write_gated),
        .write    (wb_data),
        .read_src (read_src),
        .read_dest(read_dest)   
    );

    sign_ext u_sext (
        .imm     (imm),
        .imm_ext (imm_ext)
    );

    alu u_alu (
        .a        (alu_a),
        .b        (alu_b),
        .alu_op   (alu_op),
        .result   (alu_result),
        .zero     (zero),
        .carry    (),
        .negative (),
        .overflow ()
    );

    dmem u_dmem (
        .clk       (clk),
        .mem_read  (mem_read),
        .mem_write (mem_write),
        .addr      (alu_result),
        .wr_data   (read_src),
        .rd_data   (rd_data)
    );

endmodule
