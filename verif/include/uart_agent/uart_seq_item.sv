class uart_seq_item extends uvm_sequence_item;
    `uvm_object_utils(uart_seq_item)

    function new(string name="uart_seq_item");
        super.new(name);
    endfunction
    
    rand logic [8:0]    data;
    rand logic          inject_parity_error;
    rand logic          inject_framing_error;
              
endclass