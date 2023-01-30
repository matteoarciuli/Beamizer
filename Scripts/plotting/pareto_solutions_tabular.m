%replot from old tests in dashboard
close all
load('cache/myhomedata.mat'); %load home path
cd(myhome)
cd TESTS

D = dir; % A is a struct ... first elements are '.' and '..' used for navigation.

for k = 3:length(D) % in questo modo salto . e ..
 if isdir(D(k).name) % cosi salto il file output.txt e navigo solo le cartelle dei weights
        currD = D(k).name; % Get the current subdirectory name
        cd(currD);
        if app.ModeButtonGroup.Buttons(1).Value == 1
        load('G1.mat'); %carico sempre la prima, ma in realta' devo segnarmi il gruppo cosi da caricarlo
        n_dep = 1; %nel caso single test
        end
        if app.ModeButtonGroup.Buttons(2).Value == 1
        load("test.mat")
        id_sel = app.IDEditField.Value;
        k = id_sel+1;
        key = TEST(k,3)
        s1 = 'G';
        s2 = num2str(TEST(k,2));
        s3 = '.mat';
        s= append(s1,s2,s3);
        load(s)
        n_dep = key; %nel caso single test
        end
    end 
end
      

 x =TEST(:,7:9);
[membership,member_value] = find_pareto_frontier(x);
pareto_frontier_solutions_index = find(membership == 1);
%retrieve the test matrix solutions on the pareto front is like a cercavert

for i = 1:length(pareto_frontier_solutions_index)
    pareto_front(i,:) = TEST(pareto_frontier_solutions_index(i),:) ;

end 
pareto_front(:,5:6) = [];
pareto_front(:,8:11) = [];

indici = find ( pareto_front(:,4) == str2num(app.SubsetAmplitudeDropDown.Value))
tabella = array2table(pareto_front(indici,:), 'VariableNames', {'colonna1', 'colonna2', 'colonna3','4','5','6','7'});
nuovaTabella = tabella(:, [1 3 5 6 7]);
% Rinomina le colonne della tabella
nuovaTabella.Properties.VariableNames = {'id', 'tentativo', 'f1', 'f2', 'f3'};

% Stampa la tabella

% Aggiungi la tabella alla figura
set(app.UITable, 'Data', nuovaTabella);
cd ..
cd ..
function [membership, member_value]=find_pareto_frontier(input)
out=[];
data=unique(input,'rows');
for i = 1:size(data,1)

    c_data = repmat(data(i,:),size(data,1),1);
    t_data = data;
    t_data(i,:) = Inf(1,size(data,2));
    smaller_idx = c_data>=t_data;

    idx=sum(smaller_idx,2)==size(data,2);
    if ~nnz(idx)
        out(end+1,:)=data(i,:);
    end
end
membership = ismember(input,out,'rows');
member_value = out;
end




