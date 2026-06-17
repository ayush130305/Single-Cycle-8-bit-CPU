`timescale 1ns / 1ps

module sign_ext(
    input [2:0] imm,
    output [7:0] imm_ext
    );
    
    assign imm_ext = {{5{imm[2]}}, imm};
endmodule
