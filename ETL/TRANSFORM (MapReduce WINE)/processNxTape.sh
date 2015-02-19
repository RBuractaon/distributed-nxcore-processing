#!/bin/sh
while read x y;												# Gets Filename From PIPE
do
   rm -rf /tmp/nx/$x										# Removes previous version of tape file
   X=`echo $x|sed s/.nxc//`									# Mangles File name removing extension
   hadoop fs -copyToLocal /data/raw/nxcore/$x /tmp/nx/. 	# Copies NxCore Tape from HDFS Locally
   TAPE=`ls -1 /tmp/nx/$x`									# Form full path file name
   echo "Processing $TAPE using WINE on $HOSTNAME" >&2		# Display helpful debug message in MapReduce Logs
   wine C:\\data\\ProcessTape.exe $TAPE			     		# Extracts All Data (Trades, ExgQuotes, MMQuotes, and SymbolChanges)
   #wine C:\\data\\ProcessTapeExtractTrades.exe $TAPE		# Extracts Trades Only (and Symbol Changes)
   #wine C:\\data\\ProcessTapeExtractQuotesL1.exe $TAPE		# Extracts Exchange Quotes Only (Level 1)
   #wine C:\\data\\ProcessTapeExtractQuotesL2.exe $TAPE		# Extracts Market Maker Quotes Only (Level 2)
   MM=`ls -1 /tmp/nx/processed/mmquote/$X*`					# Gets full path file name of extracted MMQUOTE file
   EX=`ls -1 /tmp/nx/processed/exgquote/$X*`				# Gets full path file name of extracted EXGQUOTE file
   TR=`ls -1 /tmp/nx/processed/trade/$X*`					# Gets full path file name of extracted TRADE file
   hadoop fs -copyFromLocal $TR /data/staging/nxcore/extract/trade/.	# Uploads trades CSV to HDFS
   hadoop fs -copyFromLocal $EX /data/staging/nxcore/extract/exgquote/.	# Uploads exgquotes CSV to HDFS
   hadoop fs -copyFromLocal $MM /data/staging/nxcore/extract/mmquote/.	# Uploads mmquotes CSV to HDFS
   rm $TR													# Clean up: Delete extracted trades CSV file
   rm $EX													# Clean up: Delete extracted exgquotes CSV file
   rm $MM													# Clean up: Delete extracted mmquotes CSV file
   rm $TAPE													# Clean up: Delete NxCore Tape File
done
