module data_controller
#(
    parameter AURORA_DATA_WIDTH = 256,
    parameter ADDR_WIDTH = 10,
    parameter NUMBER_PACKET = 5,
    parameter RECOGNIZE_ROUTER_WIDTH = 2
)(
    input clk,
    input rst_n,
///////////fifo input 0////////////
    input                           empty_input_port_0,
    output reg                      rd_input_port_0,
/////////////fifo input 1////////////
    input               empty_input_port_1,
    output reg          rd_input_port_1, 
/////////////output port 0////////////
    output reg                      we_output_port_0,
/////////////output port 1////////////
    output reg                      we_output_port_1,
////crossbar//////
    input [AURORA_DATA_WIDTH - 1:0]         data_port1_before,
    output reg [AURORA_DATA_WIDTH - 1:0]    data_port1_after,
    output reg [1:0]                        control_crossbar
);
reg [2:0] current_state;
reg [2:0] next_state;
localparam IDLE = 3'b110;
localparam READ_INPUT_0 = 3'b000;
localparam READ_INPUT_1 = 3'b001;
localparam HEADER_MODIFY = 3'b010;
localparam WRITE_OUTPUT_0 = 3'b011;
localparam WRITE_OUTPUT_1 = 3'b100;
localparam WRITE_OUTPUT_01 = 3'b101;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
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
    case(current_state)
        IDLE: begin
            if(empty_input_port_0 == 0) begin
              next_state = READ_INPUT_0;
            end
            else if (empty_input_port_1 == 0) begin
                next_state = READ_INPUT_1;
            end
            else begin
              next_state = IDLE;
            end
        end
        
        READ_INPUT_0: begin
            next_state = WRITE_OUTPUT_1;
        end
        READ_INPUT_1: begin
            next_state = HEADER_MODIFY;
        end
        HEADER_MODIFY: begin
            if(data_port1_before[8:7] > 1) begin
                next_state = WRITE_OUTPUT_01;
            end
            else begin
                next_state = WRITE_OUTPUT_0;
            end
        end
        WRITE_OUTPUT_0: begin
            if(empty_input_port_1 == 0) begin
              next_state = READ_INPUT_1;
            end
            else begin
                next_state = IDLE;
            end
        end
        WRITE_OUTPUT_1: begin
            if(empty_input_port_0 == 0) begin
              next_state = READ_INPUT_0;
            end
            else begin
                next_state = IDLE;
            end
        end
        WRITE_OUTPUT_01: begin
            if(empty_input_port_1 == 0) begin
              next_state = READ_INPUT_1;
            end
            else begin
                next_state = IDLE;
            end
        end
        default: begin
            next_state = IDLE;
        end
    endcase
end
  /***************************************************************
   * Output logic: fifo in 0 interface
   **************************************************************/
always @(*) begin
    case(current_state)
        READ_INPUT_0: begin
            rd_input_port_0 = 1;
        end
        WRITE_OUTPUT_1: begin
            rd_input_port_0 = 0;
        end
        default: begin
            rd_input_port_0 = 0;
        end
    endcase
end
  /***************************************************************
   * Output logic: fifo out 1 interface
   **************************************************************/
always @(*) begin
    case(current_state)
        READ_INPUT_0: begin
            we_output_port_1 = 0;
        end
        WRITE_OUTPUT_1: begin
            we_output_port_1 = 1;
        end
        WRITE_OUTPUT_01: begin
            we_output_port_1 = 1;
        end
        default: begin
            we_output_port_1 = 0;
        end
    endcase
end
  /***************************************************************
   * Output logic: crossbar control 
   **************************************************************/
reg [AURORA_DATA_WIDTH - 1:0] data_port1_before_reg;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        data_port1_before_reg <= 0;
    end
    else begin
        case(current_state)
            READ_INPUT_1: begin
                data_port1_before_reg <= 0;
            end
            HEADER_MODIFY: begin
                if(data_port1_before[8:7] > 1'b1) begin
                    data_port1_before_reg[8:7] <= data_port1_before[8:7] - 1'b1;
                    data_port1_before_reg[63:9] <= data_port1_before[63:9];
                    data_port1_before_reg[6:0] <= data_port1_before[6:0];
                end
                else begin
                    data_port1_before_reg <= data_port1_before;
                end
            end
            default: begin
                data_port1_before_reg <= data_port1_before;
            end
        endcase
    end
end
always @(*) begin
    case(current_state)
        READ_INPUT_1: begin
            control_crossbar = 2'b00;
            data_port1_after = 0;
        end
        HEADER_MODIFY: begin
            control_crossbar = 2'b00;
            data_port1_after = data_port1_before_reg;
        end
        WRITE_OUTPUT_1: begin
            control_crossbar = 2'b01;
            data_port1_after = 0;
        end
        WRITE_OUTPUT_0: begin
            control_crossbar = 2'b10;
            data_port1_after = data_port1_before_reg;
        end
        WRITE_OUTPUT_01: begin
            control_crossbar = 2'b11;
            data_port1_after = data_port1_before_reg;
        end
        default: begin
            control_crossbar = 2'b00;
        end
    endcase
end
  /***************************************************************
   * Output logic: fifo in 1 interface
   **************************************************************/
always @(*) begin
    case(current_state)
        READ_INPUT_1: begin
            rd_input_port_1 = 1;
        end
        HEADER_MODIFY: begin
            rd_input_port_1 = 0;
        end
        WRITE_OUTPUT_0: begin
            rd_input_port_1 = 0;
        end
        WRITE_OUTPUT_01: begin
            rd_input_port_1 = 0;
        end
        default: begin
            rd_input_port_1 = 0;
        end
    endcase
end
  /***************************************************************
   * Output logic: fifo out 0 interface
   **************************************************************/
always @(*) begin
    case(current_state)
        READ_INPUT_1: begin
            we_output_port_0 = 0;
        end
//        HEADER_MODIFY: begin
            
//        end
        WRITE_OUTPUT_0: begin
            we_output_port_0 = 1;
        end
        WRITE_OUTPUT_01: begin
            we_output_port_0 = 1;
        end
        default: begin
            we_output_port_0 = 0;
        end
    endcase
end
endmodule