/*
 Generates one output pixel from raw pixel.
 Takes 3 clocks. Can be pipelined furthur
 */
`ifndef PIXENG
 `define PIXENG
 `include "primitives.vh"

module pixel_engine #(parameter PIX_BITS = 8,
		      parameter NM = 9) // TODO: Fix this with dynamic K shape
    (/*AUTOARG*/
    // Outputs
    pix_out_data, pix_out_valid,
    // Inputs
    clk, rst, pix_in_data, pix_eng_en
    );

    /*
     For now conv filter is 3x3 gaussian blur 
     1 2 1
     2 4 2 * (1/16)
     1 2 1
     */
    
    // Globals
    input clk;
    input rst;

    // Input pixels
    input [PIX_BITS-1:0] pix_in_data [NM-1:0];
    input 		 pix_eng_en;
    
    // Output pixels
    output [PIX_BITs-1:0] pix_out_data;
    output 		  pix_out_valid;
    
    

    
    reg [PIX_BITS*2-1:0] 	 proc_pix1F [NM-1:0];
    wire [PIX_BITS*2-1:0] 	 proc_pix [NM-1:0];

    // Delay pixel engine enable by 3 clocks to account for pipeline delay
    reg [2:0] 			 pix_eng_enF;
    `SYNC_RST_MSFF(pix_eng_enF[0], pix_eng_en, clk, rst)
    `SYNC_RST_MSFF(pix_eng_enF[1], pix_eng_enF[0], clk, rst)
    `SYNC_RST_MSFF(pix_eng_enF[2], pix_eng_enF[1], clk, rst)
 

    // TODO: Replace with generate with programmable kernel as LUT
    // TODO: Do non seprable convolution case too
    assign proc_pix[0] = pix_data[0];
    assign proc_pix[1] = pix_data[1] << 1;
    assign proc_pix[2] = pix_data[2];
    assign proc_pix[3] = pix_data[3] << 1;
    assign proc_pix[4] = pix_data[4] << 2;
    assign proc_pix[5] = pix_data[5] << 1;
    assign proc_pix[6] = pix_data[6];
    assign proc_pix[7] = pix_data[7] << 1;
    assign proc_pix[8] = pix_data[8];

    `EN_SYNC_RST_MSFF(proc_pix1F, proc_pix, clk, pix_eng_enF[0], rst) // Pipeline register
    
    // TODO: Do multiple stages for addition.
    // TODO: Check if synthesis did an adder tree
    wire [PIX_BITS*2-1:0] 	 proc_pix_add;
    reg [PIX_BITS*2-1:0] 	 proc_pix_add1F;
    
    assign proc_pix_add = proc_pix1F[0] + proc_pix1F[1] + proc_pix1F[2] + proc_pix1F[3] + 
			  proc_pix1F[4] + proc_pix1F[5] + proc_pix1F[6] + proc_pix1F[7] + 
			  proc_pix1F[8] + 4'd8;
    `EN_SYNC_RST_MSFF(proc_pix_add1F, proc_pix_add, clk, pix_eng_enF[1], rst) // Pipeline register

    wire [PIX_BITS-1:0] 	 proc_pix_div;
    reg [PIX_BITS-1:0] 		 proc_pix_div1F;

    // TODO: Fix this for programmable kernel
    assign proc_pix_div = proc_pix_add1F >> 4; // Dividing by 16
    `EN_SYNC_RST_MSFF(proc_pix_div1F, proc_pix_div, clk, pix_eng_enF[2], rst)

    assign pix_out_data = proc_pix_div1F;
    assign pix_out_valid = pix_eng_enF[2];
    
    		       

endmodule // pixel_engine
`endif

    
