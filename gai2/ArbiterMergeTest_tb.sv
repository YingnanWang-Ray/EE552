//Written by Arash Saifhashemi
//Edited by Mehrdad
//EE552, Department of Electrical Engineering
//University of Southern California
//Spring 2011
`timescale 1ns/100ps

module data_generator (interface R);

	parameter W = 16;	
	reg signed [W-1:0] SendValue = 0;

	initial
	begin
	        #500;	
		forever
		begin
			SendValue = SendValue + 1;		
			R.Send(SendValue);
			$display("Send: %d", SendValue);
		end
	end
endmodule

module data_generatorOneBit (interface R);

	parameter W = 1;	
	reg unsigned [W-1:0] SendValue = 1;

	initial
	begin
	        #500;	
		forever
		begin
			//SendValue = ~SendValue ;		
			R.Send(SendValue);
			$display("Send control: %d", SendValue);
		end
	end
endmodule

//Sample data_bucket module
module data_bucket (interface r);
  parameter WIDTH = 8;
  parameter BL = 0; //ideal environment
  logic [WIDTH-1:0] ReceiveValue = 0;
  
  //Variables added for performance measurements
  real cycleCounter=0, //# of cycles = Total number of times a value is received
       timeOfReceive=0, //Simulation time of the latest Receive 
       cycleTime=0; // time difference between the last two receives
  real averageThroughput=0, averageCycleTime=0, sumOfCycleTimes=0;
  always
  begin
	$display("Start module data_bucket and time is %d", $time);	
    //Save the simulation time when Receive starts
    timeOfReceive = $time;
    r.Receive(ReceiveValue);
    #BL;
    cycleCounter += 1;		
    //Measuring throughput: calculate the number of Receives per unit of time  
    //CycleTime stores the time it takes from the begining to the end of the always block
    cycleTime = $time - timeOfReceive;
    averageThroughput = cycleCounter/$time;
    sumOfCycleTimes += cycleTime;
    averageCycleTime = sumOfCycleTimes / cycleCounter;
    $display("Execution cycle= %d, Cycle Time= %d, Average CycleTime=%f, Average Throughput=%f", cycleCounter, cycleTime, averageCycleTime, averageThroughput);
	$display("End module data_bucket and time is %d", $time);
  end

endmodule

module ArbiterMerge_cosim_tb;

	parameter W = 16;
	
	e1ofN_M #(.N(2), .M(16)) A_data ();
	e1ofN_M #(.N(2), .M(16)) B_data ();
	e1ofN_M #(.N(2), .M(16)) out_data ();
  
	data_generator	#(.W(16)) dgI3 (.R(A_data));
	data_generator	#(.W(16)) dgI4 (.R(B_data));

	ArbiterMergeTest m1 (A_data, B_data, out_data);
	data_bucket db1 (.r(out_data));
	
endmodule
