clear all; clc;
import matlab.unittest.TestSuite
methods('TestSuite')

run(TestSuite.fromFile('TestCells.m'))
run(TestSuite.fromFile('TestUtilityFunctions.m'))
run(TestSuite.fromFile('TestStatistic.m'))

