DROP TABLE IF EXISTS nxcore_staging_mmquotes;
CREATE EXTERNAL TABLE nxcore_staging_mmquotes (
		system_date				string,
		system_time				string,
		system_timezone			string,
		system_dst_indicator	string,
		system_ndays			string,
		system_dayofweek		string,
		system_dayofyear		string,
		nxsession_date			string,
		nxsession_dst_indicator	string,
		nxsession_ndays			string,
		nxsession_dayofweek		string,
		nxsession_dayofyear		string,
		nxexg_time				string,
		nxexg_timezone			string,
		symbol					string,
		listed_exg				string,
		reporting_exg			string,
		session_id				string,
		mm_ask_price			string,
		--mm_ask_price_change_int	string,
		mm_ask_price_change		string,
		mm_ask_size				string,
		mm_ask_size_change		string,
		--mm_bid_price_int		string,
		mm_bid_price			string,
		--mm_bid_price_change_int	string,
		mm_bid_price_change		string,
		mm_bid_size				string,
		mm_bid_size_change		string,
		mm_nasdaq_bid_tick		string,
		mm_price_type			string,
		mm_quote_condition_id	string,
		--mm_quote_condition_string string,
		mm_refresh				string,
		marketmaker_type		string,
		pnxstring_marketmaker	string,
		mm_quote_type			string
		) ROW FORMAT DELIMITED 
			FIELDS TERMINATED BY '\t'
			LINES TERMINATED BY '\n'
		STORED AS TEXTFILE
		LOCATION '/data/staging/nxcore/mmquotes';
