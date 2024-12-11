% IMPORTANT: This is the example config file!!
%            Make a copy of this file in this directory and name it 'config.m'!

function [trace_location, trace_header_lines, trace_header, trace_vartypes, entry_service_id, sanitized_trace_count, output_dir_sequential, output_dir_parallel] = config()
    % Adjust the variables in this block to your needs and conditions

    % *************** Trace options ***************
    % trace_location: location of alibaba cluster trace microservices v2021
    trace_location = "MSCallGraph_0.csv";
    % how many lines to skip
    trace_header_lines = 1;
    % trace table header
    trace_header = ["Nr", "trace_id", "timestamp", "rpc_id", "upstream_ms", "rpc_type", "downstream_ms", "interface", "response_time"];
    % trace variable types
    trace_vartypes = {'uint64', 'string', 'uint32', 'string', 'string', 'string', 'string', 'string', 'int16'};
    % entry_service_id: dm microservice id called by the user
    entry_service_id = '7695b43b41732a0f15d3799c8eed2852665fe8da29fd700c383550fc16e521a3';

    % How many sanitized traces shall be used to build the MS DAG
    sanitized_trace_count = 200;

    % *************** Directories for output ***************
    % convenient variable, does not get exported.
    output_dir_root = "traces-mbench";
    % DIR within root DIR to hold sequential output
    output_dir_sequential = output_dir_root+"/sequential";
    % DIR within root DIR to hold parallel output
    output_dir_parallel = output_dir_root+"/parallel";

end