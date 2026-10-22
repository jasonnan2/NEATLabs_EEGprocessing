function behoutput = behavior_Analysis(tabledata)
%find the actual working block
desiredblock = find(tabledata.Block == 1);
actualdata = tabledata(desiredblock,:);

banditcol = actualdata.ChoiceDoor; %%get the banditcol structure
rewardmat = actualdata.ChoiceValue; %the payoff structure set for the participant
bandittypecol = actualdata.ChoiceSeries;

%getting the door identity same across different datasets
ndoors = 2;
for doori = 1:ndoors %Just do for one and fill in the other
    indnow = find(banditcol == doori);
    if any(intersect(rewardmat(indnow),[-60, -70]))
        doorname{doori} = 'RareL';
        doorid(doori) = 1;
        doori_alt = setdiff([1 2],doori);
        doorname{doori_alt} = 'RareG';
        doorid(doori_alt) = 2;
    elseif any(intersect(rewardmat(indnow),[60, 70]))
        doorname{doori} = 'RareG';
        doorid(doori) = 2;
        doori_alt = setdiff([1 2],doori);
        doorname{doori_alt} = 'RareL';
        doorid(doori_alt) = 1;
    end
end

banditcol_pool = zeros(2,length(banditcol));

for doori = 1:ndoors
    banditcol_pool(doorid(doori),find(banditcol == doori)) = 1;
end

%cumulative sum of the bandit outcomes

banditcol_csumpool = cumsum(banditcol_pool(:,1:10),2);

csumpool11 = banditcol_csumpool(2,end) / 10; %to get in [0 1] scale

banditcol_csumpool = cumsum(banditcol_pool(:,11:20),2);
csumpool12 = banditcol_csumpool(2,end) / 10; %to get in [0 1] scale

banditcol_csumpool = cumsum(banditcol_pool(:,21:30),2);
csumpool13 = banditcol_csumpool(2,end) / 10; %to get in [0 1] scale

banditcol_csumpool = cumsum(banditcol_pool(:,31:40),2);
csumpool14 = banditcol_csumpool(2,end) / 10; %to get in [0 1] scale

banditcol_csumpool = cumsum(banditcol_pool(:,1:40),2);
csumpool1 = banditcol_csumpool(2,end) / 40; %to get in [0 1] scale

desiredblock = find(tabledata.Block == 2);
actualdata = tabledata(desiredblock,:);

%for the second block

banditcol = actualdata.ChoiceDoor; %%get the banditcol structure
rewardmat = actualdata.ChoiceValue; %the payoff structure set for the participant
bandittypecol = actualdata.ChoiceSeries;

for doori = 1:ndoors %Just do for one and fill in the other
    indnow = find(banditcol == doori);
    %             doorname1(doori) = bandittypecol(indnow(1));
    
    
    if any(intersect(rewardmat(indnow),[-60, -70]))
        doorname{doori} = 'RareL';
        doorid(doori) = 1;
        doori_alt = setdiff([1 2],doori);
        doorname{doori_alt} = 'RareG';
        doorid(doori_alt) = 2;
    elseif any(intersect(rewardmat(indnow),[60, 70]))
        doorname{doori} = 'RareG';
        doorid(doori) = 2;
        doori_alt = setdiff([1 2],doori);
        doorname{doori_alt} = 'RareL';
        doorid(doori_alt) = 1;
    end
end

banditcol_pool = zeros(2,length(banditcol));

for doori = 1:ndoors
    banditcol_pool(doorid(doori),find(banditcol == doori)) = 1;
end

banditcol_csumpool = cumsum(banditcol_pool(:,1:10),2);
csumpool21 = banditcol_csumpool(2,end) / 10; %to get in [0 1] scale

banditcol_csumpool = cumsum(banditcol_pool(:,11:20),2);
csumpool22 = banditcol_csumpool(2,end) / 10; %to get in [0 1] scale

banditcol_csumpool = cumsum(banditcol_pool(:,21:30),2);
csumpool23 = banditcol_csumpool(2,end) / 10; %to get in [0 1] scale

banditcol_csumpool = cumsum(banditcol_pool(:,31:40),2);
csumpool24 = banditcol_csumpool(2,end) / 10; %to get in [0 1] scale

banditcol_csumpool = cumsum(banditcol_pool(:,1:40),2);
csumpool2 = banditcol_csumpool(2,end) / 40; %to get in [0 1] scale
behoutput.values = [csumpool11,csumpool12, csumpool13, csumpool14, csumpool1, csumpool21, csumpool22, csumpool23, csumpool24, csumpool2];
behoutput.labels = {'csumpool- block 1,1','csumpool- block 1,2', 'csumpool- block 1,3', 'csumpool- block 1,4', 'csumpool- block 1', 'csumpool- block 2,1', 'csumpool- block 2,2', 'csumpool- block 2,3', 'csumpool- block 2,4', 'csumpool- block 2'};
end