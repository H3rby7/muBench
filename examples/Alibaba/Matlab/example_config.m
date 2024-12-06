% IMPORTANT: This is the example config file!!
%            Make a copy of this file in this directory and name it 'config.m'!

function [trace_location, entry_service_id] = config()
    % Adjust the variables in this block to your needs and conditions

    % trace_location: location of alibaba cluster trace microservices v2021
    trace_location = "MSCallGraph_0.csv";

    % entry_service_id: dm microservice id called by the user
    entry_service_id = '7695b43b41732a0f15d3799c8eed2852665fe8da29fd700c383550fc16e521a3';

end