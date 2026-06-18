`timescale 1ns / 1ps

module imem(
    input [7:0] addr, //address stored
    output[7:0] instr //has instructions, like opcodes are decoded to this 
    );
    reg [7:0] rom [255:0]; //created a memory array
    
//    initial begin
//    $readmemh("program.mem", rom);
//    end
    
    assign instr = rom[addr];
    
endmodule
