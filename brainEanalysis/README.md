%% Notes on data analysis
Your data needs to be well orgnaized with the same naming convention. ie: nNAVpre1, nNAVpost1, nNAVpre2, nNAVpost2, etc.
I see in your screenshots your naming convention is all over the place...these scripts won't work if your data is not consistent since it won't be able to align subjects

If you do pre/post data analysis, have one master folder with all your pre data, and one master folder with all your post data. 

If your data is organized, you shouldn't need to modify much of this code and it should just work. I don't know what your target is or what data you are running so this code also assumes you 
are running Face off, go green, lost star, middle fish, and luckydoor. 

Of course, all of this is just a template, you can modify if you need to

%% Scripts
LuckyDoor_scalpAnalysis.m - gets scalp level data for luckydoor. Need to run once for each "group"
LuckyDoor_sourceAnalysis.m - gets source level data for luckydoor. Need to run once for each "group"
organizingLDproject.m - organizes data from LuckyDoor_scalpAnalysis.m and LuckyDoor_sourceAnalysis.m

BrainE_tasks_resp_fdbk.m - gets source level data for all other cognitive tasks. Once for each "frequency band", resp/fdbk/stim, pre/post. So if you want 3 freq bands for pre and post
    you'll need to run this 3x3x2 times = 18 times. It will organize data for you, just specify the run at the top
organizingBrainEproject.m - organizes data generated from BrainE_tasks_resp_fdbk.m. You just need to specify the data files that were generated

%% Next steps
Once you have the 'project' structure from the organizingData scripts, just follow https://github.com/jasonnan2/Automated-Analysis-of-EEG
The automated analysis of EEG github is well documented




