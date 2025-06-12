module fragment_pkt
#(
    parameter DATA_WIDTH = 1024,
    parameter ADDR_WIDTH = 10,
    parameter DATA_DFX_WIDTH = DATA_WIDTH + ADDR_WIDTH,
    parameter ACK_WIDTH = 1,
    parameter SEQ_NUM_WIDTH = 1,
    parameter DFX_WIDTH = 2,
    parameter PKT_WIDTH = DATA_DFX_WIDTH + ACK_WIDTH + SEQ_NUM_WIDTH*2 + DFX_WIDTH*2,
    parameter ROUTER_WIDTH = 2,
    parameter AURORA_WIDTH = 256
)(
    input clk,
    input rst_n,
    /////////////encapsulate pkt interface/////////////////////
    input valid_pkt_send,
    input [PKT_WIDTH - 1:0] pkt_data,
    /////////////send controller interface/////////////////////
    input [ROUTER_WIDTH - 1:0] src_router,
    input start_fragment_pkt,
    output reg frag_pkt_done,
    //////////////FIFO interface/////////////////////
    output reg [AURORA_WIDTH - 1:0] frag_send,
    output reg frag_valid
);
reg [1:0] current_state;
reg [1:0] next_state;
localparam IDLE = 2'b00;
localparam FRAGMENT_PKT = 2'b01;
localparam DONE = 2'b10;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        current_state <= IDLE;
    end
    else begin
        current_state <= next_state;
    end
end
reg [2:0] frag_num;
reg start_fragment_pkt_prev;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        start_fragment_pkt_prev <= 0;
    end
    else begin
        start_fragment_pkt_prev <= start_fragment_pkt;
    end
end
always @(*) begin
    case(current_state)
        IDLE: begin
            if (start_fragment_pkt && !start_fragment_pkt_prev) begin
                next_state = FRAGMENT_PKT;
            end
            else begin
                next_state = IDLE;
            end
        end
        FRAGMENT_PKT: begin
            if (frag_num == 4) begin
                next_state = IDLE;
            end
            else begin
                next_state = FRAGMENT_PKT;
            end
        end
        DONE: begin
            next_state = IDLE;
        end
        default: begin
            next_state = IDLE;
        end
    endcase
end
reg [PKT_WIDTH - 1:0] pkt_data_reg;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        pkt_data_reg <= 0;
    end
    else if (valid_pkt_send) begin
        pkt_data_reg <= pkt_data;
    end
    else begin
        pkt_data_reg <= pkt_data_reg;
    end
end
wire [ROUTER_WIDTH - 1:0] dst_router;
assign dst_router = pkt_data_reg[3:2];
reg [1:0] TTL = 2'b10; // Time To Live
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        frag_valid <= 0;
        frag_send <= 0;
        frag_num <= 0;
        frag_pkt_done <= 0;
    end
    else begin
        case (current_state)
            FRAGMENT_PKT: begin
                frag_valid <= 1;
                if(frag_num == 4) begin
                    frag_pkt_done <= 1;
                    frag_num <= 0;
                    frag_send <= {195'h0, pkt_data_reg[1040:988], TTL, frag_num, dst_router, src_router};
                end
                else begin
                    frag_pkt_done <= 0;
                    frag_num <= frag_num + 1;
                    frag_send <= {pkt_data_reg[frag_num*247 +: 247], TTL, frag_num, dst_router, src_router};
                end
            end
            default: begin
                frag_pkt_done <= 0;
                frag_valid <= 0;
                frag_send <= 0;
                frag_num <= 0;
            end
        endcase
    end
end
// always @(posedge clk or negedge rst_n) begin
//     if(!rst_n) begin
//         frag_pkt_done <= 0;
//     end
//     else begin
//         case (current_state)
//             DONE: begin
//                 frag_pkt_done <= 1;
//             end
//             default: begin
//                frag_pkt_done <= 0; 
//             end
//         endcase
//     end
// end
endmodule