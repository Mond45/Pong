// `timescale 1ns / 1ps
// //////////////////////////////////////////////////////////////////////////////////
// // Company: 
// // Engineer: 
// // 
// // Create Date: 12/10/2023 02:42:02 PM
// // Design Name: 
// // Module Name: Pong
// // Project Name: 
// // Target Devices: 
// // Tool Versions: 
// // Description: 
// // 
// // Dependencies: 
// // 
// // Revision:
// // Revision 0.01 - File Created
// // Additional Comments:
// // 
// //////////////////////////////////////////////////////////////////////////////////

// module simple_score #(
//     parameter CORDW = 10,  // coordinate width
//     parameter H_RES = 640  // horizontal screen resolution
// ) (
//     input                  clk_pix,  // pixel clock
//     input      [CORDW-1:0] sx,       // horizontal screen position
//     input      [CORDW-1:0] sy,       // vertical screen position
//     input      [      3:0] score_l,  // score for left-side player (0-9)
//     input      [      3:0] score_r,  // score for right-side player (0-9)
//     output reg             pix       // draw pixel at this position?
// );

//   // number characters: MSB first, so we can write pixels left to right
//   /* verilator lint_off LITENDIAN */
//   reg [0:14] chars[10];  // ten characters of 15 pixels each
//   /* verilator lint_on LITENDIAN */
//   initial begin
//     chars[0] = 15'b111_101_101_101_111;
//     chars[1] = 15'b110_010_010_010_111;
//     chars[2] = 15'b111_001_111_100_111;
//     chars[3] = 15'b111_001_011_001_111;
//     chars[4] = 15'b101_101_111_001_001;
//     chars[5] = 15'b111_100_111_001_111;
//     chars[6] = 15'b100_100_111_101_111;
//     chars[7] = 15'b111_001_001_001_001;
//     chars[8] = 15'b111_101_111_101_111;
//     chars[9] = 15'b111_101_111_001_001;
//   end

//   // ensure score in range of characters (0-9)
//   wire [3:0] char_l, char_r;
//   assign char_l = (score_l < 10) ? score_l : 0;
//   assign char_r = (score_r < 10) ? score_r : 0;

//   // set screen region for each score: 12x20 pixels (8,8) from corner
//   // subtract one from 'sx' to account for latency for registering 'pix'
//   wire score_l_region, score_r_region;
//   assign score_l_region = (sx >= 7 && sx < 19 && sy >= 8 && sy < 28);
//   assign score_r_region = (sx >= H_RES - 22 && sx < H_RES - 10 && sy >= 8 && sy < 28);

//   reg [3:0] pix_addr;
//   always @(*) begin
//     if (score_l_region) pix_addr = (sx - 7) / 4 + 3 * ((sy - 8) / 4);
//     else if (score_r_region) pix_addr = (sx - (H_RES - 22)) / 4 + 3 * ((sy - 8) / 4);
//     else pix_addr = 0;
//   end

//   // score pixel for current screen position
//   always @(posedge clk_pix) begin
//     if (score_l_region) pix <= chars[char_l][pix_addr];
//     else if (score_r_region) pix <= chars[char_r][pix_addr];
//     else pix <= 0;
//   end
// endmodule

