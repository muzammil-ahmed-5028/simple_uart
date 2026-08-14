class uart_rx_item extends uvm_sequence_item;
    
    `uvm_object_utils(uart_frame_item)

    logic [8:0]    rdata;
    logic          parity_bit;
    logic          stop_bit;

    logic          has_parity;
    logic          has_parity_error;
    logic          has_framing_error;
    logic          has_start_error;

endclass