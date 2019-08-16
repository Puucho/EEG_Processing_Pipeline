ProcFiles = dir([PathPROC '*.set']); %Refresh List 
%% Power -- Finding Power for Each Freq
for ProcID = 1:length(ProcFiles)
    loadProc = ProcFiles(ProcID).name;
    procData = loadProc(1:end-4);
    
    EEG = pop_loadset(loadProc, PathPROC); %IF .SET
    EEG.setname = procData;
    
    for n = 1: nchannels

        [spectra,freqs] = spectopo(EEG.data(n,:,:), 0, EEG.srate, 'plot', 'off'); % Sesuaikan channel mana yang mau diambil

        % delta=1-4, theta=4-8, alpha=8-13, beta=13-30, gamma=30-80
        deltaIdx{n} = find(freqs>1 & freqs<=4);
        thetaIdx{n} = find(freqs>4 & freqs<=8);
        alphaIdx{n} = find(freqs>8 & freqs<=13);
        betaIdx{n}  = find(freqs>13 & freqs<=30);
        gammaIdx{n} = find(freqs>30 & freqs<=80);

        % compute absolute power
        deltaPower{n} = mean(10.^(spectra(deltaIdx{n})/10));
        thetaPower{n} = mean(10.^(spectra(thetaIdx{n})/10));
        alphaPower{n} = mean(10.^(spectra(alphaIdx{n})/10));
        betaPower{n}  = mean(10.^(spectra(betaIdx{n})/10));
        gammaPower{n} = mean(10.^(spectra(gammaIdx{n})/10));
    end
    
    %Save
    deltaPWR = deltaPower.';
    thetaPWR = thetaPower.';
    alphaPWR = alphaPower.';
    betaPWR = betaPower.';
    gammaPWR = gammaPower.';
    PowerTable = table(ChanName, deltaPWR, thetaPWR, alphaPWR, betaPWR, gammaPWR)
    writetable(PowerTable, [PathPOWER procData], 'Filetype', 'spreadsheet')
    
    deltaCell= cell2mat(deltaPower);
    thetaCell= cell2mat(thetaPower);
    alphaCell= cell2mat(alphaPower);
    betaCell = cell2mat(betaPower);
    gammaCell= cell2mat(gammaPower);

    % Dikumpul per wave
    deltaAll(ProcID,:) = deltaCell
    thetaAll(ProcID,:) = thetaCell
    alphaAll(ProcID,:) = alphaCell
    betaAll (ProcID,:) = betaCell
    gammaAll(ProcID,:) = gammaCell
  
end

%% STATS AND PLOT
ProcFiles = dir([PathPROC '*.set']); %Refresh List 
%% Statistics -- Indexing p-value (t-test) per Domain
for StatID = 1:JumlahDomain+1:length(ProcFiles);
%     loadStat = ProcFiles(StatID).name;
%     statData = loadStat(1:end-4);
    %Delta
     for Stat = 1:JumlahDomain;
     [h,p] = ttest(deltaAll(StatID,:),deltaAll(StatID+Stat,:));
     PValDelta(StatID+Stat) = p ; %Ngumpulin Delta p-value as PValDelta
     end
     %Theta
     for Stat = 1:JumlahDomain;
     [h,p] = ttest(thetaAll(StatID,:),thetaAll(StatID+Stat,:));
     PValTheta(StatID+Stat) = p; %Ngumpulin Theta p-value as PValTheta
     end
     %Alpha
     for Stat = 1:JumlahDomain;
     [h,p] = ttest(alphaAll(StatID,:),alphaAll(StatID+Stat,:));
     PValAlpha(StatID+Stat) = p; %Ngumpulin Alpha p-value as PValAlpha
     end
     %Beta
     for Stat = 1:JumlahDomain;
     [h,p] = ttest(betaAll(StatID,:),betaAll(StatID+Stat,:));
     PValBeta(StatID+Stat) = p; %Ngumpulin Beta p-value as PValBeta
     end
     %Gamma
     for Stat = 1:JumlahDomain;
     [h,p] = ttest(gammaAll(StatID,:),gammaAll(StatID+Stat,:));
     PValGamma(StatID+Stat) = p; %Ngumpulin Gamma p-value as PValGamma
     end
end


     %removing zeroes for Indexing
PValDelta(PValDelta==0) =[];
PValTheta(PValTheta==0) =[];
PValAlpha(PValAlpha==0) =[];
PValBeta(PValBeta==0) =[];
PValGamma(PValGamma==0) =[];

%Dikumpul jadi satu di workspace, also for 1 row Indexing
PValSubj = [PValDelta; PValTheta; PValAlpha; PValBeta; PValGamma]
[PValMin,PValIdx] = min(PValSubj) %ambil p-value paling kecil dari PValSubj all frequency

%% Plotting
for z = 1:length(PValIdx);
    loadStat = ProcFiles(z).name;
    statData = loadStat(1:end-4);
 
%indexing smallest p-value sebagai domain (if 1=delta - 5=gamma) dan menentukan koordinat untuk motong gambar nanti
 if PValIdx(z) == 1
           Coord(z) = {FrameDELTA}
           ImgName{z} = ['_delta.png']
        elseif PValIdx(z) == 2
           Coord(z) =  {FrameTHETA}
           ImgName{z} = ['_theta.png']
        elseif PValIdx(z) == 3
           Coord(z) =  {FrameALPHA}
           ImgName{z} = ['_alpha.png']
        elseif PValIdx(z) == 4
          Coord(z) =  { FrameBETA}
          ImgName{z} = ['_beta.png']
        elseif PValIdx(z) == 5
          Coord(z) = {FrameGAMMA}
          ImgName{z} = ['_gamma.png']
          
 end
end
%move BaseFile to new Folder (karena basefile gak di plot)
for BaseSet = 1:JumlahDomain+1:length(ProcFiles)
movefile([PathPROC ProcFiles(BaseSet).name], PathBASEPROC)
movefile([PathPROC ProcFDT(BaseSet).name], PathBASEPROC)
end

ProcFiles = dir([PathPROC '*.set']); %refresh filelist in the folder after moved supaya ga error

%Plotting
  for PlotID = 1:length(ProcFiles);
      PlotFile = ProcFiles(PlotID).name;
      PlotNameFull = [PlotFile(1:end-4), '_Full'];
      PlotName = [PlotFile(1:end-4),ImgName{PlotID}];
      EEG = pop_loadset(PlotFile, PathPROC);
      EEG.setname = PlotName;
      
        %open figure
        figure('units','normalized','outerposition',[0 0 1 1]);  %%Full Screen
        title(PlotName); %Title
        % Plotting Head All Freq (5 Kepala) yang belum di potong
        pop_spectopo(EEG, 1, [], 'EEG', ...
        'percent', 100, 'freq', [2 6 12 25 40], 'freqrange',[0 45], 'electrodes','off', 'overlap', 0);
        set(gcf,'color','w'); %background jadi putih instead of biru
        % Save 5 Kepala yang belum dipotong as png
        saveas(gcf, [PathFULLPLOT PlotNameFull], 'png')
        %Framing (motong) & save png Kepala per Coordinate
        FigWave = getframe(gcf, Coord{PlotID});
        figure;
        imshow(FigWave.cdata);
        Image = frame2im(FigWave);
               imwrite(Image,[PathPLOT PlotName],'png')
        close
        close
  end