`timescale 1ns / 1ps

module PC (
    input clk,
    input rst,
    input stall,
    input flush,
    input branch_taken,
    input [7:0] branch_target,
    output reg [7:0] pc_out

);

always @(posedge clk) begin
    if (rst) begin
    pc_out <= 8'b0;
    end else if (!stall) begin
        if (branch_taken) begin 
        pc_out <= branch_target;
        end else begin
        pc_out <= pc_out + 1'b1;
        end
    end
end


endmodule
