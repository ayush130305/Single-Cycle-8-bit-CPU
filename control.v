`timescale 1ns / 1ps

module control(
    input [3:0] opcode,
    output reg reg_write,
    output reg alu_src,
    output reg [3:0] alu_op,
    output reg mem_read,
    output reg mem_write,
    output reg branch,
    output reg branch_ne,
    output reg mem_to_reg
    );
    
    always @(*) begin
    
        reg_write  = 1'b0;
        alu_src    = 1'b0;
        alu_op     = 4'b0000;
        mem_read   = 1'b0;
        mem_write  = 1'b0;
        branch     = 1'b0;
        branch_ne = 1'b0;
        mem_to_reg = 1'b0;   
         
    case (opcode)
            4'b0000: begin // ADD
                reg_write = 1'b1;
                alu_op    = 4'b0000; 
            end
            
            4'b0001: begin // SUB
                reg_write = 1'b1;
                alu_op    = 4'b0001; 
            end 
            
            4'b0010: begin // AND
                reg_write = 1'b1;
                alu_op    = 4'b0010; 
            end                       
 
            4'b0011: begin // OR
                reg_write = 1'b1;
                alu_op    = 4'b0011; 
            end
            
            4'b0100: begin //xor
            reg_write = 1;
            alu_op = 4'b0100;        
            end
 
            4'b0101: begin //not
            reg_write = 1;
            alu_op = 4'b0101;
            end
            
            4'b0110: begin //shl
            reg_write=1;
            alu_op = 4'b0110;
            end  
            
            4'b0111: begin
            reg_write=1;
            alu_op = 4'b0111;
            end
            
            4'b1000: begin
            reg_write = 0;
            alu_op = 4'b0001;
            end               
                                                      
            4'b1001: begin 
            reg_write=1;
            alu_op = 4'b1001;            
            end
            
            4'b1010: begin // LDI 
                reg_write  = 1'b1;
                alu_src    = 1'b1; 
            end
            
            4'b1011: begin // LD (Load from Memory)
                alu_src = 1'b1;
                reg_write  = 1'b1;
                mem_read   = 1'b1;
                mem_to_reg = 1'b1; 
            end
            
            4'b1100: begin // ST (Store to Memory)
                alu_src = 1'b1;
                mem_write  = 1'b1;
            end
 
            4'b1101: begin // BEQ (Branch if Equal)
                branch     = 1'b1;
                alu_op     = 4'b0001; 
            end            

            4'b1110: begin //bne
            reg_write=0;
            branch_ne = 1;
            alu_op = 4'b0001;            
            end
            
            4'b1111: begin  //reserved
       
            end
                                    
            default: begin

            end
        endcase
    
    end 
endmodule
