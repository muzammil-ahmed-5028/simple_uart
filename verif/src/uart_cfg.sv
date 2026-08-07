class uart_cfg extends uvm_component;
    `uvm_component_utils(uart_cfg)

    rand uart_parity_e               parity;
    rand uart_stop_length_e          stop_length;
    rand int                         data_packet_length;
    rand int unsigned                baud_rate;
    
    constraint c_data_packet_length {
        soft data_packet_lenght inside {[5:9]};
    }
    
endclass