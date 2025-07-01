import win32serviceutil
import win32service
import win32event
import servicemanager
import subprocess
import os
import sys
import Parameters

class FlaskService(win32serviceutil.ServiceFramework):
    _svc_name_ = "FlaskApp2_Service"
    _svc_display_name_ = "Flask App2 Service"
    _svc_description_ = "Runs Flask app2 as a Windows service"

    def __init__(self, args):
        win32serviceutil.ServiceFramework.__init__(self, args)
        self.stop_event = win32event.CreateEvent(None, 0, 0, None)

    def SvcStop(self):
        self.ReportServiceStatus(win32service.SERVICE_STOP_PENDING)
        win32event.SetEvent(self.stop_event)
        servicemanager.LogInfoMsg("Stopping Flask App2 Service")

    def SvcDoRun(self):
        servicemanager.LogInfoMsg("Starting Flask App2 Service")

        script_path = os.path.join(os.path.dirname(__file__), "app2.py")
        log_path = os.path.join(os.path.dirname(__file__), "flask_log_app2.txt")
        python_path = Parameters.python_path

        with open(log_path, "a") as log_file:
            log_file.write(f"Trying to run {script_path} with {python_path}\n")
            try:
                subprocess.Popen([python_path, script_path], stdout=log_file, stderr=log_file)
                log_file.write("Flask process started\n")
            except Exception as e:
                log_file.write(f"ERROR: {str(e)}\n")

        win32event.WaitForSingleObject(self.stop_event, win32event.INFINITE)

if __name__ == '__main__':
    win32serviceutil.HandleCommandLine(FlaskService)
