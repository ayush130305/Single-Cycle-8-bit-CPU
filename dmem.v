`timescale 1ns / 1ps


module dmem(
    input clk,
    input mem_read,
    input mem_write,
    input [7:0] addr,
    input [7:0] wr_data,
    output [7:0] rd_data
    );

reg [7:0] mem [7:0];
assign rd_data = mem_read ? mem[addr] : 8'b0;

always @(posedge clk)
    if (mem_write) begin 
    mem[addr] <= wr_data;
    end 
endmodule
