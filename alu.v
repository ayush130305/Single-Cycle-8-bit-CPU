`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/17/2026 02:36:55 PM
// Design Name: 
// Module Name: alu
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


module alu(
    input  [7:0] a,
    input  [7:0] b,
    input  [2:0] alu_op,
    output reg [7:0] result,
    output zero,
    output reg carry,
    output negative,
    output reg overflow
    );
     
    always @(*) begin
        carry = 1'b0;
        overflow = 1'b0;
        result = 8'b0;
        
        case(alu_op)  
        3'b000: begin         
        {carry, result}  = {1'b0, a} + {1'b0, b};
        overflow = (a[7] == b[7]) && (result[7] != a[7]);   
        end
        
        3'b001: begin
        {carry, result} = {1'b0, a} - {1'b0, b};
        overflow = (a[7] != b[7]) && (result[7] != a[7]);  
        end
        
        3'b010: begin
        result = a & b;
        end
        
        3'b011: begin 
        result = a | b;
        end
        
        default: result = 8'b0;
      
        endcase
    end
    assign zero     = (result == 8'b0);
    assign negative = result[7];
endmodule
