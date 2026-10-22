## Data Organization
Your data needs to be well organized with the same naming convention to distinguish different groups

If you do pre/post data analysis, have one Main folder with all your pre data, and one Main folder with all your post data. 
If you have group level analysis, have one main folder for each group. 

## Scripts
LuckyDoor_scalpAnalysis.m - gets scalp level data for luckydoor. Need to run once for each "group"
LuckyDoor_sourceAnalysis.m - gets source level data for luckydoor. Need to run once for each "group"
organizingLDproject.m - organizes data from LuckyDoor_scalpAnalysis.m and LuckyDoor_sourceAnalysis.m

BrainE_tasks_resp_fdbk.m - gets source level data for all other cognitive tasks. Once for each "frequency band", resp/fdbk/stim, pre/post. So if you want 3 freq bands for pre and post
    you'll need to run this 3x3x2 times = 18 times. It will organize data for you, just specify the run at the top
organizingBrainEproject.m - organizes data generated from BrainE_tasks_resp_fdbk.m. You just need to specify the data files that were generated

##  Next steps
Once you have the 'project' structure from the organizingData scripts, just follow **[Automated-Analysis-of-EEG](https://github.com/jasonnan2/NEATLabs_EEGprocessing/Automated-Analysis-of-EEG)**




