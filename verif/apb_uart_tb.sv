module apb_uart_tb;

    bit clk = 1'b1;
    bit arst_n;

    apb_intf apb_if ();
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

    forever begin
        #(5 * 1ns) clk = ~clk;        
    end

    uart_core dut( 
        .clk            (clk),
        .arst_n         (arst_n),
        .rx_i           (uart_if.rx_i),
        .tx_o           (uart_if.tx_o),
        .s_apb_psel     (apb_if.PSEL),
        .s_apb_penable  (apb_if.PENABLE),
        .s_apb_pwrite   (apb_if.PWRITE),
        .s_apb_paddr    (apb_if.PADDR),
        .s_apb_pwdata   (apb_if.PWDATA),
        .s_apb_pready   (apb_if.PREADY),
        .s_apb_prdata   (apb_if.PRDATA),
        .s_apb_pslverr  (apb_if.PSLVERR),
        .irq_rx_o,
        .irq_tx_o   
    );

    initial begin
        assert_reset();
    end

endmodule