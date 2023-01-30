%% Aggiornamento dashboard GUI 

load cache\Normalization\curr_max_gNB_num.mat
app.AttemptsGauge.Value = trials;

app.SubsetAmplitudeGauge.Value = numerosity;
app.SubsetAmplitudeGauge.Limits  = [2,curr_max_gNB_num];
app.livenumbersubsetamplitude.Value = num2str(sprintf('%3.0f',numerosity));

app.livenumberattempts.Value = num2str(sprintf('%3.0f',trials));
app.liveid.Value = num2str(sprintf('%3.0f',ID));