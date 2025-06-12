module switch
#(
    parameter ROUTER_WIDTH = 2,
    parameter AURORA_WIDTH = 256
)(
    input clk,
    input rst_n,
    input [ROUTER_WIDTH - 1:0] src_router,
    /////////////input port 0 interface/////////////////////
    input empty_input_port_0,
    input [AURORA_WIDTH - 1:0] data_in_port_0,
    output reg rd_input_port_0,
    /////////////input fifo ack interface/////////////////////
    input empty_ack_fifo,
    input [AURORA_WIDTH - 1:0] ack_data,
    output reg rd_ack_fifo,
    /////////////input port 1 interface/////////////////////
    input empty_input_port_1,
    input [AURORA_WIDTH - 1:0] data_in_port_1,
    output reg rd_input_port_1,
    /////////////input port 2 interface/////////////////////
    input empty_input_port_2,
    input [AURORA_WIDTH - 1:0] data_in_port_2,
    output reg rd_input_port_2,
    /////////////output port 0 interface/////////////////////
    output reg we_output_port_0,
    output reg [AURORA_WIDTH - 1:0] data_out_port_0,
    /////////////output port 1 interface/////////////////////
    output reg we_output_port_1,
    output reg [AURORA_WIDTH - 1:0] data_out_port_1,
    /////////////output port 2 interface/////////////////////
    output reg we_output_port_2,
    output reg [AURORA_WIDTH - 1:0] data_out_port_2,
    /////////////routing table interface/////////////////////
    input [ROUTER_WIDTH - 1:0] next_router,
    output reg [ROUTER_WIDTH - 1:0] pkt_dst_router
);
reg [3:0] current_state;
reg [3:0] next_state;
localparam IDLE = 4'b0000;
localparam READ_ACK_FIFO = 4'b0001;
localparam READ_ACK_FIFO_DELAY = 4'b0010;
localparam READ_FIFO_IN0 = 4'b0011;
localparam READ_FIFO_IN0_DELAY = 4'b0100;
localparam READ_FIFO_IN1 = 4'b0101;
localparam READ_FIFO_IN1_DELAY = 4'b0110;
localparam READ_FIFO_IN2 = 4'b0111;
localparam READ_FIFO_IN2_DELAY = 4'b1000;
localparam PROCESS = 4'b1001;

localparam ROUTER0 = 2'b00;
localparam ROUTER1 = 2'b01;
localparam ROUTER2 = 2'b10;
localparam ROUTER3 = 2'b11;


always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        current_state <= IDLE;
    end
    else begin
        current_state <= next_state;
    end
end

always @(*) begin
    case(current_state)
        IDLE: begin
            if(!empty_input_port_2) begin
                next_state = READ_FIFO_IN2;
            end
            else if(!empty_input_port_1) begin
                next_state = READ_FIFO_IN1;
            end
            else if(!empty_ack_fifo) begin
                next_state = READ_ACK_FIFO;
            end
            else if(!empty_input_port_0) begin
                next_state = READ_FIFO_IN0;
            end
            else begin
                next_state = IDLE;
            end
        end
        READ_FIFO_IN2: begin
            next_state = READ_FIFO_IN2_DELAY;
        end
        READ_FIFO_IN2_DELAY: begin
            next_state = PROCESS;
        end
        // Read from input port 1
        READ_FIFO_IN1: begin
            next_state = READ_FIFO_IN1_DELAY;
        end
        READ_FIFO_IN1_DELAY: begin
            next_state = PROCESS;
        end
        // Read from ack FIFO
        READ_ACK_FIFO: begin
            next_state = READ_ACK_FIFO_DELAY;
        end
        READ_ACK_FIFO_DELAY: begin
            next_state = PROCESS;
        end
        // Read from input port 0
        READ_FIFO_IN0: begin
            next_state = READ_FIFO_IN0_DELAY;
        end
        READ_FIFO_IN0_DELAY: begin
            next_state = PROCESS;
        end
        PROCESS: begin
            next_state = IDLE;
        end
        default: next_state = IDLE;
    endcase
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        rd_ack_fifo <= 0;
        rd_input_port_0 <= 0;
        rd_input_port_1 <= 0;
        rd_input_port_2 <= 0;
    end
    else begin
        case (current_state)
            IDLE: begin
                if(!empty_input_port_2) begin
                    rd_ack_fifo <= 0;
                    rd_input_port_0 <= 0;
                    rd_input_port_1 <= 0;
                    rd_input_port_2 <= 1;
                end
                else if(!empty_input_port_1) begin
                    rd_ack_fifo <= 0;
                    rd_input_port_0 <= 0;
                    rd_input_port_1 <= 1;
                    rd_input_port_2 <= 0;
                end
                else if(!empty_ack_fifo) begin
                    rd_ack_fifo <= 1;
                    rd_input_port_0 <= 0;
                    rd_input_port_1 <= 0;
                    rd_input_port_2 <= 0;
                end
                else if(!empty_input_port_0) begin
                    rd_ack_fifo <= 0;
                    rd_input_port_0 <= 1;
                    rd_input_port_1 <= 0;
                    rd_input_port_2 <= 0;
                end
                else begin
                    rd_ack_fifo <= 0;
                    rd_input_port_0 <= 0;
                    rd_input_port_1 <= 0;
                    rd_input_port_2 <= 0;
                end
            end
            default: begin
                rd_ack_fifo <= 0;
                rd_input_port_0 <= 0;
                rd_input_port_1 <= 0;
                rd_input_port_2 <= 0;
            end
        endcase
    end
