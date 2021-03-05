# sbd2popDat
PDS and TPOP Iridium Message Decoder

    Concatinates Iridium Short Burst Data (SBD) message files originating
    from a PDS or TPOP, converts them to data units and parses the
    decoded messages to a data file, engineering file, diagnostic file
    and an undecoded raw data file.
 
    Required Argument:
        IMEI:    IMEI# file prefix either as a string or double
 
    Optional Name-Value Pair Arguments:
        SubDir: Subdirectory of the current working directory that the 
                 sbd files are located in, if left empty
                 popData will look in the current working directory
        IESSN:  IES (PIES or CPIES ONLY) Serial Number that the PDS is
                 associated with.  If this option is not utilized, a NaN
                 value will be written to the  meta-record in place of the
                 serial number. Note that the IES SN does not apply to the
                 TPOP.
 
    sbd2popDat(IMEI) processes the sbd messages located in the same
        directory as sbd2popDat
 
    sbd2popDat(IMEI,'SubDir',subdir,'IESSN',sn) processes the sbd messages 
        in the subdir subdirectory to sbd2popDat and writes sn to the data
        meta-record.
        
    usage example 1:
        The sbd files are located in the same directory as sbd2popDat, a NaN
        value will be written to the data meta-record
        sbd2popDat(300234011971200)
 
    usage example 2: 
        The sbd files are located in a subdirectory to sbd2popDat, a NaN
        value will be written to the data meta-record
        sbd2popDat(300234011971200,'SubDir','PDS085')
 
    usage example 3:
        The sbd files are located in the same directory as sbd2popDat, 424
        will be written as the associated PIES or CPIES serial number to
        the data meta-record
        sbd2popDat(300234011971200,'IESSN',424)
 
    usage example 4:
        The sbd files are located in a subdirectory to sbd2popDat, 424
        will be written as the associated PIES or CPIES serial number to
        the data meta-record
        sbd2popDat(300234011971200,'SubDir','PDS085','IESSN,424)
 
 
    A two character format (fmt) field is included at the beginning of each
    SBD message.  This format field is used to indicate to the processing
    routine how to unpack and decode the data in the remainder of the message.
    The M1, M2 and M3 records do not require decoding and are written
    directly to the <IMEI>_eng.dat file.
 
    The supported formats (FMT):
        M1      GPS/Engineering Record transmitted at the start of a data session.
        M2      GPS/Engineering Record transmitted at the end of a data session.
        M3      GPS/Engineering Record transmitted at the user's request.
        00      Non-valid format
        01      PIES Data
        02      CPIES Data
        03      Dual-Pressure CPIES Data
        04      TPOP Data - 1 sample/hr
        05      TPOP Data - 2 sample/hr
        06      TPOP Data - 3 sample/hr
        07      TPOP Data - 6 sample/hr
 
    PIES & CPIES Data Meta-Record Format
        FMT IMEI IESSN
 
    TPOP Data Meta-Record Format
        FMT IMEI NaN
 
    Note: For the TPOP, a NaN value is appended to the data meta-record as
      placeholder such that all data meta-records can be decoded equally.
 
    PDS Output Data Fields:
        MOMSN           Mobile Originated Sequence Number
        iesHRS          IES Hours elapsed since 1-Jan-1970
        TAU             Six Byte Travel Time (Hourly First Quartile)
        P1,P2           Seven Byte Pressure
        T1,T2           Five Byte Temperature from Pressure Sensor
        S1,S2           Five Byte Speed
        H1,H2           Five Byte Direction
        sosP1,sosP2     Six Byte Pressure from SOS Pressure Sensor
        sosT1,sosT2     Five Byte Temperature from SOS Pressure Sensor
        sosR1,sosR2     Six Byte Reference from SOS Pressure Sensor
        CS              One Byte Checksum (1-Checksum OK, 0-Checksum BAD)
 
        All fields are space delimited and numeric
 
    PDS Format 01 Output File Format:
        MOMSN iesHRS TAU P1 P2 CS
 
    PDS Format 02 Output File Format:
        MOMSN iesHRS TAU P1 S1 H1 P2 S2 H2 CS
 
    PDS Format 03 Output File Format:
        MOMSN iesHRS TAU P1 T1 sosP1 sosT1 sosR1 S1 H1 P2 T2 sosP2 sosT2 sosR2 S2 H2 CS
 
    PDS Format 02 Example Output Data:
            000016 410055 4.5639 3498129 5.4 234.8 3498180 9.4 276.5 1
            000016 410056 4.5633 3498247 8.2 230.2 3498315 8.4 269.9 1
            000016 410057 4.5638 3498393 8.0 256.0 3498465 6.6 277.4 1
 
 
    TPOP Output Data Fields:
        MOMSN           Mobile Originated Sequence Number
        pdsHRS          PDS Hours elapsed since 1-Jan-1970
        TEMP 1-6        Temperature Samples, degC
 
    TPOP Format 04 Output File Format:
        MOMSN pdsHRS TEMP1
 
    TPOP Format 05 Output File Format:
        MOMSN pdsHRS TEMP1 TEMP2
 
    TPOP Format 06 Output File Format:
        MOMSN pdsHRS TEMP1 TEMP2 TEMP3
 
    TPOP Format 07 Output File Format:
        MOMSN pdsHRS TEMP1 TEMP2 TEMP3 TEMP4 TEMP5 TEMP6
 
 
    2021 University of Rhode Island - Graduate School of Oceanography
