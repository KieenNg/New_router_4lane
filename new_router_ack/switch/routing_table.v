module routing_table
#(
    parameter ROUTER_WIDTH = 2

)(
    input [ROUTER_WIDTH - 1:0] src_router,
    input [ROUTER_WIDTH - 1:0] pkt_dst_router,
    output reg [ROUTER_WIDTH - 1:0] next_router
);
localparam ROUTER0 = 2'b00;
localparam ROUTER1 = 2'b01;
localparam ROUTER2 = 2'b10;
localparam ROUTER3 = 2'b11;

always @(*) begin
    case (src_router)
        ROUTER0: begin
            if (pkt_dst_router == ROUTER1) begin
                next_router = ROUTER1; 
            end
            else if (pkt_dst_router == ROUTER2) begin
                next_router = ROUTER1; 
            end
            else if (pkt_dst_router == ROUTER3) begin
                next_router = ROUTER3; 
            end
            else begin
                next_router = ROUTER0; 
            end
        end
        ROUTER1: begin
            if (pkt_dst_router == ROUTER0) begin
                next_router = ROUTER0; 
            end
            else if (pkt_dst_router == ROUTER2) begin
                next_router = ROUTER2;
            end
            else if (pkt_dst_router == ROUTER3) begin
                next_router = ROUTER2;
            end
            else begin
                next_router = ROUTER1;
            end
        end
        ROUTER2: begin
            if (pkt_dst_router == ROUTER0) begin
                next_router = ROUTER3;
            end
            else if (pkt_dst_router == ROUTER1) begin
                next_router = ROUTER1;
            end
            else if (pkt_dst_router == ROUTER3) begin
                next_router = ROUTER3;
            end
            else begin
                next_router = ROUTER2;
            end
        end
        ROUTER3: begin
            if (pkt_dst_router == ROUTER0) begin
                next_router = ROUTER0;
            end
            else if (pkt_dst_router == ROUTER1) begin
                next_router = ROUTER0;
            end
            else if (pkt_dst_router == ROUTER2) begin
                next_router = ROUTER2;
            end
            else begin
                next_router = ROUTER3;
            end
        end
        default: begin
            next_router = src_router; // Default case, stay at current router
        end
    endcase
end
endmodule