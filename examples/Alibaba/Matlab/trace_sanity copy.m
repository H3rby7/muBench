function [sanitized_traces,v_G_sub] = trace_sanity_copy(callg,entry_service_id,Nt)
    
    % callg: whole Alibaba trace set to be loaded as (e.g.) callg=readtable('MSCallGraph_0.csv');
    % entry_service_id: dm microservice id called by the user, this value is specified below
    % Nt: number of sanitized trace to produce
    % sanitized_traces: subset of traces off "callg" connected and complete
    % v_G_sub{i}: directed graph of the i-th sanitized trace

    traceid_v = get_traceid_v(callg,entry_service_id)

    v_G_sub = cell(Nt,1); %trace graphs
    sanitized_traces=table();
    trace_count = 0;

    for i=1:height(traceid_v)
        traceid = traceid_v(i);
        trace_g_idx =  find(strcmp(callg.traceid,traceid)>0);
        trace_g = callg(trace_g_idx,:);
        trace_g = sortrows(trace_g,'rpcid','ascend');
        sanity_check = true;
        calls = table();

        % Fix um '?' for 0.1
        % In these traces, it happens that some metrics in MS_CallGraph_Table are lost. 
        % For example, the name of some MS is recorded as NAN, '(?)' or '' in the traces.
        % As the call via RPC will be recorded twice in MS_CallGraph_Table, 
        % some metrics related to rpcID could be found from another record even if one is missing.
        for j = 1 : height(trace_g)
            if strcmp(trace_g.rpcid{j},'0.1') && strcmp(trace_g.um{j},'(?)')
               trace_g.um{j} = entry_service_id;
            end
        end


        % Remove if um or dm length IS NOT 64
        good_idx = [];
        for j = 1 : height(trace_g)
            if length(trace_g.um{j}) ~= 64 || length(trace_g.dm{j}) ~= 64
                continue
            end
            good_idx = [good_idx;j];
        end
        if length(good_idx) <=1
            sanity_check = false;
            continue
        end
        trace_g = trace_g(good_idx,:);



        % Remove duplicates
        considered_calls = strings(0);
        good_idx = [];
        for j = 1 : height(trace_g)
            if isempty(find(strcmp(trace_g.rpcid{j},considered_calls),1))
                considered_calls = [considered_calls;trace_g.rpcid{j}];
                good_idx = [good_idx;j];
            end
        end
        if length(good_idx) <=1
            sanity_check = false;
            continue
        end
        trace_g = trace_g(good_idx,:);
        


        % check correct calls hierarchy
        for j = 1 : height(trace_g)
            rpcid = trace_g.rpcid{j};
            if rpcid=='0'
                %this is the user 
                %calls = [calls; trace_g(j,:)];
                continue
            end
            % check parent existence
            last_dot = find(rpcid=='.',1,'last');
            rpcid_parent = rpcid(1:last_dot-1);
            if isempty(find(strcmp(trace_g.rpcid,rpcid_parent),1))
                % parent doesn't exist
                sanity_check=false;
                break
            end
            % check sibling existence
            rpcid_last_call_num = str2num(rpcid(last_dot+1:end));
            if rpcid_last_call_num == 0
                % numbering error
                sanity_check=false;
                break
            end
            if rpcid_last_call_num ~= 1
                % this calculation will always return the original 'rpc_id'
                % WHy?
                rpcid_sibling = convertStringsToChars(string(rpcid(1:last_dot))+num2str(rpcid_last_call_num));
                % which means this will never be empty, as we just find the same item.
                if isempty(find(strcmp(trace_g.rpcid,rpcid_sibling),1))
                    % parent doesn't exist
                    sanity_check=false;
                    break
                end
            end
        end
        
        if sanity_check == false
            % trace not valid
            continue
        end
        



        % check ms connectivity
        G_sub = digraph();
        sanity_check = true;
        user_row = -1;
        for j = 1 : height(trace_g)
            % add um,dm nodes
            if strcmp(trace_g.rpcid{j},'0')
                continue
            end
            um = trace_g.um{j};
            dm = trace_g.dm{j};
            % add nodes
            if numnodes(G_sub)==0
                G_sub = addnode(G_sub,um);
            elseif not(findnode(G_sub,um))
                G_sub = addnode(G_sub,um);
            end
            if not(findnode(G_sub,dm))
                G_sub = addnode(G_sub,dm);
            end
            
            % add edges
            if strcmp(um,dm)
                %skip autocall
                continue
            end
            G_sub = addedge(G_sub,um,dm); % add one edge x call
        end
        if findnode(G_sub,entry_service_id)==0
            continue
        end
        depths = distances(G_sub,entry_service_id);
        if max(depths==inf)
            fprintf("trace %d not connected \n",i)
            % not completly connected trace
            continue
        end
    
        %fprin
    
        trace_count = trace_count + 1;
        sanitized_traces = [sanitized_traces; trace_g];
        v_G_sub{trace_count} = G_sub;
        fprintf("correct traces %d out of %d \n",trace_count,i)
        if trace_count>=Nt
            break
        end
    end
end

