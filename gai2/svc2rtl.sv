//-------------------------------------------------------------------------------------------------
//Written by Arash Saifhashemi
//University of Southern California
//Fall 2011
//Version 1.00
//  Change Log:
//    -March 21, 2012: Separated interface variables for synthesis and simulation.
//-------------------------------------------------------------------------------------------------



`ifndef __E1OFN_M__
	`define  __E1OFN_M__
  `timescale 1ps/1ps
  typedef struct packed {
    logic [1:0] d;
  } SDualRail;
  
  typedef struct packed {
    logic       e;
  } SEnable;
  
  //DataGenerator2 command parameters
  `define CMD_RANDOM          0
  `define CMD_ROUND_ROBIN     1
  `define CMD_DATA            2
  `define CMD_RND_UNIFORM     3
  `define CMD_RND_BINARY_PROB 4
  

   
  //Name of enable and bits variables
  `define ENABLE  bitse
  `define BITS    bitsd
  
/*	`define E1OFN_M(NVal,MVal) interface e1of``NVal``_``MVal;	\
			parameter M = MVal;	\
			parameter N = NVal; \
			parameter Type = 0; \
      parameter W = $clog2(N)*M ; \
      wire SDualRail `BITS [M-1:0] ; \
      wire SEnable `ENABLE [M-1:0] ; \
			modport Out (output `BITS, input `ENABLE, import Send); \
      modport In  (input `BITS, output `ENABLE, import Receive); \
			task Send (input logic[$clog2 (N) * M-1:0] data);	\
			endtask	\
			task Receive (output logic[$clog2 (N) * M-1:0] data);	\
			endtask	\
		endinterface
   `define e1ofN_M(NVal,MVal) e1of``NVal``_``MVal
*/   

    //Common channels
    /*
    `E1OFN_M(2,1)
    `E1OFN_M(2,2)
    `E1OFN_M(2,4)
    `E1OFN_M(2,8)
    `E1OFN_M(2,16)
    `E1OFN_M(2,20)
    `E1OFN_M(2,32)
    `E1OFN_M(2,40)
    `E1OFN_M(2,48)
    `E1OFN_M(2,64)
    `E1OFN_M(2,80)
    `E1OFN_M(2,96)
    `E1OFN_M(2,128)
    */
`endif

`ifndef __BUNDLED_DATA__
	`define  __BUNDLED_DATA__
  `timescale 1ps/1ps
   
  //Name of enable and bits variables
  `define ACK a 
  `define REQ r
  `define DATA d
  
	`define BUNDLED_DATA(WVal) interface bundled_data_``WVal;	\
			parameter M = WVal;	\
                        parameter N = 2 ;   \
			parameter Type = 1;  \
      wire [M-1:0] `DATA; \
      wire  `REQ; \
      wire  `ACK; \
			modport Out (output `DATA, input `ACK, output `REQ, import Send); \
      modport In  (input `DATA, output `ACK, input `REQ, import Receive); \
			task Send (input logic[M-1:0] data);	\
			endtask	\
			task Receive (output logic[M-1:0] data);	\
			endtask	\
		endinterface
   //`define bundled_data(WVal) bundled_data_``WVal

`endif
	

 
 
//`ifndef __E1OFN_M__
        `define  __E1OFN_M__
        `define E1OFN_M(NVal,MVal) interface e1of``NVal``_``MVal;       \
                        `define __e1of``NVal``_``MVal \
                        parameter M = MVal;     \
                        parameter N = NVal; \
                        parameter W = $clog2(N)*M ; \
                        `ifdef __e1of``NVal``_1 \
                                wire e; \
                        `else \
                                wire [M-1:0] e; \
                        `endif \
                        wire [N-1:0][M-1:0] d; \
                        modport Out (output d, input e , import Send);  \
                        modport In  (input d, output e , import Receive);       \
                        task Send (input logic[$clog2 (N) * M-1:0] data);       \
                        endtask \
                        task Receive (output logic[$clog2 (N) * M-1:0] data);   \
                        endtask \
                endinterface
 

