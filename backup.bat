@echo off
echo Starting Roblox Studio backup...

REM Step 1: Pull latest from GitHub
cd /d "C:\Users\yanbo\OneDrive\Desktop\virus-rng-simulator"
git pull origin main

REM Step 2: Open Claude in browser with backup prompt
REM (You then just confirm and let Claude do the MCP reads + file writes)
start "" "https://claude.ai/new?q=Do+a+full+backup:+Read+every+script+from+Roblox+Studio+via+MCP+that+matches+HANDOFF.md,+write+each+to+its+correct+path+in+C:\Users\yanbo\OneDrive\Desktop\virus-rng-simulator\src\,+then+run+git+add+-A+%26%26+git+commit+-m+'backup:+auto+snapshot'+%26%26+git+push"

echo Browser opened. Complete the backup in Claude, then press any key to exit.
pause
