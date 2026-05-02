# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Set the clock period to 0.5 s (2Hz)
    clock = Clock(dut.clk, 0.5, units="sec")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    dut._log.info("Test project behavior")




    # Input put a square wave signal with pulse duration of 2 clock cycles for a total of 26 cycles
    
    pattern = 0b1001

    for i in range(13):
        spike = 1 if (i % 2 == 0) else 0
        dut.ui_in.value = pattern | (spike << 4)
        await ClockCycles(dut.clk, 2)



    # wait one more cycle in case outputs update on the following edge
    await ClockCycles(dut.clk, 1)

    ui_val = int(dut.ui_in.value) & 0b00001111
    uo_raw = int(dut.uo_out.value)
    uo_pattern = (uo_raw & 0b00111100) >> 2
    actuator = (uo_raw & 0b00000010) >> 1
    uio_val = int(dut.uio_out.value) & 0b00001111

    dut._log.info(f"ui_in raw     = {int(dut.ui_in.value):08b}")
    dut._log.info(f"uio_out raw     = {int(dut.uio_out.value):08b}")
    dut._log.info(f"uo_out raw    = {uo_raw:08b}")
    dut._log.info(f"ui_in[3:0]    = {ui_val:04b} ({ui_val})")
    dut._log.info(f"uio_out[3:0]    = {uio_val:04b} ({uio_val})")
    dut._log.info(f"uo_out[5:2]   = {uo_pattern:04b} ({uo_pattern})")
    dut._log.info(f"actuator bit  = {actuator}")


    #check  input pattern matches real time spike pattern
    assert ( int(dut.ui_in.value) & 0b00001111) == ( (int(dut.uo_out.value) & 0b00111100) >> 2 )


    #check actuator has been activated
    assert ((int(dut.uo_out.value) & 0b00000010) >> 1) == 1

    # Keep testing the module by changing the input values, waiting for
    # one or more clock cycles, and asserting the expected output values.
