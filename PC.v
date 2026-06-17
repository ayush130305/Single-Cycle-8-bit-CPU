`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/17/2026 03:37:29 PM
// Design Name: 
// Module Name: PC
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module PC (
    input clk,
    input rst,
    input branch_taken,
    input [7:0] branch_target,
    output reg [7:0] pc_out

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
