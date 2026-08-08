interface uart_if;
    
    logic rx_i;
    logic tx_o;

endinterface

package uart_verif_pkg;

    typedef enum {
        PARITY_NONE,
        PARITY_ODD,
        PARITY_EVEN
    } uart_parity_e;

    typedef enum {
        1_STOP_PERIOD,
        1_5_STOP_PERIOD,
        2_STOP_PERIOD,
    } uart_stop_length_e;

    `include "uart_seq_item.sv"
    `include "uart_base_driver.sv"
    `include "uart_tx_driver.sv"
    `include "uart_rx_driver.sv"
    
    `include "uart_tx_monitor.sv"
    `include "uart_rx_monitor.sv"

endpackage