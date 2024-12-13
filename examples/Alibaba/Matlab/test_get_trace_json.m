Nr = [50584; 50581; 50580; 50579; 50583];
trace_id = ["0b0ab4e315919238654535000ead8e";"0b0ab4e315919238654535000ead8e";"0b0ab4e315919238654535000ead8e";"0b0ab4e315919238654535000ead8e";"0b0ab4e315919238654535000ead8e"];
timestamp = [265451; 265457; 265457; 265460; 265460];
rpc_id = ["0"; "0.1"; "0.1.1"; "0.1.2"; "0.1.2.1"];
upstream_ms = ["synthetic_id_as_the_upstream_of_this_trace_entry_is_the_end_user"; ...
"7695b43b41732a0f15d3799c8eed2852665fe8da29fd700c383550fc16e521a3"; ...
"9a3ef4d24dd4e7fb8baaa9e30aea1395caa50f583630f69047c8e20f2e8d9554"; ...
"9a3ef4d24dd4e7fb8baaa9e30aea1395caa50f583630f69047c8e20f2e8d9554"; ...
"9a3ef4d24dd4e7fb8baaa9e30aea1395caa50f583630f69047c8e20f2e8d9554"];
rpc_type = ["http"; "http"; "mc"; "rpc";"mc"];
downstream_ms = ["7695b43b41732a0f15d3799c8eed2852665fe8da29fd700c383550fc16e521a3"; ...
"9a3ef4d24dd4e7fb8baaa9e30aea1395caa50f583630f69047c8e20f2e8d9554"; ...
"9653f5baba69c9fb50bfb30a8571eb04dbceaae7c7f379e20bd73a41168a2913"; ...
"9a3ef4d24dd4e7fb8baaa9e30aea1395caa50f583630f69047c8e20f2e8d9554"; ...
"9ee59483550ea795bc04e930ad6b37b7852e92fa9a71556565e91380dd39de03"];
interface = ["1f888de4377607e9402377e6ab0e83cc3c542b95e9c2133caa7e29e2028796a0"; ...
"1f888de4377607e9402377e6ab0e83cc3c542b95e9c2133caa7e29e2028796a0"; ...
""; ...
"da36ccfdc24fd53f0626f1a2b234ded133e139f240ae650cd6f707c424c5c3e8"; ...
""];
response_time = [-8; -4; 1; 0; 0];

trace = table(Nr, trace_id, timestamp, rpc_id, upstream_ms, rpc_type, downstream_ms, interface, response_time);


fprintf("digraph+jsonencode");
tic
get_trace_json(trace)
toc

% Structure of trace is:
% synthetic_id_as_the_upstream_of_this_trace_entry_is_the_end_user
% |_ 7695b43b41732a0f15d3799c8eed2852665fe8da29fd700c383550fc16e521a3
%    |_ 9a3ef4d24dd4e7fb8baaa9e30aea1395caa50f583630f69047c8e20f2e8d9554
%       |_ [calls self]
%       |_ 9653f5baba69c9fb50bfb30a8571eb04dbceaae7c7f379e20bd73a41168a2913
%       |_ 9ee59483550ea795bc04e930ad6b37b7852e92fa9a71556565e91380dd39de03

% fprintf("string concat");
% tic
% involved_ms = unique([trace.upstream_ms ; trace.downstream_ms]);
% concatted = get_json_mubench('0.1',trace,involved_ms,0)
% toc
% jsonencode(jsondecode("{"+concatted+"}"), "PrettyPrint",true)