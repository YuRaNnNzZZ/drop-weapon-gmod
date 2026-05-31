@ECHO OFF

SET BIN=..\..\..\bin
IF EXIST %BIN%\win64 (
	SET BIN=%BIN%\win64
)

SET GMA_NAME=drop_weapon_rewrite
SET ID=946373028

%BIN%\gmad.exe create -out "%GMA_NAME%.gma" -warninvalid -folder "%~dp0
%BIN%\gmpublish.exe update -id "%ID%" -addon "%GMA_NAME%.gma"
del %GMA_NAME%.gma
pause