module reg_file(
    input  [1:0] rs,
    input  [1:0] rd,
    input  [1:0] write_addr,// destination register address for write
    input        write_en,
    input        clk,
    input  [7:0] write,//data to be written into registers[write_addr]
    output [7:0] read_src,
    output [7:0] read_dest
);

    reg [7:0] registers [3:0]; //4, 8 bit registers

integer i;
initial begin
    for (i = 0; i < 4; i = i+1)
        registers[i] = 8'b0; //males registers 0
end

    assign read_src  = registers[rs];//reads from source register (B)
    assign read_dest = registers[rd];//reads from destination register (A)

always @(posedge clk) begin
    if (write_en && write_addr != 2'b00) begin
        registers[write_addr] <= write;//when write_en must be high ,write_addr dest. can not be R0 (as R0 is always 0), only then it writes into a specific register at address
    end
end

endmodule
