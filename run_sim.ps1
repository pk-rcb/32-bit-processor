<#
.SYNOPSIS
    Automated build, test, and waveform visualization script for 32-bit MIPS Processor.
.DESCRIPTION
    Compiles Verilog source with Icarus Verilog, runs the simulation using vvp,
    checks assertions, and optionally launches GTKWave.
.PARAMETER Waveform
    Switch to automatically launch GTKWave with the preconfigured signal layout.
#>
param(
    [switch]$Waveform
)

Write-Host "===============================================================================" -ForegroundColor Cyan
Write-Host "       32-bit MIPS 5-Stage Pipelined Processor Build and Simulation" -ForegroundColor Cyan
Write-Host "===============================================================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Compilation
Write-Host "[1/3] Compiling Verilog modules with Icarus Verilog..." -ForegroundColor Yellow
iverilog -g2012 -o sim.vvp tb/MIPS_Processor_tb.v
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Compilation failed!" -ForegroundColor Red
    exit $LASTEXITCODE
}
Write-Host "[1/3] Compilation SUCCESSFUL.`n" -ForegroundColor Green

# Step 2: Run simulation
Write-Host "[2/3] Executing simulation with vvp..." -ForegroundColor Yellow
vvp sim.vvp
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Simulation failed during execution!" -ForegroundColor Red
    exit $LASTEXITCODE
}
Write-Host "[2/3] Simulation FINISHED.`n" -ForegroundColor Green

# Step 3: Waveform
Write-Host "[3/3] Waveform dump: mips_processor.vcd" -ForegroundColor Cyan
if ($Waveform) {
    Write-Host "Launching GTKWave with signals layout..." -ForegroundColor Yellow
    Start-Process gtkwave -ArgumentList "mips_processor.vcd", "tb/gtkwave_signals.gtkw"
} else {
    Write-Host "Tip: Run with -Waveform to automatically open in GTKWave:`n  .\run_sim.ps1 -Waveform" -ForegroundColor Gray
}

Write-Host "`n===============================================================================" -ForegroundColor Cyan
