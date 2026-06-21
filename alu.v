`timescale 1ns / 1ps

module alu(
    input  [7:0] a,
    input  [7:0] b,
    input  [3:0] alu_op,
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
        4'b0000: begin   //add      
        {carry, result}  = {1'b0, a} + {1'b0, b};
        overflow = (a[7] == b[7]) && (result[7] != a[7]);   
        end
        
        4'b0001: begin //sub
        {carry, result} = {1'b0, a} - {1'b0, b};
        overflow = (a[7] != b[7]) && (result[7] != a[7]);  
        end
        
        4'b0010: begin //and
        result = a & b;
        end
        
        4'b0011: begin //or
        result = a | b;
        end
        
        4'b0100: begin //xor
        result = a ^ b;
        end
        
        4'b0101: begin //not
        result = ~(a);
        end
        
        4'b0110: begin //shl
        result = a << b[2:0];
        end
        
        4'b0111: begin //shr
        result = a >> b[2:0];
        end
        
        4'b1001: begin //mov
        result = b;
        end
              
        default: result = 8'b0;
      
        endcase
    end
    assign zero     = (result == 8'b0);
    assign negative = result[7];
endmodule
