`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/11/2023 05:31:00 PM
// Design Name: 
// Module Name: ScoreCounter
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

module ScoreCounter (
    input clk,
    input reset,
    input enable,
    output logic [7:0] count
);
  reg [7:0] cnt;
  always @(posedge clk) begin
    if (reset) cnt <= 0;
    else if (enable) cnt <= cnt + 1;
  end
  logic [3:0] l, r;
  always_comb begin
    l = cnt / 10;
    r = cnt % 10;
  end
  always_comb begin
    count = {l, r};
  end
endmodule
