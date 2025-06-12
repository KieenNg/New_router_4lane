module encapsulate_pkt
#(
    parameter DATA_WIDTH = 1024,
    parameter ADDR_WIDTH = 10,
    parameter DATA_DFX_WIDTH = DATA_WIDTH + ADDR_WIDTH,
    parameter ACK_WIDTH = 1,
    parameter SEQ_NUM_WIDTH = 1,
    parameter DFX_WIDTH = 2,
    parameter PKT_WIDTH = DATA_DFX_WIDTH + ACK_WIDTH + SEQ_NUM_WIDTH*2 + DFX_WIDTH*2
)(
    input clk,
    input rst_n,
    /////////////get dfx data interface/////////////////////
    input valid_dfx_data,
    input [DATA_DFX_WIDTH - 1:0] dfx_data,
    /////////////send controller interface/////////////////////
    input start_encap_pkt,
    input [DFX_WIDTH - 1:0] pkt_src_dfx,
    input [DFX_WIDTH - 1:0] pkt_dst_dfx,
    input [SEQ_NUM_WIDTH - 1:0] pkt_sn,
    output reg done_encap_pkt,
    input replay_pkt_sent,
    /////////////fragment_pkt interface/////////////////////
    output reg [PKT_WIDTH - 1:0] pkt_data,
    output reg valid_pkt_send
);

reg [1:0] current_state;
reg [1:0] next_state;
localparam IDLE = 2'b00;
localparam ENCAP_PKT = 2'b01;
localparam DONE = 2'b10;
localparam REPLAY_PKT_SENT = 2'b11;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        current_state <= IDLE;
    end
    else begin
        current_state <= next_state;
    end
end
//***************************************************************
// Next state logic
reg start_encap_pkt_prev;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        start_encap_pkt_prev <= 0;
    end
    else begin
        start_encap_pkt_prev <= start_encap_pkt;
    end
end
always @(*) begin
    case (current_state)
        IDLE: begin
            if (start_encap_pkt && !start_encap_pkt_prev) begin
                next_state = ENCAP_PKT;
            end else if(replay_pkt_sent) begin
                next_state = REPLAY_PKT_SENT;
            end
            else begin
                next_state = IDLE;
            end
        end
        ENCAP_PKT: begin
            next_state = DONE;
        end
        DONE: begin
            next_state = IDLE;
        end
        REPLAY_PKT_SENT: begin
            next_state = IDLE;
        end
        default: next_state = IDLE;
    endcase
end

/***************************************************************
 * Output logic: get dfx data interface
**************************************************************/
reg [DATA_DFX_WIDTH - 1:0] dfx_data_reg;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        dfx_data_reg <= 0;
    end
    else if (valid_dfx_data) begin
        dfx_data_reg <= dfx_data;
    end
    else begin
        dfx_data_reg <= dfx_data_reg;
    end
end
reg [DFX_WIDTH - 1:0] pkt_src_dfx_reg;
reg [DFX_WIDTH - 1:0] pkt_dst_dfx_reg;
reg [SEQ_NUM_WIDTH - 1:0] pkt_sn_reg;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        pkt_src_dfx_reg <= 0;
        pkt_dst_dfx_reg <= 0;
        pkt_sn_reg <= 0;
    end
    else begin
        case (current_state)
            IDLE: begin
                if(start_encap_pkt) begin
                    pkt_src_dfx_reg <= pkt_src_dfx;
                    pkt_dst_dfx_reg <= pkt_dst_dfx;
                    pkt_sn_reg <= pkt_sn;
                end
                else begin
                    pkt_src_dfx_reg <= pkt_src_dfx_reg;
                    pkt_dst_dfx_reg <= pkt_dst_dfx_reg;
                    pkt_sn_reg <= pkt_sn_reg;
                end
            end
            default: begin
                pkt_src_dfx_reg <= pkt_src_dfx_reg;
                pkt_dst_dfx_reg <= pkt_dst_dfx_reg;
                pkt_sn_reg <= pkt_sn_reg;
            end
        endcase
    end
end
/***************************************************************
 * Output logic: send controller interface and fragment_pkt interface
**************************************************************/
reg [PKT_WIDTH - 1:0] pkt_data_reg;
reg valid_pkt_send_reg;
reg ack_pkt_sent = 0;
reg rn_pkt_sent = 0;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        done_encap_pkt <= 0;
        pkt_data_reg <= 0;
        valid_pkt_send_reg <= 0;
    end
    else begin
        case (current_state)
            ENCAP_PKT: begin
                done_encap_pkt <= 0;
                pkt_data_reg <= {dfx_data_reg, ack_pkt_sent, rn_pkt_sent, pkt_sn_reg, pkt_dst_dfx_reg, pkt_src_dfx_reg};
                valid_pkt_send_reg <= 1;
            end
            DONE: begin
                done_encap_pkt <= 1;
                pkt_data_reg <= pkt_data_reg;
                valid_pkt_send_reg <= 0;
            end
            default: begin
                done_encap_pkt <= 0;
                pkt_data_reg <= pkt_data_reg;
                valid_pkt_send_reg <= 0;
            end
        endcase
    end
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        pkt_data <= 0;
        valid_pkt_send <= 0;
    end
    else begin
        case (current_state)
            DONE: begin
                pkt_data <= pkt_data_reg;
                valid_pkt_send <= valid_pkt_send_reg;
            end
            REPLAY_PKT_SENT: begin
                pkt_data <= pkt_data_reg;
                valid_pkt_send <= 1; // Replay packet is sent, so we keep sending the last packet
            end
            default: begin
                pkt_data <= pkt_data;
                valid_pkt_send <= 0;
            end
        endcase
    end
end
endmodule