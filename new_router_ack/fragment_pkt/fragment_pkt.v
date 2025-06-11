module fragment_pkt
#(
    parameter DATA_WIDTH = 1024,
    parameter ADDR_WIDTH = 10,
    parameter DATA_DFX_WIDTH = DATA_WIDTH + ADDR_WIDTH,
    parameter ACK_WIDTH = 1,
    parameter SEQ_NUM_WIDTH = 1,
    parameter DFX_WIDTH = 2,
    parameter PKT_WIDTH = DATA_DFX_WIDTH + ACK_WIDTH + SEQ_NUM_WIDTH*2 + DFX_WIDTH*2,
    parameter AURORA_WIDTH = 256
)(
    input clk,
    input rst_n,
    /////////////encapsulate pkt interface/////////////////////
    input valid_pkt_send,
    input [PKT_WIDTH - 1:0] pkt_data,
    /////////////send controller interface/////////////////////
    input start_fragment_pkt,
    input [DFX_WIDTH - 1:0] pkt_src_dfx,
);
endmodule