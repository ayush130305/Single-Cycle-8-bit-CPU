`timescale 1ns / 1ps
// Instruction memory - combinational read, no clock
// 256 x 16-bit ROM, addressed by PC
module imem(
    input [7:0] addr,
    output[15:0] instr
    );
    reg [15:0] rom [255:0];
    
//    initial begin
//    $readmemh("program.mem", rom);
//    end
    
    assign instr = rom[addr];
    
endmodule
