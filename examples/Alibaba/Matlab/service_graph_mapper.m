function service_graph_mapper(data, ~, intermKVStore)
    % Find traces that start from the entering service

    sanitized_traces = data{1,2}{1};
    
    % all trace entries, where rpc_id = '0'
    trace_rpc_ids_0_idx = strcmp(sanitized_traces.rpc_id,"0")>0;

    % extract interface property as unique list -> these will represent a 'service'
    interfaces = unique(sanitized_traces.interface(trace_rpc_ids_0_idx,:));
    l_interfaces = length(interfaces);

    % service_graph will be a table with these columns:
    % service: ID of the service ('interface')
    % trace_ids: list of trace_id that correspond to that service
    % graph: a digraph constructed using the available traces' upstream and downstream information
    traces_by_service = cell(l_interfaces,2);

    for i = 1:l_interfaces
        interface = interfaces{i};
        traces_by_service{i,1} = interface;

        % trace_ids that have this service/interface as root (rpc_id=='0')
        related_trace_ids = unique(sanitized_traces.trace_id((strcmp(sanitized_traces.interface,interface)>0) & trace_rpc_ids_0_idx,:));

        % trace_g = all trace entries of the related_trace_ids
        trace_g = sanitized_traces(ismember(sanitized_traces.trace_id, related_trace_ids),:);
        traces_by_service{i,2} = trace_g;
    end

    addmulti(intermKVStore, traces_by_service(:,1), traces_by_service(:,2));
end
