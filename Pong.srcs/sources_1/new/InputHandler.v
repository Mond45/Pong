`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/11/2023 01:56:01 PM
// Design Name: 
// Module Name: InputHandler
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


module InputHandler (
    input clk,
    input kclk,
    input kdata,
    output reg wDown,
    output reg sDown,
    output reg upDown,
    output reg downDown,
    output reg spaceDown
);
  reg CLK50MHZ = 0;
  always @(posedge (clk)) begin
    CLK50MHZ <= ~CLK50MHZ;
  end

  logic [15:0] keycode;
  logic oflag;
  PS2Receiver ps2Receiver (
      .clk(CLK50MHZ),
      .kclk(kclk),
      .kdata(kdata),
      .keycode(keycode),
      .oflag(oflag)
  );
  always @(posedge clk) begin
    if (oflag) begin
      if (keycode[7:0] == 8'h1D) wDown <= keycode[15:8] != 8'hF0;
      else if (keycode[7:0] == 8'h1B) sDown <= keycode[15:8] != 8'hF0;
      else if (keycode[7:0] == 8'h75) upDown <= keycode[15:8] != 8'hF0;
      else if (keycode[7:0] == 8'h72) downDown <= keycode[15:8] != 8'hF0;
      else if (keycode[7:0] == 8'h29) spaceDown <= keycode[15:8] != 8'hF0;
    end
  end
endmodule
