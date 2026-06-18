`timescale 1ns / 1ps

module PC (
    input clk,
    input rst,
    input branch_taken, //1: branch target gets stored in pc_out
    input [7:0] branch_target, //if branch is taken then it jumps the pc to another instruction, if not pc goes to next instruction
    output reg [7:0] pc_out //works as a counter

);

always @(posedge clk) begin
    if (rst) begin
    pc_out <= 8'b0;
    end else begin
        if (branch_taken) begin 
        pc_out <= branch_target;
        end else begin
        pc_out <= pc_out + 1'b1;
        end
    end
end

endmodule
