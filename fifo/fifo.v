module fifo
#(
	parameter DATA_WIDTH = 256,
    parameter DEPTH_WIDTH = 128
)(
    input clk,             
    input rst_n,             
    input write_enable,     
    input read_enable,      
    input [DATA_WIDTH - 1:0] data_in, 
    output reg [DATA_WIDTH- 1:0] data_out,
    output empty            
);
    reg [DATA_WIDTH - 1:0] mem [0:DEPTH_WIDTH - 1];     
    reg [$clog2(DEPTH_WIDTH) - 1:0] write_ptr;        
    reg [$clog2(DEPTH_WIDTH) - 1:0] read_ptr;         
    reg [$clog2(DEPTH_WIDTH) - 1:0] count;            


    assign empty = (count == 0);        
    wire full = (count == DEPTH_WIDTH);          


    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            write_ptr <= 7'b0;
            read_ptr <= 7'b0;
            count <= 7'b0;
            data_out <= 256'b0;
        end
        else begin
            // Write operation
            if (write_enable && !full) begin
                mem[write_ptr] <= data_in;  
                write_ptr <= write_ptr + 1;
                count <= count + 1;         
            end

            // Read operation
            if (read_enable && !empty) begin
                data_out <= mem[read_ptr];  
                read_ptr <= read_ptr + 1;   
                count <= count - 1;        
            end

            
            if (write_enable && read_enable && !full && !empty) begin
                mem[write_ptr] <= data_in; 
                data_out <= mem[read_ptr];  
                write_ptr <= write_ptr + 1;
                read_ptr <= read_ptr + 1;
                count <= count; 
            end
        end
    end

endmodule
