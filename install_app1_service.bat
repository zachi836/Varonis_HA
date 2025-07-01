@echo off
REM Run this as administrator
python Creating_app1.py install
python Creating_app1.py start
sc config FlaskApp1_Service start= auto
pause
