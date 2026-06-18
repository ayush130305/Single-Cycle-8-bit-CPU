`timescale 1ns / 1ps

module imem(
    input [7:0] addr, //address from PC — selects which instruction to fetch
    output[7:0] instr //fed into decoder to extract opcode, registers, immediate
    );
    reg [7:0] rom [255:0]; //created a memory array of 256, with 8 bit entries
    
//    initial begin
//    $readmemh("program.mem", rom);
//    end
    
    assign instr = rom[addr];
    
endmodule
