module reassembly_pkt
#(
    parameter DATA_WIDTH = 1024,
    parameter ADDR_WIDTH = 10,
    parameter DATA_DFX_WIDTH = DATA_WIDTH + ADDR_WIDTH,
    parameter ACK_WIDTH = 1,
    parameter SEQ_NUM_WIDTH = 1,
    parameter DFX_WIDTH = 2,
    parameter PKT_WIDTH = DATA_DFX_WIDTH + ACK_WIDTH + SEQ_NUM_WIDTH*2 + DFX_WIDTH*2,
    parameter ROUTER_WIDTH = 2,
    parameter AURORA_WIDTH = 256,
    parameter NUMBER_FRAG = 5
)(
    input clk,
    input rst_n,
    /////////////fragment recv fifo/////////////////////
    input empty_frag_fifo,
    output reg rd_frag_fifo,
    input [AURORA_WIDTH - 1:0] frag_recv,
    /////////////fifo dfx data/////////////////////
    output reg valid_dfx_data,
    output reg [DATA_DFX_WIDTH - 1:0] data_dfx_recv,
    //////////////receive controller/////////////////////
    output reg valid_pkt_recv,
    output reg type_pkt, // 0: not ack packet, 1: ack packet
    output reg [DFX_WIDTH - 1:0] src_dfx_recv,
    output reg [DFX_WIDTH - 1:0] dst_dfx_recv, //khong quan tam
    output reg [SEQ_NUM_WIDTH - 1:0] pkt_sn_recv,
    output reg [SEQ_NUM_WIDTH - 1:0] pkt_rn_recv
    //input ready_receive_pkt
);
localparam IDLE = 3'b000;
localparam READ_FIFO = 3'b001;
localparam READ_FIFO_DELAY = 3'b010;
localparam REASSEMBLY_PKT = 3'b011;
localparam REASSEMBLY_PKT_DONE = 3'b100;
reg [2:0] current_state;
reg [2:0] next_state;

localparam ROUTER_0 = 2'b00;
localparam ROUTER_1 = 2'b01;
localparam ROUTER_2 = 2'b10;
localparam ROUTER_3 = 2'b11;


always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        current_state <= IDLE;
    end else begin
        current_state <= next_state;    
    end
end
reg ready_receive_pkt = 1;
always @(*) begin
    case(current_state)
        IDLE: begin
            if(!empty_frag_fifo && ready_receive_pkt) begin
                next_state = READ_FIFO;
            end else begin
                next_state = IDLE;
            end
        end
        READ_FIFO: begin
            next_state = READ_FIFO_DELAY;
        end
        READ_FIFO_DELAY: begin
            next_state = REASSEMBLY_PKT;
        end
        REASSEMBLY_PKT: begin
            next_state = REASSEMBLY_PKT_DONE;
        end
        REASSEMBLY_PKT_DONE: begin
            next_state = IDLE;
        end
        default: next_state = IDLE;
    endcase
end

//reg [AURORA_WIDTH - 1:0] frag_recv_reg;
//reg valid_pkt_data_reg;

reg [ROUTER_WIDTH - 1:0] pkt_recv_src_router = 0;
reg [ROUTER_WIDTH - 1:0] pkt_recv_dst_router = 0;
reg [2:0] pkt_recv_frag_num = 0;

always @(*) begin
    pkt_recv_src_router = frag_recv[1:0];
    pkt_recv_dst_router = frag_recv[3:2];
    pkt_recv_frag_num = frag_recv[6:4];
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        rd_frag_fifo <= 1'b0;
    end
    else begin
        case(current_state)
            IDLE: begin
                if(!empty_frag_fifo && ready_receive_pkt) begin
                    rd_frag_fifo <= 1'b1;
                end else begin
                    rd_frag_fifo <= 1'b0;
                end
            end
            READ_FIFO: begin
                rd_frag_fifo <= 1'b0;
            end
            READ_FIFO_DELAY: begin
                rd_frag_fifo <= 1'b0;
            end
            REASSEMBLY_PKT: begin
                rd_frag_fifo <= 1'b0;
            end
            default: begin
                rd_frag_fifo <= 1'b0;
            end
        endcase
    end
