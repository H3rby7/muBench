function [json] = get_trace_string_json(trace, parallel)
    % Convert a sanitized trace for a trace_id to an muBench conformous
    % json text output
    % trace - The input trace
    % parallel = 1 - Sibiling calls executed in parallel (e.g. 0.1 calls 0.1.1 and 0.1.2 in parallel)
    % prettyPrint - formatting option for jsonencode
    % json - the output string
    [~, ~, ~, ~, entry_service_id, ~, ~, ~] = config();

    trace = sortrows(trace, 'rpc_id', 'asc');
    dg = digraph(trace.upstream_ms', trace.downstream_ms', 'omitselfloops');

    if hascycles(dg)
        % We could possibly find a workaround for these traces, however
        % they are only a small percentage of the total.
        trace_id = trace.trace_id{1,:};
        fprintf('Warning: Trace with ID "%s" has cycles and is being skipped\n', trace_id);
        body{1} = '';
    else
        body = rec(dg, entry_service_id, parallel);
    end
    json = ['{' body{1} '}'];

    % validity check
    % jsondecode(json);
end

function [out] = rec(digraph, node_name, parallel)
    % Recursively iterates over the digraph and creates a char array cell from it
    children = digraph.successors(node_name);
    if isempty(children)
        c_as_str = {''};
    else
        c_nodes = cellfun(@(c) rec(digraph, c, parallel), children);
        if parallel
            c_as_str = join(c_nodes, "},{", 1);
        else
            c_as_str = join(c_nodes, ",", 1);
        end
    end
    out = {['"' node_name '":[{' c_as_str{1} '}]']};
end
