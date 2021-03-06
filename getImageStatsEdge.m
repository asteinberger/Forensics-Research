%{
Search through all images in crops directory, and save edge, smooth and
alternate color channels statistics data from images in <cameraDir>.txt

author: Adam Steinberger <http://www.amsteinberger.com/>
date: July 01, 2011
updated: July 31, 2011
Copyright (C) Summer 2011  Skidmore College

This software was developed as part of a Skidmore College Summer
Faculty/Student Research Grant lead by Prof. Michael Eckmann.

This program is free software: you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the Free
Software Foundation, either version 3 of the License, or (at your option)
any later version.

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
more details.

You should have received a copy of the GNU General Public License along
with this program.  If not, see <http://www.gnu.org/licenses/>.
%}

diary off;
clear; % clear matlab environment
clc; % clear homescreen
startTime = clock; % keep track of overall runtime
thresh1 = 0.035; % used for edge detection
thresh2 = 30; % used for edge median filter
d = datestr(now);
diary(['getImageStatsEdge ',d,'.diary']);

%{
MODIFY THESE DIRECTORIES TO DESIRED LOCATIONS ON EACH PARTICULAR MACHINE
Photos must be 512 by 512 pixel JPEGs. The photos directory should have a
folder for each camera, and images inside of each camera directory. Log
file contains the filename, cam #, and photo # of last photo processed.
Computation will start at next photo if software crashes or is killed. To
run software for first time, you must edit this file so it reads: FILE 1 0.
Image stats are saved in text files, one file per camera, in the statistics
directory. Each line in these files contains statistics for an individual
image.
%}
photoDirectory = '/students/home/semistatic/summer2011/crops/';
logDirectory = '/students/home/visionmatlab/workspace/iStatEdge.log';
statsDirectory = '/students/home/visionmatlab/stats/07-26-edge/';
folders = strfind(photoDirectory,'/');
pDirLen = length(folders);

% pre-allocate new 500x500 cell matrix
fileLists = cell(500,500);

% Get all files for each camera in photos directory
cameraList = dir(photoDirectory);
numCams = length(cameraList);
for i = 3:length(cameraList)
    cam = [photoDirectory,cameraList(i).name];
    fileLists{i} = getAllFiles(cam);
end

% Get log of last image processed by this software
logFile = fopen(logDirectory,'r');
data = textscan(logFile,'%s %d %d');
camStart = data{2}+2;
photoStart = data{3}+1;
fclose(logFile);

