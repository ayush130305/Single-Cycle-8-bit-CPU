module reg_file(
    input  [1:0] rs,
    input  [1:0] rd,
    input  [1:0] write_addr,
    input        write_en,
    input        clk,
    input  [7:0] write,
    output [7:0] read_src,
    output [7:0] read_dest
);

reg [7:0] registers [3:0];

integer i;
initial begin
    for (i = 0; i < 4; i = i+1)
        registers[i] = 8'b0;
end

assign read_src  = registers[rs];
assign read_dest = registers[rd];

always @(posedge clk) begin
    if (write_en && write_addr != 2'b00) begin
        registers[write_addr] <= write;
    end
end

endmodule