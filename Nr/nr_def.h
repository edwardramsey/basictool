#ifdef _NR_DEF_H
#define _NR_DEF_H

// define Nr filename
#define STATUS_FILE "status"
#define CAPABILITY_FILE	"capability"
#define CMD_LINE_FILE "cmd_line"
#define PID_FILE "pid"

// punctuation separate content in the file
#define SEPARATOR ":="


// define bash file path
#define SHELL_INIT "./nrInit.sh"

// default value 
const static int32 FILE_PERMISSION = 0770;
const static int32 DEFAULT_FILE_LEN = 1024;

static aistring nrFileType[] = {
		STATUS_FILE, CAPABILITY_FILE, CMD_LINE_FILE, PID_FILE
	};


#endif
