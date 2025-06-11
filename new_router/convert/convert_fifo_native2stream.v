module fifo_native2stream
#(
    parameter DATA_WIDTH = 256
)(
    input wire clk,
    input wire rst_n,
    // FIFO interface
    input empty,
    output reg rd_en,
    input [DATA_WIDTH - 1:0] dout,
    // Stream interface
    input s_axis_tready,
    output reg s_axis_tvalid,
    output reg [DATA_WIDTH - 1:0] s_axis_tdata
);
reg [1:0] current_state;
reg [1:0] next_state;

localparam IDLE = 2'b00;
localparam READ = 2'b01;
localparam TRANSFER = 2'b10;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        current_state <= IDLE;
    end else begin
        current_state <= next_state;
    end
end

always @(*) begin
    case (current_state)
        IDLE: begin
            if (!empty && s_axis_tready) begin
                next_state = READ;
            end else begin
                next_state = IDLE;
            end
        end
        
        READ: begin
            next_state = TRANSFER;
        end
        
        TRANSFER: begin
            if (!empty && s_axis_tready) begin
                next_state = READ;
            end else begin
                next_state = IDLE;
            end
        end
        
        default: begin
            next_state = IDLE;
        end
    endcase
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        rd_en <= 1'b0;
        s_axis_tvalid <= 1'b0;
        s_axis_tdata <= {DATA_WIDTH{1'b0}};
    end else begin
        case (current_state)
            IDLE: begin
                if (!empty && s_axis_tready) begin
                    rd_en <= 1'b1;
                    s_axis_tvalid <= 1'b0;
                end else begin
                    rd_en <= 1'b0;
                    s_axis_tvalid <= 1'b0;
                end
            end
            
            READ: begin
                rd_en <= 1'b0;
                s_axis_tvalid <= 1'b0;
            end
            
            TRANSFER: begin
                s_axis_tvalid <= 1'b1;
                s_axis_tdata <= dout;
                
                if (!empty && s_axis_tready) begin
                    rd_en <= 1'b1;
                end else begin
                    rd_en <= 1'b0;
                end
            end
            
            default: begin
                rd_en <= 1'b0;
                s_axis_tvalid <= 1'b0;
            end
        endcase
    end
end
endmodule