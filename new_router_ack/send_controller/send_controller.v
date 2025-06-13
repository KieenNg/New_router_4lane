module send_controller
#(
    parameter ADDR_WIDTH = 10,
    parameter ACK_WIDTH = 1,
    parameter SEQ_NUM_WIDTH = 1,
    parameter DFX_WIDTH = 2
)(
    input clk,
    input rst_n,
    ////////////total controller////////////
    input                           router_start_req,
    input [ADDR_WIDTH - 1:0]        router_scr_addr,
    input [ADDR_WIDTH - 1:0]        router_dst_addr,
    input [1:0]                     router_src_dfx,
    input [1:0]                     router_dst_dfx,
    output reg                      router_send_done,
    ////////////get_dfx_data interface////////////
    output reg                      start_get_data,
    output reg [ADDR_WIDTH - 1:0]   v_src_addr,
    output reg [ADDR_WIDTH - 1:0]   v_dst_addr,
    input                           done_get_data,
    ////////////recv controller interface////////////
    input valid_ack_pkt_recv,
    input rn_ack_pkt_recv,
    input [DFX_WIDTH - 1:0] src_dfx_ack_pkt_recv,
    output reg wait_ack_pkt_recv,
    ////////////encapsulate packet interface////////////
    output reg start_encap_pkt,
    output reg [DFX_WIDTH - 1:0] pkt_src_dfx,
    output reg [DFX_WIDTH - 1:0] pkt_dst_dfx,
    output reg pkt_sn,
    input done_encap_pkt,
    ////////////fragment_pkt interface////////////
    output reg start_frag_pkt,
    input frag_pkt_done
);
localparam ROUTER0 = 2'b00;
localparam ROUTER1 = 2'b01;
localparam ROUTER2 = 2'b10;
localparam ROUTER3 = 2'b11;

reg [SEQ_NUM_WIDTH - 1:0] router0_rn_ack_pkt;
reg [SEQ_NUM_WIDTH - 1:0] router1_rn_ack_pkt;
reg [SEQ_NUM_WIDTH - 1:0] router2_rn_ack_pkt;
reg [SEQ_NUM_WIDTH - 1:0] router3_rn_ack_pkt;

reg [SEQ_NUM_WIDTH - 1:0] router0_sn_send;
reg [SEQ_NUM_WIDTH - 1:0] router1_sn_send;
reg [SEQ_NUM_WIDTH - 1:0] router2_sn_send;
reg [SEQ_NUM_WIDTH - 1:0] router3_sn_send;
reg [SEQ_NUM_WIDTH - 1:0] router0_sn_send_next;
reg [SEQ_NUM_WIDTH - 1:0] router1_sn_send_next;
reg [SEQ_NUM_WIDTH - 1:0] router2_sn_send_next;
reg [SEQ_NUM_WIDTH - 1:0] router3_sn_send_next;



reg [2:0] current_state;
reg [2:0] next_state;
localparam IDLE = 3'b000;
localparam GET_DFX_DATA = 3'b001;
localparam ENCAP_PKT = 3'b010;
localparam FRAG_PKT = 3'b011;
localparam WAIT_ACK_PKT = 3'b100;
localparam READ_ACK_PKT = 3'b101;
localparam REPLAY_SENT_PKT = 3'b110;

// State register
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        current_state <= IDLE;
    end
    else begin
        current_state <= next_state;
    end
end
reg router_start_req_prev;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        router_start_req_prev <= 0;
    end
    else begin
        router_start_req_prev <= router_start_req;
    end
end
/***************************************************************
    * Next state logic
    **************************************************************/
