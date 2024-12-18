function [t] = min_max_mean(data)
   t = rowfun(@getMinMaxMean, ...
       data, ...
       "InputVariables", ["cpu", "memory"],  ...
       "GroupingVariables", "timestamp", ...
       "OutputVariableNames", ["cpu_min", "cpu_mean", "cpu_max", "memory_min", "memory_mean", "memory_max"]);

end

function [cpu_min, cpu_mean, cpu_max, memory_min, memory_mean, memory_max] = getMinMaxMean(cpu, memory)
    cpu_min = min(cpu);
    cpu_mean = mean(cpu);
    cpu_max = max(cpu);
    memory_min = min(memory);
    memory_mean = mean(memory);
    memory_max = max(memory);
end