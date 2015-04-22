function numSongs = music(dataDirectory);

    addpath('~/Dropbox/work/common');
    addpath('~/Dropbox/work/snippets');
    addpath('~/Dropbox/work/InfoGeomCode');

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
    artist = cell(numFiles,1);
    song_name = cell(numFiles,1);
    genre = cell(numFiles,1);
    info = cell(numFiles,1);
    
    
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
                [tag,message]=readid3(identifier);
                numSongs = numSongs + 1;
            end
        end
        [tag,message]=readid3(identifier);
        info{i} = strrep(identifier,strcat(dataDirectory,filesep),'');
        genre{i} = '';
        if strcmp(message,'Success')
            artist{i} = strtrim(tag.artist);
            song_name{i} = strtrim(tag.song_name);
            info{i} = sprintf('%s - %s',artist{i},song_name{i}); 
            genre{i} = strtrim(tag.genre);
        end
        
        progress(info{i},i,numFiles,beginTime);
     end

     save('musicData','info','genre','ng','ngVar','nsf','nsfVar');
     sendmail('ahmad.asif@gmail.com', fullfile(strcat(dataFolder,'-',num2str(numSongs)),num2str(numFiles)));

end
