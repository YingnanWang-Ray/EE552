`timescale 1ns/1ns
import SystemVerilogCSP::*;


module data_generator (interface send);
  parameter WIDTH = 9;
  parameter addrWIDTH=4;
  parameter FL = 0; //ideal environment
  parameter ADDR=0;
  parameter n=WIDTH/8;
  parameter x_addr;
  parameter y_addr;
  logic [WIDTH-1:0] Value=0;
  logic [WIDTH-1:0] SendValue=0;
  //logic [addrWIDTH/2-1:0] addr=ADDR,SendAddr;
  logic [addrWIDTH/2-1:0] x_dest;
  logic [addrWIDTH/2-1:0] y_dest;
  logic send_requirment;
  integer ct=0;
  
  integer send_result;
  initial 
  begin 
  send_result = $fopen("send_result.txt");
  end
 
 always
  begin
    //sa=ct;
    //add a display here to see when this module starts its main loop
    
	do begin
		
		Value = $random() % (2**WIDTH);
		
		//$display("Value = %b", Value);
		x_dest = Value[WIDTH-2:WIDTH-3];
		y_dest = Value[WIDTH-4:WIDTH-5];
	  
		send_requirment = (x_dest == x_addr) && (y_dest == y_addr);
		//$display("send_requirment = %d, x_addr=%b, x_dest=%b, y_addr = %b, y_dest=%b", send_requirment, x_addr,x_dest,y_addr,y_dest);
		
	    if(send_requirment != 1) send.Send(Value);
		end
	while (send_requirment) ;
	  $display("packet data:%b from (%d,%d) send to (%d,%d) at time = %d", Value,x_addr,y_addr ,x_dest,y_dest, $time);
	  $fdisplay(send_result,"packet data:%b from (%d,%d) send to (%d,%d) at time = %d", Value,x_addr,y_addr ,x_dest,y_dest, $time);
      //SendAddr={addr[addrWIDTH-1:1],~addr[0]};
     // SendAddr=$random() % (2**addrWIDTH);
      //wait(addr==0);
      //if(SendAddr[3:0]!=addr[3:0])begin
        //Communication action Send is about to start
       // $display("%m From:%H To:%H.Send %H %H time:%d",addr,SendAddr[3:0],SendValue,Value,$time);
        //r.Send({{addrWIDTH-4{1'b0}},SendAddr[3:0],SendValue});
        //Communication action Send is finished
        //ct=ct+1;

  end
    
  
endmodule

module data_bucket (interface r);
  parameter WIDTH = 8;
  parameter BL = 0; //ideal environment
  logic [WIDTH-1:0] ReceiveValue = 0;
  parameter x_addr;
  parameter y_addr;
  integer receive_result;
  //Variables added for performance measurements
  real cycleCounter=0, //# of cycles = Total number of times a value is received
       timeOfReceive=0, //Simulation time of the latest Receive 
       cycleTime=0; // time difference between the last two receives
  real averageThroughput=0, averageCycleTime=0, sumOfCycleTimes=0;
  
  initial 
  begin 
  receive_result = $fopen("receive_result.txt");
  end
  
  always
  begin
	//$display("Start module data_bucket and time is %m%d", $time);	
    //Save the simulation time when Receive starts
    timeOfReceive = $time;
	//$display("Start receiving in module %m.time=%d", $time);
    r.Receive(ReceiveValue);
	//$display("stop receiving in module %m.time=%d", $time);
	$display("packet data:%b receive at (%d,%d) at time = %d", ReceiveValue ,x_addr,y_addr,$time);
	$fdisplay(receive_result,"packet data:%b receive at (%d,%d) at time = %d", ReceiveValue ,x_addr,y_addr,$time);
    #BL;
    cycleCounter += 1;		
    //Measuring throughput: calculate the number of Receives per unit of time  
    //CycleTime stores the time it takes from the begining to the end of the always block
    cycleTime = $time - timeOfReceive;
    //averageThroughput = cycleCounter/$time;
    sumOfCycleTimes += cycleTime;
    //averageCycleTime = sumOfCycleTimes / cycleCounter;
    //$display("Execution cycle= %d, Cycle Time= %d, 
    //Average CycleTime=%f, Average Throughput=%f", cycleCounter, cycleTime, 
    //averageCycleTime, averageThroughput);
	//$display("End module data_bucket and time is %d", $time);
  end

endmodule

module Client (interface in,interface out);
    parameter WIDTH = 9;
    parameter addrWIDTH=4;
    parameter FL = 0; //ideal environment
	parameter x_addr;
	parameter y_addr;
    //Channel #(.WIDTH(WIDTH),.hsProtocol(P4PhaseBD)) intf  [4:0] ();
    data_generator #(.WIDTH(WIDTH),.addrWIDTH(addrWIDTH),.FL(FL),.x_addr(x_addr), .y_addr(y_addr)) dg(out);
    
    data_bucket #(.WIDTH(WIDTH),.x_addr(x_addr), .y_addr(y_addr)) db(in);
    
endmodule // Client
