`timescale 1ns / 1ps
module cpu_tb();
    reg clk, rst;
    integer i;
    cpu u_cpu(.clk(clk), .rst(rst));
    initial begin clk=0; repeat(1000) #5 clk=~clk; $finish; end

    initial begin

        $display("=== TEST 1: Generic + Forwarding ===");
        for(i=0;i<256;i=i+1) u_cpu.u_imem.rom[i]=16'h0;
        u_cpu.u_imem.rom[0]=16'hA403; // LDI R1,3
        u_cpu.u_imem.rom[1]=16'hA802; // LDI R2,2
        u_cpu.u_imem.rom[2]=16'h0900; // ADD R1,R2 → R1=5
        u_cpu.u_imem.rom[3]=16'hC400; // ST R1,0   → MEM[0]=5
        rst=1; #40; rst=0; #200;
        $display("  R1=%0d R2=%0d MEM0=%0d", u_cpu.u_rf.registers[1],u_cpu.u_rf.registers[2],u_cpu.u_dmem.mem[0]);
        $display("  Expected: R1=5 R2=2 MEM0=5");

        $display("=== TEST 2: Load-Use Hazard ===");
        for(i=0;i<256;i=i+1) u_cpu.u_imem.rom[i]=16'h0;
        u_cpu.u_imem.rom[0]=16'hA40A; // LDI R1,10
        u_cpu.u_imem.rom[1]=16'hC400; // ST R1,0
        u_cpu.u_imem.rom[2]=16'hA803; // LDI R2,3
        u_cpu.u_imem.rom[3]=16'hB400; // LD R1,0   → R1=10
        u_cpu.u_imem.rom[4]=16'h0900; // ADD R1,R2 → R1=13
        u_cpu.u_imem.rom[5]=16'hC400; // ST R1,0   → MEM[0]=13
        rst=1; #40; rst=0; #250;
        $display("  R1=%0d R2=%0d MEM0=%0d", u_cpu.u_rf.registers[1],u_cpu.u_rf.registers[2],u_cpu.u_dmem.mem[0]);
        $display("  Expected: R1=13 R2=3 MEM0=13");

        $display("=== TEST 3: Control Hazard (Flush) ===");
        for(i=0;i<256;i=i+1) u_cpu.u_imem.rom[i]=16'h0;
        // BEQ at rom[3], ID_EX_pc=3, imm=2 → target=5
        // rom[4] = bad instruction → gets flushed by flush on IF_ID
        // rom[5] = ST → executes correctly
        u_cpu.u_imem.rom[0]=16'hA403; // LDI R1,3
        u_cpu.u_imem.rom[1]=16'hA802; // LDI R2,2
        u_cpu.u_imem.rom[2]=16'h0900; // ADD R1,R2 → R1=5
        u_cpu.u_imem.rom[3]=16'hD002; // BEQ R0,+2 → jump to rom[5]
        u_cpu.u_imem.rom[4]=16'hA8FF; // LDI R2,255 → MUST BE FLUSHED
        u_cpu.u_imem.rom[5]=16'hC400; // ST R1,0   → MEM[0]=5
        rst=1; #40; rst=0; #250;
        $display("  R1=%0d R2=%0d MEM0=%0d", u_cpu.u_rf.registers[1],u_cpu.u_rf.registers[2],u_cpu.u_dmem.mem[0]);
        $display("  Expected: R1=5 R2=2 MEM0=5 (R2=255 means flush failed)");

        $finish;
    end
endmodule