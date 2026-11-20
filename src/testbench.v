`timescale 1ns/100ps
`include "project.v"

module tb_simple;
    reg        clk = 0;
    reg        rst_n = 0;
    reg  [7:0] ui_in = 8'h00;       // 8'h00 = NOP
    wire [7:0] uo_out;
    wire [7:0] uio_out, uio_oe;

    tt_um_legend1243 dut (
        .ui_in(ui_in),   .uo_out(uo_out),
        .uio_in(8'h00),  .uio_out(uio_out), .uio_oe(uio_oe),
        .ena(1'b1),      .clk(clk),         .rst_n(rst_n)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("./build/wave.fst");
        $dumpvars(0, tb_simple);
    end

    // put one instruction on ui_in and let one clock edge execute it
    task run(input [7:0] instr);
        begin
            ui_in = instr;
            @(posedge clk);
            #1;
        end
    endtask

    // compare uo_out with the value we expect
    task check(input [7:0] expected);
        begin
            if (uo_out === expected)
                $display("PASS  uo_out=%h", uo_out);
            else
                $display("FAIL  uo_out=%h  expected=%h", uo_out, expected);
        end
    endtask

    initial begin
        #22 rst_n = 1;              // reset covers a couple of clock edges

        // instruction byte = {opcode, operands}
        run(8'hB5);                 // LDI_A 5
        run(8'hC3);                 // LDI_B 3
        run(8'h10);                 // ADD      Z = 5+3 = 8, CF = 0
        run(8'hF0);  check(8'h08);  // OUT      {000, CF, Z} = 0_1000

        run(8'h30);                 // SUB      Z = 5-3 = 2, CF = 0
        run(8'hF0);  check(8'h02);

        run(8'hB3);                 // LDI_A 3
        run(8'hC5);                 // LDI_B 5
        run(8'h30);                 // SUB      Z = 3-5 = 14, CF = 1 (borrow)
        run(8'hF0);  check(8'h1E);  // {000, 1, 1110}

        run(8'h20);                 // ADDC     Z = 3+5+CF(1) = 9, CF = 0
        run(8'hF0);  check(8'h09);

        $finish;
    end
endmodule