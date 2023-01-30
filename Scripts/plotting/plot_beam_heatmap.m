%% PLOT BEAMS
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



x_site=deployment_BS{1,n_dep}(:,1); %tutte le righe che contengono le x delle gNB
y_site=deployment_BS{1,n_dep}(:,2); %tutte le righe che contengono le y delle gNB
pointsize = 5;
plot_outside_gui =app.ShowoutsideGUICheckBox.Value;
if plot_outside_gui == 1


% % 
% %     figure
% %     scatter(data_ms_collect{1,n_dep}(:,1), data_ms_collect{1,n_dep}(:,2), pointsize, data_ms_collect{1,n_dep}(:,4), 'filled');
% %     hold on;
% %     plot(x_site,y_site, 'm^');
% %     title('Beam plot');
% %     colorbar
% %    % caxis(log10([0.1 1]));
% %     hold on;
% %     grid on;



    figure;
scatter(data_ms_collect{1,n_dep}(:,1), data_ms_collect{1,n_dep}(:,2), pointsize, data_ms_collect{1,n_dep}(:,4), 'filled');
colormap(turbo);

hold on;
plot(x_site,y_site, 'm^');
title('Beam plot');
grid on;
else
    f = figure;
%     scatter(data_ms_collect{1,n_dep}(:,1), data_ms_collect{1,n_dep}(:,2), pointsize, data_ms_collect{1,n_dep}(:,4), 'filled');
    scatter(data_ms_collect{1,n_dep}(:,1),data_ms_collect{1,n_dep}(:,2),pointsize,data_ms_collect{1,n_dep}(:,4),"filled","square");
    h = gca;
    h.Children.Parent=app.UIAxes;
    hold(app.UIAxes,"on")
    plot(x_site,y_site, 'm^');
    colorbar
    h = gca;
    h.Children.Parent=app.UIAxes;
    c = colorbar(app.UIAxes)
    colormap(app.UIAxes, turbo)
    c.Label.String = 'Electric field Strength V/m';
    hold(app.UIAxes,"on")
    grid(app.UIAxes,"on")
    close(f)
end
cd ..
cd ..