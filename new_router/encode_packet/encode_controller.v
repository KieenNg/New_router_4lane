module encode_controller
#(
    parameter DATA_WIDTH = 1024,
    parameter ADDR_WIDTH = 10,
    parameter DATA_DFX_WIDTH = DATA_WIDTH + ADDR_WIDTH
)(
    input clk,
    input rst_n,
    ////////////total controller////////////
    input                           router_start_req,
    input [ADDR_WIDTH - 1:0]        router_scr_addr,
    input [ADDR_WIDTH - 1:0]        router_dst_addr,
    output reg                      router_done,
    ////////////arbiter////////////
    input                           arbiter_read_gnt,
    output reg                      arbiter_read_req,
    output reg [ADDR_WIDTH - 1:0]   arbiter_src_addr,
    input [DATA_WIDTH - 1:0]        data_arbiter_send,
    ////////////encode packet////////////
    input                           ready_encode_pkt,
    output reg                      start_encode_pkt,
    output reg [DATA_DFX_WIDTH - 1:0]   data_dfx_send,
    input                           encode_done
);

reg [2:0] current_state;
reg [2:0] next_state;
reg router_start_req_prev; // Biến lưu trạng thái trước đó của router_start_req

localparam IDLE = 3'b000;
localparam READ_ARBITER = 3'b001;
localparam READ_ARBITER_DELAY = 3'b010;
localparam START_ENCODE_PKT = 3'b011;
localparam ENCODE_PKT = 3'b100;

// Lưu giá trị trước đó của router_start_req để phát hiện sườn lên
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        router_start_req_prev <= 0;
    end
    else begin
        router_start_req_prev <= router_start_req;
    end
end

// State register
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        current_state <= IDLE;
    end
    else begin
        current_state <= next_state;
    end
end

/***************************************************************
 * Next state logic
 **************************************************************/
always @(*) begin
    case (current_state)
        IDLE: begin
            // Chuyển trạng thái khi phát hiện sườn lên của router_start_req
            if (router_start_req && !router_start_req_prev) begin
                next_state = READ_ARBITER;
            end
            else begin
                next_state = IDLE;
            end
        end
        READ_ARBITER: begin
            next_state = arbiter_read_gnt ? READ_ARBITER_DELAY : READ_ARBITER;
        end
        READ_ARBITER_DELAY: begin
            next_state = START_ENCODE_PKT;
        end 
        START_ENCODE_PKT: begin
            next_state = ready_encode_pkt ? ENCODE_PKT : START_ENCODE_PKT;
        end
        ENCODE_PKT: begin
            if (encode_done) begin
                next_state = IDLE;
            end
            else begin
                next_state = ENCODE_PKT;
            end
        end
        default: begin
            next_state = IDLE;
        end
    endcase
end

/***************************************************************
 * Output logic: Control signals
 **************************************************************/
reg [ADDR_WIDTH - 1:0] router_scr_addr_reg;
reg [ADDR_WIDTH - 1:0] router_dst_addr_reg;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        router_done <= 0;
        router_scr_addr_reg <= 10'h0;
        router_dst_addr_reg <= 10'h0;
    end
    else begin
        case (current_state)
            IDLE: begin
                router_done <= 1;
                router_scr_addr_reg <= router_scr_addr;
                router_dst_addr_reg <= router_dst_addr;
            end
            default: begin
                router_done <= 0;
                router_scr_addr_reg <= router_scr_addr_reg;
                router_dst_addr_reg <= router_dst_addr_reg;
            end
        endcase
    end
end

/***************************************************************
 * Output logic: arbiter signals
 **************************************************************/
reg [DATA_WIDTH - 1:0] data_arbiter_send_reg;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        arbiter_read_req <= 0;
        arbiter_src_addr <= 10'h0;
        data_arbiter_send_reg <= 0;
    end
    else begin
        case (current_state)
            READ_ARBITER: begin
                arbiter_read_req <= 1;
                arbiter_src_addr <= router_scr_addr_reg;
                data_arbiter_send_reg <= 0;
            end
            READ_ARBITER_DELAY: begin
                arbiter_read_req <= 1;
                arbiter_src_addr <= router_scr_addr_reg;
                data_arbiter_send_reg <= data_arbiter_send;
            end
            default: begin
                arbiter_read_req <= 0;
                arbiter_src_addr <= router_scr_addr_reg;
                data_arbiter_send_reg <= data_arbiter_send;
            end
        endcase
    end
end

/***************************************************************
 * Output logic: encode packet signals
 **************************************************************/
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        start_encode_pkt <= 0;
        data_dfx_send <= 0;
    end
    else begin
        case (current_state)
            START_ENCODE_PKT: begin
                start_encode_pkt <= 1;
                data_dfx_send <= {data_arbiter_send, router_dst_addr_reg};
            end
            ENCODE_PKT: begin
                start_encode_pkt <= 0;
                data_dfx_send <= {data_arbiter_send, router_dst_addr_reg};
            end
            default: begin
                start_encode_pkt <= 0;
                data_dfx_send <= 0;
            end
        endcase
    end
end
endmodule