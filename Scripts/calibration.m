%% MODULO DI CALIBRAZIONE
% Questo modulo è utilizzato per calcolare i valori massimi di tp, cmax e totemf.
% calcola utilizzando la funzione LOCPLAN i termini di normalizzazione. Inoltre, registra il tempo di
% calibrazione e visualizza il risultato della calibrazione su una lampada colorata.

clearvars -except weigths progressbar app event test_mode myhome kml_import mobj_coeff_tuning
mobj_calibration = 1; % impostare la variabile di calibrazione su 1
trials = 1;
calibration_time = tic % inizio il timer per la calibrazione
app.CalibrationstatusLamp.Color = [1 1 0]; % cambia il colore della lampada di stato della calibrazione a giallo
operator; % esegue lo script dell'operatore che importa o emula la posizione della bss
% generazione dei punti di distribuzione
dsms=0;
dep_key =trials;
GENERATOR;
% generazione dei punti di misura
dsms=1;
dep_key =trials;
GENERATOR;
max_tp_emf_cal = 0; % abilita la calibrazione della tp
LOCPLAN;
max_tp_emf_cal = 1; % abilita la calibrazione della tp
LOCPLAN;
app.CalibrationstatusLamp.Color = [0 1 0]; % cambia il colore della lampada di stato della calibrazione a verde
calibration_time = toc; % arresto il timer per la calibrazione
app.calibrationtime.Value = num2str(calibration_time); % mostra il tempo di calibrazione
drawnow;
mobj_calibration = 0; % impostare la variabile di calibrazione su 0

