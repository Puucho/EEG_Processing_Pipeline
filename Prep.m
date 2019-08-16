%% UPDATE LOG
%{
01/08/19
Cut Frame for 1080

09/07/19
- [Plotting] full head image save (.png) as opposed to only that one head
- read ChanLocs dibuat lebih simpel

29/04/19
Gamma di ganti freq 40

<29/04/19
tau deh apaan aja lupa h3h3
%} 
% TO DO -- Max 1 dan 2 untuk Define Area; t-test save as excel
%% Prep
clear
JumlahDomain = 8; %E.g. Digibrain = 8, ZTPI = 5
Alat = 'Emotiv'
%Alat = Deymed
Resolusi = 1080 %1080 dan 768
%Resolusi = 768
PathMain = '\0-Brain-Data_Programs\0-Processing Folders\EEGLAB\';
EEGLab = '\0-Brain-Data_Programs\MatLab\eeglab\eeglab';%Masukin path EEGLab
%% Pathing
    PathRAW = [PathMain '0-RawFiles\']; %WAJIB diakhiri dengan '\'
    PathCUT = [PathMain '1-CutFiles\']; %Path "CutFiles" untuk syntax save file di bawah
    PathPROC = [PathMain '2-PPFiles\'];
        PathBASEPROC = [PathPROC 'BaseFile\'];
    PathPLOT = [PathMain '3-Plot Single\'];
    PathFULLPLOT = [PathMain '4-Plot All\'];
    PathPOWER = [PathMain '5-Power\'];
    PathCODE = [PathMain 'Codes\'];
    TimingTable = dir([PathMain '*.xlsx']); 
%% Code Path
CODECut = [PathCODE 'Cutting_EDF'];
CODEProc = [PathCODE, 'PreProcessing.m'];
CODEPower = [PathCODE 'PowerPLOT.m'];
%% Files
rawDataFiles = dir([PathRAW '*.edf']); %baca File rawData as .edf
SetFiles = dir([PathCUT '*.set']);
ProcFiles = dir([PathPROC '*.set']);
ProcFDT = dir([PathPROC '*.fdt']);
EdfFiles = dir([PathCUT '*.edf']);
%% If Conditions
if Alat == 'Emotiv'
	nchannels = 14
	CHLocs = '\0-Brain-Data_Programs\MatLab\eeglab\sample_locs\emotivupdated.ced';
	ChanNum = [3:16]
    ChanName = {'AF3';'F7';'F5';'FC5';'T7';'P7';'O1';'O2';'P8';'T8';'FC6';'F4';'F8';'AF4'}
else
	nchannels = 19
	CHLocs = 
	ChanNum = [1:19]
    ChanName = {'FP1';'FP2';'F7';'F3';'Fz';'F4';'F8';'T7';'C3';'Cz';'C4';'T8';'P7';'P3';'Pz';'P4';'P8';'O1';'O2'}
end
if Resolusi == 1080
%Cut Frame on 1920x1080	
	FrameDELTA = [254 667 222 217];
	FrameTHETA = [564 667 222 217];
	FrameALPHA = [874 667 222 217];
	FrameBETA  = [1184 667 222 217];
	FrameGAMMA = [1494 667 222 217];
%Cut Frame on 1366x768
else
	FrameDELTA = [181 455 154 154];
	FrameTHETA = [401 455 154 154];
	FrameALPHA = [622 455 154 154];
	FrameBETA  = [842 455 154 154];
	FrameGAMMA = [1062 455 154 154];
end
%Change th option to use double precision
pop_editoptions('option_storedisk', 0, 'option_savetwofiles', 1,...
        'option_saveversion6', 1, 'option_single', 0, 'option_memmapdata', 0,...
        'option_eegobject', 0, 'option_computeica', 1, 'option_scaleicarms', 1,...
        'option_rememberfolder', 1, 'option_donotusetoolboxes', 0,...
        'option_checkversion', 1, 'option_chat', 0);
%% Comment kalo ga dipake
run (EEGLab); 
    close;
run (CODECut);
run (CODEProc);
run (CODEPower);