module register (
    input clk,
    input rst_n,
    input enable,
    input [3:0] idata,
    output reg [3:0] rdata 
);
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            rdata <= 4'b0000;
        end 
        else if(enable) begin
            rdata <= idata;
        end
    end
endmodule

module carry_flag (
    input clk,
    input rst_n,
    input enable,
    input idata,
    output reg rdata 
);
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            rdata <= 1'b0;
        end 
        else if(enable) begin
            rdata <= idata;
        end
    end
endmodule