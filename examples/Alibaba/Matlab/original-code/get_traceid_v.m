function [traceid_v] = get_traceid_v(callg,entry_service_id)
    % Find traces that start from the entering service
    % callg: whole Alibaba trace set to be loaded as (e.g.) callg=readtable('MSCallGraph_0.csv');
    % entry_service_id: dm microservice id called by the user, this value is specified below
    % traceid_v: Array of trace IDs that start from the entering service

    trace_id_idx_1 = find(strcmp(callg.rpcid,"0")>0);
    trace_id_idx_2 = find(strcmp(callg.dm,entry_service_id)>0);
    trace_id_idx = intersect(trace_id_idx_1,trace_id_idx_2);
    
    traceid_v = callg.traceid(trace_id_idx);

end
