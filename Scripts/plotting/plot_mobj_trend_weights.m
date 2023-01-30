%% plot multiobjective trend, all weigths

clc
close all
cd ..
cd ..
cd TESTS

plot_outside_gui =app.ShowoutsideGUICheckBox.Value;

if plot_outside_gui == 1
    D = dir; % A is a struct ... first elements are '.' and '..' used for navigation.
    figure
for k = 3:length(D) % in questo modo salto . e ..
    if isdir(D(k).name) % cosi salto il file output.txt e navigo solo le cartelle dei weights

        currD = D(k).name; % Get the current subdirectory name
        cd(currD);
        disp(k-2) % decommentalo solo per capire il ciclo
        disp(currD)
        load('test.mat', 'TEST');
        k = find(TEST(:,5) == max(TEST(:,5))); %restituisce la riga della matrice di test con la funzione multiobiettivo migliore
        key = TEST(k,3);

        X = ['ID:',num2str(sprintf('%3.0f',TEST(k,1))),'  GRUPPO:',num2str(sprintf('%3.0f',TEST(k,2))),'  TENTATIVO:',num2str(sprintf('%3.0f',TEST(k,3))),' AMPIEZZA-SUBSET:',num2str(sprintf('%3.0f',TEST(k,4))),'  MOBJ:', num2str(sprintf('%0.4f',TEST(k,5))),'  CURRENT-BEST:',num2str(sprintf('%0.4f',TEST(k,6))),'  f1/f2/f3:',num2str((sprintf('%0.4f',TEST(k,7)))),'/',num2str((sprintf('%0.4f',TEST(k,8))))];
        disp(X)
        s1 = 'G';
        s2 = num2str(TEST(k,2));
        s3 = '.mat';
        s= append(s1,s2,s3);
        load(s) % cosi faccio il load della G.mat associata al max per il coefficente attuale
        % Run your function. Note, I am not sure on how your function is written,
        % but you may need some of the following
        n_dep =key;

        hold on
        plot(TEST(:,1),TEST(:,5)) %plot id sulle x e current best obj sulle y
        title("Multiobjective trend using different weights")
        xlabel('ID')
        ylabel('MOBJ-Value')
        cd ..
    end
end
else
     D = dir; % A is a struct ... first elements are '.' and '..' used for navigation.
     f = figure;
for k = 3:length(D) % in questo modo salto . e ..
    if isdir(D(k).name) % cosi salto il file output.txt e navigo solo le cartelle dei weights

        currD = D(k).name; % Get the current subdirectory name
        cd(currD);
        disp(k-2) % decommentalo solo per capire il ciclo
        disp(currD)
        load('test.mat', 'TEST');
        k = find(TEST(:,5) == max(TEST(:,5))); %restituisce la riga della matrice di test con la funzione multiobiettivo migliore
        key = TEST(k,3);

        X = ['ID:',num2str(sprintf('%3.0f',TEST(k,1))),'  GRUPPO:',num2str(sprintf('%3.0f',TEST(k,2))),'  TENTATIVO:',num2str(sprintf('%3.0f',TEST(k,3))),' AMPIEZZA-SUBSET:',num2str(sprintf('%3.0f',TEST(k,4))),'  MOBJ:', num2str(sprintf('%0.4f',TEST(k,5))),'  CURRENT-BEST:',num2str(sprintf('%0.4f',TEST(k,6))),'  f1/f2/f3:',num2str((sprintf('%0.4f',TEST(k,7)))),'/',num2str((sprintf('%0.4f',TEST(k,8))))];
        disp(X)
        s1 = 'G';
        s2 = num2str(TEST(k,2));
        s3 = '.mat';
        s= append(s1,s2,s3);
        load(s) % cosi faccio il load della G.mat associata al max per il coefficente attuale
        % Run your function. Note, I am not sure on how your function is written,
        % but you may need some of the following
        n_dep =key;

        hold(app.UIAxes,"on")
        plot(TEST(:,1),TEST(:,5)) %plot id sulle x e current best obj sulle y
        h = gca;
        h.Children.Parent=app.UIAxes;
        hold(app.UIAxes,"on")
%         title("Multiobjective trend using different weights")
%         xlabel('ID')
%         ylabel('MOBJ-Value')
        cd ..
    end
end
    app.UIAxes.XLabel.String = 'ID';
    app.UIAxes.YLabel.String = 'MOBJ-Value';
    app.UIAxes.Title.String = "Multiobjective trend using different weights";
    axis(app.UIAxes, 'tight')
close(f)
end 

cd ..