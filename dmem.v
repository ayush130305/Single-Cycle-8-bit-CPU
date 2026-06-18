`timescale 1ns / 1ps


module dmem(
    input clk,
    input mem_read, //used for LD, puts mem[addr] <- data inside onto address to be loaded from reg
    input mem_write, // used for ST, purs mem[addr] data into a register 
    input [7:0] addr, //address
    input [7:0] wr_data, // after mem_wr is 1 it allows data in wr_data to be written to mem[addr]
    output [7:0] rd_data // if mem_rd is 1 it allows mem[addr] to be accessed to be read
    );

    reg [7:0] mem [7:0]; //mem array in register
assign rd_data = mem_read ? mem[addr] : 8'b0;

always @(posedge clk)
    if (mem_write) begin 
    mem[addr] <= wr_data;
    end 
endmodule
