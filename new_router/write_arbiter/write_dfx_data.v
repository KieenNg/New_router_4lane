module write_dfx_data
#(
    parameter DATA_WIDTH = 1024,
    parameter ADDR_WIDTH = 10,
    parameter DATA_DFX_WIDTH = DATA_WIDTH + ADDR_WIDTH
)(
    input clk,
    input rst_n,
    /////////////arbiter data fifo/////////////////////
    input                        empty_arbiter_fifo,
    input [DATA_DFX_WIDTH - 1:0] data_dfx_recv,
    output reg                 read_arbiter_fifo,
    ////////////////////arbiter///////////////////////////
    input                           arbiter_write_gnt,
    output reg                      arbiter_write_req,
    output reg [ADDR_WIDTH - 1:0]   router_dst_addr_recv,
    output reg [DATA_WIDTH - 1:0]   data_arbiter_recv
);
reg [1:0] current_state;
reg [1:0] next_state;

localparam IDLE = 2'b00;
localparam READ_DFX_DATA = 2'b01;
localparam WRITE_ARBITER = 2'b10;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        current_state <= IDLE;
        //next_state <= IDLE;
    end else begin
        current_state <= next_state;    
    end
end
always @(*) begin
    case(current_state)
        IDLE: begin
            if(!empty_arbiter_fifo)begin
                next_state = READ_DFX_DATA;
            end else begin
                next_state = IDLE;
            end
        end
        READ_DFX_DATA: begin
            next_state = WRITE_ARBITER;
        end
        WRITE_ARBITER: begin
            if(arbiter_write_gnt) begin
                next_state = IDLE;
            end else begin
                next_state = WRITE_ARBITER;
            end
        end
        default: next_state = IDLE;
    endcase 
end

reg [DATA_DFX_WIDTH - 1:0] data_dfx_reg;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        data_dfx_reg <= 0;
        //read_arbiter_fifo <= 0;
    end else begin
        case (current_state)
            IDLE: begin
                data_dfx_reg <= 0;
                // if(!empty_arbiter_fifo) begin
                //     read_arbiter_fifo <= 1'b1;
                //     //data_dfx_reg <= data_arbiter_recv;
                // end else begin
                //     read_arbiter_fifo <= 1'b0;
                //     //data_dfx_reg <= 0;
                // end
            end
            READ_DFX_DATA: begin
                //read_arbiter_fifo <= 1'b0;
                data_dfx_reg <= data_dfx_recv;
            end
            WRITE_ARBITER: begin
                //read_arbiter_fifo <= 1'b0;
                data_dfx_reg <= data_dfx_recv;
            end
            default: begin
                //read_arbiter_fifo <= 1'b0;
                data_dfx_reg <= 0;
            end
    endcase
    end
end
always @(*) begin
    case (current_state)
        IDLE: begin
            if(!empty_arbiter_fifo) begin
                read_arbiter_fifo <= 1'b1;
            end else begin
                read_arbiter_fifo <= 1'b0;
            end
        end
        READ_DFX_DATA: begin
            read_arbiter_fifo = 1'b0;
        end
        WRITE_ARBITER: begin
            read_arbiter_fifo = 1'b0;
        end
        default: begin
            read_arbiter_fifo = 1'b0;
        end
endcase
end
// write arbiter interface
// always @(*) begin
//     case (current_state)
//         IDLE: begin
//             arbiter_write_req = 1'b0;
//             router_dst_addr_recv = 0;
//             data_arbiter_recv = 0;
//         end
//         READ_DFX_DATA: begin
//             arbiter_write_req = 1'b1;
//             router_dst_addr_recv = data_dfx_reg[9:0];
//             data_arbiter_recv = data_dfx_reg[1033:10];
//         end
//         WRITE_ARBITER: begin
//             router_dst_addr_recv = data_dfx_reg[9:0];
//             data_arbiter_recv = data_dfx_reg[1033:10];
//             if(arbiter_write_gnt) begin
//                 arbiter_write_req = 1'b0;
//             end else begin
//                 arbiter_write_req = 1'b1;
//             end
//         end
//         default: begin
//             arbiter_write_req = 1'b0;
//             router_dst_addr_recv = 0;
//             data_arbiter_recv = 0;
//         end
//     endcase
// end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        arbiter_write_req <= 0;
        router_dst_addr_recv <= 0;
        data_arbiter_recv <= 0;
    end else begin
        case (current_state)
            IDLE: begin
                arbiter_write_req <= 1'b0;
                router_dst_addr_recv <= 0;
                data_arbiter_recv <= 0;
            end
            READ_DFX_DATA: begin
                arbiter_write_req <= 1'b1;
                router_dst_addr_recv <= data_dfx_reg[9:0];
                data_arbiter_recv <= data_dfx_reg[1033:10];
            end
            WRITE_ARBITER: begin
                router_dst_addr_recv <= data_dfx_reg[9:0];
                data_arbiter_recv <= data_dfx_reg[1033:10];
                if(arbiter_write_gnt) begin
                    arbiter_write_req <= 1'b0;
                end else begin
                    arbiter_write_req <= 1'b1;
                end
            end
            default: begin
                arbiter_write_req <= 1'b0;
                router_dst_addr_recv <= router_dst_addr_recv;
                data_arbiter_recv <= data_arbiter_recv;
            end
        endcase
    end
end
endmodule