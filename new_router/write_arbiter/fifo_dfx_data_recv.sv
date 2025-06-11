module fifo_dfx_data_recv (
    input clk,             
    input rst_n,             
    input write_enable,     
    input read_enable,      
    input [1033:0] data_in, 
    output reg [1033:0] data_out,
    output empty            
);
    reg [1033:0] mem [0:3];     
    reg [1:0] write_ptr;        
    reg [1:0] read_ptr;         
    reg [2:0] count;            


    assign empty = (count == 0);        
    wire full = (count == 4);          


    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            write_ptr <= 2'b00;
            read_ptr <= 2'b00;
            count <= 3'b000;
            data_out <= 1034'b0;
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