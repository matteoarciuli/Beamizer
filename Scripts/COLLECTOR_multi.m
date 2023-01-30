%% Modulo Collector 
% modalità multipla
% problema di ottimizzazione della funzione multi-obiettivo

% cancella tutte le variabili ad eccezione di quelle elencate
clearvars -except sa alpha beta gamma weigths path progressbar app event test_mode myhome kml_import mobj_coeff_tuning mobj_calibration


numerosity = app.MinimumnumberofgNBsEditField.Value; % valore minimo del numero di gNBs
MAX_num = app.MaximumnumberofgNBsEditField.Value; % valore massimo del numero di gNBs
Max_attempts_per_group = app.GroupattemptsEditField.Value; % numero massimo di tentativi per gruppo
ID = 0; % ID dell'esperimento corrente
ext = 1;
TEST = []; %  matrice che contiene tutte le informazioni di un esperimento
cbc = []; %  matrice che contiene i valori current best mobj
cb_net_emf =[]; %   matrice che contiene l'evoluzione del net emf con il miglior mobj attuale
cb_ctot = []; % matrice che contiene l'evoluzione costo con il miglior mobj attuale
cb_net_tp =[]; % matrice che contiene l'evoluzione del throughput con il miglior mobj attuale

filenumb =1; 
tStart = tic; %  variabile per il tempo di inizio dell'esperimento
% lancio modulo che recupera le coordinate delle posizioni consentite
% per l'installazione di nuovi siti
operator;
% pulisci i grafici app.liveplot, app.liveplot_2, app.liveplot_5, app.liveplot_4 e app.liveplot_3
cla(app.liveplot)
cla(app.liveplot_2)
cla(app.liveplot_5)
cla(app.liveplot_4)
cla(app.liveplot_3)


