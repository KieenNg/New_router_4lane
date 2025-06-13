module recv_controller
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
    /////////////reassemble packet interface/////////////////////
    input valid_pkt_recv,
    input type_pkt,
    input [DFX_WIDTH - 1:0] src_dfx_recv,
    input [DFX_WIDTH - 1:0] dst_dfx_recv,
    input [SEQ_NUM_WIDTH - 1:0] pkt_sn_recv,
    input [SEQ_NUM_WIDTH - 1:0] pkt_rn_recv,
    output reg ready_receive_pkt,
    /////////////send controller interface/////////////////////
    output reg valid_ack_pkt_recv,
    output reg rn_ack_pkt_recv,
    output reg [DFX_WIDTH - 1:0] src_dfx_ack_pkt_recv,
    input wait_ack_pkt_recv,
    /////////////fragment_pkt interface/////////////////////
    output reg start_cre_ack_pkt,
    output reg [DFX_WIDTH - 1:0] src_dfx_ack_pkt_send,
    output reg [DFX_WIDTH - 1:0] dst_dfx_ack_pkt_send,
    output reg [SEQ_NUM_WIDTH - 1:0] rn_ack_pkt_send,
    input create_done_ack_pkt,
    /////////////total controller interface/////////////////////
    output reg valid_v_recv,
    output reg [ADDR_WIDTH - 1:0] src_dfx,
    input check_recv_done
);
reg [2:0] current_state;
reg [2:0] next_state;
localparam IDLE = 3'b000;
localparam PROCESS = 3'b001;
localparam PREPARE_ACK_PKT = 3'b010;
localparam SEND_ACK_PKT = 3'b011;
localparam INFOR_SEND_CONTROLLER = 3'b100;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        current_state <= IDLE;
    end else begin
        current_state <= next_state;
    end
end
reg type_pkt_reg;
reg [DFX_WIDTH - 1:0] src_dfx_recv_reg;
reg [DFX_WIDTH - 1:0] dst_dfx_recv_reg;
reg [SEQ_NUM_WIDTH - 1:0] pkt_sn_recv_reg;
reg [SEQ_NUM_WIDTH - 1:0] pkt_rn_recv_reg;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        type_pkt_reg <= 0;
        src_dfx_recv_reg <= 0;
        dst_dfx_recv_reg <= 0;
        pkt_sn_recv_reg <= 0;
        pkt_rn_recv_reg <= 0;
    end else begin
        if (valid_pkt_recv && ready_receive_pkt) begin
            type_pkt_reg <= type_pkt;
            src_dfx_recv_reg <= src_dfx_recv;
            dst_dfx_recv_reg <= dst_dfx_recv;
            pkt_sn_recv_reg <= pkt_sn_recv;
            pkt_rn_recv_reg <= pkt_rn_recv;
        end
    end
end
always @(*) begin
    case (current_state)
        IDLE: begin
            if (valid_pkt_recv && ready_receive_pkt) begin
                next_state = PROCESS;
            end else begin
                next_state = IDLE;
            end
        end
        PROCESS: begin
            next_state = type_pkt_reg ? INFOR_SEND_CONTROLLER : PREPARE_ACK_PKT;
        end
        PREPARE_ACK_PKT: begin
            next_state = SEND_ACK_PKT;
        end
        SEND_ACK_PKT: begin
            next_state = create_done_ack_pkt ? IDLE : SEND_ACK_PKT;
        end
        INFOR_SEND_CONTROLLER: begin
            if (valid_ack_pkt_recv && wait_ack_pkt_recv) begin
                next_state = IDLE;
            end else begin
                next_state = INFOR_SEND_CONTROLLER;
            end
        end
        default: next_state = IDLE;
    endcase
end

////////// Output logic: reassemble packet interface
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        ready_receive_pkt <= 1;
    end else begin
        case (current_state)
            IDLE: begin
                if (valid_pkt_recv && ready_receive_pkt) begin
                    ready_receive_pkt <= 0;
                end else begin
                    ready_receive_pkt <= 1;
                end
            end
            default: ready_receive_pkt <= 0;
        endcase
    end 
end

////////// Output logic: cre_ack_pkt interface
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        start_cre_ack_pkt <= 0;
        src_dfx_ack_pkt_send <= 0;
        dst_dfx_ack_pkt_send <= 0;
        rn_ack_pkt_send <= 0;
    end
    else begin
        case (current_state)
            PREPARE_ACK_PKT: begin
                start_cre_ack_pkt <= 1;
                src_dfx_ack_pkt_send <= dst_dfx_recv_reg;
                dst_dfx_ack_pkt_send <= src_dfx_recv_reg;
                rn_ack_pkt_send <= pkt_sn_recv_reg + 1;
            end
            SEND_ACK_PKT: begin
                start_cre_ack_pkt <= 0;
                src_dfx_ack_pkt_send <= src_dfx_ack_pkt_send;
                dst_dfx_ack_pkt_send <= dst_dfx_ack_pkt_send;
                rn_ack_pkt_send <= rn_ack_pkt_send;
            end
            default: begin
                start_cre_ack_pkt <= 0;
                src_dfx_ack_pkt_send <= 0;
                dst_dfx_ack_pkt_send <= 0;
                rn_ack_pkt_send <= 0;
            end
        endcase
    end 
end

////////// Output logic: send controller interface
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        valid_ack_pkt_recv <= 0;
        rn_ack_pkt_recv <= 0;
        src_dfx_ack_pkt_recv <= 0;
    end
    else begin
        case (current_state)
            INFOR_SEND_CONTROLLER: begin
                valid_ack_pkt_recv <= 1;
                rn_ack_pkt_recv <= pkt_rn_recv_reg;
                src_dfx_ack_pkt_recv <= src_dfx_recv_reg;
            end
            default: begin
                valid_ack_pkt_recv <= 0;
                rn_ack_pkt_recv <= 0;
                src_dfx_ack_pkt_recv <= 0;
            end
        endcase
    end 
end

////////// Output logic: total controller interface
reg valid_v_recv_reg;
reg [ADDR_WIDTH - 1:0] src_dfx_reg;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        valid_v_recv_reg <= 0;
        src_dfx_reg <= 0;
    end
    else begin
        if(valid_pkt_recv && (type_pkt == 0)) begin
            valid_v_recv_reg <= 1;
            src_dfx_reg <= src_dfx_recv;
        end else begin
            if (check_recv_done) begin
                valid_v_recv_reg <= 0;
                src_dfx_reg <= 0;
            end else begin
                valid_v_recv_reg <= valid_v_recv_reg;
                src_dfx_reg <= src_dfx_reg;
            end
        end
    end 
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        valid_v_recv <= 0;
        src_dfx <= 0;
    end
    else begin
        valid_v_recv <= valid_v_recv_reg;
        src_dfx <= src_dfx_reg;
    end 
end

endmodule