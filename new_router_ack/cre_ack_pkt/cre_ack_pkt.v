module cre_ack_pkt
#(
    parameter ACK_WIDTH = 1,
    parameter SEQ_NUM_WIDTH = 1,
    parameter DFX_WIDTH = 2,
    parameter ROUTER_WIDTH = 2,
    parameter AURORA_WIDTH = 256
)(
    input clk,
    input rst_n,
    input [ROUTER_WIDTH - 1:0] src_router,
    /////////////recv_controller interface/////////////////////
    input start_cre_ack_pkt,
    input [DFX_WIDTH - 1:0] src_dfx_ack_pkt_send,
    input [DFX_WIDTH - 1:0] dst_dfx_ack_pkt_send,
    input [SEQ_NUM_WIDTH - 1:0] rn_ack_pkt_send,
    output reg cre_done_ack_pkt,
    /////////////fifo_ack_pkt interface/////////////////////
    output reg valid_ack_frag,
    output reg [AURORA_WIDTH - 1:0] ack_frag_send
);
reg [1:0] current_state;
reg [1:0] next_state;
localparam IDLE = 2'b00;
localparam PREPARE_ACK_PKT = 2'b01;
localparam DONE = 2'b10;

reg [ACK_WIDTH - 1:0] ack_send = 1;
reg start_cre_ack_pkt_prev;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        start_cre_ack_pkt_prev <= 0;
    end
    else begin
        start_cre_ack_pkt_prev <= start_cre_ack_pkt;
    end
end
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
            if (start_cre_ack_pkt && !start_cre_ack_pkt_prev) begin
                next_state = PREPARE_ACK_PKT;
            end else begin
                next_state = IDLE;
            end
        end
        
        PREPARE_ACK_PKT: begin
            next_state = DONE;
        end
        
        DONE: begin
            next_state = IDLE;
        end
        
        default: begin
            next_state = IDLE;
        end
    endcase
end
reg [DFX_WIDTH - 1:0] src_dfx_ack_pkt_reg;
reg [DFX_WIDTH - 1:0] dst_dfx_ack_pkt_reg;
reg [SEQ_NUM_WIDTH - 1:0] rn_ack_pkt_reg;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        src_dfx_ack_pkt_reg <= 0;
        dst_dfx_ack_pkt_reg <= 0;
        rn_ack_pkt_reg <= 0;
    end else begin
        case (current_state)
            IDLE: begin
                if(start_cre_ack_pkt) begin
                    src_dfx_ack_pkt_reg <= src_dfx_ack_pkt_send;
                    dst_dfx_ack_pkt_reg <= dst_dfx_ack_pkt_send;
                    rn_ack_pkt_reg <= rn_ack_pkt_send;
                end else begin
                    src_dfx_ack_pkt_reg <= 0;
                    dst_dfx_ack_pkt_reg <= 0;
                    rn_ack_pkt_reg <= 0;
                end
            end
            
            PREPARE_ACK_PKT: begin
                src_dfx_ack_pkt_reg <= src_dfx_ack_pkt_reg;
                dst_dfx_ack_pkt_reg <= dst_dfx_ack_pkt_reg;
                rn_ack_pkt_reg <= rn_ack_pkt_reg;
            end
            
            DONE: begin
                // No change in registers, just acknowledge completion
            end
            
            default: begin
                src_dfx_ack_pkt_reg <= 0;
                dst_dfx_ack_pkt_reg <= 0;
                rn_ack_pkt_reg <= 0;
            end
        endcase
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cre_done_ack_pkt <= 0;
    end else begin
        case (current_state)
            IDLE: begin
                cre_done_ack_pkt <= 0;
            end
            
            PREPARE_ACK_PKT: begin
                cre_done_ack_pkt <= 0;
            end
            
            DONE: begin
                cre_done_ack_pkt <= 1; 
            end
            
            default: begin
                cre_done_ack_pkt <= 0;
            end
        endcase
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        valid_ack_frag <= 0;
        ack_frag_send <= 0;
    end else begin
        case (current_state)
            DONE: begin
                valid_ack_frag <= 1;
                ack_frag_send <= {240'h0, ack_send, rn_ack_pkt_reg, 1'b0, dst_dfx_ack_pkt_reg, src_dfx_ack_pkt_reg, 2'b10, 3'b000, dst_dfx_ack_pkt_reg, src_router};
            end
            default: begin
                valid_ack_frag <= 0;
                ack_frag_send <= 0;
            end
        endcase
    end
end
endmodule