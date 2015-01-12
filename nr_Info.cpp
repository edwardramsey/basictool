#include "nr_info.h"


int32 NrInfo::WriteToFile(const char *szFileName, const char *szFileContent)
{
	CAutoLock Lock(s_lock); 
	if (NULL == szFileName || NULL == szFileContent) 
	{
		return -1;
	}

	FILE *fd = fopen(szFileName, "w");
	if(!fd)
	{
		return -1;
	}
	
	int32 iRet = fwrite(szFileContent, strlen(szFileContent), 1, fd);
	if(1 != iRet)
	{
		fclose(fd);
		return -1;
	}

	fclose(fd);
	return 0;
}


int32 NrInfo::ReadNrRecord(
		aistring& filename, 
		AISTD map<aistring, aistring>& mapItemValue)
{
	CAutoLock Lock(s_lock);
	FILE* fd = fopen(filename.c_str(), "r");
	if(!fd)
	{
		return -1;
	}

	char szBuf[DEFAULT_FILE_LEN] = {0};

	while(fgets(szBuf, sizeof(szBuf), fd) != NULL)
	{
		if(NULL != szBuf)
		{
			aistring line = szBuf;
			int32 pos = line.find(SEPARATOR);
			
			if(pos != AISTD string::npos)
			{
				mapItemValue[line.substr(0, pos)] = line.substr(pos+2);
			}
		}	
	}

	fclose(fd);

	return 0;
}

int32 NrInfo::ReadNrRecord(
	aistring& filename, 
	AISTD vector<aistring>& vecItemName,
	AISTD map<aistring, aistring>& mapItemValue)
{
	mapItemValue.clear();
	CAutoLock Lock(s_lock);
	FILE* fd = fopen(filename.c_str(), "r");
	if(!fd)
	{
		return -1;
	}

	char szBuf[DEFAULT_FILE_LEN] = {0};

	while(fgets(szBuf, sizeof(szBuf), fd) != NULL)
	{
		if(NULL != szBuf)
		{
			aistring line = szBuf;
			int32 pos = line.find(SEPARATOR);
			
			aistring key;
			if(pos != AISTD string::npos)
			{
				key = line.substr(0, pos);	
				for(int32 i = 0; i < vecItemName.size(); ++i)
				{
					if(key == vecItemName[i])
					{
						mapItemValue[key] = line.substr(pos+2);
						if("\n" == line.substr(line.length()-1))
						{
							mapItemValue[key] = mapItemValue[key].substr(0, mapItemValue[key].length()-1);
						}
						break;
					}
				}
			}

		}	
	}

	fclose(fd);

	return 0;
}



int32 NrInfo::InitNrFile(NrProcKey& nrProcKey)
{
	int iRet = 0; 
	if (0 == nrProcKey.m_iFlowId 
	 || 0 == nrProcKey.m_iSrvId 
	 || 0 == nrProcKey.m_iProcId)
	{
		return -1;
	}

	if(NULL == opendir(nrProcKey.g_rootPath.c_str()))
	{
		return -1;
	}
	
	char szText[DEFAULT_FILE_LEN] ={0};
	snprintf(szText, sizeof(szText), "%s%d_%d_%d/", nrProcKey.g_rootPath.c_str(), 
					nrProcKey.m_iFlowId, nrProcKey.m_iSrvId, nrProcKey.m_iProcId);
	m_strNrPath = szText;

	aistring strShellCmd = SHELL_INIT;
	strShellCmd += m_strNrPath;
	for(int32 i =0; i < sizeof(nrFileType)/sizeof(aistring); ++i)
	{
		strShellCmd += " " + nrFileType[i];
	}
	
	strShellCmd += " 1>/dev/null 2>&1 &";
	// 手动恢复信号量
	signal(SIGCHLD, SIG_DFL);
	iRet = system(strShellCmd.c_str());

	// if(NULL == opendir(m_strNrPath))
	// {
	// 	DBE2_LOG(DEBUG_LOGGER, "need mkdir path %s", m_strNrPath.c_str());
	// 	int32 ret = mkdir(m_strNrPath.c_str(), FILE_PERMISSION);
	// 	if(0 != ret)
	// 	{
	// 		DBE2_LOG(ERROR_LOGGER, "mkdir path %s fail,errno %d, err_msg:%s",
	// 								m_strNrPath.c_str(), errno, strerror(errno));
	// 		return -1;
	// 	}
	// }
	// else
	// {
	// 	DBE2_LOG(DEBUG_LOGGER, "path [%s] exist", m_strNrPath.c_str());
	// }

	return iRet;
}

