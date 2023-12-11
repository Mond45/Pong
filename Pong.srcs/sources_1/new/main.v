`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/10/2023 02:20:31 PM
// Design Name: 
// Module Name: main
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


module main (
    input clk,
    input PS2Data,
    input PS2Clk,
    input btnC,
    output logic [3:0] vgaRed,
    output logic [3:0] vgaGreen,
    output logic [3:0] vgaBlue,
    output logic Hsync,
    output logic Vsync,
    output [6:0] seg,
    output [3:0] an
);

  logic wDown, sDown, upDown, downDown, spaceDown;

  InputHandler inputHandler (
      .clk(clk),
      .kclk(PS2Clk),
      .kdata(PS2Data),
      .wDown(wDown),
      .sDown(sDown),
      .upDown(upDown),
      .downDown(downDown),
      .spaceDown(spaceDown)
  );

  logic reset;
  debounce debounceC (
      .clk (clk),
      .in  (btnC),
      .out (reset),
      .ondn(),
      .onup()
  );

  logic coll_l, coll_r, collL, collR;

  Pong pong (
      .clk_100m(clk),
      .reset(reset),
      .btn_fire(spaceDown),
      .sig_1up(wDown),
      .sig_1dn(sDown),
      .sig_2up(upDown),
      .sig_2dn(downDown),
      .vga_hsync(Hsync),
      .vga_vsync(Vsync),
      .vga_r(vgaRed),
      .vga_g(vgaGreen),
      .vga_b(vgaBlue),
      .coll_l(coll_l),
      .coll_r(coll_r)
  );

  oneShot oneShotL (
      .clk(clk),
      .in (coll_l),
      .out(collL)
  );

  oneShot oneShotR (
      .clk(clk),
      .in (coll_r),
      .out(collR)
  );

  logic [7:0] scoreL, scoreR;
  logic [3:0] scoreL_0, scoreL_1, scoreR_0, scoreR_1;

  always @(posedge clk) begin
    if (reset) begin
      scoreL <= 0;
      scoreR <= 0;
    end else begin
      if (collL) scoreR <= scoreR + 1;
      if (collR) scoreL <= scoreL + 1;
    end
  end

  always_comb begin
    scoreL_0 = scoreL / 10;
    scoreL_1 = scoreL % 10;
    scoreR_0 = scoreR / 10;
    scoreR_1 = scoreR % 10;
  end

  sevenSegment sevenSeg (
      .clk(clk),
      .d0 (scoreL_0),
      .d1 (scoreL_1),
      .d2 (scoreR_0),
      .d3 (scoreR_1),
      .an (an),
      .seg(seg)
  );
endmodule
