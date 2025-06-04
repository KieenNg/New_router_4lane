`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/30/2025 01:23:18 AM
// Design Name: 
// Module Name: tb_router_u250_top
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


module tb_router_u250_top();

    wire user_clk;
    reg CLK_IN_300M_clk_n;
    reg CLK_IN_300M_clk_p;
    
    reg GT_REFCLK_clk_n;
    reg GT_REFCLK_clk_p;
    //wire channel_up;
    wire [0:3] GT_SERIAL_RX_rxn;
    wire [0:3] GT_SERIAL_RX_rxp;
    wire [0:3] GT_SERIAL_TX_txn;
    wire [0:3] GT_SERIAL_TX_txp;
    
    reg [9:0] router_dst_addr;
    reg [9:0] router_scr_addr;
    reg router_start_req;
    //reg rst_n;
    wire router_done;
    router_u250_top_sim router_u250_top_sim_i(
        .CLK_IN_300M_clk_n(CLK_IN_300M_clk_n),
        .CLK_IN_300M_clk_p(CLK_IN_300M_clk_p),
        .user_clk(user_clk),
        .router_done(router_done),
        .GT_REFCLK_clk_n(GT_REFCLK_clk_n),
        .GT_REFCLK_clk_p(GT_REFCLK_clk_p),

        .GT_SERIAL_RX_rxn(GT_SERIAL_RX_rxn),
        .GT_SERIAL_RX_rxp(GT_SERIAL_RX_rxp),
        .GT_SERIAL_TX_txn(GT_SERIAL_TX_txn),
        .GT_SERIAL_TX_txp(GT_SERIAL_TX_txp),
        
        .router_dst_addr(router_dst_addr),
        .router_scr_addr(router_scr_addr),
        .router_start_req(router_start_req)
    );
    localparam CLOCK_PERIOD = 3.333;
    localparam GT_CLOCK = 6.4;
    assign GT_SERIAL_RX_rxn = GT_SERIAL_TX_txn;
    assign GT_SERIAL_RX_rxp = GT_SERIAL_TX_txp;
    
    initial begin
        CLK_IN_300M_clk_p = 0;
        CLK_IN_300M_clk_n = 1;
        forever #(CLOCK_PERIOD/2) begin
            CLK_IN_300M_clk_p = ~CLK_IN_300M_clk_p;
            CLK_IN_300M_clk_n = ~CLK_IN_300M_clk_n;
        end
    end
    
    initial begin 
        GT_REFCLK_clk_n = 0;
        GT_REFCLK_clk_p = 1;
    end
    always begin
       #(GT_CLOCK/2);
        GT_REFCLK_clk_n = ~GT_REFCLK_clk_n;
        GT_REFCLK_clk_p = ~GT_REFCLK_clk_p;
    end

    integer num_transmissions = 0;
    integer cycle_count_start;
    integer cycle_count_end;

    task drive_router (
        input logic [9:0] src_addr,
        input logic [9:0] dst_addr,
        input integer is_last // Flag to indicate last transmission
    );
        if (num_transmissions == 0) begin
            @(posedge user_clk);
            cycle_count_start = $time; // Capture time at first router_start_req
        end
        router_start_req = 1;
        router_scr_addr = src_addr;
        router_dst_addr = dst_addr;
        @(posedge user_clk);
        router_start_req = 0;
        router_scr_addr = 10'h0;
        router_dst_addr = 10'h0;
        @(posedge router_done);
        if (is_last) begin
            cycle_count_end = $time; // Capture time at last router_done
        end
        @(posedge user_clk); // Wait one cycle after router_done
        num_transmissions = num_transmissions + 1;
    endtask

    initial begin
        real total_data_bits;
        real total_time_seconds, throughput, throughput_byte;

        router_start_req = 0;
        wait (router_done == 1);
        repeat(10) @(posedge user_clk);

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
        
        
        //`include "instructions.vh"
        drive_router(10'h5, 10'hf, 1);

        total_data_bits = 1024.0 * num_transmissions;
        total_time_seconds = (cycle_count_end - cycle_count_start) * 1e-3; // Convert ps to seconds
        throughput = total_data_bits / total_time_seconds;
        throughput_byte = (total_data_bits / 8.0) / total_time_seconds;

        $display("Number of Transmissions: %0d", num_transmissions);
        $display("Total Data Transmitted: %0.0f bits", total_data_bits);
        $display("Start Time: %0.5f ns", cycle_count_start * 1e-3); // Convert ps to ns
        $display("End Time: %0.5f ns", cycle_count_end * 1e-3); // Convert ps to ns
        $display("Total Time: %0.10f nano seconds", total_time_seconds);
        $display("Throughput: %0.3e bits/second", throughput);
        $display("Throughput_byte: %0.3e Byte/second", throughput_byte);

        repeat(5000) @(posedge user_clk);
        $finish;
    end
     initial begin
         $monitor("Time=%0t | dest_addr = 0x%h| data_arbiter_recv = 0x%h", 
             $time, router_u250_top_sim_i.system_wrapper_i.system_i.arbiter_bram_0.dst_addr, router_u250_top_sim_i.system_wrapper_i.system_i.arbiter_bram_0.data_arbiter_recv);
     end
endmodule
