`timescale 1ns / 1ps

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
            overflow = (a[7] == b[7]) && (result[7] != a[7]);   //checks if both inputs have the same sign and result is opp sign of input, then overflow occurs
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
    assign zero     = (result == 8'b0); // if result is all 0's then then we start the zero flag (0-neg, 1-pos)
    assign negative = result[7]; // read the 8th bit 
endmodule
