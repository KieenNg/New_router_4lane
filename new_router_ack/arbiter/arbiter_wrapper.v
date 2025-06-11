`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/19/2025 10:58:11 AM
// Design Name: 
// Module Name: arbiter_wrapper
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


module arbiter_wrapper
#(
    parameter VRF_ADDR_WIDTH = 10,
    parameter VRF_DATA_WIDTH = 1024
) (
    input clk,
    input rst_n,
    //BRAM port A
    output [VRF_ADDR_WIDTH-1:0] bram_a_addr_o,
    input [VRF_DATA_WIDTH-1:0] bram_a_dout_i,
    output [VRF_DATA_WIDTH-1:0] bram_a_din_o,
    output bram_a_en_o,
    output bram_a_we_o,

    //BRAM port B
    output  [VRF_ADDR_WIDTH-1:0] bram_b_addr_o,
    input [VRF_DATA_WIDTH-1:0] bram_b_dout_i,
    output  [VRF_DATA_WIDTH-1:0] bram_b_din_o,
    output  bram_b_en_o,
    output  bram_b_we_o,
    
     // Router interface
    input [VRF_ADDR_WIDTH-1:0] src_addr,
    output  [VRF_DATA_WIDTH-1:0] data_arbiter_send,
    input read_req,
    output  read_gnt,
    
    input [VRF_ADDR_WIDTH-1:0] dst_addr,
    input [VRF_DATA_WIDTH-1:0] data_arbiter_recv,
    input write_req,
    output  write_gnt
    );
    arbiter arbiter_i(
        .clk(clk),
        .rst_n(rst_n),
        //BRAM port A
        .bram_a_addr_o(bram_a_addr_o),
        .bram_a_dout_i(bram_a_dout_i),
        .bram_a_din_o(bram_a_din_o),
        .bram_a_en_o(bram_a_en_o),
        .bram_a_we_o(bram_a_we_o),

        //BRAM port B
        .bram_b_addr_o(bram_b_addr_o),
        .bram_b_dout_i(bram_b_dout_i),
        .bram_b_din_o(bram_b_din_o),
        .bram_b_en_o(bram_b_en_o),
        .bram_b_we_o(bram_b_we_o),
        
        //Router interface
        .router_v_src_addr_i(src_addr),
        .router_v_src_data_o(data_arbiter_send),
        .router_read_req_i(read_req),
        .router_read_gnt_o(read_gnt),
        .router_v_res_addr_i(dst_addr),
        .router_v_res_data_i(data_arbiter_recv),
        .router_write_req_i(write_req),
        .router_write_gnt_o(write_gnt)
    );
    
endmodule
