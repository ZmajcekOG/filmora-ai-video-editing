@echo off
REM Requires Docker Desktop to be running. First start builds images (10+ min).
cd /d "%USERPROFILE%\ai-tools\supoclip"
docker compose up -d --build
echo.
echo SupoClip: http://localhost:3107   (API docs: http://localhost:8000/docs)
echo Stop with:  docker compose down   (in %USERPROFILE%\ai-tools\supoclip)
start http://localhost:3107
pause
