@echo off& call load.bat _strlen2 _getLF _getRandomNum _parseASCIIStr _showBlockASCII2 _infiniteLoopPause& call loadE.bat CurS curl jq urlencode win_iconv setWT& call loadJ.bat Md5Util& setlocal enabledelayedexpansion
%CurS% /crv 0
set appKey=2e92d7586dc7352a
set secretKey=zXQ1Vo4ODUt8nHc3H006BSRo5RMNhBzK
::https://github.com/afc163/fanyi
::有道翻译
::    接口API文档 http://ai.youdao.com/docs/api.s
::    中英 http://openapi.youdao.com/api?q=爱&from=zh_CHS&to=en&appKey=2e92d7586dc7352a&salt=1&sign=464E72FDEDE11962A65371A07BE0C423     ====>   http://openapi.youdao.com/api?q=%E7%88%B1&from=zh_CHS&to=en&appKey=2e92d7586dc7352a&salt=46&sign=4C3EEE22E9B06B191FA2A1430AB8C0E0
::    英中 http://openapi.youdao.com/api?q=love&from=en&to=zh_CHS&appKey=2e92d7586dc7352a&salt=58&sign=E6E3B884ADC9E9AD567709F172F82F56
::curl|jq|win_iconv通过管道相连
::jq -r 格式化输出 -c去除双引号 "filter,filter"逗号连接多个filter
::win_iconv -c 跳过不能解析的字符
::TODO 目前是英译汉, 后续增加汉译英
set word=%~1
if "!word!" EQU "" set word=love




set titleStr=翻译[!word!]& title !titleStr!& %setWT% !titleStr!,200
(%_call%  ("1 20 salt") %_getRandomNum%)
::set salt=5
for /f "delims=" %%i in ('%Md5Util% "!appKey!!word!!salt!!secretKey!"') do set sign=%%i
for /f "delims=" %%i in ('%urlencode% "!word!"') do set wordStr=%%i
%curl% -s "http://openapi.youdao.com/api?q=%wordStr%&from=en&to=zh_CHS&appKey=!appKey!&salt=!salt!&sign=!sign!"|%jq% -r -c ".web[].key,.web[].value,.basic.explains[]?"|%win_iconv% -c -f UTF-8 -t GBK>%temp%\fanyiData.txt

::parse
set /a keyIndex=valueIndex=explainIndex=1, keyFlag=valueFlag=screenWidth=screenHeight=0
for /f "delims=" %%i in (%temp%\fanyiData.txt) do (
	set str=%%i
	(%_call% ("str tempLen") %_strlen2%)
	set /a tempLen+=5& if !tempLen! GTR !screenWidth! set screenWidth=!tempLen!
	
	if "!str:~0,1!" EQU "[" (
		set valueStr=%%~i
		for /l %%a in (1,1,10) do (
			for /f "tokens=1* delims=[,]" %%b in ("!valueStr!") do (
				for %%x in (!valueIndex!) do set value%%x=!value%%x!%%~b & set valueStr=%%c
			)
		)
		set /a valueIndex+=1, keyFlag=1
	) else if !keyFlag! EQU 0 (
		set key!keyIndex!=%%i& set /a keyIndex+=1
	) else if !keyFlag! EQU 1 (
		set explain!explainIndex!=%%i& set /a explainIndex+=1
	)
)

::draw
set /a explainMax=explainIndex-1, keyMax=keyIndex-1
set drawStr=!LF!!LF!  !word!!LF!!LF!
for /l %%i in (1,1,!explainMax!) do set drawStr=!drawStr!  -  !explain%%i!!LF!
set drawStr=!drawStr!!LF!
for /l %%i in (1,1,!keyMax!) do set drawStr=!drawStr!  %%i. !key%%i!!LF!     !value%%i!!LF!
set drawStr=!drawStr!!LF!!LF!



(%_call% ("word asciiWord asciiWordHeight") %_parseASCIIStr%)
for /l %%i in (1,1,!asciiWordHeight!) do (
	set tempStr=!asciiWord_%%i!
	(%_call% ("tempStr tempLen") %_strlen2%)
	set /a tempLen+=2& if !tempLen! GTR !screenWidth! set screenWidth=!tempLen!
	set drawStr=!drawStr!  !tempStr!!LF!
)



if "%fanyiShowMode%" EQU "clip" (
	echo !drawStr!|clip
	exit
)
::show
::screenWidth: 字符串最大长度+4空格
::screenHeight: 2空行 + 1单词展示行 + 1空行 + n解释行 + 1空行 + m*2网络用法行 + 2空行 + asciiWordHeight + 3空行
set /a screenWidth+=4, screenHeight=2+1+1+explainMax+1+keyMax*2+2+asciiWordHeight+3
mode !screenWidth!,!screenHeight!
echo !drawStr!& (%_infiniteLoopPause%)