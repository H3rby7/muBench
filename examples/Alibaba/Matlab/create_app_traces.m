function [app_traces] = create_app_traces(v_G_app,u_trace_ids_a,sanitized_traces)
    % v_G_app{i} graph of app #i
    % u_trace_ids_a service of app #i
    % Alibaba sanitized traces
    % app_traces{i} is a table that contains the subset of traces of the app #i
    
    app_traces=cell(length(v_G_app),1);
    for i=1:length(v_G_app)
        app_traces{i} = table();
        for j=1:length(u_trace_ids_a{i})
            trace_id = u_trace_ids_a{i}(j);
            trace_id_idx_1 = strcmp(sanitized_traces.trace_id,trace_id)>0;
            app_traces{i,:} = [app_traces{i,:};sanitized_traces(trace_id_idx_1,:)];
        end

        % trace/app check
        ms = unique([app_traces{i}.upstream_ms ; app_traces{i}.downstream_ms]);
        u_ms_length = length(ms)-1;
        numnodes = v_G_app{i}.numnodes;
        if (u_ms_length ~= numnodes)
            fprintf('Warning trace %d not consistent with app graph',i);
            m = max([height(ms); height(v_G_app{i}.Nodes.Name)]);
            cmp = cell(m,2);
            ms_sorted = sort(ms);
            for j=1:m
                if j > length(ms_sorted)
                    break;
                end
                cmp{j,1} = ms_sorted(j);
            end
            nodes_sorted = sort(v_G_app{i}.Nodes.Name);
            for j=1:m
                if j > length(nodes_sorted)
                    break;
                end
                cmp{j,2} = nodes_sorted{j};
            end
            cmp
        end
        
    end
end