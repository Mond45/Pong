`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/10/2023 10:16:54 PM
// Design Name: 
// Module Name: debounce
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module oneShot (
    input clk,
    input in,
    output reg out
);
  reg s;
  always @(posedge clk) begin
    if (s == 0 && !in) begin
      s   <= 0;
      out <= 0;
    end else if (s == 0 && in) begin
      s   <= 1;
      out <= 1;
    end else if (s == 1 && in) begin
      s   <= 1;
      out <= 0;
    end else if (s == 1 && !in) begin
      s   <= 0;
      out <= 0;
    end
  end
endmodule

module debounce (
    input clk,  // clock
    input in,  // signal input
    output reg out,  // signal output (debounced)
    output ondn,  // on down (one tick)
    output onup  // on up (one tick)
);

  // sync with clock and combat metastability
  reg sync_0, sync_1;
  always @(posedge clk) sync_0 <= in;
  always @(posedge clk) sync_1 <= sync_0;

  reg [17:0] cnt;  // 2^18 = 2.6 ms counter at 100 MHz
  wire idle, max;

  assign idle = (out == sync_1);
  assign max  = &cnt;
  assign ondn = ~idle & max & ~out;
  assign onup = ~idle & max & out;

  always @(posedge clk) begin
    if (idle) begin
      cnt <= 0;
    end else begin
      cnt <= cnt + 1;
      if (max) out <= ~out;
    end
  end
endmodule
