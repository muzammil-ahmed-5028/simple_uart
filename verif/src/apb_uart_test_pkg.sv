package apb_uart_test_pkg;
    
    import uart_vip_pkg::*;
    import apb_vip_pkg::*;
    import uvm_pkg::*;
    
    `include "uvm_macros.svh"
    `include "env/apb_uart_env.sv"
    `include "tests/apb_uart_base_test.sv"
    `include "tests/apb_uart_rif_smoke_test.sv"
    `include "tests/apb_uart_tx_smoke_test.sv"
endpackage
