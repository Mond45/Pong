`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/10/2023 02:42:02 PM
// Design Name: 
// Module Name: Pong
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

module Pong (
    input              clk_100m,
    input              reset,
    input              btn_fire,
    input              sig_1up,
    input              sig_1dn,
    input              sig_2up,
    input              sig_2dn,
    output logic       vga_hsync,
    output logic       vga_vsync,
    output logic [3:0] vga_r,
    output logic [3:0] vga_g,
    output logic [3:0] vga_b,
    output logic [7:0] score_l,
    output logic [7:0] score_r
);

  wire de, clk_pix, hsync, vsync;
  wire [9:0] x, y;
  vga_sync vga (
      .clk(clk_100m),
      .reset(0),
      .hsync(hsync),
      .vsync(vsync),
      .video_on(de),
      .p_tick(clk_pix),
      .x(x),
      .y(y)
  );
  localparam BALL_SIZE = 8;
  localparam BALL_ISPX = 3;
  localparam BALL_ISPY = 3;
  localparam PAD_HEIGHT = 70;
  localparam PAD_WIDTH = 10;
  localparam PAD_OFFS = 32;
  localparam PAD_SPY = 3;

  localparam H_RES = 640;
  localparam V_RES = 480;

  logic frame;
  always_comb frame = (y == 480 && x == 0);

  logic sig_fire;
  debounce deb_fire (
      .clk (clk_pix),
      .in  (btn_fire),
      .out (),
      .ondn(),
      .onup(sig_fire)
  );

  logic [9:0] ball_x, ball_y;
  logic [9:0] ball_spx;
  logic [9:0] ball_spy;
  logic ball_dx, ball_dy;

  logic [9:0] padl_y, padr_y;

  logic ball, padl, padr;

  logic coll_l, coll_r, o_coll_l, o_coll_r;

  oneShot oneShotCollL (
      .clk(clk_pix),
      .in (coll_l),
      .out(o_coll_l)
  );

  oneShot oneShotCollR (
      .clk(clk_pix),
      .in (coll_r),
      .out(o_coll_r)
  );

  ScoreCounter scoreCounterL (
      .clk(clk_pix),
      .reset(reset),
      .enable(o_coll_r),
      .count(score_l)
  );

  ScoreCounter scoreCounterR (
      .clk(clk_pix),
      .reset(reset),
      .enable(o_coll_l),
      .count(score_r)
  );

  enum {
    NEW_GAME,
    POSITION,
    READY,
    POINT,
    PLAY
  } state;
  always_ff @(posedge clk_pix) begin
    case (state)
      NEW_GAME: state <= POSITION;
      POSITION: state <= READY;
      READY: state <= (sig_fire) ? PLAY : READY;
      POINT: state <= POSITION;
      PLAY: begin
        if (coll_l || coll_r) begin
          state <= POINT;
        end else state <= PLAY;
      end
      default: state <= NEW_GAME;
    endcase
    if (reset) state <= NEW_GAME;
  end

  always_ff @(posedge clk_pix) begin
    if (state == POSITION) padl_y <= (V_RES - PAD_HEIGHT) / 2;
    else if (frame && state == PLAY) begin
      if (sig_1dn) begin
        if (padl_y + PAD_HEIGHT + PAD_SPY >= V_RES - 1) begin
          padl_y <= V_RES - PAD_HEIGHT - 1;
        end else padl_y <= padl_y + PAD_SPY;
      end else if (sig_1up) begin
        if (padl_y < PAD_SPY) begin
          padl_y <= 0;
        end else padl_y <= padl_y - PAD_SPY;
      end
    end
  end

  always_ff @(posedge clk_pix) begin
    if (state == POSITION) padr_y <= (V_RES - PAD_HEIGHT) / 2;
    else if (frame && state == PLAY) begin
      if (sig_2dn) begin
        if (padr_y + PAD_HEIGHT + PAD_SPY >= V_RES - 1) begin
          padr_y <= V_RES - PAD_HEIGHT - 1;
        end else padr_y <= padr_y + PAD_SPY;
      end else if (sig_2up) begin
        if (padr_y < PAD_SPY) begin
          padr_y <= 0;
        end else padr_y <= padr_y - PAD_SPY;
      end
    end
  end

  always_ff @(posedge clk_pix) begin
    case (state)
      POSITION: begin
        coll_l   <= 0;
        coll_r   <= 0;
        ball_spx <= BALL_ISPX;
        ball_spy <= BALL_ISPY;

        ball_y   <= (V_RES - BALL_SIZE) / 2;
        ball_x   <= (H_RES - BALL_SIZE) / 2;
        if (coll_r) begin
          ball_dx <= 1;
        end else begin
          ball_dx <= 0;
        end
      end

      PLAY: begin
        if (frame) begin
          if (ball_dx == 0) begin
            if (ball_x + BALL_SIZE + ball_spx > H_RES - 1) begin
              ball_x <= H_RES - BALL_SIZE;
              coll_r <= 1;
            end else ball_x <= ball_x + ball_spx;
          end else begin
            if (ball_x < ball_spx) begin
              ball_x <= 0;
              coll_l <= 1;
            end else ball_x <= ball_x - ball_spx;
          end

          if (ball_dy == 0) begin
            if (ball_y + BALL_SIZE + ball_spy >= V_RES - 1) ball_dy <= 1;
            else ball_y <= ball_y + ball_spy;
          end else begin
            if (ball_y < ball_spy) ball_dy <= 0;
            else ball_y <= ball_y - ball_spy;
          end
        end
      end
    endcase

    if (ball && padl && ball_dx == 1) ball_dx <= 0;
    if (ball && padr && ball_dx == 0) ball_dx <= 1;
  end

  always_comb begin
    ball = (x >= ball_x) && (x < ball_x + BALL_SIZE) && (y >= ball_y) && (y < ball_y + BALL_SIZE);
    padl = (x >= PAD_OFFS) && (x < PAD_OFFS + PAD_WIDTH)
               && (y >= padl_y) && (y < padl_y + PAD_HEIGHT);
    padr = (x >= H_RES - PAD_OFFS - PAD_WIDTH - 1) && (x < H_RES - PAD_OFFS - 1)
               && (y >= padr_y) && (y < padr_y + PAD_HEIGHT);
  end

  logic score_pix;
  ScoreDisplay scoreDisplay (
      .x(x),
      .y(y),
      .score_l(score_l),
      .score_r(score_r),
      .pix(score_pix)
  );

  logic [3:0] red, green, blue;
  always_comb begin
    if (score_pix) {red, green, blue} = 12'hDDD;
    else if (ball) {red, green, blue} = 12'hFFF;
    else if (padl) {red, green, blue} = 12'hFFF;
    else if (padr) {red, green, blue} = 12'hFFF;
    else {red, green, blue} = 12'h111;

    if (!de) {red, green, blue} = 12'h0;
  end

  always_ff @(posedge clk_pix) begin
    vga_hsync <= hsync;
    vga_vsync <= vsync;
    vga_r <= red;
    vga_g <= green;
    vga_b <= blue;
  end
endmodule
