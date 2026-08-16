class uart_tx_custom_sequence extends uvm_sequence #(uart_seq_item);
    `uvm_object_utils(uart_tx_custom_sequence)
    
    bit [8:0] data;
    bit inject_parity_error;
    bit inject_framing_error;

    function new(string name="uart_tx_custom_seq");
        super.new(name);
    endfunction

    virtual task body();
        
        uart_seq_item txn;
        txn = uart_seq_item::type_id::create("txn");

        start_item(txn);
        
        txn.data = data;
        txn.inject_parity_error = inject_parity_error;
        txn.inject_framing_error = inject_framing_error;
        
        finish_item(txn);

    endtask
endclass