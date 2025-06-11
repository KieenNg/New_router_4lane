`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/21/2025 10:16:22 PM
// Design Name: 
// Module Name: arbiter_bram
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


module arbiter_bram
#(
    parameter ADDR_WIDTH = 10,
    parameter DATA_WIDTH = 1024
) (
    input clk,
    input rst_n,
     // Router interface
    input [ADDR_WIDTH-1:0] src_addr,
    output  [DATA_WIDTH-1:0] data_arbiter_send,
    input read_req,
    output  read_gnt,
    
    input [ADDR_WIDTH-1:0] dst_addr,
    input [DATA_WIDTH-1:0] data_arbiter_recv,
    input write_req,
    output  write_gnt
);
//BRAM port A
    wire [ADDR_WIDTH-1:0] bram_a_addr_o;
    wire [DATA_WIDTH-1:0] bram_a_dout_i;
    wire [DATA_WIDTH-1:0] bram_a_din_o;
    wire bram_a_en_o;
    wire bram_a_we_o;

    //BRAM port B
    wire  [ADDR_WIDTH-1:0] bram_b_addr_o;
    wire [DATA_WIDTH-1:0] bram_b_dout_i;
    wire  [DATA_WIDTH-1:0] bram_b_din_o;
    wire  bram_b_en_o;
    wire  bram_b_we_o;
    arbiter_wrapper arbiter_wrapper_i(
        .clk(clk),
        .rst_n(rst_n),
        .src_addr(src_addr),
        .data_arbiter_send(data_arbiter_send),
        .read_req(read_req),
        .read_gnt(read_gnt),
        .dst_addr(dst_addr),
        .data_arbiter_recv(data_arbiter_recv),
        .write_req(write_req),
        .write_gnt(write_gnt),
        .bram_a_addr_o(bram_a_addr_o),
        .bram_a_dout_i(bram_a_dout_i),
        .bram_a_din_o(bram_a_din_o),
        .bram_a_en_o(bram_a_en_o),
        .bram_a_we_o(bram_a_we_o),
        .bram_b_addr_o(bram_b_addr_o),
        .bram_b_dout_i(bram_b_dout_i),
        .bram_b_din_o(bram_b_din_o),
        .bram_b_en_o(bram_b_en_o),
        .bram_b_we_o(bram_b_we_o)
    );
    blk_mem_gen_0 vector_reg_file (
  .clka(clk),    // input wire clka
  .ena(bram_a_en_o),      // input wire ena
  .wea(bram_a_we_o),      // input wire [0 : 0] wea
  .addra(bram_a_addr_o),  // input wire [9 : 0] addra
  .dina(bram_a_din_o),    // input wire [1023 : 0] dina
  .douta(bram_a_dout_i),  // output wire [1023 : 0] douta
  .clkb(clk),    // input wire clkb
  .enb(bram_b_en_o),      // input wire enb
  .web(bram_b_we_o),      // input wire [0 : 0] web
  .addrb(bram_b_addr_o),  // input wire [9 : 0] addrb
  .dinb(bram_b_din_o),    // input wire [1023 : 0] dinb
  .doutb(bram_b_dout_i)  // output wire [1023 : 0] doutb
);
endmodule
