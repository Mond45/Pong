`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/11/2023 01:33:57 AM
// Design Name: 
// Module Name: sevenSegment
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

module mux4 (
    input [1:0] sel,
    input [3:0] d1,
    input [3:0] d2,
    input [3:0] d3,
    input [3:0] d4,
    output reg [3:0] out
);

  always @(*) begin
    case (sel)
      2'b00: out = d1;
      2'b01: out = d2;
      2'b10: out = d3;
      2'b11: out = d4;
    endcase
  end

endmodule

module decoder4 (
    input [1:0] in,
    output reg [3:0] out
);

  always @(in) begin
    case (in)
      2'b00: out = 4'b0001;
      2'b01: out = 4'b0010;
      2'b10: out = 4'b0100;
      2'b11: out = 4'b1000;
    endcase
  end

endmodule

module sevenSegDecoder (
    input [3:0] in,
    output reg [6:0] out
);
  always @(in)
    case (in)
      4'b0001: out = 7'b1111001;  // 1
      4'b0010: out = 7'b0100100;  // 2
      4'b0011: out = 7'b0110000;  // 3
      4'b0100: out = 7'b0011001;  // 4
      4'b0101: out = 7'b0010010;  // 5
      4'b0110: out = 7'b0000010;  // 6
      4'b0111: out = 7'b1111000;  // 7
      4'b1000: out = 7'b0000000;  // 8
      4'b1001: out = 7'b0010000;  // 9
      4'b1010: out = 7'b0001000;  // A
      4'b1011: out = 7'b0000011;  // b
      4'b1100: out = 7'b1000110;  // C
      4'b1101: out = 7'b0100001;  // d
      4'b1110: out = 7'b0000110;  // E
      4'b1111: out = 7'b0001110;  // F
      default: out = 7'b1000000;  // 0
    endcase

endmodule

module counter #(
    parameter N = 4
) (
    input clk,
    output reg [N-1:0] val
);

  always @(posedge clk) begin
    val <= val + 1;
  end

endmodule

module sevenSegment (
    input clk,
    input [3:0] d0,
    input [3:0] d1,
    input [3:0] d2,
    input [3:0] d3,
    output [6:0] seg,
    output [3:0] an
);

  localparam cnt_bits = 19;

  wire [cnt_bits-1:0] cnt;
  wire [1:0] active;
  wire [3:0] enb;
  wire [3:0] activeDigit;

  counter #(cnt_bits) c (
      clk,
      cnt
  );
  decoder4 dec (
      active,
      enb
  );
  mux4 mx (
      active,
      d3,
      d2,
      d1,
      d0,
      activeDigit
  );
  sevenSegDecoder sseg (
      activeDigit,
      seg
  );

  assign active = cnt[cnt_bits-1:cnt_bits-2];
  assign an = ~enb;
endmodule
