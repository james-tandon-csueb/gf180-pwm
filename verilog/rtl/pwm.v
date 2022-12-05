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
 * pwm
 *
 * Core pulse width modulation functionality.
 */
module pwm(
  input clk,
  input rst,
  output [7:0] pwmOut, // output pin of pwm
  input [3:0] addr, // address of pwm register
  input [7:0] data, // data to write to pwm register
  input we);

  reg [7:0] pwmThresh[0:7]; // sets threshold for high/low transition
  reg [4:0] pwmShift[0:7]; // sets the clock division rate
  reg [31:0] pwmCtr; // sets threshold for high/low transition

  reg [7:0] pwmOut;

  always @(posedge clk) begin
    if (rst) begin
      pwmCtr <= 8'b0;
      pwmThresh[0] <= 8'b0;
      pwmThresh[1] <= 8'b0;
      pwmThresh[2] <= 8'b0;
      pwmThresh[3] <= 8'b0;
      pwmThresh[4] <= 8'b0;
      pwmThresh[5] <= 8'b0;
      pwmThresh[6] <= 8'b0;
      pwmThresh[7] <= 8'b0;
      pwmShift[0] <= 5'b0;
      pwmShift[1] <= 5'b0;
      pwmShift[2] <= 5'b0;
      pwmShift[3] <= 5'b0;
      pwmShift[4] <= 5'b0;
      pwmShift[5] <= 5'b0;
      pwmShift[6] <= 5'b0;
      pwmShift[7] <= 5'b0;
    end else begin
      pwmCtr <= pwmCtr + 8'b1;
      if (we) begin
        if (addr[3]) pwmShift[addr[2:0]] <= data[4:0];
        else pwmThresh[addr[2:0]] <= data[7:0];
      end
      pwmOut[0] <= (((pwmCtr >> pwmShift[0])& 8'hff) < pwmThresh[0]) ? 1'b1 : 1'b0;
      pwmOut[1] <= (((pwmCtr >> pwmShift[1])& 8'hff) < pwmThresh[1]) ? 1'b1 : 1'b0;
      pwmOut[2] <= (((pwmCtr >> pwmShift[2])& 8'hff) < pwmThresh[2]) ? 1'b1 : 1'b0;
      pwmOut[3] <= (((pwmCtr >> pwmShift[3])& 8'hff) < pwmThresh[3]) ? 1'b1 : 1'b0;
      pwmOut[4] <= (((pwmCtr >> pwmShift[4])& 8'hff) < pwmThresh[4]) ? 1'b1 : 1'b0;
      pwmOut[5] <= (((pwmCtr >> pwmShift[5])& 8'hff) < pwmThresh[5]) ? 1'b1 : 1'b0;
      pwmOut[6] <= (((pwmCtr >> pwmShift[6])& 8'hff) < pwmThresh[6]) ? 1'b1 : 1'b0;
      pwmOut[7] <= (((pwmCtr >> pwmShift[7])& 8'hff) < pwmThresh[7]) ? 1'b1 : 1'b0;
    end
  end

endmodule

`default_nettype wire

