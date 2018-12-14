
`timescale 1 ns / 1 ps

	module OCR_v2_0 #
	(
		// Users to add parameters here
		DWIDTH = 32,
		IWIDTH = 64,
		AWIDTH = 13,
		CLASS  = 16,
		// User parameters ends
		// Do not modify the parameters beyond this line


		// Parameters of Axi Slave Bus Interface S00_AXI
		parameter integer C_S00_AXI_DATA_WIDTH	= 32,
		parameter integer C_S00_AXI_ADDR_WIDTH	= 5
	)
	(
		// Users to add ports here
		output wire interrupt,
		
		output wire LED_1,
		
		output wire LED_2,
		
		output wire LED_3,
		
		input wire finish, //Pin for development only
		output state, //Pin for development only
		
		/*
		input wire [31:0] addra,
		input wire clka,
		input wire [31:0] dina,
		output wire [DWIDTH-1:0] douta,
		input wire ena,
		input wire rsta,
		input wire [3:0] wea,*/
		
		
		// User ports ends
		// Do not modify the ports beyond this line


		// Ports of Axi Slave Bus Interface S00_AXI
		input wire  s00_axi_aclk,
		input wire  s00_axi_aresetn,
		input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr,
		input wire [2 : 0] s00_axi_awprot,
		input wire  s00_axi_awvalid,
		output wire  s00_axi_awready,
		input wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata,
		input wire [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb,
		input wire  s00_axi_wvalid,
		output wire  s00_axi_wready,
		output wire [1 : 0] s00_axi_bresp,
		output wire  s00_axi_bvalid,
		input wire  s00_axi_bready,
		input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr,
		input wire [2 : 0] s00_axi_arprot,
		input wire  s00_axi_arvalid,
		output wire  s00_axi_arready,
		output wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata,
		output wire [1 : 0] s00_axi_rresp,
		output wire  s00_axi_rvalid,
		input wire  s00_axi_rready
	);
	
	//wire [0:0] finish;
	wire [CLASS-1:0] idef_result;
	wire [DWIDTH-1:0] cost_function;
	wire [0:0] training;
	wire [0:0] stop;
	wire [1:0] command;
	wire [63:0] idef_image;
	wire [15:0] dataset_length;
// Instantiation of Axi Bus Interface S00_AXI
	OCR_v2_0_S00_AXI # ( 
		.C_S_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH),
		.DWIDTH(DWIDTH),
		.IWIDTH(IWIDTH),
		.AWIDTH(AWIDTH),
		.CLASS(CLASS)
	) OCR_v2_0_S00_AXI_inst (
		
		.finish(finish),
		.idef_result(idef_result),
		.cost_function(cost_function),
		.interrupt(interrupt),
		.training(training),
		.command(command),
		.idef_image(idef_image),
		.dataset_length(dataset_length),
		.stop(stop),
		.LED_1(LED_1),
		.LED_2(LED_2),
		
		
		.S_AXI_ACLK(s00_axi_aclk),
		.S_AXI_ARESETN(s00_axi_aresetn),
		.S_AXI_AWADDR(s00_axi_awaddr),
		.S_AXI_AWPROT(s00_axi_awprot),
		.S_AXI_AWVALID(s00_axi_awvalid),
		.S_AXI_AWREADY(s00_axi_awready),
		.S_AXI_WDATA(s00_axi_wdata),
		.S_AXI_WSTRB(s00_axi_wstrb),
		.S_AXI_WVALID(s00_axi_wvalid),
		.S_AXI_WREADY(s00_axi_wready),
		.S_AXI_BRESP(s00_axi_bresp),
		.S_AXI_BVALID(s00_axi_bvalid),
		.S_AXI_BREADY(s00_axi_bready),
		.S_AXI_ARADDR(s00_axi_araddr),
		.S_AXI_ARPROT(s00_axi_arprot),
		.S_AXI_ARVALID(s00_axi_arvalid),
		.S_AXI_ARREADY(s00_axi_arready),
		.S_AXI_RDATA(s00_axi_rdata),
		.S_AXI_RRESP(s00_axi_rresp),
		.S_AXI_RVALID(s00_axi_rvalid),
		.S_AXI_RREADY(s00_axi_rready)
	);

	// Add user logic here

	wire [0:0] arm;
	
	
	FSM_mst MASTER_CU (
		.clk(s00_axi_aclk),
		.reset(~s00_axi_aresetn),
		.training(training),
		.stop(stop),
		.interrupt(interrupt),
		.command(command),
		.arm(arm),
		.state(state));
	
	assign idef_result = 16'b0000000000000001;
	assign cost_function = 32'b00000000000000000000000000000010;
	assign LED_3 = finish;
	/*
	feedforwardnet NN_core
	  (.clk(s00_axi_aclk),
	   .reset(~s00_axi_aresetn),
	   .image(idef_image),
	   .arm(arm),
	   .train(training),
	   .finish(finish),
	   .result(idef_result),
	   .stop(stop),
	   
	   .iteration_cplt(dataset_length),
	   .cost(cost_function),
	   
	   .PS_addr(addra),
	   .PS_clk(clka),
	   .PS_din(dina),
	   .PS_dout(douta),
	   .PS_en(ena),
       .PS_rst(~rsta),
       .PS_we(wea));*/
	
	/*
	character_recognition NN_Core (
		.clk(s00_axi_aclk), 
		.reset(~s00_axi_aresetn), 
		.arm(arm),
		.idef_image(idef_image),
		.dataset_length(dataset_length),
		.training(training),
		.dataset_data(dataset_data),
		.result(idef_result),
		.finish(idef_finish),
		.dataset_addr(dataset_addr),
		.cost_function(cost_function),
		.iteration_finish(iteration_finish),
		.en_dataset_ROM(en_dataset_ROM),
		
		.PS_addr(addra),
		.PS_clk(clka),
		.PS_din(dina),
		.PS_dout(douta),
		.PS_en(ena),
		.PS_rst(rsta),
		.PS_we(wea)
		);*/

	// User logic ends

endmodule
