
function [services] = app_cluster(services, sharingT, napps)
    % an app is a set of "similar" services. Grouping performed according to the paper https://ieeexplore.ieee.org/abstract/document/9774016 
    % v_G_app{i} dependency graph of app #i
    % u_service_a{i} set of services that belongs to app #i
    % u_traceids_a{i} set of traces that belongs to app #i
    % services as returned by 'service_graphs' with these columns:
    % service: ID of the service ('interface')
    % trace_ids: list of trace_id that correspond to that service
    % graph: a digraph constructed using the available traces' upstream and downstream information
    % sharingT sharing threshold to declare two services as similar
    % napps number of applications to be generated, if <=0 then this number is computed as in the paper 
    
    h_services = height(services);
    similarity_matrix = zeros(h_services,h_services);

    for i = 1:h_services
        svc_i = services{i,2}{1};
        nodes1= svc_i.graph{1}.Nodes;
        if height(nodes1) == 0
            continue;
        end
        for j = i+1:h_services
            svc_j = services{j,2}{1};
            nodes2= svc_j.graph{1}.Nodes;
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

    % append a column to the services table 
    % to hold the corresponding app (cluster)
    services = [services table(clusters)];
    services.Properties.VariableNames(3) = "app";
end