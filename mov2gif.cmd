::@echo off
setlocal
if "%1" == "" goto :usage
set FFMPEG="c:\tools\ffmpeg64\ffmpeg.exe"
set FPS=12
set WIDTH=480

set INPUT=%1
set START=%2
set LENGTH=%3

if "%START%" == "" set START=0
if "%LENGTH%" == "" set LENGTH=5

set BNAME=%INPUT:.mp4=%
set BNAME=%BNAME:~-6%

set LOGDIR=log
if not exist %LOGDIR%\. mkdir %LOGDIR%

set TMPDIR=tmp
if not exist %TMPDIR%\. mkdir %TMPDIR%

set OUTDIR=gif
if not exist %OUTDIR%\. mkdir %OUTDIR%

set LOGFILE=%LOGDIR%\%BNAME%.%START%.%LENGTH%.log

:trim
:: STEP 1 = EXTRACT
set TRIMMED="%TMPDIR%\%BNAME%.%START%.%LENGTH%.%FPS%.mp4"
if exist %TRIMMED% goto :palette
echo === TRIM INPUT FILE
%FFMPEG% -i %INPUT% -ss %START% -t %LENGTH% -vf fps=%FPS%,scale=%WIDTH%:-1:flags=lanczos -an -b:v 5M -y %TRIMMED% 2>> %LOGFILE%

:: generate palette
:palette
set PALETTE="%TMPDIR%\%BNAME%.%START%.palette.png"
if exist %PALETTE% goto :animated
echo === CALCULATE PALETTE
%FFMPEG% -i %TRIMMED% -vf scale=%WIDTH%:-1:flags=lanczos,palettegen -y %PALETTE% 2>> %LOGFILE%


:animated
set GIF="%OUTDIR%\%BNAME%.%START%.%LENGTH%.%FPS%.gif"
if exist %GIF% goto :eof
echo === CONVERT TO ANIMATED GIF
%FFMPEG% -i %TRIMMED% -i %PALETTE% -r 6 -filter_complex "[x]; [x][1:v] paletteuse" -y %GIF% 2>> %LOGFILE%
goto :eof



:usage
echo %0 [INPUT FILE] [start] [length]

goto :eof
