function traceIdReducer(trace_id, intermValIter, outKVStore)
    T = emptyTraceTable();
    while hasnext(intermValIter)
        t_traces = getnext(intermValIter);
        T = [T;t_traces];
    end
    if height(T) == 0
        return
    end
    if are_parents_present(T, trace_id)
        % TODO: Add  the 'connectivity check'
        add(outKVStore, trace_id, sortrows(T,'rpc_id','ascend'));
    end
end

function [pass] = are_parents_present(trace, trace_id)
    % as soon as one trace entry is falsy we drop the whole trace_id
    pass = true;
    
    for i=1:height(trace)
        rpc_id = trace.rpc_id{i};
        if rpc_id == '0'
            % entrypoint, the user call
            continue;
        end

        last_dot = find(rpc_id=='.',1,'last');
        last_digit = rpc_id(last_dot+1:end);
        if last_digit == '0'
            % numbering error (should never be 0)
            % fprintf("drop trace [%s], because contains an RPC_ID with last digit '0' [%s]\n", trace_id, rpc_id);
            pass=false;
            break
        end

        rpc_id_parent = rpc_id(1:last_dot-1);
        if isempty(find(strcmp(trace.rpc_id,rpc_id_parent),1))
            % parent doesn't exist
            % Maybe we could make an exception for a missing the '0', as we
            % know that service is out entry_point?

            % fprintf("drop trace [%s], because parent [%s] is missing\n", trace_id, rpc_id_parent);
            pass=false;
            break
        end

        % in the original impl there is a sibling-rpc_id check that
        % complicatedly reconstructs its own rpc_id and looks for that
        % in the trace, where it will always find itself and be happy.
        % We skip that step.
    end    
end