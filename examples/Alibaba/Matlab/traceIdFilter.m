function traceIdFilter(data, ~, intermKVStore, entry_service_id)
    % Find traces that start from the entering service

    trace_id_idx_1 = find(strcmp(data.rpcid,"0")>0);
    trace_id_idx_2 = find(strcmp(data.dm,entry_service_id)>0);
    trace_id_idx = intersect(trace_id_idx_1,trace_id_idx_2);
    
    trace_ids = data.traceid(trace_id_idx);
    asCells = cell(height(trace_ids),1);

    for i=1:height(trace_ids)
        traceid = trace_ids(i);

        % 'traceid'     must match
        related_entries = data((strcmp(data.traceid,traceid)>0),:);

        % Fix um '?' for 0.1
        % In these traces, it happens that some metrics in MS_CallGraph_Table are lost. 
        % For example, the name of some MS is recorded as NAN, '(?)' or '' in the traces.
        % As the call via RPC will be recorded twice in MS_CallGraph_Table, 
        % some metrics related to rpcID could be found from another record even if one is missing.
        um_is_entry_service = (strcmp(related_entries.rpcid,'0.1') & strcmp(related_entries.um,'(?)'));
        related_entries.um(um_is_entry_service) = {entry_service_id};
        
        % filter unusable 'dm' and 'um' lengths
        related_entries = related_entries(cellfun(@dm_um_filter,related_entries.dm, related_entries.um),:);
        
        % Be unique by rpcid
        [~, idx] = unique(related_entries.rpcid);

        asCells{i} = table2cell(related_entries(idx,:));
    end

    addmulti(intermKVStore, trace_ids, asCells);
end

function [pass] = dm_um_filter(dm, um)
    pass = true;
    % 'dm' length must be 64
    if (length(dm) ~= 64)
        pass = false;
    % 'um' length must be 64
    elseif (length(um) ~= 64)
        pass = false;
    end
end