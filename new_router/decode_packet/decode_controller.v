module decode_controller
(
    input                                   clk,
    input                                   rst_n,
    //////////////////packet fifo/////////////////////////
    input                                   empty_pkt_fifo,
    output reg                              read_pkt_fifo,
    /////////////////decode packet///////////////////////
    input                           ready_decode_pkt,
    output reg                      start_decode_pkt,
    input                           decode_done
);
reg [1:0] current_state;
reg [1:0] next_state;

localparam IDLE = 2'b00;
localparam READ_PKT = 2'b01;
localparam DECODE_PKT = 2'b10;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        current_state <= IDLE;
    end else begin
        current_state <= next_state;    
    end
end

always @(*) begin
    case(current_state)
        IDLE: begin
            if(!empty_pkt_fifo) begin
                next_state = READ_PKT;
            end else begin
                next_state = IDLE;
            end
        end
        READ_PKT: begin
            next_state = DECODE_PKT;
        end
        DECODE_PKT: begin
            if(decode_done) begin
                next_state = IDLE;
            end else begin
                next_state = DECODE_PKT;
            end
        end
        default: next_state = IDLE;
    endcase 
end

// packet fifo interface
always @(*) begin
    case (current_state)
        IDLE: begin
            read_pkt_fifo = 1'b0;
        end
        READ_PKT: begin
            read_pkt_fifo = 1'b1;
        end
        DECODE_PKT: begin
            read_pkt_fifo = 1'b0;
        end
        default: begin
            read_pkt_fifo = 1'b0;
        end
    endcase
end
//decode interface
always @(*) begin
    case (current_state)
        IDLE: begin
            start_decode_pkt = 1'b0;
        end
        READ_PKT: begin
            start_decode_pkt = 1'b0;
        end
        DECODE_PKT: begin
            start_decode_pkt = 1'b1;
        end
        default: begin
            start_decode_pkt = 1'b0;
        end
    endcase
end
endmodule