always @(*) begin
    case (current_state)
        IDLE: begin
            if (router_start_req && !router_start_req_prev) begin
                next_state = GET_DFX_DATA;
            end
            else begin
                next_state = IDLE;
            end
        end
        GET_DFX_DATA: begin
            if (done_get_data) begin
                next_state = ENCAP_PKT;
            end
            else begin
                next_state = GET_DFX_DATA;
            end
        end
        ENCAP_PKT: begin
            if (done_encap_pkt) begin
                next_state = FRAG_PKT;
            end
            else begin
                next_state = ENCAP_PKT;
            end
        end
        FRAG_PKT: begin
            if (frag_pkt_done) begin
                next_state = WAIT_ACK_PKT;
            end
            else begin
                next_state = FRAG_PKT;
            end
        end
        WAIT_ACK_PKT: begin
            next_state = (valid_ack_pkt_recv && wait_ack_pkt_recv) ? READ_ACK_PKT : WAIT_ACK_PKT;
            if (valid_ack_pkt_recv && wait_ack_pkt_recv) begin
                case(src_dfx_ack_pkt_recv)
                    ROUTER0: begin
                        if (router0_rn_ack_pkt == router0_sn_send) begin
                            next_state = REPLAY_SENT_PKT;
                        end
                        else begin
                            next_state = IDLE;
                        end
                    end
                    ROUTER1: begin
                        if (router1_rn_ack_pkt == router1_sn_send) begin
                            next_state = REPLAY_SENT_PKT;
                        end
                        else begin
                            next_state = IDLE;
                        end
                    end
                    ROUTER2: begin
                        if (router2_rn_ack_pkt == router2_sn_send) begin
                            next_state = REPLAY_SENT_PKT;
                        end
                        else begin
                            next_state = IDLE;
                        end
                    end
                    ROUTER3: begin
                        if (router3_rn_ack_pkt == router3_sn_send) begin
                            next_state = REPLAY_SENT_PKT;
                        end
                        else begin
                            next_state = IDLE;
                        end
                    end
                    default: begin
                        next_state = IDLE; // Default case if no valid source DFX
                    end
                endcase
            end
            else begin
                next_state = WAIT_ACK_PKT;
            end
        end
        READ_ACK_PKT: begin
            next_state = REPLAY_SENT_PKT;
        end
        REPLAY_SENT_PKT: begin
            next_state = FRAG_PKT;
        end
        default: begin
            next_state = IDLE;
        end
    endcase
end

reg [ADDR_WIDTH - 1:0] router_scr_addr_reg;
reg [ADDR_WIDTH - 1:0] router_dst_addr_reg;
reg [1:0] router_src_dfx_reg;
reg [1:0] router_dst_dfx_reg;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        router_scr_addr_reg <= 0;
        router_dst_addr_reg <= 0;
        router_src_dfx_reg <= 0;
        router_dst_dfx_reg <= 0;
    end
    else begin
        case (current_state)
            IDLE: begin
                if(router_start_req && !router_start_req_prev) begin
                    router_scr_addr_reg <= router_scr_addr;
                    router_dst_addr_reg <= router_dst_addr;
                    router_src_dfx_reg <= router_src_dfx;
                    router_dst_dfx_reg <= router_dst_dfx;
                end
                else begin
                    router_scr_addr_reg <= router_scr_addr_reg;
                    router_dst_addr_reg <= router_dst_addr_reg;
                    router_src_dfx_reg <= router_src_dfx_reg;
                    router_dst_dfx_reg <= router_dst_dfx_reg;
                end
            end
            default: begin
                router_scr_addr_reg <= router_scr_addr_reg;
                router_dst_addr_reg <= router_dst_addr_reg;
                router_src_dfx_reg <= router_src_dfx_reg;
                router_dst_dfx_reg <= router_dst_dfx_reg;
            end
        endcase
    end
end

/***************************************************************
 * Output logic: get_dfx_data interface
 **************************************************************/
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        start_get_data <= 0;
        v_src_addr <= 0;
        v_dst_addr <= 0;
    end
    else begin
        case (current_state)
            IDLE: begin
                start_get_data <= 0;
                v_src_addr <= 0;
                v_dst_addr <= 0;
            end
            GET_DFX_DATA: begin
                start_get_data <= 1;
                v_src_addr <= router_scr_addr_reg;
                v_dst_addr <= router_dst_addr_reg;
            end
            default: begin
                start_get_data <= 0;
                v_src_addr <= 0;
                v_dst_addr <= 0;
            end
        endcase
    end