% Loop through each image file
for camera = camStart:numCams
    
    % get directory information
    currentDir = fileLists{camera}{1};
    fold = strfind(currentDir,'/');
    ext = strfind(currentDir,'.');
    model = currentDir(fold(pDirLen)+1:fold(pDirLen+1)-1);
    dataFile = strcat(statsDirectory,model,'.txt');
    
    for photo = photoStart:length(fileLists{camera})
        
        str = ['Read camera ',num2str(camera-2),' of ', ...
            num2str(numCams-2),' file ',num2str(photo),' of ', ...
            num2str(length(fileLists{camera})),' ', ...
            fileLists{camera}{photo}];
        dstr = [datestr(now),': ',str];
        disp(dstr)
        
        % only process JPEGs in indoors and outdoors directories
        if (((size(strfind(fileLists{camera}{photo},'.JPG'),1) > 0) || ...
                (size(strfind(fileLists{camera}{photo},'.jpg'),1) > 0)) && ...
                ((size(strfind(fileLists{camera}{photo},'dark-frame'),1) == 0)) && ...
                ((size(strfind(fileLists{camera}{photo},'blue-sky'),1) == 0)))
            
            % read image file
            fimg = ForensicImage(fileLists{camera}{photo});

            % get image statistics
            [iStat3,iStat5,iStat7] = fimg.imgStatsEdge(thresh1,thresh2,camera-2,photo);
            [iStatS3,iStatS5,iStatS7] = fimg.imgStatsSmooth(thresh1);
            iStatACB = fimg.imgStatsACB();
            
            % remove all NaNs from image stats
            iStat3 = iStat3.clean();
            iStat5 = iStat5.clean();
            iStat7 = iStat7.clean();
            iStatS3 = iStatS3.clean();
            iStatS5 = iStatS5.clean();
            iStatS7 = iStatS7.clean();
            iStatACB = iStatACB.clean();
            
            % all image stats for red 3x3 neighborhoods
            iStat3Red = imgStats(iStat3.avg(1),iStat3.sd(1), ...
                iStat3.skew(1),iStat3.kurt(1),iStat3.entropy(1), ...
                iStat3.energy(1),iStat3.pixels(:,:,1), ...
                iStat3.meds(:,:,1),iStat3.errors(:,1));
            
            % all image stats for green 3x3 neighborhoods
            iStat3Green = imgStats(iStat3.avg(2),iStat3.sd(2), ...
                iStat3.skew(2),iStat3.kurt(2),iStat3.entropy(2), ...
                iStat3.energy(2),iStat3.pixels(:,:,2), ...
                iStat3.meds(:,:,2),iStat3.errors(:,2));
            
            % all image stats for blue 3x3 neighborhoods
            iStat3Blue = imgStats(iStat3.avg(3),iStat3.sd(3), ...
                iStat3.skew(3),iStat3.kurt(3),iStat3.entropy(3), ...
                iStat3.energy(3),iStat3.pixels(:,:,3), ...
                iStat3.meds(:,:,3),iStat3.errors(:,3));
            
            % all image stats for red 5x5 neighborhoods
            iStat5Red = imgStats(iStat5.avg(1),iStat5.sd(1), ...
                iStat5.skew(1),iStat5.kurt(1),iStat5.entropy(1), ...
                iStat5.energy(1),iStat5.pixels(:,:,1), ...
                iStat5.meds(:,:,1),iStat5.errors(:,1));
            
            % all image stats for green 5x5 neighborhoods
            iStat5Green = imgStats(iStat5.avg(2),iStat5.sd(2), ...
                iStat5.skew(2),iStat5.kurt(2),iStat5.entropy(2), ...
                iStat5.energy(2),iStat5.pixels(:,:,2), ...
                iStat5.meds(:,:,2),iStat5.errors(:,2));
            
            % all image stats for blue 5x5 neighborhoods
            iStat5Blue = imgStats(iStat5.avg(3),iStat5.sd(3), ...
                iStat5.skew(3),iStat5.kurt(3),iStat5.entropy(3), ...
                iStat5.energy(3),iStat5.pixels(:,:,3), ...
                iStat5.meds(:,:,3),iStat5.errors(:,3));
            
            % all image stats for red 7x7 neighborhoods
            iStat7Red = imgStats(iStat7.avg(1),iStat7.sd(1), ...
                iStat7.skew(1),iStat7.kurt(1),iStat7.entropy(1), ...
                iStat7.energy(1),iStat7.pixels(:,:,1), ...
                iStat7.meds(:,:,1),iStat7.errors(:,1));
            
            % all image stats for green 7x7 neighborhoods
            iStat7Green = imgStats(iStat7.avg(2),iStat7.sd(2), ...
                iStat7.skew(2),iStat7.kurt(2),iStat7.entropy(2), ...
                iStat7.energy(2),iStat7.pixels(:,:,2), ...
                iStat7.meds(:,:,2),iStat7.errors(:,2));
            
            % all image stats for blue 7x7 neighborhoods
            iStat7Blue = imgStats(iStat7.avg(3),iStat7.sd(3), ...
                iStat7.skew(3),iStat7.kurt(3),iStat7.entropy(3), ...
                iStat7.energy(3),iStat7.pixels(:,:,3), ...
                iStat7.meds(:,:,3),iStat7.errors(:,3));
            
            % all image stats for red 3x3 neighborhoods
            iStatS3Red = imgStats(iStatS3.avg(1),iStatS3.sd(1), ...
                iStatS3.skew(1),iStatS3.kurt(1),iStatS3.entropy(1), ...
                iStatS3.energy(1),iStatS3.pixels(:,:,1), ...
                iStatS3.meds(:,:,1),iStatS3.errors(:,1));
            
            % all image stats for green 3x3 neighborhoods
            iStatS3Green = imgStats(iStatS3.avg(2),iStatS3.sd(2), ...
                iStatS3.skew(2),iStatS3.kurt(2),iStatS3.entropy(2), ...
                iStatS3.energy(2),iStatS3.pixels(:,:,2), ...
                iStatS3.meds(:,:,2),iStatS3.errors(:,2));
            
            % all image stats for blue 3x3 neighborhoods
            iStatS3Blue = imgStats(iStatS3.avg(3),iStatS3.sd(3), ...
                iStatS3.skew(3),iStatS3.kurt(3),iStatS3.entropy(3), ...
                iStatS3.energy(3),iStatS3.pixels(:,:,3), ...
                iStatS3.meds(:,:,3),iStatS3.errors(:,3));
            
            % all image stats for red 5x5 neighborhoods
            iStatS5Red = imgStats(iStatS5.avg(1),iStatS5.sd(1), ...
                iStatS5.skew(1),iStatS5.kurt(1),iStatS5.entropy(1), ...
                iStatS5.energy(1),iStatS5.pixels(:,:,1), ...
                iStatS5.meds(:,:,1),iStatS5.errors(:,1));
            
            % all image stats for green 5x5 neighborhoods
            iStatS5Green = imgStats(iStatS5.avg(2),iStatS5.sd(2), ...
                iStatS5.skew(2),iStatS5.kurt(2),iStatS5.entropy(2), ...
                iStatS5.energy(2),iStatS5.pixels(:,:,2), ...
                iStatS5.meds(:,:,2),iStatS5.errors(:,2));
            
            % all image stats for blue 5x5 neighborhoods
            iStatS5Blue = imgStats(iStatS5.avg(3),iStatS5.sd(3), ...
                iStatS5.skew(3),iStatS5.kurt(3),iStatS5.entropy(3), ...
                iStatS5.energy(3),iStatS5.pixels(:,:,3), ...
                iStatS5.meds(:,:,3),iStatS5.errors(:,3));
            
            % all image stats for red 7x7 neighborhoods
            iStatS7Red = imgStats(iStatS7.avg(1),iStatS7.sd(1), ...
                iStatS7.skew(1),iStatS7.kurt(1),iStatS7.entropy(1), ...
                iStatS7.energy(1),iStatS7.pixels(:,:,1), ...
                iStatS7.meds(:,:,1),iStatS7.errors(:,1));
            
            % all image stats for green 7x7 neighborhoods
            iStatS7Green = imgStats(iStatS7.avg(2),iStatS7.sd(2), ...
                iStatS7.skew(2),iStatS7.kurt(2),iStatS7.entropy(2), ...
                iStatS7.energy(2),iStatS7.pixels(:,:,2), ...
                iStatS7.meds(:,:,2),iStatS7.errors(:,2));
            
            % all image stats for blue 7x7 neighborhoods
            iStatS7Blue = imgStats(iStatS7.avg(3),iStatS7.sd(3), ...
                iStatS7.skew(3),iStatS7.kurt(3),iStatS7.entropy(3), ...
                iStatS7.energy(3),iStatS7.pixels(:,:,3), ...
                iStatS7.meds(:,:,3),iStatS7.errors(:,3));
            
            % all image stats for alternate color channel 1
            iStatACB1 = imgStats(iStatACB.avg(1),iStatACB.sd(1), ...
                iStatACB.skew(1),iStatACB.kurt(1),iStatACB.entropy(1), ...
                iStatACB.energy(1),0,0,0);
            
            % all image stats for alternate color channel 2
            iStatACB2 = imgStats(iStatACB.avg(2),iStatACB.sd(2), ...
                iStatACB.skew(2),iStatACB.kurt(2),iStatACB.entropy(2), ...
                iStatACB.energy(2),0,0,0);
            
            % all image stats for alternate color channel 3
            iStatACB3 = imgStats(iStatACB.avg(3),iStatACB.sd(3), ...
                iStatACB.skew(3),iStatACB.kurt(3),iStatACB.entropy(3), ...
                iStatACB.energy(3),0,0,0);
            
            % format for writting data to text file
            format = ['%s %d ', ...
                '1:%f 2:%f 3:%f 4:%f 5:%f 6:%f ', ...
                '7:%f 8:%f 9:%f 10:%f 11:%f 12:%f ', ...
                '13:%f 14:%f 15:%f 16:%f 17:%f 18:%f ', ...
                '19:%f 20:%f 21:%f 22:%f 23:%f 24:%f ', ...
                '25:%f 26:%f 27:%f 28:%f 29:%f 30:%f ', ...
                '31:%f 32:%f 33:%f 34:%f 35:%f 36:%f ', ...
                '37:%f 38:%f 39:%f 40:%f 41:%f 42:%f ', ...
                '43:%f 44:%f 45:%f 46:%f 47:%f 48:%f ', ...
                '49:%f 50:%f 51:%f 52:%f 53:%f 54:%f ', ...
                '55:%f 56:%f 57:%f 58:%f 59:%f 60:%f ', ...
                '61:%f 62:%f 63:%f 64:%f 65:%f 66:%f ', ...
                '67:%f 68:%f 69:%f 70:%f 71:%f 72:%f ', ...
                '73:%f 74:%f 75:%f 76:%f 77:%f 78:%f ', ...
                '79:%f 80:%f 81:%f 82:%f 83:%f 84:%f ', ...
                '85:%f 86:%f 87:%f 88:%f 89:%f 90:%f ', ...
                '91:%f 92:%f 93:%f 94:%f 95:%f 96:%f ', ...
                '97:%f 98:%f 99:%f 100:%f 101:%f 102:%f ', ...
                '103:%f 104:%f 105:%f 106:%f 107:%f 108:%f ', ...
                '109:%f 110:%f 111:%f 112:%f 113:%f 114:%f ', ...
                '115:%f 116:%f 117:%f 118:%f 119:%f 120:%f ', ...
                '121:%f 122:%f 123:%f 124:%f 125:%f 126:%f\n'];
            
            % open data text file for appending data to it
            dataOut = fopen(dataFile,'a');
            
            % append data to data text file
            fprintf(dataOut,format,strrep(fimg.filename,' ','_'),camera-2, ...
                iStat3Red.avg,iStat3Red.sd,iStat3Red.skew, ...
                iStat3Red.kurt,iStat3Red.entropy,iStat3Red.energy, ...
                iStat3Green.avg,iStat3Green.sd,iStat3Green.skew, ...
                iStat3Green.kurt,iStat3Green.entropy,iStat3Green.energy, ...
                iStat3Blue.avg,iStat3Blue.sd,iStat3Blue.skew, ...
                iStat3Blue.kurt,iStat3Blue.entropy,iStat3Blue.energy, ...
                iStat5Red.avg,iStat5Red.sd,iStat5Red.skew, ...
                iStat5Red.kurt,iStat5Red.entropy,iStat5Red.energy, ...
                iStat5Green.avg,iStat5Green.sd,iStat5Green.skew, ...
                iStat5Green.kurt,iStat5Green.entropy,iStat5Green.energy, ...
                iStat5Blue.avg,iStat5Blue.sd,iStat5Blue.skew, ...
                iStat5Blue.kurt,iStat5Blue.entropy,iStat5Blue.energy, ...
                iStat7Red.avg,iStat7Red.sd,iStat7Red.skew, ...
                iStat7Red.kurt,iStat7Red.entropy,iStat7Red.energy, ...
                iStat7Green.avg,iStat7Green.sd,iStat7Green.skew, ...
                iStat7Green.kurt,iStat7Green.entropy,iStat7Green.energy, ...
                iStat7Blue.avg,iStat7Blue.sd,iStat7Blue.skew, ...
                iStat7Blue.kurt,iStat7Blue.entropy,iStat7Blue.energy, ...
                iStatS3Red.avg,iStatS3Red.sd,iStatS3Red.skew, ...
                iStatS3Red.kurt,iStatS3Red.entropy,iStatS3Red.energy, ...
                iStatS3Green.avg,iStatS3Green.sd,iStatS3Green.skew, ...
                iStatS3Green.kurt,iStatS3Green.entropy,iStatS3Green.energy, ...
                iStatS3Blue.avg,iStatS3Blue.sd,iStatS3Blue.skew, ...
                iStatS3Blue.kurt,iStatS3Blue.entropy,iStatS3Blue.energy, ...
                iStatS5Red.avg,iStatS5Red.sd,iStatS5Red.skew,...
                iStatS5Red.kurt,iStatS5Red.entropy,iStatS5Red.energy, ...
                iStatS5Green.avg,iStatS5Green.sd,iStatS5Green.skew, ...
                iStatS5Green.kurt,iStatS5Green.entropy,iStatS5Green.energy, ...
                iStatS5Blue.avg,iStatS5Blue.sd,iStatS5Blue.skew, ...
                iStatS5Blue.kurt,iStatS5Blue.entropy,iStatS5Blue.energy, ...
                iStatS7Red.avg,iStatS7Red.sd,iStatS7Red.skew, ...
                iStatS7Red.kurt,iStatS7Red.entropy,iStatS7Red.energy, ...
                iStatS7Green.avg,iStatS7Green.sd,iStatS7Green.skew, ...
                iStatS7Green.kurt,iStatS7Green.entropy,iStatS7Green.energy, ...
                iStatS7Blue.avg,iStatS7Blue.sd,iStatS7Blue.skew, ...
                iStatS7Blue.kurt,iStatS7Blue.entropy,iStatS7Blue.energy, ...
                iStatACB1.avg,iStatACB1.sd,iStatACB1.skew, ...
                iStatACB1.kurt,iStatACB1.entropy,iStatACB1.energy, ...
                iStatACB2.avg,iStatACB2.sd,iStatACB2.skew, ...
                iStatACB2.kurt,iStatACB2.entropy,iStatACB2.energy, ...
                iStatACB3.avg,iStatACB3.sd,iStatACB3.skew, ...
                iStatACB3.kurt,iStatACB3.entropy,iStatACB3.energy);
            
            % close data text file
            fclose(dataOut);
            
            % allow software to start where it left off by saving last
            % image file and camera/photo number data to log file
            logFile = fopen(logDirectory,'w');
            fprintf(logFile,'%s %d %d',fimg.filename,camera-2,photo);
            fclose(logFile);
            
        end

    end
    
    % reset photoStart to get all images in next camera directory
    photoStart = 1;

end

% get overall runtime
diary off;
fprintf('Total duration: %f sec\n',etime(clock,startTime))
