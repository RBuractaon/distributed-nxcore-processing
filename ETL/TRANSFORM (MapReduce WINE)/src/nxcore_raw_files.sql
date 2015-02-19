CREATE EXTERNAL TABLE nxcore_raw_files (
  date timestamp,
  filename string
  )
  ROW FORMAT DELIMITED
  FIELDS TERMINATED BY '\t'
  LINES TERMINATED BY '\n'
  STORED AS TEXTFILE LOCATION 'nxcore_raw_files';
