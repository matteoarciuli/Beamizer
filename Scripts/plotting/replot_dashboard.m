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

cla(app.liveplot)
cla(app.liveplot_2)
cla(app.liveplot_5)
cla(app.liveplot_4)
cla(app.liveplot_3)


plot_outside_gui =app.ShowoutsideGUICheckBox.Value;
if plot_outside_gui == 1
        figure;
        x =TEST(:,7:9);
        [membership,member_value] = find_pareto_frontier(x);
        plot3(x(:,1),x(:,2),x(:,3),'.k','markersize',12);
        hold on
        plot3(member_value(:,1),member_value(:,2),member_value(:,3),'.r','markersize',15);
        grid on
        
        figure
        plot(TEST(:,1),TEST(:,5))
        figure
        plot(TEST(:,1),TEST(:,6))
        figure
        plot(TEST(:,1),TEST(:,11))
        figure
        plot(TEST(:,1),TEST(:,13))
        figure
        plot(TEST(:,1),TEST(:,12))
       
else
        f=figure;
%         plot(TEST(:,1),TEST(:,5))
      
        x =TEST(:,7:9);
        [membership,member_value] = find_pareto_frontier(x);
        plot3(x(:,1),x(:,2),x(:,3),'.k','markersize',12);
        lpvar = gca;
        lpvar.Children.Parent=app.liveplot;
        hold on
        plot3(member_value(:,1),member_value(:,2),member_value(:,3),'.r','markersize',15);
        lpvar = gca;
        lpvar.Children.Parent=app.liveplot;
        close(f)
        drawnow;


         f=figure;
        plot(TEST(:,1),TEST(:,5))
        lpvar = gca;
        lpvar.Children.Parent=app.liveplot_2;
        hold on
        plot(TEST(:,1),TEST(:,6),'Color', 'red')
        lpvar = gca;
        lpvar.Children.Parent=app.liveplot_2;
        close(f)
        drawnow;
        %costs
        f=figure;
        plot(TEST(:,1),TEST(:,11))
        lpvar = gca;
        lpvar.Children.Parent=app.liveplot_5;
        close(f)
        drawnow;
        %emf prog
        f=figure;
        plot(TEST(:,1),TEST(:,13))
        lpvar = gca;
        lpvar.Children.Parent=app.liveplot_4;
        close(f)
        drawnow;
        %trhoughput
        f=figure;
        plot(TEST(:,1),TEST(:,12))
        lpvar = gca;
        lpvar.Children.Parent=app.liveplot_3;
        close(f)
        drawnow;
        
end
        cd ..
cd ..