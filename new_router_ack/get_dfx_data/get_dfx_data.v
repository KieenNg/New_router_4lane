module get_dfx_data
#(
    parameter DATA_WIDTH = 1024,
    parameter ADDR_WIDTH = 10,
    parameter DATA_DFX_WIDTH = DATA_WIDTH + ADDR_WIDTH
)(
    input clk,
    input rst_n,
    /////////////send controller interface/////////////////////
    input start_get_data,
    input [ADDR_WIDTH - 1:0] v_src_addr,
    input [ADDR_WIDTH - 1:0] v_dst_addr,
    output reg done_get_data,
    /////////////arbiter interface/////////////////////
    input                           read_gnt,
    output reg                      read_req,
    output reg [ADDR_WIDTH - 1:0]   vrf_src_addr,
    input [DATA_WIDTH - 1:0]        data_send,
    /////////////encapsulate packet interface/////////////////////
    output reg [DATA_DFX_WIDTH - 1:0] dfx_data,
    output reg                      valid_dfx_data
);
reg [1:0] current_state;
reg [1:0] next_state;
localparam IDLE = 2'b00;
localparam READ_VRF = 2'b01;
localparam READ_VRF_DELAY = 2'b10;
localparam DONE = 2'b11;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        current_state <= IDLE;
    end
    else begin
        current_state <= next_state;
    end
end

reg start_get_data_prev;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        start_get_data_prev <= 0;
    end
    else begin
        start_get_data_prev <= start_get_data;
    end
end
/***************************************************************
 * Next state logic
 **************************************************************/
always @(*) begin
    case (current_state)
        IDLE: begin
            if (start_get_data && !start_get_data_prev) begin
                next_state = READ_VRF;
            end
            else begin
                next_state = IDLE;
            end
        end
        READ_VRF: begin
            next_state = read_gnt ? READ_VRF_DELAY : READ_VRF;
        end
        READ_VRF_DELAY: begin
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
/***************************************************************
 * Output logic: send controller interface
 **************************************************************/
reg [ADDR_WIDTH - 1:0] v_src_addr_reg;
reg [ADDR_WIDTH - 1:0] v_dst_addr_reg;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        done_get_data <= 0;
        v_src_addr_reg <= 10'h0;
        v_dst_addr_reg <= 10'h0;
    end
    else begin
        case (current_state)
            IDLE: begin
            done_get_data <= 0;
            v_src_addr_reg <= v_src_addr;
            v_dst_addr_reg <= v_dst_addr;
            end
            READ_VRF_DELAY: begin
            done_get_data <= 1;
            v_src_addr_reg <= v_src_addr_reg;
            v_dst_addr_reg <= v_dst_addr_reg;
        end
            default: begin
                done_get_data <= 0;
                v_src_addr_reg <= v_src_addr_reg;
                v_dst_addr_reg <= v_dst_addr_reg;
            end
        endcase
    end
end
 /***************************************************************
 * Output logic: arbiter interface
 **************************************************************/
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        read_req <= 0;
        vrf_src_addr <= 10'h0;
    end
    else begin
        case (current_state)
            READ_VRF: begin
                read_req <= 1;
                vrf_src_addr <= v_src_addr_reg;
            end
            READ_VRF_DELAY: begin
                read_req <= 1;
                vrf_src_addr <= v_src_addr_reg;
            end
            DONE: begin
                read_req <= 0;
                vrf_src_addr <= v_src_addr_reg;
            end
            default: begin
                read_req <= 0;
                vrf_src_addr <= v_src_addr_reg;
            end
        endcase
    end
end
/***************************************************************
 * Output logic: encapsulate packet interface
 **************************************************************/
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        valid_dfx_data <= 0;
        dfx_data <= 0;
    end
    else begin
        case (current_state)
            IDLE: begin
                valid_dfx_data <= 0;
                dfx_data <= 0;
            end
            READ_VRF: begin
                valid_dfx_data <= 0;
                dfx_data <= 0;
            end
            READ_VRF_DELAY: begin
                valid_dfx_data <= 0;
                dfx_data <= 0;
            end
            DONE: begin
                valid_dfx_data <= 1;
                dfx_data <= {data_send, v_dst_addr_reg};
            end
            default: begin
                valid_dfx_data <= 0;
                dfx_data <= 0;
            end
        endcase
    end
end
endmodule