module Pong (
    input              clk_100m,
    input              reset,
    input              btn_fire,
    input              btn_1up,
    input              btn_1dn,
    input              btn_2up,
    input              btn_2dn,
    output logic       vga_hsync,
    output logic       vga_vsync,
    output logic [3:0] vga_r,
    output logic [3:0] vga_g,
    output logic [3:0] vga_b,
    output logic coll_l,
    output logic coll_r
);

  wire de, clk_pix, hsync, vsync;
  wire [9:0] x, y;
  vga_sync vga (
      .clk(clk_100m),
      .reset(reset),
      .hsync(hsync),
      .vsync(vsync),
      .video_on(de),
      .p_tick(clk_pix),
      .x(x),
      .y(y)
  );
  localparam BALL_SIZE = 8;  // ball size in pixels
  localparam BALL_ISPX = 2;  // initial horizontal ball speed
  localparam BALL_ISPY = 1;  // initial vertical ball speed
  localparam PAD_HEIGHT = 72;  // paddle height in pixels
  localparam PAD_WIDTH = 10;  // paddle width in pixels
  localparam PAD_OFFS = 32;  // paddle distance from edge of screen in pixels
  localparam PAD_SPY = 3;  // vertical paddle speed

  localparam H_RES = 640;  // horizontal screen resolution
  localparam V_RES = 480;

  logic frame;
  always_comb frame = (y == 480 && x == 0);
  logic sig_fire, sig_1up, sig_1dn, sig_2up, sig_2dn;

  debounce deb_fire (
      .clk (clk_pix),
      .in  (btn_fire),
      .out (),
      .ondn(),
      .onup(sig_fire)
  );

  debounce deb_1up (
      .clk (clk_pix),
      .in  (btn_1up),
      .out (sig_1up),
      .ondn(),
      .onup()
  );
  debounce deb_1dn (
      .clk (clk_pix),
      .in  (btn_1dn),
      .out (sig_1dn),
      .ondn(),
      .onup()
  );
  debounce deb_2up (
      .clk (clk_pix),
      .in  (btn_2up),
      .out (sig_2up),
      .ondn(),
      .onup()
  );
  debounce deb_2dn (
      .clk (clk_pix),
      .in  (btn_2dn),
      .out (sig_2dn),
      .ondn(),
      .onup()
  );

  logic [9:0] ball_x, ball_y;
  logic [9:0] ball_spx;
  logic [9:0] ball_spy;
  logic ball_dx, ball_dy;
  
  logic [9:0] padl_y, padr_y;  // vertical position of left and right paddles

  logic ball, padl, padr;

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

  // Player paddle control
  always_ff @(posedge clk_pix) begin
    if (state == POSITION) padl_y <= (V_RES - PAD_HEIGHT) / 2;
    else if (frame && state == PLAY) begin
      if (sig_1dn) begin
        if (padl_y + PAD_HEIGHT + PAD_SPY >= V_RES - 1) begin  // bottom of screen?
          padl_y <= V_RES - PAD_HEIGHT - 1;  // move down as far as we can
        end else padl_y <= padl_y + PAD_SPY;  // move down
      end else if (sig_1up) begin
        if (padl_y < PAD_SPY) begin  // top of screen
          padl_y <= 0;  // move up as far as we can
        end else padl_y <= padl_y - PAD_SPY;  // move up
      end
    end
  end
  always_ff @(posedge clk_pix) begin
    if (state == POSITION) padr_y <= (V_RES - PAD_HEIGHT) / 2;
    else if (frame && state == PLAY) begin
      if (sig_2dn) begin
        if (padr_y + PAD_HEIGHT + PAD_SPY >= V_RES - 1) begin  // bottom of screen?
          padr_y <= V_RES - PAD_HEIGHT - 1;  // move down as far as we can
        end else padr_y <= padr_y + PAD_SPY;  // move down
      end else if (sig_2up) begin
        if (padr_y < PAD_SPY) begin  // top of screen
          padr_y <= 0;  // move up as far as we can
        end else padr_y <= padr_y - PAD_SPY;  // move up
      end
    end
  end

  always_ff @(posedge clk_pix) begin
    case (state)

      POSITION: begin
        coll_l   <= 0;  // reset screen collision flags
        coll_r   <= 0;
        ball_spx <= BALL_ISPX;  // reset speed
        ball_spy <= BALL_ISPY;

        // centre ball vertically and position on paddle (right or left)
        ball_y   <= (V_RES - BALL_SIZE) / 2;
        if (coll_r) begin
          ball_x  <= H_RES - (PAD_OFFS + PAD_WIDTH + BALL_SIZE);
          ball_dx <= 1;  // move left
        end else begin
          ball_x  <= PAD_OFFS + PAD_WIDTH;
          ball_dx <= 0;  // move right
        end
      end

      PLAY: begin
        if (frame) begin
          // horizontal ball position
          if (ball_dx == 0) begin  // moving right
            if (ball_x + BALL_SIZE + ball_spx > H_RES - 1) begin
              ball_x  <= H_RES - BALL_SIZE;  // move to edge of screen
              coll_r  <= 1;
            end else ball_x <= ball_x + ball_spx;
          end else begin  // moving left
            if (ball_x < ball_spx) begin
              ball_x  <= 0;  // move to edge of screen
              coll_l  <= 1;
            end else ball_x <= ball_x - ball_spx;
          end

          // vertical ball position
          if (ball_dy == 0) begin  // moving down
            if (ball_y + BALL_SIZE + ball_spy >= V_RES - 1) ball_dy <= 1;  // move up next frame
            else ball_y <= ball_y + ball_spy;
          end else begin  // moving up
            if (ball_y < ball_spy) ball_dy <= 0;  // move down next frame
            else ball_y <= ball_y - ball_spy;
          end
        end
      end
    endcase

    // change direction if ball collides with paddle
    if (ball && padl && ball_dx == 1) ball_dx <= 0;  // left paddle
    if (ball && padr && ball_dx == 0) ball_dx <= 1;  // right paddle
  end

  always_comb begin
    ball = (x >= ball_x) && (x < ball_x + BALL_SIZE) && (y >= ball_y) && (y < ball_y + BALL_SIZE);
    padl = (x >= PAD_OFFS) && (x < PAD_OFFS + PAD_WIDTH)
               && (y >= padl_y) && (y < padl_y + PAD_HEIGHT);
    padr = (x >= H_RES - PAD_OFFS - PAD_WIDTH - 1) && (x < H_RES - PAD_OFFS - 1)
               && (y >= padr_y) && (y < padr_y + PAD_HEIGHT);
  end

  logic [3:0] red, green, blue;
  always_comb begin
    if (ball) {red, green, blue} = 12'hFFF;
    else if (padl) {red, green, blue} = 12'hF00;
    else if (padr) {red, green, blue} = 12'h00F;
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
