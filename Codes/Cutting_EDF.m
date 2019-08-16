%% Timing
TableFile = [PathMain 'Cut Timing' '.xlsx']
Timing = xlsread(TableFile, 3)
    %Timing = readtable(TableFile, 'Sheet', 3); %Nama File Excel (sesuaikan dengan nama filenya), 3 = baca file dari Sheet 3
    %Timing = table2array(Timing)
TimeIDX = 4:2:(JumlahDomain*4)+6
%Start dari Kolom 4. Kolom = 1-3 ID dan nama saja

%% Timing Code Below
for Participant = 1:length(rawDataFiles); %for loop sesuai jumlah partisipan (total file) dalam folder
    loadName = rawDataFiles(Participant).name;
    dataName = loadName(1:end-24); %Dio: end-24 bcs exported emotiv filename is too long
    for JDT = 1:2:(JumlahDomain*2)+1; %Jumlah Domain for Timing, sesuai kolom di excel (4, 6, 8, dst)
        DomID = num2str((JDT-1)/2,'%02d'); %DomID = Nama belakang supaya sesuai dgn domain (num2str %02d = 0 dengan 2 digit dibelakang)
        DomName = [dataName '_' DomID]; %Dhio: Use this for the domain file indicator

        EEG = pop_biosig([PathRAW loadName]);
        EEG = eeg_checkset(EEG);
        EEG = pop_select(EEG,'time',[Timing(Participant,[TimeIDX(:, JDT)]) Timing(Participant,[TimeIDX(:, JDT+1)])]);
        EEG = pop_saveset(EEG, 'filename',DomName,'filepath',PathCUT);
    end
end