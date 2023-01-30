%% Modulo Collector 
% modalità singola
% utile per debug e postprocessing

clearvars -except sa alpha beta gamma weigths path progressbar app event test_mode myhome kml_import mobj_coeff_tuning mobj_calibration
%close all;


numerosity = app.NumberofgNBsEditField.Value; % valore del numero di gNB da installare
ID = 0; % ID dell'esperimento corrente
ext = 1;
TEST = []; %  matrice che contiene tutte le informazioni di un esperimento
cbc = []; %  matrice che contiene i valori current best mobj
cb_net_emf =[]; %   matrice che contiene l'evoluzione del net emf con il miglior mobj attuale
cb_ctot = []; % matrice che contiene l'evoluzione costo con il miglior mobj attuale
cb_net_tp =[]; % matrice che contiene l'evoluzione del throughput con il miglior mobj attuale

filenumb =1; 
%  variabile per il tempo di inizio dell'esperimento
tStart = tic;
% lancio modulo che recupera le coordinate delle posizioni consentite
% per l'installazione di nuovi siti
operator; 
%inizializzazione delle variabili per la raccolta dati
ms_collect={};
tp_collect={};
m_obj_collect ={};
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
trials = 1; 
if ID == 0
    pext=1;
    dinamics = 0;

end

if ext==pext+1
    numerosity = pnumerosity +1;
    filenumb = filenumb+1;
end

tic;
clearvars -except trials accuracy r num_user tp_collect ms_collect m_obj_collect served_ratio unserved_ratio exec_time ds_served ds_unserved ...
    avg_tp_collect avg_emf_collect deployment_BS data_ms_collect numerosity filenumb selected_winner n0 M_OBJ_COLLECT ext tStart ID TEST pext pnumerosity MAX_num cbc pcb dinamics ctot_collect cb_net_emf cb_ctot cb_net_tp sa alpha beta gamma weigths path progressbar app event myhome kml_import mobj_coeff_tuning mobj_calibration


dsms=0;
dep_key =trials;
% lancio modulo generator per ottenere i deployment spots
GENERATOR;
dsms=1;
dep_key =trials;
% lancio modulo generator per ottenere i measurement spots
GENERATOR;
% lancio modulo locplan
LOCPLAN;

% raccolta dati postprocessati
if app.PostprocessingCheckBox.Value == 1
    ms_collect={};
    tp_collect={};
    m_obj_collect ={};
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
end
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
cb_net_tp = [cb_net_tp c_net_tp];% miglior valore attuale per il throughput

X = ['ID:',num2str(sprintf('%3.0f',ID)),'  GRUPPO:',num2str(sprintf('%3.0f',ext)),'  TENTATIVO:',num2str(sprintf('%3.0f',trials)),' AMPIEZZA-SUBSET:',num2str(sprintf('%3.0f',numerosity)),'  MOBJ:', num2str(sprintf('%0.4f',m_obj_sol2)),'  CURRENT-BEST:',num2str(sprintf('%0.4f',max(cbc))),'  f1/f2/f3:',num2str((sprintf('%0.4f',f_1))),'/',num2str((sprintf('%0.4f',f_2))),'/',num2str((sprintf('%0.4f',f_3))),'  USERS.COV(%)',num2str((sprintf('%5.1f',ratio_served*100))),' ', ctrl,'  COST-BMOF ',num2str(sprintf('%7.0f',c_ctot)),'  EMF-BMOF', num2str(sprintf('%7.4f',c_net_emf)),'  TP', num2str(sprintf('%12.0f',c_net_tp))];
disp(X)
TEST = [TEST; ID, ext, trials, numerosity,m_obj_sol2,max(cbc), f_1, f_2, f_3, ratio_served*100,c_ctot,c_net_emf,c_net_tp];%, f_1, f_2, f_3, ratio_served*100];
ID = ID+1;
pcb = cb;
trials = trials+1;
filename=( ['Data/G' num2str(filenumb) '.mat'] );
save(filename,'tp_collect','ms_collect','m_obj_collect','M_OBJ_COLLECT','served_ratio','unserved_ratio','exec_time','ds_served','ds_unserved','avg_tp_collect','avg_emf_collect','deployment_BS','data_ms_collect','numerosity','ctot_collect');
winner = max(cell2mat(M_OBJ_COLLECT));

tEnd =toc(tStart);
X = ['TEMPO DI ESECUZIONE TOTALE = ',num2str(tEnd),' [sec]'];
disp(X)
app.Executiontotaltime.Value = num2str(tEnd);
drawnow;
save('Data/test.mat','TEST');
Y = ["Set di pesi utilizzato", 'ALPHA: ',num2str(alpha), 'BETA: ',num2str(beta), 'GAMMA: ',num2str(gamma)];
disp(Y)