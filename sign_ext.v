`timescale 1ns / 1ps

// no longer extends the imm, however it makes sure the sign is proper
//if -imm pc can go behind, +imm pc goes ahead
module sign_ext(
    input [7:0] imm,
    output [7:0] imm_ext
    );
    
    assign imm_ext = imm;
endmodule
