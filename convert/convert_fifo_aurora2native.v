module fifo_aurora2native
#(
    parameter DATA_WIDTH = 256
)(
    input wire clk,
    input wire rst_n,
    // Stream interface
    input m_axis_tvalid,
    input [DATA_WIDTH - 1:0] m_axis_tdata,
    // FIFO interface
    output reg wr_en,
    output reg [DATA_WIDTH - 1:0] data_in
);
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        wr_en <= 1'b0;
        data_in <= {DATA_WIDTH{1'b0}};
    end else begin
        wr_en <= m_axis_tvalid;
        data_in <= m_axis_tdata;
    end
end
endmodule