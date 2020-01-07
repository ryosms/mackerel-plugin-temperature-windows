@echo off
cd %~dp0

powershell -ExecutionPolicy RemoteSigned -File mackerel-plugin-temperature.ps1
