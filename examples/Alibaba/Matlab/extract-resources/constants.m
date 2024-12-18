function [trace_header, trace_vartypes, mapped_trace_vartypes] = constants()
    % NO NOT adjust the variables in this block

    % trace table header
    trace_header = ["Nr", "ms_name", "ms_instance_id", "node_id", "cpu", "memory", "timestamp"];
    % trace variable types
    trace_vartypes = {'uint64', 'string', 'string', 'string', 'double', 'double', 'uint32'};
    % mapped trace variable types 
    % (as we are mapping timestamp from millis to minutes 
    % uint32 -> single)
    mapped_trace_vartypes = {'uint64', 'string', 'string', 'double', 'double', 'single'};
end