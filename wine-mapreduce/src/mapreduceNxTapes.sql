set mapred.map.tasks = 1099;  		-- Set to the number of tape files
set hive.base.inputformat=org.apache.hadoop.hive.ql.io.HiveInputFormat;
set mapreduce.job.reduces = 1099;	-- Set to the number of tape files
set mapred.reduce.tasks = 1099;		-- Set to the number of tape files
set mapred.task.timeout = 86400000;	-- Set to 24 Hours currently needs to be bumped up since a Full Extract of New Data was 1.9 days! This was for a below than average sized file.
ADD FILE processNxTape.sh;			-- In here set the type of processing: All, trades only, L1 quotes only, message counts, etc.

DROP TABLE IF EXISTS nxcore_processed_files;
CREATE TABLE nxcore_processed_files(
	filename string)
	ROW FORMAT DELIMITED 
		FIELDS TERMINATED BY '\t'
		LINES TERMINATED BY '\n';

FROM(
	FROM nxcore_raw_files			-- Table in HDFS with NxCore file names (I think it has date and filename as the columns)
	MAP filename
	USING '/bin/cat'
	AS filename
	cluster by filename) nxcore
INSERT OVERWRITE TABLE nxcore_processed_files
	REDUCE nxcore.filename
	USING 'bash processNxTape.sh'	-- Execute bash script piping in the file name from the MAPPER
	AS filename;
