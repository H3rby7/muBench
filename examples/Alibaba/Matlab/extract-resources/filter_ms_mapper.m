function filter_ms_mapper(data, ~, intermKVStore, used_ms)
    % Filter for the MS we are interested in and map
    relevant_traces = data(ismember(data.ms_name, used_ms),:);
    by_ms_name = findgroups(relevant_traces{:, 2});
    % Split table
    split = splitapply( @(varargin) varargin, relevant_traces , by_ms_name);
    ms_count = height(split);
    ms_tables = cell(ms_count, 2);

    vars = data.Properties.VariableNames;
    for i=1:ms_count
        t = table(split{i, :}, VariableNames=vars);
        % Because the sampling rate is 30s, we map
        % timestamp from millis to minutes (60000 millis)
        t.timestamp = single(t.timestamp) / 60000;
        ms_tables{i,1} = t.ms_name{1};
        ms_tables{i,2} = t;
    end
    addmulti(intermKVStore, vertcat(ms_tables(:,1)), ms_tables(:,2));
end
