function numSongs = music(dataDirectory,vectorSize);

    addpath('~/work/common');
    addpath('~/work/snippets');
    addpath('~/work/InfoGeomCode');

    currentFile = strcat('current',num2str(vectorSize),'.mat');
    allFile = strcat('all',num2str(vectorSize),'.mat');
    
    numSongs = 0;
%     vectorSize = 50000;
    vectorOffset = 1000000;

    fileList = rdir([strcat(dataDirectory), '/**/*.mp3']);
    dataFiles = {fileList(~[fileList.isdir]).name};
    numFiles = size(dataFiles,2);

    if (numFiles == 0)
        error('No music files found');end
    
    ng = NaN(numFiles,1);
    ngVar = NaN(numFiles,1);
    nsf = NaN(numFiles,1);
    nsfVar = NaN(numFiles,1);
    artist = cell(numFiles,1);
    song_name = cell(numFiles,1);
    genre = cell(numFiles,1);
    info = cell(numFiles,1);
    
    
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
                [tag,message]=readid3(identifier);
                info{numSongs} = strrep(identifier,strcat(dataDirectory,filesep),'');
                genre{numSongs} = '';
                if strcmp(message,'Success')
                    artist{numSongs} = strtrim(tag.artist);
                    song_name{numSongs} = strtrim(tag.song_name);
                    genre{numSongs} = strtrim(tag.genre);
                end
            end
        end

        

        
        progress(sprintf('%s - %s',artist{numSongs},song_name{numSongs}),i,numFiles,beginTime);
    end
    
    save(currentFile,'artist','song_name','genre','ng','ngVar','nsf','nsfVar');
 
    if exist(allFile)==2
        oldData = load(allFile);
        currentData = load(currentFile);
        theFields = fieldnames(currentData);
        for j=1:length(theFields)
            allData.(theFields{j}) = [oldData.(theFields{j});currentData.(theFields{j})];
        end
        save(allFile,'-struct','allData');
    else
        save(allFile,'artist','song_name','genre','ng','ngVar','nsf','nsfVar');
    end
        
    delete(currentFile);
    
    


     
%     sendmail('ahmad.asif@gmail.com', fullfile(strcat(dataDirectory,'-',num2str(numSongs)),num2str(numFiles)));

end
