import sys
sys.path.append("C:\\Program Files\\Python312\\Lib\\site-packages")
from time import sleep
from azure.identity import CertificateCredential
from azure.storage.blob import BlobServiceClient, BlobType
import datetime
import Parameters

# Auth and config
tenant_id = Parameters.tenant_id
client_id = Parameters.client_id
pem_cert_path = Parameters.pem_cert_path
account_url = "https://zachivaroinishasa1.blob.core.windows.net"
container_name = "logs"
local_file_path = Parameters.logs_path

#Auth
credential = CertificateCredential(
    tenant_id=tenant_id,
    client_id=client_id,
    certificate_path=pem_cert_path
)

#Clients
blob_service_client = BlobServiceClient(account_url, credential)
container_client = blob_service_client.get_container_client(container_name)

#Interval (in seconds)
interval = 3600

while (True):
    time = datetime.datetime.now()
    blob_name = "app1_logs.txt" + str(time)
    blob_client = container_client.get_blob_client(blob_name)
    # Read local file and append content
    with open(local_file_path, "rb") as f:
        content = f.read()
        blob_client.upload_blob(content, overwrite=True)
    f.close()
    print("File content uploaded successfully.")
    with open(local_file_path, "w") as f:
        f.write("")
    f.close()
    print("Local file content cleared successfully.")

    sleep(interval)
