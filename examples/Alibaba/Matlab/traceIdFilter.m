function traceIdFilter(data, ~, intermKVStore, entry_service_id)
    % Find traces that start from the entering service

    trace_id_idx_1 = find(strcmp(data.rpcid,"0")>0);
    trace_id_idx_2 = find(strcmp(data.dm,entry_service_id)>0);
    trace_id_idx = intersect(trace_id_idx_1,trace_id_idx_2);
    
    trace_ids = data.traceid(trace_id_idx);
    asCells = cell(height(trace_ids),1);

    for i=1:height(trace_ids)
        traceid = trace_ids(i);

        % Matching traceid and 
        % 'dm' field length is 64
        related_entries = data((strcmp(data.traceid,traceid)>0 & cellfun(@length,data.dm) == 64),:);

        % Fix um '?' for 0.1
        % In these traces, it happens that some metrics in MS_CallGraph_Table are lost. 
        % For example, the name of some MS is recorded as NAN, '(?)' or '' in the traces.
        % As the call via RPC will be recorded twice in MS_CallGraph_Table, 
        % some metrics related to rpcID could be found from another record even if one is missing.
        um_is_entry_service = related_entries((strcmp(related_entries.rpcid,'0.1') & strcmp(related_entries.um,'(?)')),:);
        related_entries.um(um_is_entry_service) = {entry_service_id};
        asCells{i} = table2cell(related_entries);
    end

    addmulti(intermKVStore, trace_ids, asCells);
end