end
/***************************************************************
 * Output logic: recv controller interface
 **************************************************************/
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        wait_ack_pkt_recv <= 0;
    end
    else begin
        case (current_state)
            WAIT_ACK_PKT: begin
                if(valid_ack_pkt_recv && wait_ack_pkt_recv) begin
                    wait_ack_pkt_recv <= 0;
                end
                else begin
                    wait_ack_pkt_recv <= 1;
                end
            end
            default: begin
                wait_ack_pkt_recv <= 0;
            end
        endcase
    end
end

reg [SEQ_NUM_WIDTH - 1:0] rn_ack_pkt_recv_reg;
reg [DFX_WIDTH - 1:0] src_dfx_ack_pkt_recv_reg;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        rn_ack_pkt_recv_reg <= 0;
        src_dfx_ack_pkt_recv_reg <= 0;
    end
    else begin 
        case (current_state)
            WAIT_ACK_PKT: begin
                if(valid_ack_pkt_recv && wait_ack_pkt_recv) begin
                    rn_ack_pkt_recv_reg <= rn_ack_pkt_recv;
                    src_dfx_ack_pkt_recv_reg <= src_dfx_ack_pkt_recv;
                end
                else begin
                    rn_ack_pkt_recv_reg <= 0;
                    src_dfx_ack_pkt_recv_reg <= 0;
                end
            end
            READ_ACK_PKT: begin
                rn_ack_pkt_recv_reg <= rn_ack_pkt_recv_reg;
                src_dfx_ack_pkt_recv_reg <= src_dfx_ack_pkt_recv_reg;
            end
            REPLAY_SENT_PKT: begin
                rn_ack_pkt_recv_reg <= rn_ack_pkt_recv_reg;
                src_dfx_ack_pkt_recv_reg <= src_dfx_ack_pkt_recv_reg;
            end
            default: begin
                rn_ack_pkt_recv_reg <= 0;
                src_dfx_ack_pkt_recv_reg <= 0;
            end
        endcase
    end 
end
always @(*) begin
    if(valid_ack_pkt_recv && wait_ack_pkt_recv) begin
        case(src_dfx_ack_pkt_recv)
            WAIT_ACK_PKT: begin
                
            end
        endcase
    end
end
// always @(posedge clk or negedge rst_n) begin
//     if (!rst_n) begin
//         router0_rn_ack_pkt <= 0;
//         router1_rn_ack_pkt <= 0;
//         router2_rn_ack_pkt <= 0;
//         router3_rn_ack_pkt <= 0;
//     end
//     else begin
//         if(valid_ack_pkt_recv && wait_ack_pkt_recv) begin
//             case(src_dfx_ack_pkt_recv)
//                 ROUTER0: begin
//                     router0_rn_ack_pkt <= rn_ack_pkt_recv;
//                     router1_rn_ack_pkt <= router1_rn_ack_pkt;
//                     router2_rn_ack_pkt <= router2_rn_ack_pkt;
//                     router3_rn_ack_pkt <= router3_rn_ack_pkt;
//                 end
//                 ROUTER1: begin
//                     router1_rn_ack_pkt <= rn_ack_pkt_recv;
//                     router0_rn_ack_pkt <= router0_rn_ack_pkt;
//                     router2_rn_ack_pkt <= router2_rn_ack_pkt;
//                     router3_rn_ack_pkt <= router3_rn_ack_pkt;
//                 end
//                 ROUTER2: begin
//                     router2_rn_ack_pkt <= rn_ack_pkt_recv;
//                     router0_rn_ack_pkt <= router0_rn_ack_pkt;
//                     router1_rn_ack_pkt <= router1_rn_ack_pkt;
//                     router3_rn_ack_pkt <= router3_rn_ack_pkt;
//                 end
//                 ROUTER3: begin
//                     router3_rn_ack_pkt <= rn_ack_pkt_recv;
//                     router0_rn_ack_pkt <= router0_rn_ack_pkt;
//                     router1_rn_ack_pkt <= router1_rn_ack_pkt;
//                     router2_rn_ack_pkt <= router2_rn_ack_pkt;
//                 end
//                 default: begin
//                     router0_rn_ack_pkt <= router0_rn_ack_pkt;
//                     router1_rn_ack_pkt <= router1_rn_ack_pkt;
//                     router2_rn_ack_pkt <= router2_rn_ack_pkt;
//                     router3_rn_ack_pkt <= router3_rn_ack_pkt;
//                 end
//             endcase
//         end
//         else begin
//             router0_rn_ack_pkt <= router0_rn_ack_pkt;
//             router1_rn_ack_pkt <= router1_rn_ack_pkt;
//             router2_rn_ack_pkt <= router2_rn_ack_pkt;
//             router3_rn_ack_pkt <= router3_rn_ack_pkt;
//         end
//     end
// end

