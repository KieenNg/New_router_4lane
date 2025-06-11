module tb_new_router_aurora();
    reg init_clk;
    reg GT_REFCLK_clk_n;
    reg GT_REFCLK_clk_p;
    reg pma_init;
    reg reset_pb;
    wire channel_up;
    wire GT_SERIAL_RX_rxn;
    wire GT_SERIAL_RX_rxp;
    wire GT_SERIAL_TX_txn;
    wire GT_SERIAL_TX_txp;
    
    reg [9:0] router_dst_addr;
    reg [9:0] router_scr_addr;
    reg router_start_req;
    //reg rst_n;
    wire router_done;
    system_wrapper system_wrapper_i(
        .init_clk(init_clk),
        .GT_REFCLK_clk_n(GT_REFCLK_clk_n),
        .GT_REFCLK_clk_p(GT_REFCLK_clk_p),
        .pma_init(pma_init),
        .reset_pb(reset_pb),
        .channel_up(channel_up),
        .GT_SERIAL_RX_rxn(GT_SERIAL_RX_rxn),
        .GT_SERIAL_RX_rxp(GT_SERIAL_RX_rxp),
        .GT_SERIAL_TX_txn(GT_SERIAL_TX_txn),
        .GT_SERIAL_TX_txp(GT_SERIAL_TX_txp),
        
        .router_done(router_done),
        .router_dst_addr(router_dst_addr),
        .router_scr_addr(router_scr_addr),
        .router_start_req(router_start_req)
    );
    parameter CLK_PERIOD = 10;
    parameter GT_CLOCK = 6.4;
    assign GT_SERIAL_RX_rxn = GT_SERIAL_TX_txn;
    assign GT_SERIAL_RX_rxp = GT_SERIAL_TX_txp;
    initial begin
        init_clk = 1;
        forever #(CLK_PERIOD/2) init_clk = ~init_clk;
    end
    
    initial begin 
        GT_REFCLK_clk_n = 0;
        GT_REFCLK_clk_p = 1;
    end
    always begin
       #(GT_CLOCK/2);
        GT_REFCLK_clk_n = ~GT_REFCLK_clk_n;
        GT_REFCLK_clk_p = ~GT_REFCLK_clk_p;
    end 
        initial begin 
//        reset_pb_0 = 0;
//        pma_init_0 = 0;
//        // Wait for clocks to stabilize
//        repeat(10) @(posedge init_clk_0);
        pma_init = 1;
        reset_pb = 1;
        repeat(128) @(posedge init_clk); // Hold for 128 cycles
        pma_init = 0;
        repeat(256) @(posedge init_clk);
        //reset_pb_0 = 1;
        //repeat(200) @(posedge init_clk_0);
        reset_pb = 0;
    end 
    initial begin 
         router_start_req = 0;
         wait (channel_up == 1);
         #(CLK_PERIOD*4);
         router_start_req = 1;
         router_scr_addr = 10'h1;
         router_dst_addr = 10'h5;
         #(CLK_PERIOD*2);
         router_start_req = 0;
         router_scr_addr = 10'h0;
         router_dst_addr = 10'h0;
         #(CLK_PERIOD*300);
         router_start_req = 1;
         router_scr_addr = 10'h0;
         router_dst_addr = 10'h6;
         #(CLK_PERIOD*2);
         router_start_req = 0;
         router_scr_addr = 10'h0;
         router_dst_addr = 10'h0;
         #(CLK_PERIOD*300);
         router_start_req = 1;
         router_scr_addr = 10'h2;
         router_dst_addr = 10'h7;
         #(CLK_PERIOD*2);
         router_start_req = 0;
         router_scr_addr = 10'h0;
         router_dst_addr = 10'h0;
         #(CLK_PERIOD*2000)
         $finish;
     end 
     initial begin
         $monitor("Time=%0t | dest_addr = 0x%h| data_arbiter_recv = 0x%h", 
             $time, tb_new_router_aurora.system_wrapper_i.system_i.arbiter_bram_0.inst.dst_addr, tb_new_router_aurora.system_wrapper_i.system_i.arbiter_bram_0.inst.data_arbiter_recv);
     end
endmodule