@echo off
title Fussball-Live-Center (lokaler Server)
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0lokaler_server.ps1"
