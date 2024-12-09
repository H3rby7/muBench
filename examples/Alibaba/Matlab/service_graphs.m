function [v_G_serv,u_services,u_trace_ids] = service_graphs(sanitized_traces)
    % v_G_serv{i} is the graph of a service where a service is identified by the interface name of the first call
    % u_services{i} interface name of the service i-th
    % u_trace_ids{i} set of trace_ids that regards service i-th
    % sanitized_trace, Alibaba trace sanitized 
    
    v_G_serv = {}; % graphs of services, a service is identified by the interface name of the first call
    trace_id_idx_1 = strcmp(sanitized_traces.rpc_id,"0")>0;
    services = sanitized_traces.interface(trace_id_idx_1);
    trace_ids = sanitized_traces.trace_id(trace_id_idx_1);
    u_services = unique(services);  % unique service id
    u_trace_ids = cell(length(u_services),1); % trace id of the services
    for i=1:length(u_services)
        u_trace_ids{i} = strings(0);
        v_G_serv{i} = digraph();
    end
    l = length(trace_ids);
    for i = 1:l
        service = services{i};
        trace_id = trace_ids{i};
        trace_g = sanitized_traces((strcmp(sanitized_traces.trace_id,trace_id)>0),:);
        u_service_id = find(strcmp(u_services,service),1,'first');
        u_trace_ids{u_service_id} = [u_trace_ids{u_service_id}; trace_id];
        for j = 1 : height(trace_g)
            
            % add upstream_ms,downstream_ms nodes
            if strcmp(trace_g.rpc_id{j},'0')
                continue
            end
            upstream_ms = trace_g.upstream_ms{j};
            downstream_ms = trace_g.downstream_ms{j};
            % add nodes
            if numnodes(v_G_serv{u_service_id})==0
                v_G_serv{u_service_id} = addnode(v_G_serv{u_service_id},upstream_ms);
            elseif not(findnode(v_G_serv{u_service_id},upstream_ms))
                v_G_serv{u_service_id} = addnode(v_G_serv{u_service_id},upstream_ms);
            end
            if not(findnode(v_G_serv{u_service_id},downstream_ms))
                v_G_serv{u_service_id} = addnode(v_G_serv{u_service_id},downstream_ms);
            end
            % add edges
            v_G_serv{u_service_id} = addedge(v_G_serv{u_service_id},upstream_ms,downstream_ms); % add one edge x call
%             if strcmp(upstream_ms,downstream_ms)
%                 %skip autocall
%                 continue
%             end
%             if findedge(v_G_serv{u_service_id},upstream_ms,downstream_ms) == 0
%                 v_G_serv{u_service_id} = addedge(v_G_serv{u_service_id},upstream_ms,downstream_ms); % add one edge x call
%             end
        end
    end
end
    
    