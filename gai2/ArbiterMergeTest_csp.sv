`timescale 1ns/1ns
`include "/home/scf-12/ee552/proteus/pdk/proteus/svc2rtl.sv"
`E1OFN_M(2,1)
`E1OFN_M(2,16)


module ArbiterMergeTest (e1of2_16 inPort1,e1of2_16 inPort2,e1of2_1 controlPort, e1of2_16 right);
  logic [inPort1.W-1:0] data;
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