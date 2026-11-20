# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, FallingEdge


async def run(dut, instr):
    """Put one instruction on ui_in, let one clock edge execute it."""
    dut.ui_in.value = instr
    await ClockCycles(dut.clk, 1)
    await FallingEdge(dut.clk)      # let registers settle before reading


def check(dut, expected):
    got = int(dut.uo_out.value)
    assert got == expected, f"uo_out={got:#04x}, expected {expected:#04x}"


@cocotb.test()
async def test_project(dut):
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    dut.ena.value = 1
    dut.ui_in.value = 0          # NOP
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    await FallingEdge(dut.clk)   # start away from the clock edge

    await run(dut, 0xB5)         # LDI_A 5
    await run(dut, 0xC3)         # LDI_B 3
    await run(dut, 0x10)         # ADD     Z=8, CF=0
    await run(dut, 0xF0)         # OUT
    check(dut, 0x08)

    await run(dut, 0x30)         # SUB     Z=2, CF=0
    await run(dut, 0xF0)
    check(dut, 0x02)

    await run(dut, 0xB3)         # LDI_A 3
    await run(dut, 0xC5)         # LDI_B 5
    await run(dut, 0x30)         # SUB     Z=14, CF=1 (borrow)
    await run(dut, 0xF0)
    check(dut, 0x1E)

    await run(dut, 0x20)         # ADDC    Z=9, CF=0
    await run(dut, 0xF0)
    check(dut, 0x09)