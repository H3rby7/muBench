% EXAMPLE CONFIG FILE
% Copy, rename to config.m and adjust values to your preference.

function [trace_location, trace_header_lines, ms_by_interfaces_location] = config()
    % Adjust the variables in this block to your needs and conditions

    % *************** Trace options ***************
    % trace_location of alibaba cluster trace microservices v2021 MSResource
    trace_location = "MSResource_0.csv";
    % how many lines to skip
    trace_header_lines = 1;

    % location of the matlab file that contains the used interfaces and microservices
    ms_by_interfaces_location = "ms_by_interfaces";
    
end