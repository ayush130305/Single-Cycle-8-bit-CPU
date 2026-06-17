`timescale 1ns / 1ps

module imem(
    input [7:0] addr,
    output[7:0] instr
    );
    reg [7:0] rom [255:0];
    
//    initial begin
//    $readmemh("program.mem", rom);
//    end
    
    assign instr = rom[addr];
    
endmodule
