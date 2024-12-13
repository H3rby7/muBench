function [json] = get_trace_json(trace, parallel, prettyPrint)
    % Convert a sanitized trace for a trace_id to an muBench conformous
    % json textz output
    % trace - The input trace
    % parallel = 1 - Sibiling calls executed in parallel (e.g. 0.1 calls 0.1.1 and 0.1.2 in parallel)
    % prettyPrint - formatting option for jsonencode
    % json - the output string
    [~, ~, ~, ~, entry_service_id, ~, ~, ~] = config();

    trace = sortrows(trace, 'rpc_id', 'asc');
    dg = digraph(trace.upstream_ms', trace.downstream_ms', 'omitselfloops');

    t_struct = rec(dg, entry_service_id);
    
    % approach: DG, iterating successors recursively
    % structure for parallel, for sequential can reduce array items into
    % struct later on.

    json = jsonencode(t_struct, PrettyPrint=prettyPrint);
    if ~parallel
        if prettyPrint
            json = regexprep(json, "\]\n\s*\},\n\s*\{", "],");
        else
            json = replace(json, '},{',',');
        end
    end
end

function [t_struct] = rec(digraph, node_name)
    % Recursively iterates over the digraph and creates a struct from it
    % if json-encoded as-is would be parallel execution.
    children = digraph.successors(node_name);
    key = ['o_' node_name];
    if isempty(children)
        c_nodes = {[struct()]};
    else
        c_nodes = cellfun(@(c) rec(digraph, c), children, 'UniformOutput',false);
    end
    t_struct = struct(key,{c_nodes});
end