// int32 NrInfo::ReadInfo(
// 		NrProcKey& nrProcKey,
// 		aistring& strItemName, 
// 		aistring& strItemValue, 
// 		char* fileName)
// {
// 	int32 iRet = InitNrFile(nrProcKey);
// 	if(0 != iRet)
// 	{
// 		DBE2_LOG(ERROR_LOGGER, "init nr[%d-%d-%d] file error", 
// 						nrProcKey.m_iFlowId, nrProcKey.m_iSrvId, nrProcKey.m_iProcId);
// 	}
//
// 	aistring path = m_strNrPath + fileName;
// 	AISTD vector<aistring> vecItemName;
// 	vecItemName.push_back(strItemName);
// 	AISTD vector<aistring> vecItemValue;
// 	iRet = ReadNrRecord(path.c_str(), vecItemName, vecItemValue);	
// 	if(0 != iRet)
// 	{
// 		DBE2_LOG(ERROR_LOGGER, "read Nr record failed");
// 		return -1;
// 	}
//
// 	strItemValue = vecItemValue[0];
//
// 	return iRet;
	
	// aistring strFileContent = "";
    //
	// aistring strNrFile;
	// int32 iRet = 0;
    //
	// for(int32 i=0; i < nrFileType.size(); ++i)
	// {
	// 	strNrFile = strNrPath + nrFileType[i];
	// 	iRet |= WriteToFile(rPk, strNrFile.c_str(), strFileContent.c_str());
	// 	if(0 != iRet)
	// 	{
	// 		DBE2_LOG("new file [%s] error", nrFileType[i]);
	// 	}
	// }
//}

int32 NrInfo::ReadInfo(
		NrProcKey& nrProcKey,
		AISTD vector<aistring>& vecItemName, 
		AISTD map<aistring, aistring>& mapItemValue, 
		const char* fileName)
{
	int32 iRet = InitNrFile(nrProcKey);
	if(0 != iRet)
	{
		return -1;
	}

	aistring path = m_strNrPath + fileName;
		
	if("" != fileName)
	{
		iRet = ReadNrRecord(path, vecItemName, mapItemValue);	
		if(0 != iRet)
		{
			return -1;
		}
	}
	else
	{
		for(int32 i = 0; i < sizeof(nrFileType)/sizeof(aistring); ++i)
		{
			aistring path = m_strNrPath + nrFileType[i];
		
			iRet = ReadNrRecord(path, vecItemName, mapItemValue);	
			if(0 != iRet)
			{
				return -1;
			}	
		}
		
	}

	return iRet;
}

int32 NrInfo::WriteInfo(
		NrProcKey& nrProcKey,
		AISTD map<aistring, aistring>& mapItemValue, 
		const char* fileName)
{
	int32 iRet = InitNrFile(nrProcKey);
	if(0 != iRet)
	{
		return -1;
	}

	if("" != fileName)
	{
		aistring path = m_strNrPath + fileName;
		AISTD map<aistring, aistring> mapFileValue;	
		aistring strFileContent;

		iRet = ReadNrRecord(path, mapFileValue);	
		if(0 != iRet)
		{
			return -1;
		}

		AISTD map<aistring, aistring>::iterator it = mapItemValue.begin();
		for(it = mapItemValue.begin(); it != mapItemValue.end(); ++it)
		{
			AISTD map<aistring, aistring>::iterator itInFile;
			itInFile = mapFileValue.find(it->first);
			if(itInFile != mapFileValue.end())
			{
				itInFile->second = it->second;
			}
			else
			{
				mapFileValue[it->first] = it->second; 
			}
		}

		for(it = mapFileValue.begin(); it != mapFileValue.end(); ++it)
		{
			char szText[DEFAULT_FILE_LEN] ={0};
			snprintf(szText, sizeof(szText), "%s%s%s\n", 
					(it->first).c_str(), SEPARATOR, (it->second).c_str());
			strFileContent += szText; 
		}

		iRet = WriteToFile(path.c_str(), strFileContent.c_str());
		if(0 != iRet)
		{
			return -1;
		}
		
	}

	return iRet;

}


NrInfo* NrInfo::GetInstance()
{

	// if(NULL == opendir(g_rootPath.c_str()))
	// {
	// 	DBE2_LOG(ERROR_LOGGER, "root path error");
	// 	return NULL;
	// }

	if(NULL == m_pInstance)
	{
		s_lock.lock();
		if(NULL == m_pInstance)
		{
			// static NrInfo sNrInfo();
			m_pInstance = new NrInfo;
		}
		s_lock.unlock();
	}

	return m_pInstance;
}





