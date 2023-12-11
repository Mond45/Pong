`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/11/2023 03:10:05 PM
// Design Name: 
// Module Name: ScoreDisplay
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
module digitPixel (
    input [3:0] digit,
    input [2:0] x,
    input [2:0] y,
    output logic pix
);
  logic [0:7] row_pix;
  always_comb begin
    case ({
      digit, y
    })
      7'b0000000: row_pix = 8'b00111100;
      7'b0000001: row_pix = 8'b01100110;
      7'b0000010: row_pix = 8'b01101110;
      7'b0000011: row_pix = 8'b01110110;
      7'b0000100: row_pix = 8'b01100110;
      7'b0000101: row_pix = 8'b01100110;
      7'b0000110: row_pix = 8'b00111100;
      7'b0000111: row_pix = 8'b00000000;

      7'b0001000: row_pix = 8'b00011000;
      7'b0001001: row_pix = 8'b00011000;
      7'b0001010: row_pix = 8'b00111000;
      7'b0001011: row_pix = 8'b00011000;
      7'b0001100: row_pix = 8'b00011000;
      7'b0001101: row_pix = 8'b00011000;
      7'b0001110: row_pix = 8'b01111110;
      7'b0001111: row_pix = 8'b00000000;

      7'b0010000: row_pix = 8'b00111100;
      7'b0010001: row_pix = 8'b01100110;
      7'b0010010: row_pix = 8'b00000110;
      7'b0010011: row_pix = 8'b00001100;
      7'b0010100: row_pix = 8'b00110000;
      7'b0010101: row_pix = 8'b01100000;
      7'b0010110: row_pix = 8'b01111110;
      7'b0010111: row_pix = 8'b00000000;

      7'b0011000: row_pix = 8'b00111100;
      7'b0011001: row_pix = 8'b01100110;
      7'b0011010: row_pix = 8'b00000110;
      7'b0011011: row_pix = 8'b00011100;
      7'b0011100: row_pix = 8'b00000110;
      7'b0011101: row_pix = 8'b01100110;
      7'b0011110: row_pix = 8'b00111100;
      7'b0011111: row_pix = 8'b00000000;

      7'b0100000: row_pix = 8'b00000110;
      7'b0100001: row_pix = 8'b00001110;
      7'b0100010: row_pix = 8'b00011110;
      7'b0100011: row_pix = 8'b01100110;
      7'b0100100: row_pix = 8'b01111111;
      7'b0100101: row_pix = 8'b00000110;
      7'b0100110: row_pix = 8'b00000110;
      7'b0100111: row_pix = 8'b00000000;

      7'b0101000: row_pix = 8'b01111110;
      7'b0101001: row_pix = 8'b01100000;
      7'b0101010: row_pix = 8'b01111100;
      7'b0101011: row_pix = 8'b00000110;
      7'b0101100: row_pix = 8'b00000110;
      7'b0101101: row_pix = 8'b01100110;
      7'b0101110: row_pix = 8'b00111100;
      7'b0101111: row_pix = 8'b00000000;

      7'b0110000: row_pix = 8'b00111100;
      7'b0110001: row_pix = 8'b01100110;
      7'b0110010: row_pix = 8'b01100000;
      7'b0110011: row_pix = 8'b01111100;
      7'b0110100: row_pix = 8'b01100110;
      7'b0110101: row_pix = 8'b01100110;
      7'b0110110: row_pix = 8'b00111100;
      7'b0110111: row_pix = 8'b00000000;

      7'b0111000: row_pix = 8'b01111110;
      7'b0111001: row_pix = 8'b01100110;
      7'b0111010: row_pix = 8'b00001100;
      7'b0111011: row_pix = 8'b00011000;
      7'b0111100: row_pix = 8'b00011000;
      7'b0111101: row_pix = 8'b00011000;
      7'b0111110: row_pix = 8'b00011000;
      7'b0111111: row_pix = 8'b00000000;

      7'b1000000: row_pix = 8'b00111100;
      7'b1000001: row_pix = 8'b01100110;
      7'b1000010: row_pix = 8'b01100110;
      7'b1000011: row_pix = 8'b00111100;
      7'b1000100: row_pix = 8'b01100110;
      7'b1000101: row_pix = 8'b01100110;
      7'b1000110: row_pix = 8'b00111100;
      7'b1000111: row_pix = 8'b00000000;

      7'b1001000: row_pix = 8'b00111100;
      7'b1001001: row_pix = 8'b01100110;
      7'b1001010: row_pix = 8'b01100110;
      7'b1001011: row_pix = 8'b00111110;
      7'b1001100: row_pix = 8'b00000110;
      7'b1001101: row_pix = 8'b01100110;
      7'b1001110: row_pix = 8'b00111100;
      7'b1001111: row_pix = 8'b00000000;
      default: row_pix = 8'b0;
    endcase
  end

  always_comb begin
    pix = row_pix[x];
  end
endmodule

module ScoreDisplay (
    input [9:0] x,
    input [9:0] y,
    input [7:0] score_l,
    input [7:0] score_r,
    output logic pix
);

  logic [3:0] l_digit_0, l_digit_1, r_digit_0, r_digit_1;

  always_comb begin
    l_digit_0 = score_l[7:4];
    l_digit_1 = score_l[3:0];
    r_digit_0 = score_r[7:4];
    r_digit_1 = score_r[3:0];
  end

  logic [3:0] digit;
  logic [2:0] dx, dy;
  logic in_area;

  always_comb begin
    in_area = 0;
    digit = 0;
    dx = 0;
    dy = 0;
    if (16 <= y && y < 24) begin
      dy = y - 16;
      if (200 <= x && x < 208) begin  //l digit 0 
        in_area = 1'b1;
        digit = l_digit_0;
        dx = x - 200;
      end else if (208 <= x && x < 216) begin  //l digit 1
        in_area = 1'b1;
        digit = l_digit_1;
        dx = x - 208;
      end else if (424 <= x && x < 432) begin  //r digit 0
        in_area = 1'b1;
        digit = r_digit_0;
        dx = x - 424;
      end else if (432 <= x && x < 440) begin  //r digit 1
        in_area = 1'b1;
        digit = r_digit_1;
        dx = x - 432;
      end
    end
  end

  logic dig_pix;

  digitPixel digitPixel (
      .digit(digit),
      .x(dx),
      .y(dy),
      .pix(dig_pix)
  );

  always_comb begin
    pix = in_area ? dig_pix : 0;
  end
endmodule
