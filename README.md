# Varonis_HA

# End user instructions:

The "RestaurantsRecommendation" API here is filtering Restaurants by some sub set of parameters 
sent to the API by the user, using HTTP GET method.
The API will return a restaurant that match the search parameters.
The searchable parameters are (you can use any subset of it): 

style (string) - "American" / "Italian" / "Thai" 
vegetarian (bool) - "true" / "false"
is_open_now (bool) - "true" / "false"

API calls examples (just open a browser and paste it there):

Request url:

http://172.190.63.47/RestaurantsRecommendation?style=Thai&vegetarian=true&is_open_now=true

Response:

{
  "address": "King George 91, Haifa",
  "clouseHour": "21:00",
  "name": "SpicyElephant",
  "openHour": "11:30",
  "style": "Thai",
  "vegetarian": true
}

Request url:

http://172.190.63.47/RestaurantsRecommendation?style=Thai&vegetarian=true

Response:

{
  "address": "King George 91, Haifa",
  "clouseHour": "21:00",
  "name": "SpicyElephant",
  "openHour": "11:30",
  "style": "Thai",
  "vegetarian": true
}

# Technical details:

Cloud platform: Azure
IAC solution: terraform
Code language: Python (Version 3.12)

## System overview:
The system in composed with 2 python applications that wrapped by windows service for each:

app1 (service name: FlaskApp1_Service) - 
This python application is responsible for the vast majority of the system. It is using Flask library to create a web application and expose the
"/RestaurantsRecommendation" API, which in turn call for the a BE function to fetch restaurants data from Cosmos DB and apply the search parameters on it and eventually return a restaurant as response. 
It is also responsible to track any API call and save it locally to app1_logs file, which contain the time, source IP and each search parameter.

app2 (service name: FlaskApp2_Service) - 
This python application is responsible to periodically upload the "app1_logs" file to Azure storage account and clean the local log file after it. 

### System Architecture Visio:
You can also find the "SystemArchitecture.jpg" which visually describes the system.  
