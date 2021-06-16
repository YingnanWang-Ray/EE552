`timescale 1ns/1ns
import SystemVerilogCSP::*;
`include "svc2rtl.sv"
`E1OFN_M(2,1)
`E1OFN_M(2,2)
`E1OFN_M(2,4)
`E1OFN_M(2,8)
`E1OFN_M(2,16)
module PipelineArbiter_1_1 (interface R1, interface R2,interface O,interface W1);
	logic d;
  always begin
		forever begin
	    wait((R1.status != idle)||(R2.status != idle));
	    if ((R1.status != idle) && (R2.status != idle)) begin
	      if ({$random}%2==0) begin                     // Both ports have tokens: select randomly
			fork
	        R1.Receive(d);  W1.Send(0); O.Send(1);
			join
	      end
	      
	      else  begin
			fork
	        R2.Receive(d);  W1.Send(1); O.Send(1);
			join
	      end
	    end
	    else if (R1.status != idle) begin  // Only R1 has a token
		  fork
	      R1.Receive(d);  W1.Send(0); O.Send(1);
		  join
	      end
	    else begin // Only R2 has a token
		  fork
	      R2.Receive(d);  W1.Send(1); O.Send(1);
		  join
	    end
		end
  end
endmodule

module PipelineArbiter (interface R1, interface R2,interface W1);
	logic d;
  always begin
		forever begin
	    wait((R1.status != idle)||(R2.status != idle));
	    if ((R1.status != idle) && (R2.status != idle)) begin
	      if ({$random}%2==0) begin                     // Both ports have tokens: select randomly
	        R1.Receive(d);  W1.Send(0); 
	      end
	      else  begin
	        R2.Receive(d);  W1.Send(1); 
	      end
	    end
	    else if (R1.status != idle) begin  // Only R1 has a token
	      R1.Receive(d);  W1.Send(0); 
	      end
	    else begin // Only R2 has a token
	      R2.Receive(d);  W1.Send(1); 
	    end
		end
  end
endmodule

module PipelineArbiter_1_2 (interface R1, interface R2,interface O,interface W1);
	logic d;
  always begin
		forever begin
	    wait((R1.status != idle)||(R2.status != idle));
	    if ((R1.status != idle) && (R2.status != idle)) begin
	      if ({$random}%2==0) begin 		  // Both ports have tokens: select randomly
			fork
	        R1.Receive(d);  
			W1.Send(2);
			O.Send(1);
			join
	      end
	      else  begin
			fork
	        R2.Receive(d);  
			W1.Send(3); 
			O.Send(1);
			join
	      end
	    end
	    else if (R1.status != idle) begin		// Only R1 has a token
		  fork
	      R1.Receive(d);  
		  W1.Send(2); 
		  O.Send(1);
		  join
	      end
	    else begin		// Only R2 has a token
		  fork
	      R2.Receive(d);  
		  W1.Send(3); 
		  O.Send(1);
		  join
	    end
		end
  end
endmodule

/*module merge (interface inPort1,interface inPort2,interface controlPort, interface right);
  parameter FL = 2;
  parameter BL = 4;
  parameter WIDTH = 8;
 
  logic [WIDTH-1:0] data;
  logic c;


  always begin
		forever begin
			controlPort.Receive(c);
			if(c==0)
				begin
					inPort1.Receive(data);
					right.Send(data);
				end
			else if(c==1)
				begin
					inPort2.Receive(data);
					right.Send(data);
				end
		end
  end
endmodule
*/
module merge_acc (e1of2_8.In inPort1,e1of2_8.In inPort2,e1of2_1.In controlPort, e1of2_8.Out right);
  parameter FL = 2;
  parameter BL = 4;
  parameter WIDTH = 8;
 
  logic [WIDTH-1:0] data;
  logic c;


  always begin
		forever begin
			controlPort.Receive(c);
			if(c==0)
				begin
					inPort1.Receive(data);
					right.Send(data);
				end
			else if(c==1)
				begin
					inPort2.Receive(data);
					right.Send(data);
				end
		end
  end
endmodule

/*module four_way_merge (interface A_data,interface B_data,interface C_data,interface D_data,interface controlPort, interface out_data);
parameter FL = 2;
  parameter BL = 4;
  parameter WIDTH = 8;
 
  logic [WIDTH-1:0] data;
  logic [1:0] c;


  always begin
		forever begin
			controlPort.Receive(c);
			if(c==0)
				begin
					A_data.Receive(data);
					out_data.Send(data);
				end
			else if(c==1)
				begin
					B_data.Receive(data);
					out_data.Send(data);
				end
			else if(c==2)
				begin
					C_data.Receive(data);
					out_data.Send(data);
				end
			else if(c==3)
				begin
					D_data.Receive(data);
					out_data.Send(data);
				end
		end
  end
endmodule
*/

module four_way_merge_acc (e1of2_8.In A_data,e1of2_8.In B_data,e1of2_8.In C_data,e1of2_8.In D_data,e1of2_2.In controlPort, e1of2_8.Out out_data);
parameter FL = 2;
  parameter BL = 4;
  parameter WIDTH = 8;
 
  logic [WIDTH-1:0] data;
  logic [1:0] c;


  always begin
		forever begin
			controlPort.Receive(c);
			if(c==0)
				begin
					A_data.Receive(data);
					out_data.Send(data);
				end
			else if(c==1)
				begin
					B_data.Receive(data);
					out_data.Send(data);
				end
			else if(c==2)
				begin
					C_data.Receive(data);
					out_data.Send(data);
				end
			else if(c==3)
				begin
					D_data.Receive(data);
					out_data.Send(data);
				end
		end
  end
endmodule

/*module four_way_ArbiterMerge (interface A_req,interface B_req,interface C_req,interface D_req ,interface A_data, interface B_data,interface C_data,
							  interface D_data,interface out_data);
  parameter FL = 2;
  parameter BL = 4;
  parameter WIDTH = 13;
  Channel #(.WIDTH(2),.hsProtocol(P4PhaseBD)) W ();

 
  
  four_way_Arbiter #(.FL(FL), .BL(BL)) four_AR(A_req,B_req,C_req,D_req,W);
  four_way_merge   #(.WIDTH(WIDTH), .FL(FL), .BL(BL)) M1(A_data, B_data,C_data,D_data,W,out_data);

  
endmodule
*/

module four_way_ArbiterMerge_acc (interface A_req,interface B_req,interface C_req,interface D_req ,e1of2_16.In  A_data, e1of2_16.In  B_data,e1of2_16.In  C_data,
							  e1of2_16.In  D_data,e1of2_16.Out  out_data);
  parameter FL = 2;
  parameter BL = 4;
  parameter WIDTH = 13;
  Channel #(.WIDTH(2),.hsProtocol(P4PhaseBD)) W ();

 
  
  four_way_Arbiter #(.FL(FL), .BL(BL)) four_AR(A_req,B_req,C_req,D_req,W);
  four_way_merge_acc #(.WIDTH(WIDTH), .FL(FL), .BL(BL)) M1(A_data, B_data,C_data,D_data,W,out_data);

  
endmodule

module four_way_Arbiter (interface A_req,interface B_req,interface C_req, interface D_req,interface control);
  parameter WIDTH = 13;
  parameter FL = 2;
  parameter BL = 4;
  e1ofN_M #(.N(2), .M(2)) W_level11();
  e1ofN_M #(.N(2), .M(2)) W_level12();
  e1ofN_M #(.N(2), .M(2)) W_level2();
  e1ofN_M #(.N(2), .M(2)) O11();
  e1ofN_M #(.N(2), .M(2)) O12();


  PipelineArbiter_1_1 P1(.R1(A_req), .R2(B_req), .O(O11), .W1(W_level11));
  PipelineArbiter_1_2 P2(.R1(C_req), .R2(D_req), .O(O12), .W1(W_level12));
  PipelineArbiter P3(.R1(O11), .R2(O12), .W1(W_level21));
  merge_acc #(.WIDTH(2), .FL(FL), .BL(BL)) M_AR(W_level11,W_level12,W_level2,control);
endmodule
