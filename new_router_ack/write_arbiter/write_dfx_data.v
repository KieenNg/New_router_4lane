module write_vrf
#(
    parameter DATA_WIDTH = 1024,
    parameter ADDR_WIDTH = 10,
    parameter DATA_DFX_WIDTH = DATA_WIDTH + ADDR_WIDTH
)(
    input clk,
    input rst_n,
    /////////////arbiter data fifo/////////////////////
    input                        empty_dfx_fifo,
    input [DATA_DFX_WIDTH - 1:0] data_dfx_recv,
    output reg                 read_dfx_fifo,
    ////////////////////arbiter///////////////////////////
    input                           write_gnt,
    output reg                      write_req,
    output reg [ADDR_WIDTH - 1:0]   vrf_dst_addr,
    output reg [DATA_WIDTH - 1:0]   data_recv
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
            if(!empty_dfx_fifo)begin
                next_state = READ_DFX_DATA;
            end else begin
                next_state = IDLE;
            end
        end
        READ_DFX_DATA: begin
            next_state = WRITE_ARBITER;
        end
        WRITE_ARBITER: begin
            if(write_gnt) begin
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
        //read_dfx_fifo <= 0;
    end else begin
        case (current_state)
            IDLE: begin
                data_dfx_reg <= 0;
                // if(!empty_dfx_fifo) begin
                //     read_dfx_fifo <= 1'b1;
                //     //data_dfx_reg <= data_recv;
                // end else begin
                //     read_dfx_fifo <= 1'b0;
                //     //data_dfx_reg <= 0;
                // end
            end
            READ_DFX_DATA: begin
                //read_dfx_fifo <= 1'b0;
                data_dfx_reg <= data_dfx_recv;
            end
            WRITE_ARBITER: begin
                //read_dfx_fifo <= 1'b0;
                data_dfx_reg <= data_dfx_recv;
            end
            default: begin
                //read_dfx_fifo <= 1'b0;
                data_dfx_reg <= 0;
            end
    endcase
    end
end
always @(*) begin
    case (current_state)
        IDLE: begin
            if(!empty_dfx_fifo) begin
                read_dfx_fifo <= 1'b1;
            end else begin
                read_dfx_fifo <= 1'b0;
            end
        end
        READ_DFX_DATA: begin
            read_dfx_fifo = 1'b0;
        end
        WRITE_ARBITER: begin
            read_dfx_fifo = 1'b0;
        end
        default: begin
            read_dfx_fifo = 1'b0;
        end
endcase
end
// write arbiter interface
// always @(*) begin
//     case (current_state)
//         IDLE: begin
//             write_req = 1'b0;
//             vrf_dst_addr = 0;
//             data_recv = 0;
//         end
//         READ_DFX_DATA: begin
//             write_req = 1'b1;
//             vrf_dst_addr = data_dfx_reg[9:0];
//             data_recv = data_dfx_reg[1033:10];
//         end
//         WRITE_ARBITER: begin
//             vrf_dst_addr = data_dfx_reg[9:0];
//             data_recv = data_dfx_reg[1033:10];
//             if(write_gnt) begin
//                 write_req = 1'b0;
//             end else begin
//                 write_req = 1'b1;
//             end
//         end
//         default: begin
//             write_req = 1'b0;
//             vrf_dst_addr = 0;
//             data_recv = 0;
//         end
//     endcase
// end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        write_req <= 0;
        vrf_dst_addr <= 0;
        data_recv <= 0;
    end else begin
        case (current_state)
            IDLE: begin
                write_req <= 1'b0;
                vrf_dst_addr <= 0;
                data_recv <= 0;
            end
            READ_DFX_DATA: begin
                write_req <= 1'b1;
                vrf_dst_addr <= data_dfx_reg[9:0];
                data_recv <= data_dfx_reg[1033:10];
            end
            WRITE_ARBITER: begin
                vrf_dst_addr <= data_dfx_reg[9:0];
                data_recv <= data_dfx_reg[1033:10];
                if(write_gnt) begin
                    write_req <= 1'b0;
                end else begin
                    write_req <= 1'b1;
                end
            end
            default: begin
                write_req <= 1'b0;
                vrf_dst_addr <= vrf_dst_addr;
                data_recv <= data_recv;
            end
        endcase
    end
end
endmodule