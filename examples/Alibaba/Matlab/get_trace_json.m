function [json] = get_trace_json(trace, parallel)
    % brain help for output format:
    % it is always { and [ in sequence -> e.g. [{[{[{}]}]}] 
    % In any case we have our MS and next an array: []
    % if its parallel, we add one {} per call
    % if its sequential we add the calls to the same {}
    % all entries in the array are executed in parallel
    [~, ~, ~, ~, entry_service_id, ~, ~, ~] = config();

    trace = sortrows(trace, 'rpc_id', 'asc');
    dg = digraph(trace.upstream_ms', trace.downstream_ms', 'omitselfloops');

    t_struct = rec(dg, entry_service_id, parallel);
    
    % approach: DG, iterating successors recursively
    % structure for parallel, for sequential can reduce array items into
    % struct later on.

    json = jsonencode(t_struct, 'PrettyPrint', true);
end

function [t_struct] = rec(digraph, node_name, parallel)
    children = digraph.successors(node_name);
    key = ['o_' node_name];
    if isempty(children)
        c_nodes = {[struct()]};
    else
        c_nodes = cellfun(@(c) rec(digraph, c, parallel), children, 'UniformOutput',false);
        % if SEQ, merge c_nodes together
    end
    if ~parallel
        c_length = length(c_nodes);
        if c_length > 1
            % c_nodes is an Nx1 cell and needs to become a 1x1 cell of
            % merged items.
            fields = strings(c_length, 1);
            calls = cell(c_length, 1);
            for i=1:c_length
                c = c_nodes(i);
                f = fieldnames(c{1});
                fields(i) = f{:};
                calls(i) = struct2cell(c{:});
            end
            c_nodes = {cell2struct(calls, fields)};
        end
    end
    % we always add them as array
    t_struct = struct(key,{c_nodes});
end

% strcmp(node_name, '9ee59483550ea795bc04e930ad6b37b7852e92fa9a71556565e91380dd39de03') > 0