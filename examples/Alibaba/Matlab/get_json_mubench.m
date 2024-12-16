function js = get_json_mubench(rpc_id,app_trace,parallel)
idx = find(strcmp(app_trace.rpc_id,rpc_id)>0,1);
if isempty(idx)
    js = "";
    return
end
own_name = convertCharsToStrings(app_trace.upstream_ms{idx});
nr = app_trace.Nr(idx);
js = char(34)+own_name+"__"+num2str(nr)+char(34)+":[";   
rpcid_child = convertCharsToStrings(rpc_id)+".1";
if not(any(strcmp(app_trace.rpc_id,rpcid_child)))
    child_name = convertCharsToStrings(app_trace.downstream_ms{idx});
    js = char(34)+child_name+"__LEAF"+char(34)+":[{}]";
    return;
else
    if parallel~=1
        js = js + "{";
    end
    for i=1:1000
        %recursion on childs
        rpcid_child = convertCharsToStrings(rpc_id)+"."+num2str(i);
        if not(any(strcmp(app_trace.rpc_id,rpcid_child)))
            break
        else
            if parallel==1
                js = js + "{"+get_json_mubench(rpcid_child,app_trace,parallel)+"},";
            else    
                js = js + get_json_mubench(rpcid_child,app_trace,parallel)+",";
            end
        end
    end
end
js = convertStringsToChars(js);
if (js(end)==',')
    js=js(1:end-1);
end
js = convertCharsToStrings(js);
if parallel~=1
    js = js + "}";
end
js = js + "]";
end