%% plot multiobjective trend, all weigths

clc
close all
cd ..
cd ..
cd TESTS\

plot_outside_gui =app.ShowoutsideGUICheckBox.Value;


if plot_outside_gui == 1
D = dir; % A is a struct ... first elements are '.' and '..' used for navigation.
figure
for k = 3:length(D) % avoid using the first ones
    if isdir(D(k).name) % cosi salto il file output.txt e navigo solo le cartelle dei weights
        currD = D(k).name % Get the current subdirectory name
        cd(currD)
        disp(k-2) % decommentalo solo per capire il ciclo
        load('test.mat', 'TEST')
        k = find(TEST(:,5) == max(TEST(:,5))) %restituisce la riga della matrice di test con la funzione multiobiettivo migliore
        key = TEST(k,3)
        s1 = 'G';
        s2 = num2str(TEST(k,2));
        s3 = '.mat';
        s= append(s1,s2,s3);
        load(s)
        % Run your function. Note, I am not sure on how your function is written,
        % but you may need some of the following
        n_dep =key;

        hold on
        plot(TEST(:,1),TEST(:,6))
        title("Progressione del current best objective, con plateau. rappr dynamics")
        xlabel('ID')
        ylabel('CURRENT BEST MOBJ-Value')
        cd ..
    end
end
else 
D = dir; % A is a struct ... first elements are '.' and '..' used for navigation.
f = figure
for k = 3:length(D) % avoid using the first ones
    if isdir(D(k).name) % cosi salto il file output.txt e navigo solo le cartelle dei weights
        currD = D(k).name % Get the current subdirectory name
        cd(currD)
        disp(k-2) % decommentalo solo per capire il ciclo
        load('test.mat', 'TEST')
        k = find(TEST(:,5) == max(TEST(:,5))) %restituisce la riga della matrice di test con la funzione multiobiettivo migliore
        key = TEST(k,3)
        s1 = 'G';
        s2 = num2str(TEST(k,2));
        s3 = '.mat';
        s= append(s1,s2,s3);
        load(s)
        % Run your function. Note, I am not sure on how your function is written,
        % but you may need some of the following
        n_dep =key;

        hold(app.UIAxes,"on")
        plot(TEST(:,1),TEST(:,6))
        h = gca;
        h.Children.Parent=app.UIAxes;
        hold(app.UIAxes,"on")
        cd ..
    end
end
app.UIAxes.XLabel.String = 'ID';
    app.UIAxes.YLabel.String = 'CURRENT BEST MOBJ-Value';
    app.UIAxes.Title.String = "Progressione del current best objective, con plateau. rappr dynamics";
    axis(app.UIAxes, 'tight')
close(f)
end
cd ..