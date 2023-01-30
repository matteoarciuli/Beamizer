%% PLOT DEPLOYMENT WITH SERVED AND UNSERVED SPOTS
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


plot_outside_gui =app.ShowoutsideGUICheckBox.Value;

if plot_outside_gui == 1
    figure; %figure porta in primo piano l'immagine
    grid on;
    hold on;


   scatter(ds_served{n_dep,1}(:,1), ds_served{n_dep,1}(:,2), '*', 'MarkerEdgeColor',[0 0 0],...
        'MarkerFaceColor',[0 .7 .7],...
        'LineWidth',1.5)
    hold on;
    plot(ds_unserved{n_dep,1}(:,1),ds_unserved{n_dep,1}(:,2),'*','color',[0.6350 0.0780 0.1840]);
    hold on;

    x_site=(deployment_BS{n_dep,1}(:,1)); %tutte le righe che contengono le x delle gNB
    y_site=(deployment_BS{n_dep,1}(:,2)); %tutte le righe che contengono le y delle gNB
    plot(x_site,y_site, 'm^', 'MarkerEdgeColor',[1 0 1],...
        'MarkerFaceColor',[1 1 1],'LineWidth',2);

    title("Deployment, gNB and deploy spots")
else
    f = figure;
    hold(app.UIAxes,"on");
    m = scatter(ds_served{1,n_dep}(:,1), ds_served{1,n_dep}(:,2), '.', 'MarkerEdgeColor',[0 0 0],...
        'MarkerFaceColor',[1 1 1],...
        'LineWidth',20)
   
    h = gca;
    h.Children.Parent=app.UIAxes;
    

    hold(app.UIAxes,"on");
   

    %NON VOGLIO MOSTRARE GLI UNSERVED
    m = plot(ds_unserved{1,n_dep}(:,1),ds_unserved{1,n_dep}(:,2), '.', 'MarkerEdgeColor',[1 0 0],...
        'MarkerFaceColor','none',...
        'LineWidth',1);
    
    h = gca;
    h.Children.Parent=app.UIAxes;
    hold(app.UIAxes,"on");

    x_site=(deployment_BS{1,n_dep}(:,1)); %tutte le righe che contengono le x delle gNB
    y_site=(deployment_BS{1,n_dep}(:,2)); %tutte le righe che contengono le y delle gNB
    m = plot(x_site,y_site, 'm^');

    h = gca;
    h.Children.Parent=app.UIAxes;
    grid(app.UIAxes,"on")

 % disegno la uncertainty area
    for i = 1:length(ds_served{1,n_dep})
            p = nsidedpoly(1000, 'Center', [ds_served{1,n_dep}(i,1)  ds_served{1,n_dep}(i,2)], 'Radius', (app.LocalizationAccuracymEditField.Value)/2);
            m = plot(p, 'FaceColor', 'b')
            h = gca;
            h.Children.Parent=app.UIAxes;
   
            hold(app.UIAxes,"on");
      
    end

     for i = 1:length(x_site)
            p = nsidedpoly(1000, 'Center', [deployment_BS{1,n_dep}(i,1)  deployment_BS{1,n_dep}(i,2)], 'Radius', 10);
            m = plot(p, 'FaceColor', 'w','FaceAlpha', 1)
            h = gca;
            h.Children.Parent=app.UIAxes;
   
            hold(app.UIAxes,"on");
      
    end

    app.UIAxes.XLabel.String = 'X[m]'
    app.UIAxes.YLabel.String = 'Y[m]'
    app.UIAxes.Title.String = 'Active deployment spots and serving beams'
    close(f)
end
cd ..
cd ..