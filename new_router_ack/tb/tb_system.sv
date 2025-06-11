`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/11/2025 01:49:20 PM
// Design Name: 
// Module Name: tb_system
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


module tb_system();
  reg clk;
  reg [9:0]router_scr_addr;
  reg [9:0]router_dst_addr;
  reg [1:0]router_src_dfx;
  reg [1:0]router_dst_dfx;
  reg router_start_req;
  reg rst_n;
  
  system_wrapper system_wrapper_i(
    .*
  );
  localparam CLOCK_PERIOD = 10;
  initial begin
        clk = 0;
        forever #(CLOCK_PERIOD/2) begin
            clk = ~clk;
        end
  end
  initial begin 
    rst_n = 0;
    repeat(4) @(posedge clk);
    rst_n = 1;
  end  
  initial begin 
         router_start_req = 0;
         repeat(10) @(posedge clk);
         router_start_req = 1;
         router_scr_addr = 10'h1;
         router_dst_addr = 10'h5;
         router_src_dfx = 2'b01;
         router_dst_dfx = 2'b10;
//         repeat(2) @(posedge clk);
//         router_start_req = 0;
//         router_scr_addr = 10'h0;
//         router_dst_addr = 10'h0;
         repeat(50) @(posedge clk);
         $finish;
     end 
endmodule
