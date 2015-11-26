@echo off
setlocal
if "%2" == "" goto :usage
set FFMPEG="c:\tools\ffmpeg.exe"
set FPS=8
set WIDTH=480

set TITLE=%1
set INPUT=%2
set START=%3
set LENGTH=%4

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
set TRIMMED="%TMPDIR%\%BNAME%.%START%.%LENGTH%.mp4"
if exist %TRIMMED% goto :palette
echo === TRIM INPUT FILE %INPUT%
:: -vf drawtext="fontfile=input/calibrib.ttf: text='%TITLE%': fontcolor=white: fontsize=24: box=1: x=25: y=25"
%FFMPEG% -i %INPUT% -ss %START% -t %LENGTH% -acodec copy -vf "scale=%WIDTH%:-1:flags=lanczos" -vf drawtext="fontfile=input/calibrib.ttf:text=%TITLE%:fontsize=30:fontcolor=white:x=10:y=35" -b:v 10M -y %TRIMMED% 2>> %LOGFILE%

:: generate palette
:palette
set PALETTE="%TMPDIR%\%BNAME%.%START%.palette.png"
if exist %PALETTE% goto :animated
echo === CALCULATE PALETTE
%FFMPEG% -i %TRIMMED% -vf scale=%WIDTH%:-1:flags=lanczos,palettegen -y %PALETTE% 2>> %LOGFILE%


:animated
set GIF="%OUTDIR%\%BNAME%.%START%.gif"
if exist %GIF% goto :eof
echo === CONVERT TO ANIMATED GIF
%FFMPEG% -i %TRIMMED% -i %PALETTE% -filter_complex "setpts=0.75*PTS,fps=%FPS%,scale=%WIDTH%:-1:flags=lanczos [x]; [x][1:v] paletteuse" -y %GIF% 2>> %LOGFILE%
goto :eof



:usage
echo %0 [INPUT FILE] [start] [length]

goto :eof
