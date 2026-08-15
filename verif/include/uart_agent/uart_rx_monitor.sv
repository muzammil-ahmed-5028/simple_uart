class uart_rx_monitor extends uvm_monitor;
    `uvm_component_utils(uart_rx_monitor)

    virtual uart_if vif;
    uart_cfg cfg;

    uvm_analysis_port #(uart_rx_item) rx_observed_port; 

    function new(string name="uart_rx_monitor",uvm_component parent);
        super.new(name,parent);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (vif == null) begin
            `uvm_fatal("NO_UART_VIF","UART Vif not passed from agent to Monitor")
        end
        
        if (cfg == null) begin
            `uvm_fatal("NO_UART_CFG_OBJECT","No uart_cfg object is passed to the Monitor")
        end

        rx_observed_port = new("rx_observed_port",this);
        
    endfunction

    virtual task run_phase(uvm_phase phase);
        
        uart_rx_item    rx_item;
        realtime        bit_period;
        realtime        stop_period;
        bit             has_parity;
        bit             expected_parity_bit;
        
        rx_item = uart_rx_item::type_id::create("rx_item");         

        forever begin

            cfg.get_config(
                bit_period,
                stop_period,
                has_parity        
            );

            rx_item.has_parity = has_parity;

            //-------------------------------------------//
            // 1. Wait for Start                         //
            //-------------------------------------------//
            
            @(negedge vif.rx_i)

            #(bit_period/2);

            //-------------------------------------------//
            // 1.5 Check if Start bit is stable or       //
            // there is noise                            //
            //-------------------------------------------//
            
            if(vif.rx_i == 1'b1) begin
               
                `uvm_warning("UART_MON","Start bit prematurely deasserted, Check if the conection is buggy")
                rx_item.has_start_error = 1'b1;
            
            end

            else begin
                
                rx_item.has_start_error = 1'b0;

                //-------------------------------------------//
                // waiting one full bit period to sample the //
                // value near the middle of each bit period  //
                //-------------------------------------------//                
                
                #(bit_period);
                
                //-------------------------------------------//
                // 2. Start Recieving Data                   //
                //-------------------------------------------//

                for (int i=0; i< cfg.data_packet_length; i++) begin
                    rx_item.rdata[i] = vif.rx_i;
                    #(bit_period);
                end

                //-------------------------------------------//
                // 3. Recive Parity Bit if Configured        //
                //-------------------------------------------//

                if (has_parity) begin
                    
                    cfg.calculate_parity(rx_item.rdata,expected_parity_bit);
                    
                    rx_item.parity_bit = vif.rx_i;
                    
                    //-------------------------------------------//
                    // 3.5 Check expected and recieved parity    //
                    //-------------------------------------------//

                    if (expected_parity_bit != rx_item.parity_bit) begin
                       `uvm_error("UART_MON",$sformatf("Parity Error: Data recieved = %0b: Expected Parity = %0b: Recieved Parity = %0b",rx_item.rdata, expected_parity_bit, rx_item.parity_bit)) 
                        rx_item.has_parity_error = 1'b1;
                    end
                    else rx_item.has_parity_error = 1'b0;
                    
                    #(bit_period);
                end
                //-------------------------------------------//
                // 4. Check for stop bit                     //
                //-------------------------------------------//

                rx_item.stop_bit = vif.rx_i;
                
                if(rx_item.stop_bit == 1'b0) begin

                    `uvm_error("UART_MON","STOP Bit Framing Error. Stop bit 0 when 1 is exptected")
                    rx_item.has_framing_error = 1'b1;
                
                end
                else rx_item.has_framing_error = 1'b0;
                
            end
            rx_observed_port.write(rx_item);
        end
    endtask
endclass