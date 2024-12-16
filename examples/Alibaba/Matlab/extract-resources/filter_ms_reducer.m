function filter_ms_reducer(ms_name, intermValIter, outKVStore)
    [~, ~, ~, ~, trace_selected_cols, trace_selected_vartypes, ~] = config();

    % Create an empty table
    T = table('Size', [0 6], 'VariableTypes',trace_selected_vartypes, 'VariableNames',trace_selected_cols);
    
    % Append all entries we have to the table
    while hasnext(intermValIter)
        t_traces = getnext(intermValIter);
        T = [T;t_traces];
    end

    % Table has no entries, no more work to do
    if height(T) == 0
        return
    end

    add(outKVStore, ms_name, sortrows(T,{'ms_instance_id', 'timestamp'},{'ascend', 'ascend'}));
end
