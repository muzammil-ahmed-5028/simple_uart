interface uart_if;
    
    logic rx_i;
    logic tx_o;

endinterface

package uart_verif_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    
    typedef enum {
        PARITY_NONE,
        PARITY_ODD,
        PARITY_EVEN
    } uart_parity_e;

    typedef enum {
        STOP_PERIOD_1X,
        STOP_PERIOD_1_5X,
        STOP_PERIOD_2X
    } uart_stop_length_e;

    `include "uart_seq_item.sv"
    `include "uart_rx_item.sv"
    `include "uart_sequencer.sv"
    `include "uart_cfg.sv"
    `include "uart_tx_driver.sv"
    `include "uart_rx_monitor.sv"
    `include "uart_agent.sv"
    
endpackage