end
reg [PKT_WIDTH - 1:0] data_pkt_recv_router_0;
reg [PKT_WIDTH - 1:0] data_pkt_recv_router_1;
reg [PKT_WIDTH - 1:0] data_pkt_recv_router_2;
reg [PKT_WIDTH - 1:0] data_pkt_recv_router_3;
reg valid_pkt_data_reg;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        data_pkt_recv_router_0 <= 0;
        data_pkt_recv_router_1 <= 0;
        data_pkt_recv_router_2 <= 0;
        data_pkt_recv_router_3 <= 0;
    end
    else begin
        case (current_state)
            REASSEMBLY_PKT: begin
                case (pkt_recv_src_router)
                    ROUTER_0: begin
                        if (pkt_recv_frag_num < NUMBER_FRAG - 1) begin
                            data_pkt_recv_router_0[pkt_recv_frag_num*247 +: 247] <= frag_recv[255:9];
                            valid_pkt_data_reg <= 0;
                        end else begin
                            data_pkt_recv_router_0[1040:988] <= frag_recv[61:9];
                            valid_pkt_data_reg <= 1;
                        end
                    end
                    ROUTER_1: begin
                        if (pkt_recv_frag_num < NUMBER_FRAG - 1) begin
                            data_pkt_recv_router_1[pkt_recv_frag_num*247 +: 247] <= frag_recv[255:9];
                            valid_pkt_data_reg <= 0;
                        end else begin
                            data_pkt_recv_router_1[1040:988] <= frag_recv[61:9];
                            valid_pkt_data_reg <= 1;
                        end
                    end
                    ROUTER_2: begin
                        if (pkt_recv_frag_num < NUMBER_FRAG - 1) begin
                            data_pkt_recv_router_2[pkt_recv_frag_num*247 +: 247] <= frag_recv[255:9];
                            valid_pkt_data_reg <= 0;
                        end else begin
                            data_pkt_recv_router_2[1040:988] <= frag_recv[61:9];
                            valid_pkt_data_reg <= 1;
                        end
                    end
                    ROUTER_3: begin
                        if (pkt_recv_frag_num < NUMBER_FRAG - 1) begin
                            data_pkt_recv_router_3[pkt_recv_frag_num*247 +: 247] <= frag_recv[255:9];
                            valid_pkt_data_reg <= 0;
                        end else begin
                            data_pkt_recv_router_3[1040:988] <= frag_recv[61:9];
                            valid_pkt_data_reg <= 1;
                        end
                    end
                    default: begin
                        data_pkt_recv_router_0 <= data_pkt_recv_router_0;
                        data_pkt_recv_router_1 <= data_pkt_recv_router_1;
                        data_pkt_recv_router_2 <= data_pkt_recv_router_2;
                        data_pkt_recv_router_3 <= data_pkt_recv_router_3;
                        valid_pkt_data_reg <= 0;
                    end
                endcase
            end
            default: begin
                data_pkt_recv_router_0 <= data_pkt_recv_router_0;
                data_pkt_recv_router_1 <= data_pkt_recv_router_1;
                data_pkt_recv_router_2 <= data_pkt_recv_router_2;
                data_pkt_recv_router_3 <= data_pkt_recv_router_3;
                valid_pkt_data_reg <= 0;
            end
        endcase
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        valid_dfx_data <= 0;
        data_dfx_recv <= 0;
    end
    else begin
        valid_dfx_data <= valid_pkt_data_reg;
        case (current_state)
            REASSEMBLY_PKT_DONE: begin
                case (pkt_recv_src_router)
                    ROUTER_0: begin
                        if(valid_pkt_data_reg) begin
                            data_dfx_recv <= data_pkt_recv_router_0[1040:7];
                        end else begin
                            data_dfx_recv <= 0;
                        end
                    end
                    ROUTER_1: begin
                        if(valid_pkt_data_reg) begin
                            data_dfx_recv <= data_pkt_recv_router_1[1040:7];
                        end else begin
                            data_dfx_recv <= 0;
                        end
                    end
                    ROUTER_2: begin
                        if(valid_pkt_data_reg) begin
                            data_dfx_recv <= data_pkt_recv_router_2[1040:7];
                        end else begin
                            data_dfx_recv <= 0;
                        end
                    end
                    ROUTER_3: begin
                        if(valid_pkt_data_reg) begin
                            data_dfx_recv <= data_pkt_recv_router_3[1040:7];
                        end else begin
                            data_dfx_recv <= 0;
                        end
                    end
                    default: begin
                        data_dfx_recv <= 0;
                    end
                endcase
            end
            default: begin
                data_dfx_recv <= 0;
            end
        endcase
    end
