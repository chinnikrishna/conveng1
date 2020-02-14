`ifndef FIFOGEN
 `define FIFOGEN
 `include "primitives.vh"
module fifo_gen #(parameter BITW = 8,
		  parameter ADDRW = 10)
    (/*AUTOARG*/
    // Outputs
    data_out, fifo_rdy, full, empty,
    // Inputs
    clk, rst, data_in, pop_data, push_data
    );

    localparam FIFO_DEPTH = (1 << FIFO_ADDRW);

    // Globals
    input clk;
    input rst;

    // Input interface
    input [BITW-1:0] data_in;
    input 		  pop_data;
    input 		  push_data;

    // Output Interface
    output [BITW-1:0] data_out;
    output 		   fifo_rdy;
    output 		   full;
    output 		   empty;


    reg [ADDRW-1:0] 	   rd_ptr, wr_ptr;
    reg [ADDRW:0] 	   status;

    // Status
    assign full = (status == (FIFO_DEPTH-1));
    assign empty = (status == 0);
    
    // Write and Read pointer update
    `EN_SYNC_RST_MSFF(wr_ptr, wr_ptr+1'b1, clk, push_data, rst)
    `EN_SYNC_RST_MSFF(rd_ptr, rd_ptr+1'b1, clk, pop_data, rst)

    // Status update
    always @(posedge clk)
      begin
	  if(rst)
	    status <= '0;
	  else
	    begin
		if((pop_data) && (~push_data) && (status != 0))
		  status <= status - 1'b1;
		else if ((~pop_data) && (push_data) && (status!=FIFO_DEPTH))
		  status <= status + 1'b1;
	    end
      end

    // FIFO Memory. Synchronous memory
    reg [BITW-1:0] fifo_mem [FIFO_DEPTH-1:0];
    always @(posedge clk)
      begin
	  if(push_data)
	    begin
		fifo_mem[wr_ptr] <= data_in;
	    end
      end

    assign data_out = fifo_mem[rd_ptr]; // Asynchronous read 

endmodule // fifo_gen
`endif

    
