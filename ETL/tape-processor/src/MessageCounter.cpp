#define _CRT_SECURE_NO_WARNINGS
#include <windows.h>
#include <stdio.h>
#include <process.h>
#include <direct.h>
#include <stdlib.h>
#include <fstream>
#include <iomanip>

#include "NxCoreAPI.h"
#include "NxCoreAPI_class.h"    

using namespace std;
static NxCoreClass nxCoreClass;


struct PerThreadData
{
	__int64 counter;
	__int64 tcounter;
	__int64 ecounter;
	__int64 mcounter;
	int rc;
	int time;
	const char* tape;
	PerThreadData() : counter(0), tcounter(0), ecounter(0), mcounter(0), rc(0), time(0), tape(0) {}
};

static int __stdcall nxCoreCallback(const NxCoreSystem* pNxCoreSys, const NxCoreMessage* pNxCoreMessage)
{
	PerThreadData *perThreadData = (PerThreadData*)pNxCoreSys->UserData;

	
		switch (pNxCoreMessage->MessageType) {
		case NxMSG_EXGQUOTE:	 {perThreadData->ecounter++; break; }
		case NxMSG_MMQUOTE:	     {perThreadData->mcounter++; break; }
		case NxMSG_TRADE:		 {perThreadData->tcounter++; break; }
	}
	perThreadData->counter++;

	//if ((pNxCoreMessage->MessageType == NxMSG_STATUS) && (pNxCoreSys->ClockUpdateInterval >= NxCLOCK_MINUTE))
	//{
	//	printf("Tape Date: %02d/%02d/%d  Tape Time: %02d:%02d:%02d\n",
	//		pNxCoreSys->nxDate.Month, pNxCoreSys->nxDate.Day, pNxCoreSys->nxDate.Year,
	//		pNxCoreSys->nxTime.Hour, pNxCoreSys->nxTime.Minute, pNxCoreSys->nxTime.Second);
	//}

	return NxCALLBACKRETURN_CONTINUE;
}

static void handleTapeThread(void *arg)
{
	PerThreadData *perThreadData = (PerThreadData*)arg;
	long startTick = GetTickCount();
	perThreadData->rc = nxCoreClass.ProcessTape(perThreadData->tape, 0, 0, (int)perThreadData, nxCoreCallback);
	perThreadData->time = GetTickCount() - startTick;
}

int main(int argc, char** argv)
{
	if (argc == 1)
	{
		fprintf(stderr, "%s tape1 [tape2 tape3 ...]\n", argv[0]);
		return -1;
	}

	if (!nxCoreClass.LoadNxCore("NxCoreAPI.dll") &&
		!nxCoreClass.LoadNxCore("C:\\Program Files\\Nanex\\NxCoreAPI\\NxCoreAPI.dll"))
	{
		fprintf(stderr, "Can't find NxCoreAPI.dll\n");
		return -1;
	}
	ofstream outstream;
	char outfile[_MAX_FNAME];
	sprintf(outfile, "%s_COUNTS.csv", argv[1]);
	printf("Output File: %s\n", outfile);
	outstream.open(outfile, std::ios::app);
	//outstream << "Tape\tCount\tTrades\tExgQuotes\tMMQuotes\tRC\tMillis" << endl;
	const int numTapes = argc - 1;
	HANDLE *threads = new HANDLE[numTapes];
	PerThreadData *perThreadData = new PerThreadData[numTapes];

	for (int i = 0; i < numTapes; i++)
	{
		perThreadData[i].tape = argv[i + 1];
		printf("Start Tape: %s\n", perThreadData[i].tape);
		threads[i] = (HANDLE)_beginthread(handleTapeThread, 0, (void*)&perThreadData[i]);
	}

	WaitForMultipleObjects(numTapes, threads, TRUE, INFINITE);

	for (int i = 0; i < numTapes; i++)
	{
		const PerThreadData& ptd = perThreadData[i];
		printf("Tape[%s] Count[%I64d] Trades[%I64d] ExgQuotes[%I64d] MMQuotes[%I64d] RC[%ld] Millis[%ld]\n", ptd.tape, ptd.counter, 
			ptd.tcounter, ptd.ecounter, ptd.mcounter, ptd.rc, ptd.time);
		outstream << ptd.tape << "\t" << ptd.counter << "\t" << ptd.tcounter << "\t" << ptd.ecounter
			<< "\t" << ptd.mcounter << "\t" << ptd.rc << "\t" << ptd.time << endl;
	}
	outstream.close();
	delete threads;
	delete perThreadData;
	return 0;
}
