/* Top Module for synthesis*/
`ifndef TOP
`define TOP
`include "primitives.vh"

  module top #(
	       parameter XMAX_BITS = 10,
	       parameter YMAX_BITS = 10,
	       parameter PIX_BITS = 8)
    (/*AUTOARG*/
    // Outputs
    pix_in_rdy, pix_out_data, pix_out_valid, pix_out_lastx,
    pix_out_lasty, done,
    // Inputs
    clk, rst, img_width, img_height, pix_in_data, pix_in_valid,
    pix_out_rdy
    );

    // Globals
    input clk;
    input rst;

    // Image dimensions
    input [XMAX_BITS-1:0] img_width;
    input [YMAX_BITS-1:0] img_height;

    // Input Pixel Data
    input [PIX_BITS-1:0]  pix_in_data;
    input 		  pix_in_valid;
    output 		  pix_in_rdy;    // Backpressure to producer

    // Output Pixel Data
    output [PIX_BITS-1:0] pix_out_data;
    output 		  pix_out_valid;
    input 		  pix_out_rdy;    // Backpressure from consumer

    output 		  pix_out_lastx;
    output 		  pix_out_lasty;
    output 		  done;

    // Counters to track row and column
    reg [XMAX_BITS-1:0]   row_cnt;
    reg [YMAX_BITS-1:0]   col_cnt;
    wire 		  row_cnt_rst, col_cnt_rst;
    wire 		  row_cnt_en, col_cnt_en;

    assign col_cnt_rst = ((col_cnt == img_width) || rst);
    assign col_cnt_en = pix_in_valid;

    assign row_cnt_en = ((row_cnt <= img_height) && col_cnt_rst);
    assign row_cnt_rst = rst;
    
    `EN_SYNC_RST_MSFF(col_cnt, col_cnt+1'b1, clk, col_cnt_en, col_cnt_rst)
    `EN_SYNC_RST_MSFF(row_cnt, row_cnt+1'b1, clk, row_cnt_en, row_cnt_rst)
    assign pix_in_rdy=1'b1;
    
    

endmodule // top
`endif



    
    
	   
	   
	   

