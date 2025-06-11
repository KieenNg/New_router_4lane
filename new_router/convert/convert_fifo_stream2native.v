module fifo_stream2native
#(
    parameter DATA_WIDTH = 256
)(
    input wire clk,
    input wire rst_n,
    // Stream interface
    input m_axis_tvalid,
    output reg m_axis_tready,
    input [DATA_WIDTH - 1:0] m_axis_tdata,
    // FIFO interface
    output reg wr_en,
    output reg [DATA_WIDTH - 1:0] data_in
);
// State definitions
reg current_state;
reg next_state;
parameter IDLE = 1'b0;
parameter WRITE = 1'b1;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        current_state <= IDLE;
        next_state <= IDLE;
    end else begin
        current_state <= next_state;
    end
end

// Next state logic
always @(*) begin
    case (current_state)
        IDLE: begin
            if (m_axis_tvalid) begin
                next_state = WRITE;
            end else begin
                next_state = IDLE;
            end
        end
        
        WRITE: begin
            if (m_axis_tvalid) begin
                next_state = WRITE;
            end else begin
                next_state = IDLE;
            end
        end
        
        default: begin
            next_state = IDLE;
        end
    endcase
end

// Output logic
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        m_axis_tready <= 1'b0;
        wr_en <= 1'b0;
        data_in <= {DATA_WIDTH{1'b0}};
    end else begin
        case (current_state)
            IDLE: begin
                if (m_axis_tvalid) begin
                    m_axis_tready <= 1'b1;
                    wr_en <= 1'b1;
                    data_in <= m_axis_tdata;
                end else begin
                    m_axis_tready <= 1'b1;
                    wr_en <= 1'b0;
                end
            end
            
            WRITE: begin
                if (m_axis_tvalid) begin
                    m_axis_tready <= 1'b1;
                    wr_en <= 1'b1;
                    data_in <= m_axis_tdata;
                end else begin
                    m_axis_tready <= 1'b1;
                    wr_en <= 1'b0;
                end
            end
            
            default: begin
                m_axis_tready <= 1'b0;
                wr_en <= 1'b0;
            end
        endcase
    end
end
endmodule