# distributed-nxcore-processing
NXCore Data Munging

The following project is used to decompress NxCore Historical Tape files (highly compressed financial market data http://www.nanex.net/historical.html) created by Nanex, LLC. The C/C++/C# API requires the use of a Microsoft Windows dynamic-link library (NxCore.dll) which is provided with the historic tape files upon purchase.


The ETL directory contains a distributed tape processing and message extraction using Hadoop. Using MapReduce through a hive streaming of a bash script.
1. NxCore tape files are uploaded to HDFS.
2. A table is created containing the date and filename of each tape
2. A hive streaming of bash script is used to distribute each file to a mapper
3. The script calls WINE to execute the tape processor windows executable file. This uses the Nanex, LLC proprietary .DLL to decompress the binary tape file
4. WINE accesses the tape files on HDFS using a HDFS NFS Gateway (/mnt/nfs_hdfs -> Z: in wine)
5. WINE writes extracted messages to HDFS using another HDFS Gateway

To help with the network bandwidth multiple HDFS NFS Gateways should be setup and configured for each worker node.
