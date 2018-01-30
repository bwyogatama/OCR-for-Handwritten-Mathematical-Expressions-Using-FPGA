//Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2016.4 (win64) Build 1733598 Wed Dec 14 22:35:39 MST 2016
//Date        : Mon Jan 01 16:43:34 2018
//Host        : JhonsonLee running 64-bit major release  (build 9200)
//Command     : generate_target BRAM.bd
//Design      : BRAM
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module BRAM_4
   (BRAM_PORTA_addr,
    BRAM_PORTA_clk,
    BRAM_PORTA_din,
    BRAM_PORTA_dout,
    BRAM_PORTA_en,
    BRAM_PORTA_we,
	BRAM_PORTA_rst,
	BRAM_PORTB_addr,
    BRAM_PORTB_clk,
    BRAM_PORTB_din,
    BRAM_PORTB_dout,
    BRAM_PORTB_en,
    BRAM_PORTB_we,
	BRAM_PORTB_rst
	);
	
  parameter DWIDTH = 32;
  parameter AWIDTH = 10;
	
	
  
  input [AWIDTH-1:0]BRAM_PORTA_addr;
  input BRAM_PORTA_clk;
  input [DWIDTH-1:0]BRAM_PORTA_din;
  output [DWIDTH-1:0]BRAM_PORTA_dout;
  input BRAM_PORTA_en;
  input BRAM_PORTA_we;
  input BRAM_PORTA_rst;

  wire [AWIDTH-1:0]BRAM_PORTA_1_ADDR;
  wire BRAM_PORTA_1_CLK;
  wire [DWIDTH-1:0]BRAM_PORTA_1_DIN;
  wire [DWIDTH-1:0]BRAM_PORTA_1_DOUT;
  wire BRAM_PORTA_1_EN;
  wire [3:0]BRAM_PORTA_1_WE;
  wire BRAM_PORTA_1_RST;

  input [AWIDTH-1:0]BRAM_PORTB_addr;
  input BRAM_PORTB_clk;
  input [DWIDTH-1:0]BRAM_PORTB_din;
  output [DWIDTH-1:0]BRAM_PORTB_dout;
  input BRAM_PORTB_en;
  input [3:0]BRAM_PORTB_we;
  input BRAM_PORTB_rst;

  wire [AWIDTH-1:0]BRAM_PORTB_1_ADDR;
  wire BRAM_PORTB_1_CLK;
  wire [DWIDTH-1:0]BRAM_PORTB_1_DIN;
  wire [DWIDTH-1:0]BRAM_PORTB_1_DOUT;
  wire BRAM_PORTB_1_EN;
  wire [3:0]BRAM_PORTB_1_WE;
  wire BRAM_PORTB_1_RST;
  
  assign BRAM_PORTA_1_ADDR = BRAM_PORTA_addr;
  assign BRAM_PORTA_1_CLK = BRAM_PORTA_clk;
  assign BRAM_PORTA_1_DIN = BRAM_PORTA_din;
  assign BRAM_PORTA_1_EN = BRAM_PORTA_en;
  assign BRAM_PORTA_1_WE = {BRAM_PORTA_we,BRAM_PORTA_we,BRAM_PORTA_we,BRAM_PORTA_we};
  assign BRAM_PORTA_dout = BRAM_PORTA_1_DOUT;
  assign BRAM_PORTA_1_RST = BRAM_PORTA_rst;
  
  assign BRAM_PORTB_1_ADDR = BRAM_PORTB_addr;
  assign BRAM_PORTB_1_CLK = BRAM_PORTB_clk;
  assign BRAM_PORTB_1_DIN = BRAM_PORTB_din;
  assign BRAM_PORTB_1_EN = BRAM_PORTB_en;
  assign BRAM_PORTB_1_WE = BRAM_PORTB_we;
  assign BRAM_PORTB_dout = BRAM_PORTB_1_DOUT;
  assign BRAM_PORTB_1_RST = BRAM_PORTB_rst;
  
  BRAM_blk_mem_4 blk_mem_gen_4
       (.addra(BRAM_PORTA_1_ADDR),
        .clka(BRAM_PORTA_1_CLK),
        .dina(BRAM_PORTA_1_DIN),
        .douta(BRAM_PORTA_1_DOUT),
        .ena(BRAM_PORTA_1_EN),
        .wea(BRAM_PORTA_1_WE),
		.rsta(BRAM_PORTA_1_RST),
		.addrb(BRAM_PORTB_1_ADDR),
        .clkb(BRAM_PORTB_1_CLK),
        .dinb(BRAM_PORTB_1_DIN),
        .doutb(BRAM_PORTB_1_DOUT),
        .enb(BRAM_PORTB_1_EN),
        .web(BRAM_PORTB_1_WE),
		.rstb(BRAM_PORTB_1_RST)
		);
endmodule
