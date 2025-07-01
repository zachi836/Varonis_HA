@echo off
REM Run this as administrator
python Creating_app2.py install
python Creating_app2.py start
sc config FlaskApp2_Service start= auto
pause
