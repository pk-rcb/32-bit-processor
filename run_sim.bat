@echo off
setlocal enabledelayedexpansion

echo ===============================================================================
echo        32-bit MIPS 5-Stage Pipelined Processor Build and Simulation
echo ===============================================================================
echo.

echo [1/3] Compiling Verilog files with Icarus Verilog...
iverilog -g2012 -o sim.vvp tb/MIPS_Processor_tb.v
if %ERRORLEVEL% neq 0 (
    echo.
    echo [ERROR] Compilation failed. Please check compiler errors above.
    pause
    exit /b %ERRORLEVEL%
)
echo [1/3] Compilation SUCCESSFUL.
echo.

echo [2/3] Running simulation with vvp...
vvp sim.vvp
if %ERRORLEVEL% neq 0 (
    echo.
    echo [ERROR] Simulation runtime error.
    pause
    exit /b %ERRORLEVEL%
)
echo [2/3] Simulation FINISHED.
echo.

echo [3/3] Waveform dump created at: mips_processor.vcd
echo.
set /p OPEN_GTK="Would you like to open waveforms in GTKWave now? (y/n): "
if /i "%OPEN_GTK%"=="y" (
    echo Launching GTKWave...
    start gtkwave mips_processor.vcd tb/gtkwave_signals.gtkw
)

echo.
echo ===============================================================================
echo Simulation process complete.
echo ===============================================================================
pause
