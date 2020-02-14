# Convolution Engine

### Introduction
While reading cuDNN paper they mentioned that implementing convolution as is in hardware requires handling many corner cases. To understand that I started implementing a separable convolution


### Working
On reset, pixels arrive on input bus pix_in_data, similar to OV7670 interface. This data is written to n+(k-1) fifos where n is number of row processors and k is filter size. For 2 processor and a 3x3 filter, there will be 4 fifos. Data will be written in round robin fashion to allow memory parallelism while accessing column data for convolution.

A scheduler assigns work to each row processor along with input fifos and output fifo address. Row processor uses shifting to do math as the gaussian kernel is seperable. 