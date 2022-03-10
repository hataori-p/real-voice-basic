@ECHO OFF
SETLOCAL
:: set this to your RealVoice directory, don't use " double quotes, use / forward slashes
SET rv_path=C:/RealVoice/
"C:/RealVoice/lua54.exe" -E -e "package.path='%rv_path%lib/?.lua'" "%rv_path%scripts/%1.lua" %2 %3 %4 %5 %6 %7 %8 %9
