%% Modulo TORUN
% Questo modulo è utilizzato per eseguire i test di calibrazione del sistema.
% Utilizza i pesi specificati nella variabile "weigths" per generare percorsi di cartelle
% e memorizzare i dati acquisiti durante i test.
% Inoltre, esegue il codice specificato in "COLLECTOR_single" o "COLLECTOR_multi"
% a seconda del valore di "test_mode".
% Infine, copia i file "G*" e "test.mat" nella cartella creata per ogni set di pesi.

clearvars -except app event % pulisce le variabili tranne quelle specificate come eccezioni
close all; % chiude tutte le finestre aperte
clc % pulisce la console

myhome = pwd; % salva la posizione corrente in una variabile myhome
save('cache/myhomedata', 'myhome') % salva la posizione corrente nella cartella cache con il nome myhomedata
cd(myhome); % cambia la directory corrente alla posizione salvata in myhome
test_mode = app.ModeButtonGroup.Buttons.Value; % recupera il valore del bottone selezionato dall'app per determinare la modalità di test
mobj_coeff_tuning = app.MOBJweightsexplorationCheckBox.Value; % recupera il valore della checkbox per determinare se esplorare i coefficienti della funzione multi-obiettivo
kml_import = app.TopologyButtonGroup.Buttons.Value; % recupera il valore del bottone per determinare se importare un file kml
addpath Data functions toload  % aggiunge le cartelle specificate alla lista di ricerca delle funzioni
addpath(genpath('cache')) % aggiunge la cartella cache e le sue sottocartelle alla lista di ricerca delle funzioni
addpath(genpath('Scripts')) % aggiunge la cartella Scripts e le sue sottocartelle alla lista di ricerca delle funzioni
tic; % inizia il cronometro per misurare il tempo di esecuzione del script

% Controlla se la casella di controllo di post elaborazione è selezionata
if app.PostprocessingCheckBox.Value == 1

else
% Controlla se la directory 'TESTS' esiste
if exist('TESTS', 'dir')
% Se esiste, rimuovi la directory
rmdir TESTS s;
% E creane una nuova
mkdir TESTS;
else
% Se non esiste, crea la directory 'TESTS'
mkdir TESTS;
end
end

% Creo una variabile 'p' che contiene il percorso completo della cartella 'TESTS'
p = genpath('TESTS');
% Aggiungo il percorso 'p' alla lista dei percorsi di ricerca
addpath(p);

% Apro il file 'output.txt' in modalità di scrittura e cancello il contenuto
fopen('output.txt','w');
% Attivo il registro delle attività nel file 'output.txt'
diary output.txt
diary on
% Inizializzo un array vuoto per i pesi
weigths =[];

% Se la modalità di test è attiva (test_mode == 1)
if test_mode == 1
% Assegno i valori delle variabili 'a', 'b' e 'c' dalle caselle di input dell'app
a = app.aEditField.Value;
b = app.bEditField.Value;
c = app.cEditField.Value;
else
    
% inizia il caso multimodale
if mobj_coeff_tuning == 1 % in questo caso forniamo il massimo e il minimo del coefficiente e lo step
min_mobjf_coeff = app.MinimumMOBJFcoefficientEditField.Value; % assegna il valore minimo del coefficiente
max_mobjf_coeff = app.MaximumMOBJFcoefficientEditField.Value; % assegna il valore massimo del coefficiente
step_mobjf_coeff = app.StepEditField.Value; % assegna il valore dello step del coefficiente
a = min_mobjf_coeff:step_mobjf_coeff:max_mobjf_coeff; % genera un array di valori del coefficiente tra il minimo e il massimo con passo specificato
b = 0.5*(1-a); % genera un array di valori per b
c = b; % genera un array di valori per c
else
a = app.aEditField_2.Value; % assegna il valore di a
b = app.bEditField_2.Value; % assegna il valore di b
c = app.cEditField_2.Value; % assegna il valore di c
end
end
for i=1:length(a) % per ogni valore di a
weigths{i}=[a(i),b(i),c(i)]; % assegna il valore di a,b,c all'array di pesi
end

% La calibrazione multi-oggettivo viene eseguita solo all'inizio
% La proprietà Color dell'oggetto "CalibrationstatusLamp" viene impostata su giallo
app.CalibrationstatusLamp.Color = [1 1 0];
drawnow;

% Se la casella di controllo "DisablecalibrationCheckBox" non è selezionata,
% viene eseguita la funzione di calibrazione
if app.DisablecalibrationCheckBox.Value == 0
calibration;
else
% altrimenti non viene eseguita la calibrazione
mobj_calibration = 0;
% e si carichera' f1 f2 f3 direttamente dalla cartella di cache
end

% pulizia delle variabili, tranne quelle specificate
clearvars -except weigths test_mode progressbar p myhome mobj_coeff_tuning kml_import i event app mobj_calibration

% Inizia un ciclo for che itera su ogni elemento della variabile "weights"
for sa = 1:length(weigths)
    % Assegna i valori di alpha, beta e gamma come primo, secondo e terzo elemento dell'elemento corrente di "weigths"
    alpha = weigths{1,sa}(1)
    beta = weigths{1,sa}(2)
    gamma = weigths{1,sa}(3)
    % Crea una stringa per il percorso della cartella
    path = ['TESTS/',num2str(alpha),'_',num2str(beta),'_',num2str(gamma)];
    % Crea la cartella specificata dalla stringa "path"
    mkdir(path) 
    % Crea un percorso completo alla cartella "TESTS"
    p = genpath('TESTS');
    % Aggiunge il percorso alla lista dei percorsi di Matlab
    addpath(p);
    % Se test_mode è uguale a 1, esegue la funzione COLLECTOR_single
    if test_mode == 1 
        COLLECTOR_single;
    % Altrimenti esegue la funzione COLLECTOR_multi
    else 
        COLLECTOR_multi;
    end
    % Crea una stringa per il percorso dei file "G*" nella cartella "Data"
    source1 = fullfile('Data','G*');
    % Crea una stringa per il percorso del file "test.mat" nella cartella "Data"
    source2 = fullfile('Data','test.mat');
    % Copia i file specificati da "source1" e "source2" nella cartella specificata da "path"
    copyfile(source1,path);
    copyfile(source2,path);
end
% Chiude il diario
diary off
% Copia il file "output.txt" nella cartella "TESTS"
copyfile('output.txt',['TESTS/']);
% Chiude tutti i file aperti
fclose('all');