import sys
sys.path.append("C:\\Program Files\\Python312\\Lib\\site-packages")
from flask import Flask, request
import random
from azure.cosmos import CosmosClient
import datetime
import pytz
from azure.identity import CertificateCredential
from azure.keyvault.secrets import SecretClient
import Parameters

##################################### Key Vault #####################################
tenant_id = Parameters.tenant_id
client_id = Parameters.client_id
pem_cert_path = Parameters.pem_cert_path
key_vault_url = "https://zachivaronishakv1.vault.azure.net/"
secret_name = "db1primarykey"

# Get secret from Azure Key Vault
credential = CertificateCredential(tenant_id, client_id, pem_cert_path)
secret_client = SecretClient(vault_url=key_vault_url, credential=credential)
primary_key = secret_client.get_secret(secret_name).value

##################################### DB #####################################
def query_db(style=None, vegetarian=None, is_open_now=None):
    endpoint = "https://zachivaronisha2.documents.azure.com:443/"
    db_name = "Restaurants"
    container_name = "Restaurants"

    client = CosmosClient(endpoint, credential=primary_key)
    database = client.get_database_client(db_name)
    container = database.get_container_client(container_name)

    tz = pytz.timezone("Asia/Jerusalem")
    israel_now = datetime.datetime.now(tz).strftime("%H:%M")

    query = "SELECT * FROM c"
    query_result = list(container.query_items(query=query, enable_cross_partition_query=True))

    parameters = {}

    if style is not None and style.strip() != "":
        parameters["style"] = style.strip()

    if vegetarian is not None and vegetarian != "":
        vegetarian_str = str(vegetarian).strip().lower()
        if vegetarian_str in ["true", "1"]:
            parameters["vegetarian"] = True
        elif vegetarian_str in ["false", "0"]:
            parameters["vegetarian"] = False

    open_now_flag = False
    if is_open_now is not None and is_open_now != "":
        open_now_str = str(is_open_now).strip().lower()
        if open_now_str in ["true", "1"]:
            open_now_flag = True

    # If no filters given, return one random recommendation
    if not parameters and not open_now_flag:
        return random.choice([item['restaurantRecommendation'] for item in query_result])

    final_results = []

    for item in query_result:
        rec = item.get("restaurantRecommendation", {})
        match = True

        # Apply filters
        for param_name, param_value in parameters.items():
            if rec.get(param_name) != param_value:
                match = False
                break

        # Check opening hours if requested
        if open_now_flag and match:
            open_time = rec.get("openHour")
            close_time = rec.get("clouseHour")
            if not (open_time <= israel_now <= close_time):
                match = False

        if match:
            final_results.append(rec)

    return random.choice(final_results) if final_results else "No restaurant found"

##################################### Web #####################################
application_logs_path = Parameters.logs_path
app = Flask(__name__)

@app.before_request
def log_request_info():
    method = request.method
    ip = request.remote_addr
    path = request.path
    timestamp = datetime.datetime.now().isoformat()
    style = request.args.get("style", "")
    vegetarian = request.args.get("vegetarian", "")
    is_open_now = request.args.get("is_open_now", "")
    with open(application_logs_path, "a+") as f:
        f.write(f"[{timestamp}] INFO: {ip} {method} {path} style={style}, vegetarian={vegetarian}, is_open_now={is_open_now} \n")

@app.route('/RestaurantsRecommendation')
def restaurants_recommendation():
    style = request.args.get("style")
    vegetarian = request.args.get("vegetarian")
    is_open_now = request.args.get("is_open_now")

    with open(application_logs_path, "a+") as f:
        timestamp = datetime.datetime.now().isoformat()
        f.write(f"[{timestamp}] INFO: application successfully called\n")

    return query_db(style, vegetarian, is_open_now)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)