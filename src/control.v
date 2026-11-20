module control_ALU (

    input [3:0] opcode,
    input [1:0] operand_1,
    input [1:0] operand_2,
    input [3:0] operand_imm,

    input [3:0] read_A,
    input [3:0] read_B,
    input [3:0] read_Z,
    input CF_in,

    output reg enable_A,
    output reg enable_B,
    output reg enable_Z,
    output reg enable_CF,

    output reg [3:0] write_A,
    output reg [3:0] write_B,
    output reg [3:0] write_Z,
    output reg CF_out
);

localparam  NOP = 4'd0,     ADD = 4'd1,     ADDC = 4'd2,    SUB = 4'd3,
            SUBC = 4'd4,    NOT = 4'd5,     AND = 4'd6,     OR = 4'd7,
            XOR = 4'd8,     LSHIFT = 4'd9,  RSHIFT = 4'd10, LDI_A = 4'd11,
            LDI_B = 4'd12,  MOV = 4'd13,    CMP = 4'd14,    OUT = 4'd15
;
reg [3:0]A;
reg [3:0]B;
reg C;
wire [3:0]Z;
wire CF;

shared_adder adder(.A(A),.B(B),.CF_in(C),.Z(Z),.CF_out(CF));

always @(*) begin
    enable_A = 1'b0;    
    enable_B = 1'b0;
    enable_Z = 1'b0;
    enable_CF = 1'b0;

    write_A = 4'b0000;
    write_B = 4'b0000;
    write_Z = 4'b0000;
    CF_out = 4'b0000;
    A = read_A;
    B = read_B;
    C = 0;

    case (opcode)
        NOP:;
        ADD: begin
            write_Z = Z;
            CF_out = CF;

            enable_Z = 1'b1;
            enable_CF = 1'b1;
        end
        ADDC: begin
            C = CF_in;

            write_Z = Z;
            CF_out = CF;

            enable_Z = 1'b1;
            enable_CF = 1'b1;
        end
        SUB: begin
            A = read_A;
            B = ~read_B;
            C = 1;

            write_Z = Z;
            CF_out = ~CF;

            enable_Z = 1'b1;
            enable_CF = 1'b1;
        end
        SUBC: begin
            A = read_A;
            B = ~read_B;
            C = ~CF_in;  

            write_Z = Z;
            CF_out = ~CF;

            enable_Z = 1'b1;
            enable_CF = 1'b1;
            
        end
        NOT: begin
            write_Z =  ~read_A;
            enable_Z = 1'b1;
        end
        AND: begin
            write_Z =  read_A & read_B; 
            enable_Z = 1'b1;
        end
        OR: begin
            write_Z =  read_A | read_B; 
            enable_Z = 1'b1;
        end
        XOR: begin
            write_Z =  read_A ^ read_B;
            enable_Z = 1'b1;
        end
        LSHIFT: begin
            {CF_out,write_Z} = read_A<<1;
            
            enable_Z = 1'b1;
            enable_CF = 1'b1;
        end
        RSHIFT: begin
            CF_out = read_A[0];
            write_Z = read_A>>1;
            
            enable_Z = 1'b1;
            enable_CF = 1'b1;
        end
        LDI_A: begin
            write_A = operand_imm;
            enable_A = 1'b1;
        end
        LDI_B: begin
            write_B = operand_imm;
            enable_B = 1'b1;
        end
        MOV: begin
            case (operand_1)
                2'b01:begin
                    case (operand_2)
                        2'b00: write_A = 4'b0000;
                        2'b01: ;
                        2'b10: write_A = read_B;
                        2'b11: write_A = read_Z;
                    endcase
                enable_A = 1'b1;
                end 
                2'b10:begin
                    case (operand_2)
                        2'b00: write_B = 4'b0000;
                        2'b01: write_B = read_A;
                        2'b10: ;
                        2'b11: write_B = read_Z; 
                    endcase
                enable_B = 1'b1;
                end
                2'b11: begin
                    case (operand_2)
                        2'b00: write_Z = 4'b0000;
                        2'b01: write_Z = read_A;
                        2'b10: write_Z = read_B;
                        2'b11: ;
                    endcase
                enable_Z = 1'b1;
                end
                default: ;
            endcase
        end
        CMP: begin
            write_Z ={
                (read_A == 4'b0000),  
                (read_A == read_B),
                (read_A < read_B),    
                (read_A > read_B)
                };
            enable_Z = 1'b1;
        end
        default:;
   endcase 
    
end

endmodule

module shared_adder (
    input [3:0] A,
    input [3:0] B,
    input CF_in,
    output wire [3:0] Z,
    output wire CF_out
);

    assign {CF_out,Z} = A + B + CF_in;
endmodule