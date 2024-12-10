
function [app_graphs] = app_graphs(graphs,sharingT,napps)
    % an app is a set of "similar" services. Grouping performed according to the paper https://ieeexplore.ieee.org/abstract/document/9774016 
    % v_G_app{i} dependency graph of app #i
    % u_service_a{i} set of services that belongs to app #i
    % u_traceids_a{i} set of traces that belongs to app #i
    % graphs as returned by 'service_graphs' (cell with 3 columns)
    % Col1 -> u_services{i} service name of service #i
    % Col2 -> u_traceids{i} set of traces of service #i
    % Col3 -> v_G_serv{i} dependency graph of service{i}
    % sharingT sharing threshold to declare two services as similar
    % napps number of applications to be generated, if <=0 then this number is computed as in the paper 
    
    service_digraphs = graphs(:,3);
    
    similarity_matrix = zeros(length(graphs),length(graphs));
    for i = 1:length(service_digraphs)
        nodes1= service_digraphs{i}.Nodes;
        if height(nodes1) == 0
            continue;
        end
        for j = i+1:length(service_digraphs)
            nodes2= service_digraphs{j}.Nodes;
            if height(nodes2) == 0
                continue;
            end
            % use node names to calculate similarity between two service graphs
            names1 = nodes1.Name;
            names2 = nodes2.Name;
            common = sum(ismember(names1, names2));
            %fprintf("%d, %d common %d\n",i,j,common);
            if(common>sharingT*length(names1) && common>sharingT*length(names2))
              similarity_matrix(i,j)=1;
              similarity_matrix(j,i)=1;
            end
        end
    end
    % clustering for findings apps
    myfunc=@(X,K)(spectralcluster(X,K));
    if napps<=0
        k_opt=evalclusters(similarity_matrix,myfunc,'CalinskiHarabasz','klist',2:50);
        napps = k_opt.OptimalK;
    end
    clusters = spectralcluster(similarity_matrix,napps);
    app_graphs = cell(napps,4);
    for i=1:napps
        service_idx = (clusters==i); %services idx of the cluster/app
        % App Number
        app_graphs{i,1} = i;
        % Related Trace IDs
        app_graphs{i,2} = cat(1, graphs{service_idx,2});
        % Related Services
        app_graphs{i,3} = cat(1, graphs{service_idx,1});
        % App graph
        related_svc_digraphs = service_digraphs{service_idx,1};
        app_graphs{i,4} = digraph(related_svc_digraphs.Edges);
    end
end

        
    
    