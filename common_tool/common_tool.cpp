#include "common_tool.h"


std::string FormatString(const char * format, ...)
{
    char buf[4096];
   	std::string strRet;
    if ( format != 0 )
    {
        va_list args;
        va_start(args, format);
        vsnprintf(buf, sizeof(buf), format, args);
        buf[sizeof(buf) - 1] = 0;
        va_end(args);
        strRet = buf;
    }
    return strRet;
}
