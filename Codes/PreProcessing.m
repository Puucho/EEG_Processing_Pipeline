SetFiles = dir([PathCUT '*.set']); %Refresh Set Files
%% PREPROCESSING
for SubjID = 1: length(SetFiles);
    loadName = SetFiles(SubjID).name;
    dataName = loadName(1:end-4);
    saveName = [dataName '_PP'] %adding 'PP' (PreProcessed) to file name
    
    %Step 1: Import data. 
%   EEG = pop_biosig(loadName, PathCUT); %IF .EDF
    EEG = pop_loadset(loadName, PathCUT); %IF .SET
    EEG.setname = dataName;

    %STEP 2: Changing sample rate GA DIPAKE
%     EEG = pop_resample(EEG, 250);

    %STEP 3: High-pass filter and Low pass filter
    EEG = pop_eegfiltnew(EEG,1,50,826);

    %STEP 4: Select channels (Ini yang 3:16 atau 1:19)
    EEG = pop_select( EEG,'channel',ChanNum);
    
    %STEP 5: Importing channel location
    EEG.chanlocs = readlocs(CHLocs)
    
        %Keeping original EEG file
        originalEEG = EEG; % Just back up original EEG data
        
    %STEP 6: Removing bad channels by using raw_clean plug in
    EEG = clean_rawdata(EEG, 5, [0.25 0.75], 0.8, 4, 5, 0.5);

    %STEP 7: Interpolate channels.
    EEG = pop_interp(EEG, originalEEG.chanlocs, 'spherical');

    %STEP 8: Apply average reference after adding initial reference (Re-Reference)
    EEG.nbchan = EEG.nbchan+1;
    EEG.data(end+1,:) = zeros(1, EEG.pnts);
    EEG.chanlocs(1,EEG.nbchan).labels = 'initialReference';
    EEG = pop_reref(EEG, []);
    EEG = pop_select( EEG,'nochannel',{'initialReference'});

    %STEP 9: Epoching data 1 to 3 sec
    EEG = eeg_regepochs(EEG, 'limits', [1 3] , 'extractepochs', 'on'); % RUBAH timing epoch

    %STEP 10: Automatic epoch rejection
    EEG = pop_autorej(EEG, 'threshold', 1000,'startprob',5,'maxrej', 5, 'nogui','on'); %nogui diganti on, eegplot hapus aja
    
    %STEP 11: Rejection epoch by probability (6SD single channel, 2SD for all channels)
    EEG = eeg_checkset( EEG );
    EEG = pop_jointprob(EEG,1,[1:14] ,6,2,1,0,0,[],0);
    
    %STEP 12: Running ICA (Ini lama nih prosesnya)
    EEG = eeg_checkset(EEG);
    EEG = pop_runica(EEG, 'extended',1,'interupt','on');
    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    
    %STEP 13 : Checking whether EEG data contains ICA decomposition
    EEG = eeg_checkset(EEG, 'ica');
    
    %STEP 14: Removing line noise with cleanLine;
    EEG = pop_cleanline(EEG,'Bandwidth',2,'ChanCompIndices',[1:EEG.nbchan],...
        'ComputeSpectralPower',0,'LineFrequencies',[60 120],...
        'NormalizeSpectrum',0,'LineAlpha',0.01,'PaddingFactor',2,...
        'PlotFigures',0,'ScanForLines',1,'SignalType','Channels',...
        'SmoothingFactor',100,'VerboseOutput',1); % HAPUS SlidingWinLength dan SlidingWinstep
    
    %STEP 15: Rejecting ICA by extreme value
    EEG = pop_eegthresh(EEG,0,[1:5] ,-20,20,1,2.996,0,1);

    %Save new preprocessed File (with added "_PP")
    EEG = pop_saveset(EEG, 'filename',saveName,'filepath', PathPROC);  
end

