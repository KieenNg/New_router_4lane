`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/02/2025 09:37:56 AM
// Design Name: 
// Module Name: new_router_top
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


module new_router_top(
  input clk,
  input rst_n,
  input [9:0]router_dst_addr,
  input [9:0]router_scr_addr,
  input router_start_req,
  output router_done,
  output [63:0]s_axis_tdata,
  input s_axis_tready,
  output s_axis_tvalid
);
system_wrapper system_wrapper_i(
    .clk(clk),
    .rst_n(rst_n),
    .router_done(router_done),
    .router_dst_addr(router_dst_addr),
    .router_scr_addr(router_scr_addr),
    .router_start_req(router_start_req),
    .s_axis_tdata(s_axis_tdata),
    .s_axis_tready(s_axis_tready),
    .s_axis_tvalid(s_axis_tvalid)
);
//    parameter CLK_PERIOD = 10;
//    initial begin
//        clk = 1;
//        forever #(CLK_PERIOD/2) clk = ~clk;
//    end
//    initial begin
//        rst_n = 1;
        
//    end
endmodule
