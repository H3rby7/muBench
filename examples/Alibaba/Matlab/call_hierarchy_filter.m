function call_hierarchy_filter(data, ~, intermKVStore)
    % as soon as one trace entry is falsy we drop the whole trace_id
    % how do we know we have all trace-rows for our ID this time?
    pass = true;
    
    for i=1:height(trace)
        rpcid = trace.rpcid{i};
        if rpcid == '0'
            % entrypoint, the user call
            continue;
        end

        last_dot = find(rpcid=='.',1,'last');
        last_digit = rpcid(last_dot+1:end);
        if last_digit == '0'
            % numbering error (should never be 0)
            pass=false;
            break
        end

        rpcid_parent = rpcid(1:last_dot-1);
        if isempty(find(strcmp(trace.rpcid,rpcid_parent),1))
            % parent doesn't exist
            pass=false;
            break
        end

        % in the original impl there is a sibling-rpc_id check that
        % complicatedly reconstructs its own rpc_id and looks for that
        % in the trace, where it will always find itself and be happy.
        % We skip that step.
    end    

    addmulti(intermKVStore, trace_ids, asCells);
end
