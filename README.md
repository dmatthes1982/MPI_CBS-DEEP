# MPI_CBS-DEEP

## DEEP: A dual-EEG Pipeline for adult and infant hyperscanning studies. - User Manual

### Table of Contents
1. [ Overview. ](#overview)
2. [Setup and Run (DEEP_main).](#setupRun)

<a name="overview"></a>
### Overview

The pipeline was initially designed to analyze data from a mother-infant hyperscanning study conducted in our lab. We reasoned that more researchers could benefit from the pipeline, and started the process of adjusting the functionalities of the pipeline to address the needs of a general user. Because this is work in progress, in the current version of the pipeline, users would need to adjust the “DEEP_generalDefinitions.mat” script to be able to proceed with the pipeline. This script includes information specific to our study such as the EEG markers used to indicate the events or the duration of the conditions. In Table S1, we present information on the DEEP_generalDefinitions.mat file used to analyze the data in the paper. 

Table S1: The attributes of the DEEP_generalDefinitions.mat file that are relevant to the analyses reported in the paper.

Attributes|Content|Description
:---|:------------------|:---
artfctMark:|{'S 4' 'S 5' 'S 3'}|Markers indicating periods that will be deleted from the analyses such as reaks. S4: Pause, S5: Resume, S3: Quit
artfctNum:|[4 5 3]|Numeric form of artfct
atfctString:|{3x1 cell}|Cell array of string, artfct
condMark:|{'S 11' 'S 13'}|Markers indicating the conditions analyzed in the current paper. S11: Free play condition, S13: Resting state condition Please note that the original experiment includes other conditions, which are not relevant to the analyses reported in this paper.
condMarkDual:|{'S 11' 'S 13'}|Dual condition markers used for the analyses of the example dataset.
condNum:|[11 13]|Numeric form of condMark
condNumDual:|[11 13]|Numeric form of condMarkDual
condString:|{2x1 cell}|Cell array of string, cond
duration:|[150 45]|The duration of the free play and resting state conditions, respectively, in seconds.
trialNum1sec:|[150 45]|The total number of trials in the free play and resting state conditions, respectively, in one second epochs.
trialNum5sec:|[30 9]|The total number of trials in the free play and resting state conditions, respectively, in five second epochs.

The pipeline is based on functions of the FieldTrip toolbox (https://www.fieldtriptoolbox.org/). Users are expected to download the FieldTrip toolbox independently. Once it is downloaded and set up correctly (see startup.m), one can type **“ft_version”** in the MATLAB command window to get the latest version of the FieldTrip toolbox. One can also clone and use a certain version of the FieldTrip toolbox to operate the pipeline.

In order to operate the pipeline and analyze the data, each researcher can create their own session. In one session, data for each processing step is saved. Several sessions for the same study can operate in parallel without interfering with one another. Thus, several researchers can work simultaneously on the data analysis. Preprocessing steps completed in one session can be copied to another session using the **“DEEP_cloneSession”** script. Within each session, the user can choose from several processing steps. Whereas preprocessing steps 1 to 6 have to be done in a fixed order, users can proceed with the subsequent steps (e.g., steps 7 or 8) depending on the analysis of their choice.

The user launches the pipeline by typing the **“DEEP_main”** command in the MATLAB command window. Following this, the user is asked to select the default path or define a new path on their computer where the raw data are stored. The processed data and the final exported data will also be saved under this path. Next, the user chooses the participants’ data to be processed among three options 1) all available dyads 2) all new dyads 3) a specific subsample of dyads. This gives flexibility to users especially when they want to exclude some of the participants’ data from the start or to perform the processing steps with a subsample of participants reducing preprocessing time and effort.

After the dyads are selected, the pipeline allows the user to choose the processing steps that are available for the imported data files (e.g., if no data was imported for a certain participant, no later processing steps can be selected). This function also helps the user to remember which preprocessing steps are completed for which dyads. In the current version of the pipeline, the same preprocessing steps are applied to both the mother and the infant data. For each preprocessing step, first, the data of the adult is processed followed by the data of the infant/child. When processing data of two adult participants, the pipeline first processes data of participant 1 followed by data of participant 2. After each processing step, data files are restored separately as *.mat files. Below, we will illustrate each processing step in detail and introduce the main functions used at each step.

<a name="setupRun"></a>
### Setup and Run (DEEP_main)

After downloading the project files from the GitHub repository (https://github.com/dmatthes1982/MPI_CBS-DEEP), run MATLAB. After opening MATLAB, make sure that you are working with the right directory. Otherwise, switch to "…/DEEP_eeg_pipeline directory". Check the following:

```
>> pwd
ans =
'/data/UserName/MATLAB/scripts/ DEEP/DEEP_eeg_pipeline'
```
DEEP scripts should be ready to run in the MATLAB command window when you are in the right directory. If not, check if you have successfully installed the FieldTrip toolbox and the project files.

![LaunchPipeline](images/LaunchPipeline.png)

To launch the pipeline, type the following in the command window in MATLAB:

```
>> DEEP_main
```