end

localparam NOT_ACK_PKT = 1'b0;
localparam ACK_PKT = 1'b1;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        valid_pkt_recv <= 0;
        type_pkt <= 0;
        src_dfx_recv <= 0;
        dst_dfx_recv <= 0;
        pkt_sn_recv <= 0;
        pkt_rn_recv <= 0;
    end
    else begin
        case (current_state)
            REASSEMBLY_PKT_DONE: begin
                case (pkt_recv_src_router)
                    ROUTER_0: begin
                        if(valid_pkt_data_reg) begin
                            valid_pkt_recv <= 1;
                            type_pkt <= NOT_ACK_PKT;
                            src_dfx_recv <= data_pkt_recv_router_0[1:0];
                            dst_dfx_recv <= data_pkt_recv_router_0[3:2];
                            pkt_sn_recv <= data_pkt_recv_router_0[4:4];
                            pkt_rn_recv <= data_pkt_recv_router_0[5:5];
                        end else begin
                            valid_pkt_recv <= 0;
                            type_pkt <= 0;
                            src_dfx_recv <= 0;
                            dst_dfx_recv <= 0;
                            pkt_sn_recv <= 0;
                            pkt_rn_recv <= 0;
                        end
                    end
                    ROUTER_1: begin
                        if(valid_pkt_data_reg) begin
                            valid_pkt_recv <= 1;
                            type_pkt <= NOT_ACK_PKT;
                            src_dfx_recv <= data_pkt_recv_router_1[1:0];
                            dst_dfx_recv <= data_pkt_recv_router_1[3:2];
                            pkt_sn_recv <= data_pkt_recv_router_1[4:4];
                            pkt_rn_recv <= data_pkt_recv_router_1[5:5];
                        end else begin
                            valid_pkt_recv <= 0;
                            type_pkt <= 0;
                            src_dfx_recv <= 0;
                            dst_dfx_recv <= 0;
                            pkt_sn_recv <= 0;
                            pkt_rn_recv <= 0;
                        end
                    end
                    ROUTER_2: begin
                        if(valid_pkt_data_reg) begin
                            valid_pkt_recv <= 1;
                            type_pkt <= NOT_ACK_PKT;
                            src_dfx_recv <= data_pkt_recv_router_2[1:0];
                            dst_dfx_recv <= data_pkt_recv_router_2[3:2];
                            pkt_sn_recv <= data_pkt_recv_router_2[4:4];
                            pkt_rn_recv <= data_pkt_recv_router_2[5:5];
                        end else begin
                            valid_pkt_recv <= 0;
                            type_pkt <= 0;
                            src_dfx_recv <= 0;
                            dst_dfx_recv <= 0;
                            pkt_sn_recv <= 0;
                            pkt_rn_recv <= 0;
                        end
                    end
                    ROUTER_3: begin
                        if(valid_pkt_data_reg) begin
                            valid_pkt_recv <= 1;
                            type_pkt <= NOT_ACK_PKT;
                            src_dfx_recv <= data_pkt_recv_router_3[1:0];
                            dst_dfx_recv <= data_pkt_recv_router_3[3:2];
                            pkt_sn_recv <= data_pkt_recv_router_3[4:4];
                            pkt_rn_recv <= data_pkt_recv_router_3[5:5];
                        end else begin
                            valid_pkt_recv <= 0;
                            type_pkt <= 0;
                            src_dfx_recv <= 0;
                            dst_dfx_recv <= 0;
                            pkt_sn_recv <= 0;
                            pkt_rn_recv <= 0;
                        end
                    end
                    default: begin
                        valid_pkt_recv <= 0;
                        type_pkt <= 0;
                        src_dfx_recv <= 0;
                        dst_dfx_recv <= 0;
                        pkt_sn_recv <= 0;
                        pkt_rn_recv <= 0;
                    end
                endcase
            end
            default: begin
                valid_pkt_recv <= 0;
                type_pkt <= 0;
                src_dfx_recv <= 0;
                dst_dfx_recv <= 0;
                pkt_sn_recv <= 0;
                pkt_rn_recv <= 0;
            end
        endcase
    end
end
endmodule