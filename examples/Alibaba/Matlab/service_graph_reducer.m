function service_graph_reducer(service_name, intermValIter, outKVStore)
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

    % Create directed graph
    % using the trace upstream and downstream combinations to describe its edges
    graph = digraph(T.upstream_ms', T.downstream_ms');

    % Sanity Check
    ms_from_trace = unique([T.upstream_ms ; T.downstream_ms]);
    ms_count_graph = graph.numnodes;
    if (length(ms_from_trace) ~= ms_count_graph)
        fprintf('Warning: MS count for Service %s -> count of MS in service graph and count of MS from trace differ!\n', service_name);
        % nodenames = graph{i,3}.Nodes.Name
        % ms_from_trace
    end

    services = {{T}, graph};
    as_table = cell2table(services, "VariableNames", ["traces", "graph"]);

    add(outKVStore, service_name, as_table);
end
