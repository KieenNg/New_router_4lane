module encode_packet
#(
    parameter DATA_WIDTH = 1024,
    parameter ADDR_WIDTH = 10,
    parameter DATA_DFX_WIDTH = DATA_WIDTH + ADDR_WIDTH,
    parameter NUMBER_PACKET = 19,
    parameter AURORA_DATA_WIDTH = 256
)(
    input                                   clk,
    input                                   rst_n,
    //encode_controller
    input                                   start_encode_pkt,
    input [DATA_DFX_WIDTH - 1:0]            data_dfx_send,
    output reg                              ready_encode_pkt,
    output reg                              encode_done,
    //fifo in 0
    output reg                              encode_valid,
    output reg [AURORA_DATA_WIDTH - 1:0]    data_send
);
reg [1:0] TTL = 2'b10;
reg [1:0] src_router = 2'b00;
reg [4:0] pkt_number;

reg [1:0] current_state;
reg [1:0] next_state;
localparam IDLE = 2'b00;
localparam ENCODE_PKT = 2'b01;
localparam ENCODE_PKT_DONE = 2'b10;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        current_state <= IDLE;
        //next_state <= IDLE;
    end
    else current_state <= next_state;
end

/***************************************************************
    * Next state logic
**************************************************************/
always @(*) begin
    case(current_state)
        IDLE: begin
            if(start_encode_pkt && ready_encode_pkt) begin
                next_state = ENCODE_PKT;
            end
            else begin
                next_state = IDLE;
            end
        end
        ENCODE_PKT: begin
            if(pkt_number == 4) begin
                next_state = ENCODE_PKT_DONE;
            end
            else begin
                next_state = ENCODE_PKT;
            end
        end
        ENCODE_PKT_DONE: begin
            next_state = IDLE;
        end
        default: begin
            next_state = IDLE;
        end
    endcase
end
/***************************************************************
 * Output logic: control signals
**************************************************************/
reg [DATA_DFX_WIDTH - 1:0] data_dfx_send_reg;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        ready_encode_pkt <= 0;
        data_dfx_send_reg <= 0;
    end
    else begin
        case (current_state)
            IDLE: begin
                if(start_encode_pkt && ready_encode_pkt) begin
                    ready_encode_pkt <= 0;
                    data_dfx_send_reg <= data_dfx_send;
                end
                else begin
                    ready_encode_pkt <= 1;
                    data_dfx_send_reg <= 0;
                end
            end
            default: begin
                ready_encode_pkt <= 0;
                data_dfx_send_reg <= data_dfx_send_reg;
            end
        endcase
    end
end
/***************************************************************
 * Output logic: fifo 
**************************************************************/
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        encode_valid <= 0;
        data_send <= 0;
        pkt_number <= 0;
    end
    else begin
        case (current_state)
            ENCODE_PKT: begin
                encode_valid <= 1;
                if(pkt_number == NUMBER_PACKET - 1) begin
                    pkt_number <= 0;
                    data_send <= {201'b0, data_dfx_send_reg[1033:988], TTL, pkt_number, src_router};
                end
                else begin
                    pkt_number <= pkt_number + 1;
                    data_send <= {data_dfx_send_reg[pkt_number*247 +: 247], TTL, pkt_number, src_router};
                end
            end
            default: begin
                encode_valid <= 0;
                data_send <= 0;
                pkt_number <= 0;
            end
        endcase
    end
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        encode_done <= 0;
    end
    else begin
        case (current_state)
            ENCODE_PKT_DONE: begin
                encode_done <= 1;
            end
            default: begin
                encode_done <= 0;
            end
        endcase
    end
end
endmodule