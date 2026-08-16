module apb_uart_tb;
    import uvm_pkg::*;
    import apb_uart_test_pkg::*;

    bit clk = 1'b1;
    bit arst_n;

    apb_intf #(32,32) apb_if ();
    uart_if uart_if ();

    assign apb_if.PCLK      = clk;
    assign apb_if.PRESETN   = arst_n;
    
    task assert_reset();
        // Start simulation with reset deasserted
        arst_n <= 1'b1;
        #(50 * 1ns);
    
        // assert Reset
        arst_n <= 1'b0;
        #(50 * 1ns);
    
        // Deassert Reset
        arst_n <= 1'b1;
    endtask

    task start_clock();
        fork
            forever begin
            
                #(5 * 1ns) clk = ~clk;
            end
        join_none
    endtask

    

    uart_core dut( 
        .clk            (clk),
        .arst_n         (arst_n),
        .rx_i           (uart_if.tx_o),
        .tx_o           (uart_if.rx_i),
        .s_apb_psel     (apb_if.PSEL),
        .s_apb_penable  (apb_if.PENABLE),
        .s_apb_pwrite   (apb_if.PWRITE),
        .s_apb_paddr    (apb_if.PADDR),
        .s_apb_pwdata   (apb_if.PWDATA),
        .s_apb_pready   (apb_if.PREADY),
        .s_apb_prdata   (apb_if.PRDATA),
        .s_apb_pslverr  (apb_if.PSLVERR),
        .irq_rx_o(),
        .irq_tx_o()   
    );

    initial begin
        assert_reset();
        start_clock();
    end
    
    initial begin
        $dumpfile("apb_uart_tb.fst");
        $dumpvars(0,apb_uart_tb);    
    end

    initial begin
        uvm_config_db#(virtual apb_intf#(32,32))::set(null,"uvm_test_top.env.apb_agent","apb_intf",apb_if);
        uvm_config_db#(virtual uart_if)::set(null,"uvm_test_top.env.uart_agent_inst","uart_vif",uart_if);
        run_test();    
    end

endmodule
