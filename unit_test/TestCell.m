classdef TestCell < matlab.unittest.TestCase
    %TestCell unit-tests class Cell
    %   
    
    properties
    end
    
    methods (Test)
        function testSchedule( testCase )
            cell = Cell(1,5,7);
            cell.schedule(Direction.Uplink, 3);
            testCase.verifyEqual(cell.uQueue, 3);
        end
        
        function testTransmit( testCase )
            %TODO: unit test for transmit()
        end
        
        function testReceive( testCase )
            %TODO: unit test for receive()
        end
        
        function testThroughput( testCase )
            %TODO: unit test for throughput()
        end 
    end
    
end

