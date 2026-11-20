module out (
    input clk,
    input rst_n,
    input [3:0] opcode,
    
    input CF_in,
    input [3:0] read_Z,
    output reg [7:0] write_out
);


always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        write_out <= 8'd0;
    end
    else begin
        if(opcode == 4'd15) begin
            write_out <= {3'b000,CF_in,read_Z};
        end
        end
end

endmodule