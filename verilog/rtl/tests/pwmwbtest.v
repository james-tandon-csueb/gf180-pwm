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

module pwmwbtest;
`ifdef USE_POWER_PINS
    reg vdd;	// User area 1 1.8V supply
    reg vss;	// User area 1 digital ground
`endif

    // Wishbone Slave ports (WB MI A)
    reg wb_clk_i;
    reg wb_rst_i;
    reg wbs_stb_i;
    reg wbs_cyc_i;
    reg wbs_we_i;
    reg [3:0] wbs_sel_i;
    reg [31:0] wbs_dat_i;
    reg [31:0] wbs_adr_i;
    wire wbs_ack_o;
    wire [31:0] wbs_dat_o;

    // Logic Analyzer Signals
    reg  [63:0] la_data_in;
    wire [63:0] la_data_out;
    reg  [63:0] la_oenb;

    // IOs
    reg  [`MPRJ_IO_PADS-1:0] io_in;
    wire [`MPRJ_IO_PADS-1:0] io_out;
    wire [`MPRJ_IO_PADS-1:0] io_oeb;

    // IRQ
    wire [2:0] irq;

  pwm_wb pwmwb0(
`ifdef USE_POWER_PINS
    vdd,	// User area 1 1.8V supply
    vss,	// User area 1 digital ground
`endif

    // Wishbone Slave ports (WB MI A)
    wb_clk_i,
    wb_rst_i,
    wbs_stb_i,
    wbs_cyc_i,
    wbs_we_i,
    wbs_sel_i,
    wbs_dat_i,
    wbs_adr_i,
    wbs_ack_o,
    wbs_dat_o,

    // Logic Analyzer Signals
    la_data_in,
    la_data_out,
    la_oenb,

    // IOs
    io_in,
    io_out,
    io_oeb,

    // IRQ
    irq
  );

  always #5 wb_clk_i = ~wb_clk_i;

  integer i;

  initial begin
    $dumpfile("pwmwbtest.vcd");
    $dumpvars;
//reset system
    la_oenb = 64'hc000_0000_0000_0000;
    io_in = 128'b0;
    wb_rst_i = 1'b1;
    wb_clk_i = 1'b1;
    wbs_stb_i = 1'b0;
    wbs_cyc_i = 1'b0;
    wbs_we_i = 1'b0;
    wbs_adr_i = 32'b0;
    wbs_dat_i = 32'b0;
    wbs_sel_i = 4'b1111;
    la_data_in = 64'b0;
    io_in = 0;
    #10
    wb_rst_i = 1'b0;
    #10
// main test here
    // assign clock divider shifts 2^n s.t. n=1
    for (i=0; i < 8; i = i+1) begin
      wbs_adr_i = 32'hFEED_0000 | (8+i);
      $display("Assigning address %b", wbs_adr_i);
      wbs_dat_i = 8'b10;
      wbs_we_i = 1'b1;
      wbs_cyc_i = 1'b1;
      wbs_stb_i = 1'b1;
      #10 ;
      if (~wbs_ack_o) $display("Error, wbs_ack_o error: expected 1 at time=%d addr=%x, data=%x",$time,wbs_adr_i,
        wbs_dat_i);
      #10 ;
      wbs_adr_i = 32'b0;
      wbs_dat_i = 8'b0;
      wbs_we_i = 1'b0;
      wbs_cyc_i = 1'b0;
      wbs_stb_i = 1'b0;
      #10 ;
    end
    $display("Shift values:");
    for (i=0; i < 8; i=i+1) begin
      $display("pwmShift[%d]=%d",i,pwmwb0.pwm0.pwmShift[i]);
    end
    // assign thresholds
    for (i=0; i < 8; i = i+1) begin
      wbs_adr_i = 32'hFEED_0000 | i;
      $display("Assigning address %b", wbs_adr_i);
      wbs_dat_i = 8'b1 << i;
      wbs_we_i = 1'b1;
      wbs_cyc_i = 1'b1;
      wbs_stb_i = 1'b1;
      #10 ;
      if (~wbs_ack_o) $display("Error, wbs_ack_o error: expected 1 at time=%d addr=%x, data=%x",$time,wbs_adr_i,
        wbs_dat_i);
      #10 ;
      wbs_adr_i = 32'b0;
      wbs_dat_i = 8'b0;
      wbs_we_i = 1'b0;
      wbs_cyc_i = 1'b0;
      wbs_stb_i = 1'b0;
      #10 ;
    end
    $display("threshold values:");
    for (i=0; i < 8; i=i+1) begin
      $display("pwmThresh[%d]=%d",i,pwmwb0.pwm0.pwmThresh[i]);
    end
    for (i=0; i < 2048; i=i+1) begin
      $display("i=%d pwmOut=%b",i,io_out);
      #10 ;
    end
// end main test
    $finish;
  end

endmodule

