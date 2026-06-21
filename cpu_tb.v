`timescale 1ns / 1ps

module cpu_tb();

    reg clk, rst;

    cpu u_cpu (
        .clk (clk),
        .rst (rst)
    );

    initial clk = 0;
    always #5 clk = ~clk;
  initial begin
    u_cpu.u_imem.rom[0] = 16'hA403; // LDI R1, 3
    u_cpu.u_imem.rom[1] = 16'hA802; // LDI R2, 2
    u_cpu.u_imem.rom[2] = 16'h0900; // ADD R1, R2
    u_cpu.u_imem.rom[3] = 16'hC400; // ST R1, 0
    rst = 1;
    #20;
    rst = 0;
    #50;
    $display("PC     = %0d", cpu_tb.u_cpu.u_pc.pc_out);
    $display("R1     = %0d", cpu_tb.u_cpu.u_rf.registers[1]);
    $display("R2     = %0d", cpu_tb.u_cpu.u_rf.registers[2]);
    $display("MEM[0] = %0d", cpu_tb.u_cpu.u_dmem.mem[0]);
    $finish;
end

endmodule