function traceIdFilter(data, ~, intermKVStore, entry_service_id)
    % Find traces that start from the entering service

    trace_id_idx_1 = find(strcmp(data.rpcid,"0")>0);
    trace_id_idx_2 = find(strcmp(data.dm,entry_service_id)>0);
    trace_id_idx = intersect(trace_id_idx_1,trace_id_idx_2);
    
    trace_ids = data.traceid(trace_id_idx);
    addmulti(intermKVStore, trace_ids, cell(length(trace_ids),1));
end
