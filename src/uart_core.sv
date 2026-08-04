module uart_core 
import UART_CTRL_REGS_pkg::UART_CTRL_REGS__in_t;
import UART_CTRL_REGS_pkg::UART_CTRL_REGS__out_t;
(
    // Clocks and Resets
    input logic clk,
    input logic arst_n,
    
    // UART Top Interface
    input logic rx_i
    output logic tx_o,

    // UART RIF Interface
    input wire s_apb_psel,
    input wire s_apb_penable,
    input wire s_apb_pwrite,
    input wire [4:0] s_apb_paddr,
    input wire [31:0] s_apb_pwdata,
    output logic s_apb_pready,
    output logic [31:0] s_apb_prdata,
    output logic s_apb_pslverr,

    // Hardware interface not added as pinouts it is  currently not needed
    // Hardware interface used internally in UART
);

UART_CTRL_REGS (
    .clk(clk),
    .rst(arst_n),
    .s_apb_psel(),
    .s_apb_penable(),
    .s_apb_pwrite(),
    .s_apb_paddr(),
    .s_apb_pwdata(),
    .s_apb_pready(),
    .s_apb_prdata(),
    .s_apb_pslverr(),
    .hwif_in(),
    .hwif_out()
);



endmodule