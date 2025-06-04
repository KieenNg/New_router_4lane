module crossbar
#(
    parameter AURORA_DATA_WIDTH = 256
)(
    input [1:0]                            control_crossbar,
    input [AURORA_DATA_WIDTH - 1:0]        data_in_port_0,
    input [AURORA_DATA_WIDTH - 1:0]        data_in_port_1,
    input [AURORA_DATA_WIDTH - 1:0]        data_port_1_after,
    output [AURORA_DATA_WIDTH - 1:0]       data_port_1_before,
    output reg [AURORA_DATA_WIDTH - 1:0]       data_out_port_0,
    output reg [AURORA_DATA_WIDTH - 1:0]       data_out_port_1
);
assign data_port_1_before = data_in_port_1;
always @(*) begin
    case(control_crossbar)
        2'b01: begin
            data_out_port_0 = 0;
            data_out_port_1 = data_in_port_0;
        end
        2'b10: begin
            data_out_port_0 = data_port_1_after;
            data_out_port_1 = 0;
        end
        2'b11: begin
            data_out_port_0 = data_port_1_after;
            data_out_port_1 = data_port_1_after;
        end
        default: begin
            data_out_port_0 = 0;
            data_out_port_1 = 0;
        end
    endcase
end
endmodule