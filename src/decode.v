module decode(
    input [7:0] ui_in,
    output reg [3:0] opcode,
    output reg [1:0] operand_1,
    output reg [1:0] operand_2,
    output reg [3:0] operand_imm
);

always @(*) begin

    opcode <= ui_in[7:4];
    operand_1 <= ui_in[3:2];
    operand_2 <= ui_in[1:0];
    operand_imm <= ui_in[3:0];
end
    
endmodule