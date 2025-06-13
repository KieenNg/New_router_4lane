`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/13/2025 11:21:16 PM
// Design Name: 
// Module Name: tb_sim2router
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


module tb_sim4router(

    );
    reg clk;
    reg rst_n;
    
    reg router0_start_req;
    reg [9:0]router0_scr_addr;
    reg [9:0]router0_dst_addr;
    reg [1:0]router0_src_dfx;
    reg [1:0]router0_dst_dfx;
    wire valid_v_recv_0;
    wire [9:0]src_dfx_0;
    reg check_recv_done_0;
    wire router_send_done_0;
    
    reg router1_start_req;
    reg [9:0]router1_scr_addr;
    reg [9:0]router1_dst_addr;
    reg [1:0]router1_src_dfx;
    reg [1:0]router1_dst_dfx;
    wire valid_v_recv_1;
    wire [9:0]src_dfx_1;
    reg check_recv_done_1;
    wire router_send_done_1;
    
    
    reg router2_start_req;
    reg [9:0]router2_scr_addr;
    reg [9:0]router2_dst_addr;
    reg [1:0]router2_src_dfx;
    reg [1:0]router2_dst_dfx;
    wire valid_v_recv_2;
    wire [9:0]src_dfx_2;
    reg check_recv_done_2;
    wire router_send_done_2;
    
    
    reg router3_start_req;
    reg [9:0]router3_scr_addr;
    reg [9:0]router3_dst_addr;
    reg [1:0]router3_src_dfx;
    reg [1:0]router3_dst_dfx;
    wire valid_v_recv_3;
    wire [9:0]src_dfx_3;
    reg check_recv_done_3;
    wire router_send_done_3;
    
    sim2router_wrapper sim2router_wrapper_i(
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
         router1_start_req = 0;
         repeat(10) @(posedge clk);
         router1_start_req = 1;
         router1_scr_addr = 10'h1;
         router1_dst_addr = 10'h5;
         router1_src_dfx = 2'b01;
         router1_dst_dfx = 2'b10;
         repeat(2) @(posedge clk);
         router1_start_req = 0;
         
        repeat(1) @(posedge router_send_done_1);
        router1_start_req = 1;
         router1_scr_addr = 10'h2;
         router1_dst_addr = 10'h7;
         router1_src_dfx = 2'b01;
         router1_dst_dfx = 2'b00;
         repeat(2) @(posedge clk);
         router1_start_req = 0;
            
         repeat(1) @(posedge router_send_done_1);
         router1_start_req = 1;
         router1_scr_addr = 10'h3;
         router1_dst_addr = 10'h9;
         router1_src_dfx = 2'b01;
         router1_dst_dfx = 2'b11;
         repeat(2) @(posedge clk);
         router1_start_req = 0;
         repeat(500) @(posedge clk);
         $finish;
     end 
endmodule
