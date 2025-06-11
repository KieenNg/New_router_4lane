`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/02/2025 09:37:13 AM
// Design Name: 
// Module Name: tb_new_router
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


module tb_router_4lane();
    reg clk;
    wire router_done;
    reg [9:0] router_dst_addr;
    reg [9:0] router_scr_addr;
    reg router_start_req;
    reg rst_n;

    router_4lane_wrapper router_4lane_wrapper_i (
        .clk(clk),
        .rst_n(rst_n),
        .router_start_req(router_start_req),
        .router_scr_addr(router_scr_addr),
        .router_dst_addr(router_dst_addr),
        .router_done(router_done)
    );

    parameter CLK_PERIOD = 10;
    initial begin
        clk = 1;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    initial begin
        rst_n = 0;
        #(CLK_PERIOD*4);
        rst_n = 1;
    end

//    integer num_transmissions = 0;
//    integer cycle_count_start;
//    integer cycle_count_end;

//    task drive_router (
//        input logic [9:0] src_addr,
//        input logic [9:0] dst_addr,
//        input integer is_last // Flag to indicate last transmission
//    );
//        if (num_transmissions == 0) begin
//            @(posedge clk);
//            cycle_count_start = $time; // Capture time at first router_start_req
//        end
//        router_start_req = 1;
//        router_scr_addr = src_addr;
//        router_dst_addr = dst_addr;
//        @(posedge clk);
//        router_start_req = 0;
//        router_scr_addr = 10'h0;
//        router_dst_addr = 10'h0;
//        @(posedge router_done);
//        if (is_last) begin
//            cycle_count_end = $time; // Capture time at last router_done
//        end
//        @(posedge clk); // Wait one cycle after router_done
//        num_transmissions = num_transmissions + 1;
//    endtask

//    initial begin
//        real total_data_bits;
//        real total_time_seconds, throughput, throughput_byte;

//        router_start_req = 0;
//        wait (router_done == 1);
//        repeat(10) @(posedge clk);

//        drive_router(10'h0, 10'h9, 0);
//        drive_router(10'h1, 10'h5, 0);
//        drive_router(10'h2, 10'hf, 0);
//        drive_router(10'h3, 10'h5, 0);
//        drive_router(10'h4, 10'h9, 0);
        
//        drive_router(10'h0, 10'h9, 0);
//        drive_router(10'h1, 10'h5, 0);
//        drive_router(10'h2, 10'hf, 0);
//        drive_router(10'h3, 10'h5, 0);
//        drive_router(10'h4, 10'h9, 0);
        
//        drive_router(10'h0, 10'h9, 0);
//        drive_router(10'h1, 10'h5, 0);
//        drive_router(10'h2, 10'hf, 0);
//        drive_router(10'h3, 10'h5, 0);
//        drive_router(10'h4, 10'h9, 0);
        
//        drive_router(10'h0, 10'h9, 0);
//        drive_router(10'h1, 10'h5, 0);
//        drive_router(10'h2, 10'hf, 0);
//        drive_router(10'h3, 10'h5, 0);
//        drive_router(10'h4, 10'h9, 0);
        
//        drive_router(10'h0, 10'h9, 0);
//        drive_router(10'h1, 10'h5, 0);
//        drive_router(10'h2, 10'hf, 0);
//        drive_router(10'h3, 10'h5, 0);
//        drive_router(10'h4, 10'h9, 0);
        
//        drive_router(10'h0, 10'h9, 0);
//        drive_router(10'h1, 10'h5, 0);
//        drive_router(10'h2, 10'hf, 0);
//        drive_router(10'h3, 10'h5, 0);
//        drive_router(10'h4, 10'h9, 0);
        
//        drive_router(10'h0, 10'h9, 0);
//        drive_router(10'h1, 10'h5, 0);
//        drive_router(10'h2, 10'hf, 0);
//        drive_router(10'h3, 10'h5, 0);
//        drive_router(10'h4, 10'h9, 0);
        
//        drive_router(10'h5, 10'hf, 1);

//        total_data_bits = 1024.0 * num_transmissions;
//        total_time_seconds = (cycle_count_end - cycle_count_start) * 1e-3; // Convert ps to seconds
//        throughput = total_data_bits / total_time_seconds;
//        throughput_byte = (total_data_bits / 8.0) / total_time_seconds;

//        $display("Number of Transmissions: %0d", num_transmissions);
//        $display("Total Data Transmitted: %0.0f bits", total_data_bits);
//        $display("Start Time: %0.5f ns", cycle_count_start * 1e-3); // Convert ps to ns
//        $display("End Time: %0.5f ns", cycle_count_end * 1e-3); // Convert ps to ns
//        $display("Total Time: %0.10f nano seconds", total_time_seconds);
//        $display("Throughput: %0.3e bits/second", throughput);
//        $display("Throughput_byte: %0.3e Byte/second", throughput_byte);

//        repeat(500) @(posedge clk);
//        $finish;
//    end
    initial begin 
         router_start_req = 0;
         wait (router_done == 1);
         repeat(10) @(posedge clk);
         router_start_req = 1;
         router_scr_addr = 10'h1;
         router_dst_addr = 10'h5;
         repeat(1) @(posedge clk);
         router_start_req = 0;
         router_scr_addr = 10'h0;
         router_dst_addr = 10'h0;
         repeat(1) @(posedge router_done);
//         repeat(1) @(posedge clk);
//         router_start_req = 1;
//         router_scr_addr = 10'h0;
//         router_dst_addr = 10'h9;
//         repeat(1) @(posedge clk);
//         router_start_req = 0;
//         router_scr_addr = 10'h0;
//         router_dst_addr = 10'h0;
//         repeat(1) @(posedge router_done);
//         repeat(1) @(posedge clk);
//         router_start_req = 1;
//         router_scr_addr = 10'h2;
//         router_dst_addr = 10'hf;
//         repeat(1) @(posedge clk);
//         router_start_req = 0;
//         router_scr_addr = 10'h0;
//         router_dst_addr = 10'h0;
         repeat(200) @(posedge clk);
         $finish;
     end
     initial begin
         $monitor("Time=%0t | dest_addr = 0x%h| data_arbiter_recv = 0x%h", 
             $time, router_4lane_wrapper_i.router_4lane_i.arbiter_bram_0.inst.dst_addr, router_4lane_wrapper_i.router_4lane_i.arbiter_bram_0.inst.data_arbiter_recv);
     end
endmodule
