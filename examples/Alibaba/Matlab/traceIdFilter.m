function traceIdFilter(data, ~, intermKVStore, entry_service_id)
    % Find traces that start from the entering service

    trace_id_idx_1 = find(strcmp(data.rpc_id,"0")>0);
    trace_id_idx_2 = find(strcmp(data.downstream_ms,entry_service_id)>0);
    trace_id_idx = intersect(trace_id_idx_1,trace_id_idx_2);
    
    trace_ids = data.trace_id(trace_id_idx);
    asCells = cell(height(trace_ids),1);
    [upstream_is_user_id] = constants();

    for i=1:height(trace_ids)
        trace_id = trace_ids(i);

        % 'traceid'     must match
        related_entries = data((strcmp(data.trace_id,trace_id)>0),:);

        % Fix upstream_ms '?' for 0.1
        % In these traces, it happens that some metrics in MS_CallGraph_Table are lost. 
        % For example, the name of some MS is recorded as NAN, '(?)' or '' in the traces.
        % As the call via RPC will be recorded twice in MS_CallGraph_Table, 
        % some metrics related to rpc_id could be found from another record even if one is missing.
        um_is_entry_service = (strcmp(related_entries.rpc_id,'0.1') & strcmp(related_entries.upstream_ms,'(?)'));
        related_entries.upstream_ms(um_is_entry_service) = {entry_service_id};

        % rpc_id 0 relates to the user's request.
        % to be safe about being filtered out we set it to a 64-long char
        % value
        um_is_user = (strcmp(related_entries.rpc_id,'0'));
        related_entries.upstream_ms(um_is_user) = {upstream_is_user_id};
        
        % filter unusable 'downstream_ms' and 'upstream_ms' lengths
        related_entries = related_entries(cellfun(@dm_um_filter,related_entries.downstream_ms, related_entries.upstream_ms),:);
        
        % Be unique by rpc_id
        [~, idx] = unique(related_entries.rpc_id);

        asCells{i} = table2cell(related_entries(idx,:));
    end

    addmulti(intermKVStore, trace_ids, asCells);
end

function [pass] = dm_um_filter(downstream_ms, upstream_ms)
    pass = true;
    % 'downstream_ms' length must be 64
    if (length(downstream_ms) ~= 64)
        pass = false;
    % 'upstream_ms' length must be 64
    elseif (length(upstream_ms) ~= 64)
        pass = false;
    end
end