end

///////////////// Data processing logic //////////////////////
reg [AURORA_WIDTH - 1:0] fifo_data_reg;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        fifo_data_reg <= 0;
    end
    else begin
        case(current_state)
            READ_FIFO_IN2_DELAY: begin
                fifo_data_reg <= data_in_port_2;
            end
            READ_FIFO_IN1_DELAY: begin
                fifo_data_reg <= data_in_port_1;
            end
            READ_ACK_FIFO_DELAY: begin
                fifo_data_reg <= ack_data;
            end
            READ_FIFO_IN0_DELAY: begin
                fifo_data_reg <= data_in_port_0;
            end
            default: fifo_data_reg <= 0;
        endcase
    end
end
always @(*) begin
    pkt_dst_router = fifo_data_reg[3:2];
end

//////////////// Output port control logic ////////////////////
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        we_output_port_0 <= 0;
        data_out_port_0 <= 0;
        we_output_port_1 <= 0;
        data_out_port_1 <= 0;
        we_output_port_2 <= 0;
        data_out_port_2 <= 0;
    end
    else begin
        case (current_state)
            PROCESS: begin
                if(next_router == src_router + 1) begin
                    we_output_port_0 <= 0;
                    data_out_port_0 <= 0;
                    we_output_port_1 <= 0;
                    data_out_port_1 <= 0;
                    we_output_port_2 <= 1;
                    data_out_port_2 <= fifo_data_reg;
                end
                else if(next_router == src_router - 1) begin
                    we_output_port_0 <= 0;
                    data_out_port_0 <= 0;
                    we_output_port_1 <= 1;
                    data_out_port_1 <= fifo_data_reg;
                    we_output_port_2 <= 0;
                    data_out_port_2 <= 0;
                end
                else if(next_router == src_router) begin
                    we_output_port_0 <= 1;
                    data_out_port_0 <= fifo_data_reg;
                    we_output_port_1 <= 0;
                    data_out_port_1 <= 0;
                    we_output_port_2 <= 0;
                    data_out_port_2 <= 0;
                end
                else begin
                    we_output_port_0 <= 0;
                    data_out_port_0 <= 0;
                    we_output_port_1 <= 0;
                    data_out_port_1 <= 0;
                    we_output_port_2 <= 0;
                    data_out_port_2 <= 0;
                end
            end
            default: begin
                we_output_port_0 <= 0;
                data_out_port_0 <= 0;
                we_output_port_1 <= 0;
                data_out_port_1 <= 0;
                we_output_port_2 <= 0;
                data_out_port_2 <= 0;
            end
            
        endcase
    end
end
endmodule