module mb_block (
    input clk_100MHz,
    input [0:0] gpio_usb_int_tri_i,
    output [31:0] gpio_usb_keycode_0_tri_o,
    output [31:0] gpio_usb_keycode_1_tri_o,
    output [0:0] gpio_usb_rst_tri_o,
    input reset_rtl_0,
    input uart_rtl_0_rxd,
    output uart_rtl_0_txd,
    input usb_spi_miso,
    output usb_spi_mosi,
    output usb_spi_sclk,
    output [0:0] usb_spi_ss
);

    // Simulation keycode register
    reg [7:0] sim_keycode;
    assign gpio_usb_keycode_0_tri_o = {24'h00, sim_keycode};
    assign gpio_usb_keycode_1_tri_o = 32'h00000000;
    assign gpio_usb_rst_tri_o = 1'b0;
    assign uart_rtl_0_txd = 1'b0;
    assign usb_spi_mosi = 1'b0;
    assign usb_spi_sclk = 1'b0;
    assign usb_spi_ss   = 1'b0;

endmodule
