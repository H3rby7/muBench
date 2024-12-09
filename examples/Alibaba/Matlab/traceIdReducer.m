function traceIdReducer(trace_id, intermValIter, outKVStore)
    [upstream_is_user_id] = constants();
    [~, ~, trace_header, trace_vartypes, ~, ~] = config();

    % Create an empty table
    T = table('Size', [0 9], 'VariableTypes',trace_vartypes, 'VariableNames',trace_header);
    
    % Append all entries we have to the table
    while hasnext(intermValIter)
        t_traces = getnext(intermValIter);
        T = [T;t_traces];
    end

    % Table has no entries, no more work to do
    if height(T) == 0
        return
    end

    % Check for sane rpc_id structure in the traces
    if not(are_parents_present(T))
        return
    end

    % Check if all mentioned ms are connected to the entrypoint
    if not(check_ms_connectivity(T, upstream_is_user_id))
        return
    end
    add(outKVStore, trace_id, sortrows(T,'rpc_id','ascend'));
end

function [pass] = are_parents_present(trace)
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
            % drop trace, because last digit of rpc_id is '0'
            pass=false;
            break
        end

        rpc_id_parent = rpc_id(1:last_dot-1);
        if isempty(find(strcmp(trace.rpc_id,rpc_id_parent),1))
            % parent doesn't exist
            % drop trace, because parent ms rpc_id is not present
            pass=false;
            break
        end

        % in the original impl there is a sibling-rpc_id check that
        % complicatedly reconstructs its own rpc_id and looks for that
        % in the trace, where it will always find itself and be happy.
        % We skip that step.
    end    
end


function [pass] = check_ms_connectivity(T, upstream_is_user_id)
    % check if all entries of this trace are connected to each other
    pass = true;

    G = digraph(T.upstream_ms', T.downstream_ms', 'omitselfloops');
    depths = distances(G,upstream_is_user_id);
    if any(depths==inf)
        % at least one node of the graph is infinitely far away
        % -> meaning: not connected
        pass = false;
    end
end