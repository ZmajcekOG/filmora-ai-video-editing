@echo off
REM Needs COMFY_BASE_URL in freefield\.env (Modal backend or local GPU backend - see README)
cd /d "%USERPROFILE%\ai-tools\freefield"
start http://127.0.0.1:3000
npm run serve
