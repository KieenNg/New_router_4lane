module fifo_dfx_data_recv_wrapper(
    input clk,             
    input rst_n,             
    input write_enable,     
    input read_enable,      
    input [1033:0] data_in, 
    output [1033:0] data_out,
    output empty 
);
fifo_dfx_data_recv fifo_dfx_data_recv_inst (
        .clk(clk),
        .rst_n(rst_n),
        .write_enable(write_enable),
        .read_enable(read_enable),
        .data_in(data_in),
        .data_out(data_out),
        .empty(empty)
);

endmodule