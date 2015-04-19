function numSongs = music(dataDirectory);

    addpath('~/work/common');
    addpath('~/work/InfoGeomCode');

    numSongs = 0;
    vectorSize = 500000;
    vectorOffset = 1000000;

    fileList = rdir([strcat(dataDirectory), '/**/*.mp3']);
    dataFiles = {fileList(~[fileList.isdir]).name};
    numFiles = size(dataFiles,2);

    if (numFiles == 0)
        error('No data files found');end

    
    ng = NaN(numFiles,1);
    ngVar = NaN(numFiles,1);
    nsf = NaN(numFiles,1);
    nsfVar = NaN(numFiles,1);
    
    figure(1);
    hold on;
    
    beginTime=progress('Initializing',0,0,0);
    for i = 1:numFiles,
        identifier=dataFiles{i};
        fileID = fopen(identifier);
        timeSeries = fread(fileID,'uint8');
        fclose(fileID);
        dataLength = size(timeSeries,1);
        if (dataLength > vectorSize + (2*vectorOffset))
            timeSeries = timeSeries((vectorOffset+1):(vectorSize+vectorOffset));
            if  any(timeSeries) && (sum(isnan(timeSeries))==0)
                dataColumn = size(timeSeries,2);
                timeSeries = timeSeries(:,dataColumn);
                normTimeSeries = (timeSeries-mean(timeSeries))/std(timeSeries);
                [ng(i),ngVar(i)] = negent_hist(normTimeSeries); % Using sjr routines
                [nsf(i),nsfVar(i)] = nsf_new(normTimeSeries);  % Using sjr routines
                numSongs = numSongs + 1;
            end
        end
        progress(identifier,i,numFiles,beginTime);
     end

     save('musicData','ng','ngVar','nsf','nsfVar');
 %    sendmail('ahmad.asif@gmail.com', strcat(dataFolder,'-',num2str(numSongs),'/',num2str(numFiles)));

end
