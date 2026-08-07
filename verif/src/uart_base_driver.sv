class uart_base_driver extends uvm_driver#(uart_seq_item);
    `uvm_component_utils(uart_base_driver)

    virtual uart_if vif;
    uart_cfg cfg;

    function new(string name="uart_base_driver",uvm_component parent);
        super.new(name,parent)
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(!uvm_config_db#(virtual uart_if)::get(this,"","uart_if",vif)) begin
            `uvm_fatal("NO_UART_VIF","Unable to get uart virtual interface")
        end
        
        if (cfg == null) begin
            `uvm_fatal("NO_UART_CFG_OBJECT","No uart_cfg object is passed to the driver")
        end

    endfunction

    virtual function get_drv_config(
        output realtime bit_period,
        output realtime stop_period,
        output int      data_packet_length 
    );
        
        bit_period = 1s/cfg.baud_rate;

        case(cfg.stop_length)
            1_STOP_PERIOD   : stop_period = bit_period;
            1_5_STOP_PERIOD : stop_period = bit_period * 1.5;
            2_STOP_PERIOD   : stop_period = bit_period * 2;
            default         : stop_period = bit_period;
        endcase

        data_packet_length = cfg.data_packet_length;

    endfunction

    virtual function calculate_parity(
        input logic [8:0] data,
        input int         data_packet_length,
        output bit        parity_bit,
        output bit        txn_has_parity
    )
        int total_high_bits;
        bit is_odd;

        if (cfg.parity == PARITY_NONE) begin
            parity_bit      = '0;
            txn_has_parity  = '0;
        end
        else begin
            txn_has_parity = '1;

            for (int i=0; i< data_packet_length; i++) begin
                if (data[i] == 1'b1) begin
                    total_high_bits++;
                end
            end

            is_odd = total_high_bits % 2; 
            
            case(cfg.parity)
                PARITY_ODD  : parity_bit = (is_odd) ?  1'b0 : 1'b1;
                PARITY_EVEN : parity_bit = (is_odd) ?  1'b1 : 1'b0;
            endcase

        end
    endfunction

endclass