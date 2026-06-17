`timescale 1ns / 1ps

module control(
    input [2:0] opcode,
    output reg reg_write,
    output reg alu_src,
    output reg [2:0] alu_op,
    output reg mem_read,
    output reg mem_write,
    output reg branch,
    output reg mem_to_reg
    );
    
    always @(*) begin
    
        reg_write  = 1'b0;
        alu_src    = 1'b0;
        alu_op     = 3'b000;
        mem_read   = 1'b0;
        mem_write  = 1'b0;
        branch     = 1'b0;
        mem_to_reg = 1'b0;   
         
    case (opcode)
            3'b000: begin // ADD
                reg_write = 1'b1;
                alu_op    = 3'b000; 
            end
            
            3'b001: begin // SUB
                reg_write = 1'b1;
                alu_op    = 3'b001; 
            end 
            
            3'b010: begin // AND
                reg_write = 1'b1;
                alu_op    = 3'b010; 
            end                       
 
            3'b011: begin // OR
                reg_write = 1'b1;
                alu_op    = 3'b011; 
            end
                        
            3'b100: begin // LDI 
                reg_write  = 1'b1;
                alu_src    = 1'b1; 
            end
            
            3'b101: begin // LD (Load from Memory)
                alu_src = 1'b1;
                reg_write  = 1'b1;
                mem_read   = 1'b1;
                mem_to_reg = 1'b1; 
            end
            
            3'b110: begin // ST (Store to Memory)
                alu_src = 1'b1;
                mem_write  = 1'b1;
            end
            
            3'b111: begin // BEQ (Branch if Equal)
                branch     = 1'b1;
                alu_op     = 3'b001; 
            end
            
            default: begin

            end
        endcase
    
    end 
endmodule
