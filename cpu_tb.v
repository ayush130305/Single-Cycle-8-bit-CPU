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
    cpu_tb.u_cpu.u_imem.rom[0] = 8'h8B; // LDI R1, 3
    cpu_tb.u_cpu.u_imem.rom[1] = 8'h92; // LDI R2, 2
    cpu_tb.u_cpu.u_imem.rom[2] = 8'h12; // ADD R1, R2
    cpu_tb.u_cpu.u_imem.rom[3] = 8'hC8; // ST R1, 0
    
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