/***************************************************************
 * Output logic: encapsulate packet interface
 **************************************************************/

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        router0_sn_send <= 0;
        router1_sn_send <= 0;
        router2_sn_send <= 0;
        router3_sn_send <= 0;
    end
    else begin
        router0_sn_send <= router0_sn_send_next;
        router1_sn_send <= router1_sn_send_next;
        router2_sn_send <= router2_sn_send_next;
        router3_sn_send <= router3_sn_send_next;
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        router0_sn_send <= 0;
        router1_sn_send <= 0;
        router2_sn_send <= 0;
        router3_sn_send <= 0;
    end
    else begin
        case (current_state)
            ENCAP_PKT: begin
                case (router_dst_dfx_reg)
                    ROUTER0: begin
                        router0_sn_send <= router0_rn_ack_pkt;
                    end
                    ROUTER1: begin
                        router1_sn_send <= router1_rn_ack_pkt;
                    end
                    ROUTER2: begin
                        router2_sn_send <= router2_rn_ack_pkt;
                    end
                    ROUTER3: begin
                        router3_sn_send <= router3_rn_ack_pkt;
                    end
                    default: begin
                        router0_sn_send <= router0_sn_send;
                        router1_sn_send <= router1_sn_send;
                        router2_sn_send <= router2_sn_send;
                        router3_sn_send <= router3_sn_send;
                    end
                endcase
            end
            default: begin
                router0_sn_send <= router0_sn_send;
                router1_sn_send <= router1_sn_send;
                router2_sn_send <= router2_sn_send;
                router3_sn_send <= router3_sn_send;
            end
        endcase
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        start_encap_pkt <= 0;
        pkt_src_dfx <= 0;
        pkt_dst_dfx <= 0;
        pkt_sn <= 0;
    end
    else begin
        case (current_state)
            IDLE: begin
                start_encap_pkt <= 0;
                pkt_src_dfx <= 0;
                pkt_dst_dfx <= 0;
                pkt_sn <= 0;
            end
            ENCAP_PKT: begin
                start_encap_pkt <= 1;
                pkt_src_dfx <= router_src_dfx_reg;
                pkt_dst_dfx <= router_dst_dfx_reg;
                case (router_dst_dfx_reg)
                    ROUTER0: begin
                        pkt_sn <= router0_sn_send;
                    end
                    ROUTER1: begin
                        pkt_sn <= router1_sn_send;
                    end
                    ROUTER2: begin
                        pkt_sn <= router2_sn_send;
                    end
                    ROUTER3: begin
                        pkt_sn <= router3_sn_send;
                    end
                    default: begin
                        pkt_sn <= 0; // Default case if no valid destination
                    end
                endcase
            end
            default: begin
                start_encap_pkt <= 0;
                pkt_src_dfx <= 0;
                pkt_dst_dfx <= 0;
                pkt_sn <= 0;
            end
        endcase
    end
end

/***************************************************************
 * Output logic: fragment_pkt interface
**************************************************************/
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        start_frag_pkt <= 0;
    end
    else begin
        case (current_state)
            FRAG_PKT: begin
                start_frag_pkt <= 1;
            end
            default: begin
                start_frag_pkt <= 0;
            end
        endcase
    end
end
endmodule