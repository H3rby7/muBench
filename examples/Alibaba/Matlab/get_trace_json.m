function [json] = get_trace_json(trace)
    % brain help for output format:
    % it is always { and [ in sequence -> e.g. [{[{[{}]}]}] 
    % In any case we have our MS and next an array: []
    % if its parallel, we add one {} per call
    % if its sequential we add the calls to the same {}
    % all entries in the array are executed in parallel
    [~, ~, ~, ~, entry_service_id, ~, ~, ~] = config();

    trace = sortrows(trace, 'rpc_id', 'asc');
    dg = digraph(trace.upstream_ms', trace.downstream_ms', 'omitselfloops');

    t_struct = rec(dg, entry_service_id);
    
    % approach: DG, iterating successors recursively
    % structure for parallel, for sequential can reduce array items into
    % struct later on.

    json = jsonencode(t_struct, "PrettyPrint",true);
end

function [t_struct] = rec(digraph, node_name)
    children = digraph.successors(node_name);
    key = ['o_' node_name];
    if isempty(children)
        c_nodes = {[struct()]};
    else
        c_nodes = cellfun(@(c) rec(digraph, c), children, 'UniformOutput',false);
    end
    t_struct = struct(key,{c_nodes});
    % t_struct = struct(['o_' node_name],arrayfun(@(c) rec(digraph, c), children));
end

% strcmp(node_name, '9ee59483550ea795bc04e930ad6b37b7852e92fa9a71556565e91380dd39de03') > 0