while numerosity <= MAX_num 
    
    %inizializzazione delle variabili per la raccolta dati
    ms_collect={};
    tp_collect={};
    M_OBJ_COLLECT={};
    served_ratio ={};
    unserved_ratio ={};
    exec_time ={};
    ds_served ={};
    ds_unserved={};
    avg_tp_collect = {};
    avg_emf_collect ={};
    deployment_BS ={};
    data_ms_collect={};
    selected_winner = {};
    ctot_collect ={};
    
    trials = 1; %inizializzo trials 
    
    if ID == 0
        pext=1;
        dinamics = 0;
        
    end
    
    if ext==pext+1
        numerosity = pnumerosity +1;
        filenumb = filenumb+1;
    end
    
    %a evita l'estrazione di subset duplicati
    if numerosity == MAX_num
        Max_attempts_per_group = 1
    end
    % fino a che il numero attuale di tentativi non supera il numero
    % massimo di tentativi per gruppo
    while dinamics < Max_attempts_per_group 

        tic;
        clearvars -except trials accuracy r num_user tp_collect ms_collect m_obj_collect served_ratio unserved_ratio exec_time ds_served ds_unserved ...
            avg_tp_collect avg_emf_collect deployment_BS data_ms_collect numerosity filenumb selected_winner n0 M_OBJ_COLLECT ext tStart ID TEST pext pnumerosity MAX_num cbc pcb dinamics ctot_collect cb_net_emf cb_ctot cb_net_tp sa alpha beta gamma weigths path progressbar app event Max_attempts_per_group test_mode myhome kml_import mobj_coeff_tuning mobj_calibration
        
        
        dsms=0;
        dep_key =trials;
        % lancio modulo generator per ottenere i deployment spots
        GENERATOR;
        % lancio modulo generator per ottenere i measurement spots
        dsms=1;
        dep_key =trials;
        GENERATOR;
        % lancio modulo locplan
        LOCPLAN;
        
        % salvataggio delle variabili raccolte per l'id corrente
        tp_collect=[tp_collect tp_ds_unw];
        ms_collect=[ms_collect data_ms(:,4)];
        M_OBJ_COLLECT = [M_OBJ_COLLECT m_obj_sol2];
        served_ratio =[served_ratio ratio_served];
        unserved_ratio = [unserved_ratio ratio_unserved];
        ds_served=[ds_served deploy_spot_comp_served];
        ds_unserved=[ds_unserved deploy_spot_unserved];
        avg_tp_collect=[avg_tp_collect avg_tp];
        avg_emf_collect=[avg_emf_collect avg_emf];
        deployment_BS = [deployment_BS BS];
        data_ms_collect = [data_ms_collect data_ms];
        % ferma il timer
        timer = toc;
        exec_time = [exec_time timer];
        ctot_collect =[ctot_collect c_tot];
        
        
        cb = max(cell2mat(M_OBJ_COLLECT));
       
        if ID ==0
            pcb =cb;

             
        end 
        if cb<pcb
            cb = pcb;
        else 
            cb = max(cell2mat(M_OBJ_COLLECT));
        end
            
        if ismember(cb,cbc)
           
            dinamics = dinamics+1;
            ctrl = '-';
            c_net_emf = cb_net_emf(end);
            c_ctot =cb_ctot(end);
            c_net_tp = cb_net_tp(end);
        else 
            dinamics =0;
            ctrl = '*';
            c_net_emf = net_emf;
            c_ctot = c_tot;
            c_net_tp = net_tp;
            
        end

        cbc =[cbc cb]; % miglior valore attuale della funzione multi-obiettivo
        cb_net_emf = [cb_net_emf c_net_emf]; % miglior valore attuale per il campo elettrico
        cb_ctot = [cb_ctot c_ctot]; % miglior valore attuale per i costi
        cb_net_tp = [cb_net_tp c_net_tp]; % miglior valore attuale per il throughput
       
        % aggiornamento della schermata dashboard
       dashboard
        
        X = ['ID:',num2str(sprintf('%3.0f',ID)),'  GRUPPO:',num2str(sprintf('%3.0f',ext)),'  TENTATIVO:',num2str(sprintf('%3.0f',trials)),' AMPIEZZA-SUBSET:',num2str(sprintf('%3.0f',numerosity)),'  MOBJ:', num2str(sprintf('%0.4f',m_obj_sol2)),'  CURRENT-BEST:',num2str(sprintf('%0.4f',max(cbc))),'  f1/f2/f3:',num2str((sprintf('%0.4f',f_1))),'/',num2str((sprintf('%0.4f',f_2))),'/',num2str((sprintf('%0.4f',f_3))),'  USERS.COV(%)',num2str((sprintf('%5.1f',ratio_served*100))),' ', ctrl,'  COST-BMOF ',num2str(sprintf('%7.0f',c_ctot)),'  EMF-BMOF', num2str(sprintf('%7.4f',c_net_emf)),'  TP', num2str(sprintf('%12.0f',c_net_tp))];
        disp(X)
        TEST = [TEST; ID, ext, trials, numerosity,m_obj_sol2,max(cbc), f_1, f_2, f_3, ratio_served*100,c_tot,net_tp,net_emf];

        %liveplotting
        f=figure;
        cla(app.liveplot)
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
        f=figure;
        plot(TEST(:,1),TEST(:,11))
        lpvar = gca;
        lpvar.Children.Parent=app.liveplot_5;
        close(f)
        drawnow;
        f=figure;
        plot(TEST(:,1),TEST(:,13))
        lpvar = gca;
        lpvar.Children.Parent=app.liveplot_4;
        close(f)
        drawnow;
        f=figure;
        plot(TEST(:,1),TEST(:,12))
        lpvar = gca;
        lpvar.Children.Parent=app.liveplot_3;
        close(f)
        drawnow;
        ID = ID+1;
        pcb = cb;
        trials = trials+1;
        if dinamics ==Max_attempts_per_group
            dinamics =0;
            break
        end
        
    end
    filename=( ['Data/G' num2str(filenumb) '.mat'] );
    save(filename,'tp_collect','ms_collect','M_OBJ_COLLECT','served_ratio','unserved_ratio','exec_time','ds_served','ds_unserved','avg_tp_collect','avg_emf_collect','deployment_BS','data_ms_collect','numerosity','ctot_collect');
    winner = max(cell2mat(M_OBJ_COLLECT)); %COMMENTATO
    pext = ext;
    ext = ext+1;
    pnumerosity = numerosity;
    numerosity = numerosity+1;
    
end
tEnd =toc(tStart);
X = ['TEMPO DI ESECUZIONE TOTALE = ',num2str(tEnd),' [sec]'];
disp(X)
app.Executiontotaltime.Value = num2str(tEnd);
drawnow;
k = find(TEST(:,5) == max(TEST(:,5))) % restituisce la riga della matrice di test con la funzione multiobiettivo migliore
k = k(end);% se piu' id hanno valore funzione multiobiettivo massimo prendi l'ultima trovata tra le tante, cosi installo di piu e copro di piu 
key = TEST(k,3)
app.WinnerID.Value = num2str(k);
drawnow;
save('Data/test.mat','TEST');
Y = ["Set di pesi utilizzato", 'ALPHA: ',num2str(alpha), 'BETA: ',num2str(beta), 'GAMMA: ',num2str(gamma)];
disp(Y)