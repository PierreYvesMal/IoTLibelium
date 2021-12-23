# IoTLibelium
Educational project for IoT at HES-SO mse

**********************
INSTALLATION (example below)
**********************
//Waspmote app
//The file is already in the Libelium, if the dedicated material was provided, skip this step.  
Download specific IDE (do not try another ide)  
Upload ALL_SENSORS.pde  

//Broker
virtualenv env  
source env/bin/activate  
export GOOGLE_APPLICATION_CREDENTIALS=absolute_path_to/iotmalengre-153b229d624c.json  
pip3 install -r requirements.txt 


**********************
DEPLOY (example below)  
**********************
source env/bin/activate  

//Broker
export GOOGLE_APPLICATION_CREDENTIALS=absolute_path_to/iotmalengre-153b229d624c.json    
python3 iot.py



************************************
EXAMPLE TESTED ON FRESH UBUNTU INSTALL:  
************************************
cd~  
sudo apt-get install git  
git clone https://github.com/PierreYvesMal/IoTLibelium  

cd IoTLibelium

//sub  
cd \~/IoTLibelium  
sudo apt-get install virtualenv  
virtualenv env  
source env/bin/activate  
export GOOGLE_APPLICATION_CREDENTIALS=\~/IoTLibelium/iotmalengre-153b229d624c.json  
pip3 install -r requirements.txt  
python3 iot.py


**********************
ABOUT
**********************
For Grafana, specific key is mandatory

