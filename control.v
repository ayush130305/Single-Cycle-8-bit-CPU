`timescale 1ns / 1ps

module control(
    input [2:0] opcode, //contains opcodes (which then get decoded to the instruction 000 -> 111)
    output reg reg_write, // tells register to be written, 1 : writes data into reg_d, 0 : ignore
    output reg alu_src, // 0: r type (reads from reg), 1: i type (reads from imm output)
    output reg [2:0] alu_op, // check alu code
    output reg mem_read, // 1: used for LD (puts mem[addr] into address)
    output reg mem_write, // 1: used for ST (puts read data in mem[addr])
    output reg branch, //used in pc mux 
    output reg mem_to_reg //0: used in alu (ADD, SUB, AND, OR, LDI), 1: dmem op (load function so store that in memory (R1))
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
