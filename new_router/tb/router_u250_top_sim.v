`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/29/2025 10:39:43 AM
// Design Name: 
// Module Name: router_u250_top
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


module router_u250_top_sim(
  input [9:0]router_dst_addr,
  input [9:0]router_scr_addr,
  input router_start_req,
  output user_clk,
  output router_done,
  input CLK_IN_300M_clk_n,
  input CLK_IN_300M_clk_p,
  input GT_REFCLK_clk_n,
  input GT_REFCLK_clk_p,
  input [0:3]GT_SERIAL_RX_rxn,
  input [0:3]GT_SERIAL_RX_rxp,
  output [0:3]GT_SERIAL_TX_txn,
  output [0:3]GT_SERIAL_TX_txp
);
wire init_clk;
reg pma_init = 1'b1;
reg reset_pb = 1'b1;
router_4lane_wrapper router_4lane_wrapper_i(
    .router_done(router_done),
    .router_dst_addr(router_dst_addr),
    .router_scr_addr(router_scr_addr),
    .router_start_req(router_start_req),
    .user_clk(user_clk),
    .CLK_IN_300M_clk_n(CLK_IN_300M_clk_n),
    .CLK_IN_300M_clk_p(CLK_IN_300M_clk_p),
    .GT_REFCLK_clk_n(GT_REFCLK_clk_n),
    .GT_REFCLK_clk_p(GT_REFCLK_clk_p),
    .GT_SERIAL_RX_rxn(GT_SERIAL_RX_rxn),
    .GT_SERIAL_RX_rxp(GT_SERIAL_RX_rxp),
    .GT_SERIAL_TX_txn(GT_SERIAL_TX_txn),
    .GT_SERIAL_TX_txp(GT_SERIAL_TX_txp),
    .init_clk(init_clk),
    .pma_init(pma_init),
    .reset_pb(reset_pb)
);
/////////////////////////////
reg [63:0] clk_counter = 1'b0;
always @(posedge init_clk) begin
    clk_counter <= clk_counter + 1;
    if (clk_counter == 64'd2000000000) begin
      clk_counter <= 64'd500;
      end
end
////////////////////////////////
always @(posedge init_clk) begin
    if (clk_counter == 64'd150) begin
      pma_init <= 1'b0;
    end
    if (clk_counter == 64'd400) begin
      reset_pb <= 1'b0;
    end
end
endmodule
