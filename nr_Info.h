#include <iostream>
#include "compile.h"
#include "aistring.h"
#include <map>
#include <vector>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <sys/types.h>
#include <dirent.h>
#include <pthread.h>

#define STATUS_FILE "status"
#define CAPABILITY_FILE	"capability"
#define CMD_LINE_FILE "cmd_line"
#define PID_FILE "pid"

#define SEPARATOR ":="

#define SHELL_INIT "./nrInit.sh "

const static int32 FILE_PERMISSION = 0770;
const static int32 DEFAULT_FILE_LEN = 1024;

//static aistring g_rootPath = "~/ipc/nr";

class locker  
{  
public:  
    inline locker(){
		pthread_mutexattr_t attr_;
        pthread_mutexattr_init(&attr_);
        pthread_mutexattr_settype(&attr_, PTHREAD_MUTEX_RECURSIVE);
		pthread_mutex_init(&mutex, &attr_);
	}  

    inline ~locker(){
		pthread_mutex_destroy(&mutex);
	}

    inline void lock(){
		pthread_mutex_lock(&mutex);
	}  

    inline void unlock(){
		pthread_mutex_unlock(&mutex);
	}

private:  
    pthread_mutex_t mutex;  
};

class CAutoLock
{
public:
	CAutoLock(locker &lock):m_lock(lock)
	{
		m_lock.lock();
	}

	~CAutoLock()
	{
		m_lock.unlock();
	}

private:
	CAutoLock(const CAutoLock &rhs):m_lock(rhs.m_lock)
	{
		*this = rhs;
	}

	CAutoLock &operator=(const CAutoLock & rhs)
	{
		return *this;
	}

private:
	locker &m_lock;
};


class NrProcKey
{
public:
	int32 m_iFlowId;
	int32 m_iSrvId;
	int32 m_iProcId;

	aistring g_rootPath;
};

static aistring nrFileType[] = {
		STATUS_FILE, CAPABILITY_FILE, CMD_LINE_FILE, PID_FILE
	};

class NrInfo
{

public:
	/*
	 * 获取实例
	 * 所有对文件的读取都通过这个单例
	 */
	static NrInfo* GetInstance();

private:
	NrInfo()
	{

	}

	~NrInfo()
	{

	}

	NrInfo(const NrInfo&);
	NrInfo& operator=(const NrInfo&);

public:

	/*
	 * 读取文件中数据
	 * @param strItemName 数据名称
	 * @param strItemValue 返回的数据值
	 * @param filename 文件名称，默认为所有文件
	 */
	/*int32 ReadAllInfo(
			NrProcKey& nrProcKey,
			AISTD map<aistring, aistring> mapItemValue);

	int32 ReadArrayInfo(
			NrProcKey nrProcKey,
			AISTD vector<aistring>& vecItemName,
			AISTD vector<aistring>& vecItemValue,
			char* filename
			);*/
	
	int32 ReadInfo(
			NrProcKey& nrProcKey,
			AISTD vector<aistring>& vecItemName, 
			AISTD map<aistring, aistring>& mapItemValue, 
			const char* fileName);

	/*
	 * 写入数据
	 */
	int32 WriteInfo(
			NrProcKey& nrProcKey,
			AISTD map<aistring, aistring>& mapItemValue,
			const char* filename);

private:

	/*
	 *	初始化NR文件夹，单例初始化时操作
	 *	1. 若存在该目录则删除该目录下的内容
	 *	2. 若不存在该目录则生成新的文件
	 */
	int32 InitNrFile(NrProcKey& nrProcKey);


	int32 WriteToFile(const char *szFileName, const char *szFileContent);

	int32 ReadNrRecord(
			aistring& filename, 
			AISTD map<aistring, aistring>& strItemValue);

	int32 ReadNrRecord(
		aistring& filename, 
		AISTD vector<aistring>& vecItemName,
		AISTD map<aistring, aistring>& mapItemValue);

private:

	static NrInfo* m_pInstance;

	// 保存对应flow_id, srv_id, proc_id 的路径
	aistring m_strNrPath;

	//pthread_mutex_t mutex;

	// 保存读取出的纪录
	AISTD map<aistring, aistring> m_MapNrRecord;

	static locker s_lock;
};


