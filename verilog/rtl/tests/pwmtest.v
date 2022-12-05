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

module pwmtest;
  reg clk;
  reg rst;
  reg [3:0] addr;
  reg [7:0] data;
  reg we;

  wire [7:0] pwmOut;

  pwm pwm0(clk,rst,pwmOut,addr,data,we);

  always #5 clk = ~clk;

  integer i;

  initial begin
    clk = 1'b0;
    rst = 1'b1;
    #10
    rst = 1'b0;
    we=1'b0;
    #10
    // assign clock divider shifts 2^n s.t. n=1
    for (i=0; i < 8; i = i+1) begin
      addr = 8+i;
      $display("Assigning address %b", addr);
      data = 8'b10;
      we = 1'b1;
      #10 ;
    end
    $display("Shift values:");
    for (i=0; i < 8; i=i+1) begin
      $display("pwmShift[%d]=%d",i,pwm0.pwmShift[i]);
    end
    // assign thresholds
    for (i=0; i < 8; i = i+1) begin
      addr = i;
      data = 8'b1 << i;
      we = 1'b1;
      #10 ;
    end
    we = 1'b0;
    $display("threshold values:");
    for (i=0; i < 8; i=i+1) begin
      $display("pwmThresh[%d]=%d",i,pwm0.pwmThresh[i]);
    end
    for (i=0; i < 2048; i=i+1) begin
      $display("i=%d pwmOut=%b",i,pwmOut);
      #10 ;
    end
    $finish;
  end

endmodule

