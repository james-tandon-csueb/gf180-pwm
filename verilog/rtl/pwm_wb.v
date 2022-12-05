// SPDX-FileCopyrightText: 2022 James Tandon
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

`default_nettype none
/*
 *-------------------------------------------------------------
 *
 * pwm_wb
 *
 * A simple pulse width modulator connected to a wishbone
 * bus. Given an input clock signal, it is capable of dividing
 * the signal by 2^n where 0 <= n < 24. This allows a 100MHz core
 * fequency to be stepped down to just under 6 Hz if need be. The
 * frequency of each PWM is individually controlled by the
 * -Divider- registers which store the value n_i for PWM i. The
 *  -Threshold- register sets the duty cycle for each PWM such
 *  that its value v_i has duty cycle (256-v_i)/256 and valid
 *  v_i values are 0 < v_i <= 255. Note that v_i=0 turns off
 *  PWM i.
 *
 * Wishbone base address: 0xFEED0000
 * 
 * Registers:
 * 0000 Threshold 0
 * 0001 Threshold 1
 * 0002 Threshold 2
 * 0003 Threshold 3
 * 0004 Threshold 4
 * 0005 Threshold 5
 * 0006 Threshold 6
 * 0007 Threshold 7
 * 0008 Divider 0
 * 0009 Divider 1
 * 000a Divider 2
 * 000b Divider 3
 * 000c Divider 4
 * 000d Divider 5
 * 000e Divider 6
 * 000f Divider 7
 *
 * Reading these registers does nothing at this time (not too helpful;
 * probably should change).
 *
 *-------------------------------------------------------------
 */

module pwm_wb #(
    parameter BITS = 32
)(
`ifdef USE_POWER_PINS
    inout vdd,	// User area 1 1.8V supply
    inout vss,	// User area 1 digital ground
`endif

    // Wishbone Slave ports (WB MI A)
    input wb_clk_i,
    input wb_rst_i,
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    output wbs_ack_o,
    output [31:0] wbs_dat_o,

    // Logic Analyzer Signals
    input  [63:0] la_data_in,
    output [63:0] la_data_out,
    input  [63:0] la_oenb,

    // IOs
    input  [`MPRJ_IO_PADS-1:0] io_in,
    output [`MPRJ_IO_PADS-1:0] io_out,
    output [`MPRJ_IO_PADS-1:0] io_oeb,

    // IRQ
    output [2:0] irq
);
    wire clk;
    wire rst;

    wire [`MPRJ_IO_PADS-1:0] io_in;
    wire [`MPRJ_IO_PADS-1:0] io_out;
    wire [`MPRJ_IO_PADS-1:0] io_oeb;

    //wire [BITS-1:0] count;

    wire valid;
    wire [3:0] wstrb;
    wire [31:0] la_write;

    reg ack;
    always @(posedge clk) begin
      ack <= valid && pwmWe && ~ack;
    end

    // WB MI A
    assign valid = wbs_cyc_i && wbs_stb_i; 
    assign wstrb = wbs_sel_i & {4{wbs_we_i}};
    assign wbs_dat_o = 32'b0;
    assign wbs_ack_o = ack;

    // IO
    //assign io_out = count;
    assign io_oeb = {(`MPRJ_IO_PADS-1){rst}};

    // IRQ
    assign irq = 3'b000;	// Unused

    // LA
    assign la_data_out = {{(127-8){1'b0}}, pwmOut};
    // Assuming LA probes [63:62] are for controlling the count clk & reset  
    assign clk = (~la_oenb[62]) ? la_data_in[62]: wb_clk_i;
    assign rst = (~la_oenb[63]) ? la_data_in[63]: wb_rst_i;

    wire pwmWe;
    assign pwmWe = 16'hFEED == wbs_adr_i[31:16];

    wire [7:0] pwmOut;
    assign io_out = 128'b0 | (pwmOut << 8);

    pwm pwm0(
      .clk(clk),
      .rst(rst),
      .pwmOut(pwmOut),
      .addr(wbs_adr_i[3:0]),
      .data(wbs_dat_i[7:0]),
      .we(pwmWe)
    );

endmodule

`default_nettype wire
