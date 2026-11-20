/*
 * Copyright (c) 2024 Chen E-Chen
 * SPDX-License-Identifier: Apache-2.0
 */

`include "registers.v"
`include "decode.v"
`include "control.v"
`include "out.v"
`include "sync.v"

`default_nettype none

module tt_um_legend1243 (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  // All output pins must be assigned. If not used, assign to 0.
  assign uio_out = 0;
  assign uio_oe  = 0;

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, clk, rst_n, 1'b0};

  //pipeline cycle - note: will replace with fsm
  wire [1:0]cyc;

  //sync
  wire sync_out;
  wire sync_in;

  //initialise registers

  //reg A
  wire enable_A;
  wire [3:0] data_A;
  wire [3:0] reg_A;
  register REG_A(
    .clk(clk),
    .rst_n(rst_n),
    .enable(enable_A),
    .idata(data_A),
    .rdata(reg_A)
  );

  //reg B
  wire enable_B;
  wire [3:0] data_B;
  wire [3:0] reg_B;
  register REG_B(
    .clk(clk),
    .rst_n(rst_n),
    .enable(enable_B),
    .idata(data_B),
    .rdata(reg_B)
  );

  //reg Z
  wire enable_Z;
  wire [3:0] data_Z;
  wire [3:0] reg_Z;
  register REG_Z(
    .clk(clk),
    .rst_n(rst_n),
    .enable(enable_Z),
    .idata(data_Z),
    .rdata(reg_Z)
  );

  //carry flag cf
  wire CF_in;
  wire CF_out;
  wire enable_CF;
  carry_flag CF(
    .clk(clk),
    .rst_n(rst_n),
    .enable(enable_CF),
    .idata(CF_in),
    .rdata(CF_out)
  );

  //decoder
  //opcode
  wire [3:0] opcode;

  //operand 
  //operand 1 and 2 for register selection
  wire [1:0] operand_1;
  wire [1:0] operand_2;
  //operand imm
  wire [3:0] operand_imm;

  decode decoder(
  .ui_in(ui_in),
  .opcode(opcode),
  .operand_1(operand_1),
  .operand_2(operand_2),
  .operand_imm(operand_imm)
  );

  //control
  control_ALU controller(

    .opcode(opcode),
    .operand_1(operand_1),
    .operand_2(operand_2),
    .operand_imm(operand_imm),

    .read_A(reg_A),
    .read_B(reg_B),
    .read_Z(reg_Z),
    .CF_in(CF_out),

    .enable_A(enable_A),   
    .enable_B(enable_B),
    .enable_Z(enable_Z),
    .enable_CF(enable_CF),

    .write_A(data_A),
    .write_B(data_B),
    .write_Z(data_Z),
    .CF_out(CF_in)
  );

  //output
  out writeout(
    .clk(clk),
    .rst_n(rst_n),
    .opcode(opcode),
    .CF_in(CF_out),
    .read_Z(reg_Z),
    .write_out(uo_out)
  );

endmodule
