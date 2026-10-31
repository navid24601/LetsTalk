@echo off
echo Starting Let's Talk at http://localhost:8000/
echo Keep this window open while using the app. Press Ctrl+C to stop.
py -m http.server 8000 --directory "%~dp0."
echo.
echo The server stopped. If port 8000 is already in use, stop the other server and try again.
pause
