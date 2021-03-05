%sbd2popDat
%   Concatinates Iridium Short Burst Data (SBD) message files originating
%   from a PDS or TPOP, converts them to data units and parses the
%   decoded messages to a data file, engineering file, diagnostic file
%   and an undecoded raw data file.
%
%   Required Argument:
%       IMEI:    IMEI# file prefix either as a string or double
%
%   Optional Name-Value Pair Arguments:
%       SubDir: Subdirectory of the current working directory that the 
%                sbd files are located in, if left empty
%                popData will look in the current working directory
%       IESSN:  IES (PIES or CPIES ONLY) Serial Number that the PDS is
%                associated with.  If this option is not utilized, a NaN
%                value will be written to the  meta-record in place of the
%                serial number. Note that the IES SN does not apply to the
%                TPOP.
%
%   sbd2popDat(IMEI) processes the sbd messages located in the same
%       directory as sbd2popDat
%
%   sbd2popDat(IMEI,'SubDir',subdir,'IESSN',sn) processes the sbd messages 
%       in the subdir subdirectory to sbd2popDat and writes sn to the data
%       meta-record.
%       
%   usage example 1:
%       The sbd files are located in the same directory as sbd2popDat, a NaN
%       value will be written to the data meta-record
%       sbd2popDat(300234011971200)
%
%   usage example 2: 
%       The sbd files are located in a subdirectory to sbd2popDat, a NaN
%       value will be written to the data meta-record
%       sbd2popDat(300234011971200,'SubDir','PDS085')
%
%   usage example 3:
%       The sbd files are located in the same directory as sbd2popDat, 424
%       will be written as the associated PIES or CPIES serial number to
%       the data meta-record
%       sbd2popDat(300234011971200,'IESSN',424)
%
%   usage example 4:
%       The sbd files are located in a subdirectory to sbd2popDat, 424
%       will be written as the associated PIES or CPIES serial number to
%       the data meta-record
%       sbd2popDat(300234011971200,'SubDir','PDS085','IESSN,424)
%
%
%   A two character format (fmt) field is included at the beginning of each
%   SBD message.  This format field is used to indicate to the processing
%   routine how to unpack and decode the data in the remainder of the message.
%   The M1, M2 and M3 records do not require decoding and are written
%   directly to the <IMEI>_eng.dat file.
%
%   The supported formats (FMT):
%       M1      GPS/Engineering Record transmitted at the start of a data session.
%       M2      GPS/Engineering Record transmitted at the end of a data session.
%       M3      GPS/Engineering Record transmitted at the user's request.
%       00      Non-valid format
%       01      PIES Data
%       02      CPIES Data
%       03      Dual-Pressure CPIES Data
%       04      TPOP Data - 1 sample/hr
%       05      TPOP Data - 2 sample/hr
%       06      TPOP Data - 3 sample/hr
%       07      TPOP Data - 6 sample/hr
%
%   PIES & CPIES Data Meta-Record Format
%       FMT IMEI IESSN
%
%   TPOP Data Meta-Record Format
%       FMT IMEI NaN
%
%   Note: For the TPOP, a NaN value is appended to the data meta-record as
%     placeholder such that all data meta-records can be decoded equally.
%
%   PDS Output Data Fields:
%       MOMSN           Mobile Originated Sequence Number
%       iesHRS          IES Hours elapsed since 1-Jan-1970
%       TAU             Six Byte Travel Time (Hourly First Quartile)
%       P1,P2           Seven Byte Pressure
%       T1,T2           Five Byte Temperature from Pressure Sensor
%       S1,S2           Five Byte Speed
%       H1,H2           Five Byte Direction
%       sosP1,sosP2     Six Byte Pressure from SOS Pressure Sensor
%       sosT1,sosT2     Five Byte Temperature from SOS Pressure Sensor
%       sosR1,sosR2     Six Byte Reference from SOS Pressure Sensor
%       CS              One Byte Checksum (1-Checksum OK, 0-Checksum BAD)
%
%       All fields are space delimited and numeric
%
%   PDS Format 01 Output File Format:
%       MOMSN iesHRS TAU P1 P2 CS
%
%   PDS Format 02 Output File Format:
%       MOMSN iesHRS TAU P1 S1 H1 P2 S2 H2 CS
%
%   PDS Format 03 Output File Format:
%       MOMSN iesHRS TAU P1 T1 sosP1 sosT1 sosR1 S1 H1 P2 T2 sosP2 sosT2 sosR2 S2 H2 CS
%
%   PDS Format 02 Example Output Data:
%           000016 410055 4.5639 3498129 5.4 234.8 3498180 9.4 276.5 1
%           000016 410056 4.5633 3498247 8.2 230.2 3498315 8.4 269.9 1
%           000016 410057 4.5638 3498393 8.0 256.0 3498465 6.6 277.4 1
%
%
%   TPOP Output Data Fields:
%       MOMSN           Mobile Originated Sequence Number
%       pdsHRS          PDS Hours elapsed since 1-Jan-1970
%       TEMP 1-6        Temperature Samples, degC
%
%   TPOP Format 04 Output File Format:
%       MOMSN pdsHRS TEMP1
%
%   TPOP Format 05 Output File Format:
%       MOMSN pdsHRS TEMP1 TEMP2
%
%   TPOP Format 06 Output File Format:
%       MOMSN pdsHRS TEMP1 TEMP2 TEMP3
%
%   TPOP Format 07 Output File Format:
%       MOMSN pdsHRS TEMP1 TEMP2 TEMP3 TEMP4 TEMP5 TEMP6
%
%
%   2021 University of Rhode Island - Graduate School of Oceanography

% !!!!!!!!! Put only help information above this line !!!!!!!!!!!!!!!!


% 2012-08-17 gfc Setup for fixed data set transmission testing
% 2012-08-19 gfc Return to Will's scheme of using IMEI# as argument
% 2012-08-30 gfc Install provisions for text messages
% 2012-08-31 gfc Include text messages in output file
% 2013-03-27 ejs Use Current Working Directory as path
% 2013-03-27 ejs Pass a subdirectory into function - if single quotes are
%                   empty then uses the current working directory
%                   Assumes that the subdirectory is below the CWD
% 2013-04-09 ejs Put description at top for help file
% 2014-03-03 ejs Get MOMSN from file name
% 2014-03-19 ejs Modify: Output Date as space delimited
% 2014-03-19 ejs Modify: Convert checksum from 'Y' to 1 and 'N' to 0
% 2015-12-02 dan Modify: Handle all message types (PDS + TPOP) 
%                        Use platform-independent fileseps for pathnames.
% 2016-07-08 ejs Fix: Include 'M' in textscan format detect 
% 2016-10-13 ejs Modify: Change date stamp to PDS Hours (pdsHrs)
% 2016-10-13 ejs Modify: Ignore any SBD Message Pad Data
% 2017-02-14 ejs Modify: Add file for raw data for formats 01 thru 07
% 2017-02-23 ejs Modify: Update Help Section
% 2018-01-29 ejs Create: sbd2popDat.m from SBDCat_r6c.m
% 2018-02-07 ejs Update: Remove check sum from TPOP cases
% 2018-02-07 ejs Update: Help section to reflect TPOP case changes
% 2018-02-07 ejs Fix: PIES case (FMT 01) indexing issues
% 2018-02-07 ejs Modify: Wrap sbd2popDat with try-catch
% 2021-02-19 ejs Update: Include CPIES or PIES as input, write SN to data
%                meta-records

function sbd2popDat(IMEI,varargin)

try
    defaultPiesSN = NaN;
    defaultProjDir = '';

    inParse = inputParser;

    addParameter(inParse,'IESSN',defaultPiesSN);
    addParameter(inParse,'SubDir',defaultProjDir);
    parse(inParse,varargin{:});

    instSN = inParse.Results.IESSN;
    SubDir = inParse.Results.SubDir;

    if(~isempty(SubDir))
       projDir = [SubDir filesep];
    elseif(isempty(SubDir))
        projDir = SubDir;
    end
    
    disp("IES SN: " + instSN);
    disp("IMEI: " + IMEI)
    disp("Data Path: " + pwd + filesep + projDir)
    
    %return

%try
    %define the format length:
    fmt_length = 2;

%     % Concatenate the backslash if there is a subdirectory 
%     % If both arguments are passed in
%     if(nargin == 2)
%         projDir = [projDir filesep];
%         disp("TAG 1")
%     end
%     % If only the IMEI is passed in
%     if(nargin == 1)
%         projDir = '';
%         disp("TAG 2")
%     end
    
    % get the current working directory and concatenate the backslash
    CurrWorkingDir = [pwd filesep];

    path(path,CurrWorkingDir)

    % convert IMEI to string if it was given as a double
    if isa(IMEI,'double')
        IMEI = num2str(IMEI);
    end
    
    % get list of filenames matching IMEI#
    filenames = dir([CurrWorkingDir projDir IMEI '_*.sbd']);
    delim = '_';  %use an underscore as a delimiter

    % quit if no files exist
    if isempty(filenames)
        disp(['No files of the form: ' IMEI '_*.sbd'])
        disp(['Checking for files of the form: ' IMEI '-*.bin'])
        
        filenames = dir([CurrWorkingDir projDir IMEI '-*.bin']);
        delim = '-';    %use a dash as a delimiter
        
        if isempty(filenames)
            disp(['No files of the form: ' IMEI '-*.bin']);    
            disp('exiting')
            return
        end
    end
    %return
    % Create a data directory, if one does not exist
    mkdir([CurrWorkingDir projDir] , 'data'); 
    
    %Parsed Data Output File
    rawHexFile = fopen([CurrWorkingDir projDir 'data/' IMEI '_raw.dat'], 'w');
    if rawHexFile == -1
        disp('Could Not Open raw data hex file');
    else
        disp('Raw Hex Data File Opened');
    end
    
    %Parsed Data Output File
    outputFile = fopen([CurrWorkingDir projDir 'data/' IMEI '.dat'], 'w');
    if outputFile == -1
        disp('Could Not Open data file');
    else
        disp('Data File Opened');
    end
    
    %Engineering File
    FID_EngOutFile = fopen([CurrWorkingDir projDir 'data' filesep IMEI '_eng.dat'], 'w');
    if FID_EngOutFile == -1
        disp('Could Not Open engineering file');
    else
        disp('Engineering File Opened');
        %Print a meta-record
        fprintf(FID_EngOutFile,'%s\n',['Engineering Data For IMEI ' IMEI]);
    end
    
    % Open the file for the Diagnostic data embedded at the end of the SBD
    % Session
    FID_diagOutFile = fopen([CurrWorkingDir projDir 'data' filesep IMEI '_diag.dat'], 'w');
    if FID_EngOutFile == -1
        disp('Could Not Open Diagnostic file');
    else
        disp('Diagnostic File Opened');
        %Print a meta-record
        fprintf(FID_diagOutFile,'%s\n',['SBD Session Diagnostics For IMEI ' IMEI]);
        %Print a description of the fields
        fprintf(FID_diagOutFile,'%s\n','Format:<MOMSN>,<retries>,<MO_STATUS_1>,< MO_STATUS_2>,< MO_STATUS_3>,< MO_STATUS_4>,< MO_STATUS_5>,< MO_STATUS_6>');
    end
    
    
    % flip filenames so we work from the top to bottom
    % NOTE: the ls command should output files in numerical order - but may
    % not work proprly - use sort_nat instead
    filenames = {filenames(:).name};
    filenames = sort_nat(filenames);
    filenames = fliplr(filenames); % Flips the order the messages are processed
    
    err=0;      % Error counter
    start=true;
    metaRecordFlag=false;
    
    % loop through files, starting with highest number
    for i = 1:length(filenames)
        currFNAME = cell2mat(filenames(i));
        %disp(currFNAME);
      
        % Get the Mobile Originated Sequence Number (MOMSN)
        MOMSN_str = currFNAME((strfind(currFNAME, delim)+1):(strfind(currFNAME, '.')-1));
        disp(['MOMSN: ' MOMSN_str]);
        
        %convert the MOMSN from a string to a number so we can make sure
        %that the proper number of leading zeros are written to the file.
        %This ensures that the colums will be lined up and readable
        MOMSN = str2double(MOMSN_str);
        
        % Check for an M2 record
        fid = fopen([projDir cell2mat(filenames(i))]);
        lineFromSBD=fscanf(fid,'%s',2);
        %disp(['Raw SBD Message: ' lineFromSBD]);
        
        % Parse the data format
        fmt = lineFromSBD(1:fmt_length);
        
        switch upper(fmt)
            %---------------------------------------------------------------------------------------------------%
            case {'M1','M2','M3'}
                disp(['    An ' fmt ' Record Found!']);
                fprintf(FID_EngOutFile,'%06d,%s\n',MOMSN,lineFromSBD);
                fclose(fid);
            %---------------------------------------------------------------------------------------------------%
            
            %---------------------------------------------------------------------------------------------------%
            case {'00'}
                fclose(fid);
                disp(['FORMAT ' fmt ' - UNSUPPORTED FORMAT']);
            %---------------------------------------------------------------------------------------------------%
            
            %---------------------------------------------------------------------------------------------------%
            case {'01'} % PIES (hourly)
                scannedData = textscan(lineFromSBD(fmt_length+1:end), '%23[0123456789ABCDEFYNR:/_]');
                scannedData = flipud(scannedData{1}); % Flips the order of the records within in the message
                %disp(scannedData{1});
                
                %Once we have the format information, write a meta-record once
                %only at the top of the file.
                if (metaRecordFlag==false)
                    %fprintf(outputFile, '%s %s\n', fmt, num2str(IMEI));
                    %fprintf(rawHexFile, '%s %s\n', fmt, num2str(IMEI));
                    fprintf(outputFile, '%s %s %s\n', fmt, num2str(IMEI),num2str(instSN));
                    fprintf(rawHexFile, '%s %s %s\n', fmt, num2str(IMEI),num2str(instSN));
                    metaRecordFlag=true;   %set flag to indicate that the meta-Record has been written
                end
                
                for j = 1:size(scannedData,1)
                    rec = scannedData{j};
                    %disp(rec);
                    iesHrs = hex2dec(rec(1:5));
                    datenumber = iesHrs / 24 + datenum(1970,1,1);
                    ENhours = datestr(datenumber, 'YYYY mm dd HH');
                    ENtau = hex2dec(rec(6:10))/10000;
                    ENpress1 = hex2dec(rec(11:16));
                    ENpress2 = hex2dec(rec(17:22));
                    cs = rec(23);
                    
                    %Look at the checksum & convert to a number
                    if ( cs == 'Y')
                        checkSum = '1';
                    elseif ( cs=='N')
                        checkSum = '0';
                        err = err +1;
                    elseif (cs == '0') %Bad Data!!!
                        checkSum = '0';
                    end
                    
                    %disp([' Date & Hour: ' ENhours ', Tau: ' num2str(ENtau) ', Press1: ' num2str(ENpress1) ', Press2: ' num2str(ENpress2)]);
                    disp(['    ' ENhours ', Tau: ' num2str(ENtau) ', Press1: ' num2str(ENpress1) ', Press2: ' num2str(ENpress2)]);
                
                    padData=false;
                    %Detect the lines used to pad out the final SBD message
                    if(iesHrs==0  && checkSum=='1')
                        padData = true;
                    end
                    
                    if(padData == false)  %Write data to a file if it is not SBD Message pad data
                        fprintf(outputFile, '%06d %06d %06.0f %07.0f %07.0f %c\n',MOMSN, iesHrs, ENtau, ENpress1, ENpress2, checkSum);
                        fprintf(rawHexFile,'%06d %s %s %s %s %s\n',iesHrs,rec(1:5),rec(6:10),rec(11:16),rec(17:22),cs);
                    end
                end
                fclose(fid);
            %---------------------------------------------------------------------------------------------------%
            
            %---------------------------------------------------------------------------------------------------%
            case {'02'} % CPIES (hourly)  
                scannedData = textscan(lineFromSBD(fmt_length+1:end), '%35[0123456789ABCDEFYNR:/_]');
                scannedData = flipud(scannedData{1}); % Flips the order of the records within in the message
                %disp(scannedData{1});
                
                %Once we have the format information, write a meta-record once
                %only at the top of the file.
                if (metaRecordFlag==false)
                    %fprintf(outputFile, '%s %s\n', fmt, num2str(IMEI));
                    %fprintf(rawHexFile, '%s %s\n', fmt, num2str(IMEI));
                    fprintf(outputFile, '%s %s %s\n', fmt, num2str(IMEI),num2str(instSN));
                    fprintf(rawHexFile, '%s %s %s\n', fmt, num2str(IMEI),num2str(instSN));
                    metaRecordFlag=true;   %set flag to indicate that the meta-Record has been written
                end
                
                for j = 1:size(scannedData,1)
                    rec = scannedData{j};
                    %disp(rec);
                    iesHrs = hex2dec(rec(1:5));
                    datenumber = iesHrs / 24 + datenum(1970,1,1);
                    ENhours = datestr(datenumber, 'YYYY mm dd HH');
                    ENtau = hex2dec(rec(6:10));
                    ENpress1 = hex2dec(rec(11:16));
                    ENsp1 = hex2dec(rec(17:19))/10;
                    ENhd1 = hex2dec(rec(20:22))/10;
                    ENpress2 = hex2dec(rec(23:28));
                    ENsp2 = hex2dec(rec(29:31))/10;
                    ENhd2 = hex2dec(rec(32:34))/10;
                    cs = rec(35);
                    
                    %Look at the checksum & convert to a number
                    if ( cs == 'Y')
                        checkSum = '1';
                    elseif ( cs=='N')
                        checkSum = '0';
                        err = err +1;
                    elseif (cs == '0') %Bad Data!!!
                        checkSum = '0';
                    end
                    
                    %disp([' Date & Hour: ' ENhours ', Tau: ' num2str(ENtau) ', Press1: ' num2str(ENpress1) ', Speed1: ' num2str(ENsp1)  ', Heading1: ' num2str(ENhd1)  ', Press2: ' num2str(ENpress2) ', Speed2: ' num2str(ENsp2)  ', Heading2: ' num2str(ENhd2)]);
                    disp(['    ' ENhours ', Tau: ' num2str(ENtau) ', Press1: ' num2str(ENpress1) ', Speed1: ' num2str(ENsp1)  ', Heading1: ' num2str(ENhd1)  ', Press2: ' num2str(ENpress2) ', Speed2: ' num2str(ENsp2)  ', Heading2: ' num2str(ENhd2)]);
                    padData=false;
                    %Detect the lines used to pad out the final SBD message
                    if(iesHrs==0  && checkSum=='1')
                        padData = true;
                    end
                    
                    if(padData == false)  %Write data to a file if it is not SBD Message pad data
                        fprintf(outputFile, '%06d %06d %06.0f %07.0f %04.1f %05.1f %07.0f %04.1f %05.1f %c\n', ...
                            MOMSN, iesHrs, ENtau, ENpress1, ENsp1, ENhd1, ENpress2, ENsp2, ENhd2, checkSum);
                        fprintf(rawHexFile,'%06d %s %s %s %s %s %s %s %s %s\n', ...
                        iesHrs,rec(1:5),rec(6:10),rec(11:16),rec(17:19),rec(20:22),rec(23:28),rec(29:31),rec(32:34),cs);
                    end
                end
                fclose(fid);
            %---------------------------------------------------------------------------------------------------%
            
            %---------------------------------------------------------------------------------------------------%
            case {'03'} % Dual-CPIES (hourly)
                scannedData = textscan(lineFromSBD(fmt_length+1:end), '%79[0123456789ABCDEFYNR:/_]');
                scannedData = flipud(scannedData{1}); % Flips the order of the records within in the message
                %disp(scannedData{1});
                
                %Once we have the format information, write a meta-record once
                %only at the top of the file.
                if (metaRecordFlag==false)
                    %fprintf(outputFile, '%s %s\n', fmt, num2str(IMEI));
                    %fprintf(rawHexFile, '%s %s\n', fmt, num2str(IMEI));
                    fprintf(outputFile, '%s %s %s\n', fmt, num2str(IMEI),num2str(instSN));
                    fprintf(rawHexFile, '%s %s %s\n', fmt, num2str(IMEI),num2str(instSN));
                    metaRecordFlag=true;   %set flag to indicate that the meta-Record has been written
                end
                
                for j = 1:size(scannedData,1)
                    rec = scannedData{j};
                    %disp(rec);
                    iesHrs = hex2dec(rec(1:5));
                    datenumber = iesHrs / 24 + datenum(1970,1,1);
                    ENhours = datestr(datenumber, 'YYYY mm dd HH');
                    ENtau = hex2dec(rec(6:10))/10000;
                    ENpress1 = hex2dec(rec(11:16));
                    ENtemp1 = hex2dec(rec(17:21));
                    ENsosP1 = hex2dec(rec(22:27));
                    ENsosT1 = hex2dec(rec(28:32));
                    ENsosR1 = hex2dec(rec(33:38));
                    ENsp1 = hex2dec(rec(39:41))/10;
                    ENhd1 = hex2dec(rec(42:44))/10;
                    ENpress2 = hex2dec(rec(45:50));
                    ENtemp2 = hex2dec(rec(51:55));
                    ENsosP2 = hex2dec(rec(56:61));
                    ENsosT2 = hex2dec(rec(62:65));
                    ENsosR2 = hex2dec(rec(67:72));
                    ENsp2 = hex2dec(rec(73:75))/10;
                    ENhd2 = hex2dec(rec(76:78))/10;
                    cs = rec(79);
                    
                    %Look at the checksum & convert to a number
                    if ( cs == 'Y')
                        checkSum = '1';
                    elseif ( cs=='N')
                        checkSum = '0';
                        err = err +1;
                    elseif (cs == '0') %Bad Data!!!
                        checkSum = '0';
                    end
                    
                    %disp([' Date & Hour: ' ENhours ', Tau: ' num2str(ENtau) ', Press1: ' num2str(ENpress1) ', Temp1: ' num2str(ENtemp1) ', SOS Press1: ' num2str(ENsosP1) ', SOS Temp1: ' num2str(ENsosT1) ', SOS Ref1: ' num2str(ENsosR1) ', Speed1: ' num2str(ENsp1)  ', Heading1: ' num2str(ENhd1)  ', Press2: ' num2str(ENpress2) ', Temp2: ' num2str(ENtemp2) ', SOS Press2: ' num2str(ENsosP2) ', SOS Temp2: ' num2str(ENsosT2) ', SOS Ref2: ' num2str(ENsosR2) ', Speed2: ' num2str(ENsp2)  ', Heading2: ' num2str(ENhd2)]);
                    disp(['    ' ENhours ', Tau: ' num2str(ENtau) ', Press1: ' num2str(ENpress1) ', Temp1: ' num2str(ENtemp1) ', SOS Press1: ' num2str(ENsosP1) ', SOS Temp1: ' num2str(ENsosT1) ', SOS Ref1: ' num2str(ENsosR1) ', Speed1: ' num2str(ENsp1)  ', Heading1: ' num2str(ENhd1)  ', Press2: ' num2str(ENpress2) ', Temp2: ' num2str(ENtemp2) ', SOS Press2: ' num2str(ENsosP2) ', SOS Temp2: ' num2str(ENsosT2) ', SOS Ref2: ' num2str(ENsosR2) ', Speed2: ' num2str(ENsp2)  ', Heading2: ' num2str(ENhd2)]);
                
                    padData=false;
                    %Detect the lines used to pad out the final SBD message
                    if(iesHrs==0  && checkSum=='1')
                        padData = true;
                    end
                    
                    if(padData == false)  %Write data to a file if it is not SBD Message pad data
                         fprintf(outputFile, '%06d %06d %06.0f %.0f %.0f %.0f %.0f %.0f %3.1f %3.1f %.0f %.0f %.0f %.0f %.0f %3.1f %3.1f %c\n', ...
                            MOMSN, iesHrs, ENtau, ENpress1, ENtemp1, ENsosP1, ENsosT1, ENsosR1, ENsp1, ENhd1, ...
                            ENpress2, ENtemp2, ENsosP2, ENsosT2, ENsosR2, ENsp2, ENhd2, checkSum);
                        fprintf(rawHexFile,'%06d %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s\n', ...
                            iesHrs,rec(1:5),rec(6:10),rec(11:16),rec(17:21),rec(22:27),rec(28:32),rec(33:38),rec(39:41), ...
                            rec(42:44),rec(45:50),rec(51:55),rec(56:61),rec(62:65),rec(67:72),rec(73:75),rec(76:78),cs);
                    end
                end
                fclose(fid);
            %---------------------------------------------------------------------------------------------------%
            
            %---------------------------------------------------------------------------------------------------%
            case {'04'} % Temp. measured 1/hour
                %scannedData = textscan(lineFromSBD(fmt_length+1:end), '%11[0123456789ABCDEFYNR:/_]');
                scannedData = textscan(lineFromSBD(fmt_length+1:end), '%10[0123456789ABCDEFYNR:/_]');
                scannedData = flipud(scannedData{1}); % Flips the order of the records within in the message
                %disp(scannedData{1});
                
                %Once we have the format information, write a meta-record once
                %only at the top of the file.
                if (metaRecordFlag==false)
                    %fprintf(outputFile, '%s %s\n', fmt, num2str(IMEI));
                    %fprintf(rawHexFile, '%s %s\n', fmt, num2str(IMEI));
                    fprintf(outputFile, '%s %s NaN\n', fmt, num2str(IMEI));
                    fprintf(rawHexFile, '%s %s NaN\n', fmt, num2str(IMEI));
                    metaRecordFlag=true;   %set flag to indicate that the meta-Record has been written
                end
                
                for j = 1:size(scannedData,1)
                    rec = scannedData{j};
                    %disp(rec);
                    pdsHrs = hex2dec(rec(1:5));
                    datenumber = pdsHrs / 24 + datenum(1970,1,1);
                    ENhours = datestr(datenumber, 'YYYY mm dd HH');
                    ENtemp1 = hex2dec(rec(6:10))/10000 - 30.0;
                    
                    %disp([' Date & Hour: ' ENhours ', Temp1: ' num2str(ENtemp1)]);
                    disp(['    ' ENhours ', Temp1: ' num2str(ENtemp1)]);
                
                    padData=false;
                    %Detect the lines used to pad out the final SBD message
                    if(pdsHrs==0)
                        padData = true;
                    end
                    
                    if(padData == false)  %Write data to a file if it is not SBD Message pad data
                        fprintf(outputFile, '%06d %06d %2.3f\n',MOMSN, pdsHrs, ENtemp1);
                        fprintf(rawHexFile,'%06d %s %s\n',pdsHrs,rec(1:5),rec(6:10));
                    end
                end
                fclose(fid);
            %---------------------------------------------------------------------------------------------------%     
            
            %---------------------------------------------------------------------------------------------------%
            case {'05'} % Temp. measured 2/hour
                scannedData = textscan(lineFromSBD(fmt_length+1:end), '%15[0123456789ABCDEFYNR:/_]');
                scannedData = flipud(scannedData{1}); % Flips the order of the records within in the message
                %disp(scannedData{1});
                
                %Once we have the format information, write a meta-record once
                %only at the top of the file.
                if (metaRecordFlag==false)
                    %fprintf(outputFile, '%s %s\n', fmt, num2str(IMEI));
                    %fprintf(rawHexFile, '%s %s\n', fmt, num2str(IMEI));
                    fprintf(outputFile, '%s %s NaN\n', fmt, num2str(IMEI));
                    fprintf(rawHexFile, '%s %s NaN\n', fmt, num2str(IMEI));
                    metaRecordFlag=true;   %set flag to indicate that the meta-Record has been written
                end
                
                for j = 1:size(scannedData,1)
                    rec = scannedData{j};
                    %disp(rec);
                    pdsHrs = hex2dec(rec(1:5));
                    datenumber = pdsHrs / 24 + datenum(1970,1,1);
                    ENhours = datestr(datenumber, 'YYYY mm dd HH');
                    ENtemp1 = hex2dec(rec(6:10))/10000 - 30.0;
                    ENtemp2 = hex2dec(rec(11:15))/10000 - 30.0;
                  
                    %disp([' Date & Hour: ' ENhours ', Temp1: ' num2str(ENtemp1) ', Temp2: ' num2str(ENtemp2)]);
                    disp(['    ' ENhours ', Temp1: ' num2str(ENtemp1) ', Temp2: ' num2str(ENtemp2)]);
                
                    padData=false;
                    %Detect the lines used to pad out the final SBD message
                    if(pdsHrs==0)
                        padData = true;
                    end
                    
                    if(padData == false)  %Write data to a file if it is not SBD Message pad data
                        fprintf(outputFile, '%06d %06d %2.3f %2.3f\n',MOMSN, pdsHrs, ENtemp1, ENtemp2);
                        fprintf(rawHexFile,'%06d %s %s %s\n',pdsHrs,rec(1:5),rec(6:10),rec(11:15));
                    end
                end
                fclose(fid);
            %---------------------------------------------------------------------------------------------------%
            
            %---------------------------------------------------------------------------------------------------%
            case {'06'} % Temp. measured 3/hour
                scannedData = textscan(lineFromSBD(fmt_length+1:end), '%20[0123456789ABCDEFYNR:/_]');
                scannedData = flipud(scannedData{1}); % Flips the order of the records within in the message
                %disp(scannedData{1});
                
                %Once we have the format information, write a meta-record once
                %only at the top of the file.
                if (metaRecordFlag==false)
                    %fprintf(outputFile, '%s %s\n', fmt, num2str(IMEI));
                    %fprintf(rawHexFile, '%s %s\n', fmt, num2str(IMEI));
                    fprintf(outputFile, '%s %s NaN\n', fmt, num2str(IMEI));
                    fprintf(rawHexFile, '%s %s NaN\n', fmt, num2str(IMEI));
                    metaRecordFlag=true;   %set flag to indicate that the meta-Record has been written
                end
                
                for j = 1:size(scannedData,1)
                    rec = scannedData{j};
                    %disp(rec);
                    pdsHrs = hex2dec(rec(1:5));
                    datenumber = pdsHrs / 24 + datenum(1970,1,1);
                    ENhours = datestr(datenumber, 'YYYY mm dd HH');
                    ENtemp1 = hex2dec(rec(6:10))/10000 - 30.0;
                    ENtemp2 = hex2dec(rec(11:15))/10000 - 30.0;
                    ENtemp3 = hex2dec(rec(16:20))/10000 - 30.0;
                    
                    %disp([' Date & Hour: ' ENhours ', Temp1: ' num2str(ENtemp1) ', Temp2: ' num2str(ENtemp2) ', Temp3: ' num2str(ENtemp3)]);
                    disp(['    ' ENhours ', Temp1: ' num2str(ENtemp1) ', Temp2: ' num2str(ENtemp2) ', Temp3: ' num2str(ENtemp3)]);
                
                    padData=false;
                    %Detect the lines used to pad out the final SBD message
                    if(pdsHrs==0)
                        padData = true;
                    end
                    
                    if(padData == false)  %Write data to a file if it is not SBD Message pad data
                        fprintf(outputFile, '%06d %06d %2.3f %2.3f %2.3f\n',MOMSN, pdsHrs, ENtemp1, ENtemp2, ENtemp3);
                        fprintf(rawHexFile,'%06d %s %s %s %s\n',pdsHrs,rec(1:5),rec(6:10),rec(11:15),rec(16:20));
                    end
                end
                fclose(fid);
            %---------------------------------------------------------------------------------------------------%
            
            %---------------------------------------------------------------------------------------------------%
            case {'07'} % Temp. measured 6/hour
                scannedData = textscan(lineFromSBD(fmt_length+1:end), '%35[0123456789ABCDEFYNR:/_]');
                scannedData = flipud(scannedData{1}); % Flips the order of the records within in the message
                %disp(scannedData{1});
                
                %Once we have the format information, write a meta-record once
                %only at the top of the file.
                if (metaRecordFlag==false)
                    %fprintf(outputFile, '%s %s\n', fmt, num2str(IMEI));
                    %fprintf(rawHexFile, '%s %s\n', fmt, num2str(IMEI));
                    fprintf(outputFile, '%s %s NaN\n', fmt, num2str(IMEI));
                    fprintf(rawHexFile, '%s %s NaN\n', fmt, num2str(IMEI));
                    metaRecordFlag=true;   %set flag to indicate that the meta-Record has been written
                end
                
                for j = 1:size(scannedData,1)
                    rec = scannedData{j};
                    %disp(rec);
                    pdsHrs = hex2dec(rec(1:5));
                    datenumber = pdsHrs / 24 + datenum(1970,1,1);
                    ENhours = datestr(datenumber, 'YYYY mm dd HH');
                    ENtemp1 = hex2dec(rec(6:10))/10000 - 30.0;
                    ENtemp2 = hex2dec(rec(11:15))/10000 - 30.0;
                    ENtemp3 = hex2dec(rec(16:20))/10000 - 30.0;
                    ENtemp4 = hex2dec(rec(21:25))/10000 - 30.0;
                    ENtemp5 = hex2dec(rec(26:30))/10000 - 30.0;
                    ENtemp6 = hex2dec(rec(31:35))/10000 - 30.0;

                    %disp([' Date & Hour: ' ENhours ', Temp1: ' num2str(ENtemp1) ', Temp2: ' num2str(ENtemp2) ', Temp3: ' num2str(ENtemp3) ', Temp4: ' num2str(ENtemp4) ', Temp5: ' num2str(ENtemp5) ', Temp6: ' num2str(ENtemp6)]);
                    disp(['    ' ENhours ', Temp1: ' num2str(ENtemp1) ', Temp2: ' num2str(ENtemp2) ', Temp3: ' num2str(ENtemp3) ', Temp4: ' num2str(ENtemp4) ', Temp5: ' num2str(ENtemp5) ', Temp6: ' num2str(ENtemp6)]);
                    padData=false;
                    %Detect the lines used to pad out the final SBD message
                    if(pdsHrs==0)
                        padData = true;
                    end
                    
                    if(padData == false)  %Write data to a file if it is not SBD Message pad data
                         fprintf(outputFile, '%06d %06d %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f\n',MOMSN, pdsHrs, ENtemp1, ENtemp2, ENtemp3, ENtemp4, ENtemp5, ENtemp6);
                        fprintf(rawHexFile,'%06d %s %s %s %s %s %s %s\n',pdsHrs,rec(1:5),rec(6:10),rec(11:15),rec(16:20),rec(21:25),rec(26:30),rec(31:35));
                    end
                end
                fclose(fid);
            %---------------------------------------------------------------------------------------------------%    
            
            %---------------------------------------------------------------------------------------------------%   
            otherwise
                fclose(fid);
                disp(['FORMAT ' fmt ' - UNSUPPORTED FORMAT']); 
            %---------------------------------------------------------------------------------------------------%   
        end %End of switch statement
        
        %Find any SBD Diagnostic Data and write it to the diag file
        % First look for the diag data delimiter, '$', then if found write
        % the diagnostic data to the diagnostic file.
        index_of_diag_delim = strfind(lineFromSBD,'$');
        if(index_of_diag_delim)
            fprintf(FID_diagOutFile,'%06d,%s\n', MOMSN, lineFromSBD(index_of_diag_delim+1:end));
        end

    end

    % close file
    fclose(outputFile);
    disp(['Done  -  see output file ==> ' CurrWorkingDir projDir IMEI '.dat'])
    fclose all;
    disp('  Total Checksum errors: ')
    disp(err)
 
    return
    
catch ME
    fclose('all');
    error('Error in function %s() at line %d.\n\nError Message:\n%s', ...
        ME.stack(1).name, ME.stack(1).line, ME.message);

end
      
end

function [cs,index] = sort_nat(c,mode)
%sort_nat: Natural order sort of cell array of strings.
% usage:  [S,INDEX] = sort_nat(C)
%
% where,
%    C is a cell array (vector) of strings to be sorted.
%    S is C, sorted in natural order.
%    INDEX is the sort order such that S = C(INDEX);
%
% Natural order sorting sorts strings containing digits in a way such that
% the numerical value of the digits is taken into account.  It is
% especially useful for sorting file names containing index numbers with
% different numbers of digits.  Often, people will use leading zeros to get
% the right sort order, but with this function you don't have to do that.
% For example, if C = {'file1.txt','file2.txt','file10.txt'}, a normal sort
% will give you
%
%       {'file1.txt'  'file10.txt'  'file2.txt'}
%
% whereas, sort_nat will give you
%
%       {'file1.txt'  'file2.txt'  'file10.txt'}
%
% See also: sort

% Version: 1.4, 22 January 2011
% Author:  Douglas M. Schwarz
% Email:   dmschwarz=ieee*org, dmschwarz=urgrad*rochester*edu
% Real_email = regexprep(Email,{'=','*'},{'@','.'})


% Set default value for mode if necessary.
if nargin < 2
	mode = 'ascend';
end

% Make sure mode is either 'ascend' or 'descend'.
modes = strcmpi(mode,{'ascend','descend'});
is_descend = modes(2);
if ~any(modes)
	error('sort_nat:sortDirection',...
		'sorting direction must be ''ascend'' or ''descend''.')
end

% Replace runs of digits with '0'.
c2 = regexprep(c,'\d+','0');

% Compute char version of c2 and locations of zeros.
s1 = char(c2);
z = s1 == '0';

% Extract the runs of digits and their start and end indices.
[digruns,first,last] = regexp(c,'\d+','match','start','end');

% Create matrix of numerical values of runs of digits and a matrix of the
% number of digits in each run.
num_str = length(c);
max_len = size(s1,2);
num_val = NaN(num_str,max_len);
num_dig = NaN(num_str,max_len);
for i = 1:num_str
	num_val(i,z(i,:)) = sscanf(sprintf('%s ',digruns{i}{:}),'%f');
	num_dig(i,z(i,:)) = last{i} - first{i} + 1;
end

% Find columns that have at least one non-NaN.  Make sure activecols is a
% 1-by-n vector even if n = 0.
activecols = reshape(find(~all(isnan(num_val))),1,[]);
n = length(activecols);

% Compute which columns in the composite matrix get the numbers.
numcols = activecols + (1:2:2*n);

% Compute which columns in the composite matrix get the number of digits.
ndigcols = numcols + 1;

% Compute which columns in the composite matrix get chars.
charcols = true(1,max_len + 2*n);
charcols(numcols) = false;
charcols(ndigcols) = false;

% Create and fill composite matrix, comp.
comp = zeros(num_str,max_len + 2*n);
comp(:,charcols) = double(s1);
comp(:,numcols) = num_val(:,activecols);
comp(:,ndigcols) = num_dig(:,activecols);

% Sort rows of composite matrix and use index to sort c in ascending or
% descending order, depending on mode.
[unused,index] = sortrows(comp);
if is_descend
	index = index(end:-1:1);
end
index = reshape(index,size(c));
cs = c(index);
end
