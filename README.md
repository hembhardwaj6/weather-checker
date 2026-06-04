## Description
The fetch_temperature function first checks the cache. If valid data is found, it serves it immediately.
If the cache is expired or empty, the function fetches fresh data from the wttr.in API and updates the cache.
Flask Routes:

#### / (GET): Displays the form to enter a city name.
#### / (POST): Handles form submission, fetches the temperature, and returns it to the browser.
## Browser UI:
Users enter the city name in a simple form.
The temperature is displayed along with a note indicating whether it was cached.


## Prerequisites
* python 3.12
* pip
* requests
* diskcache
* flask
* gunicorn

* install all with pip
```
pip install requests diskcache flask gunicorn
```

### Run the Application
Save the Python script and the HTML file in the same directory.
Run the Flask app:
python main.py
By default it runs on 5000 port
Open your browser and go to:
```
http://localhost:5000
```

### Run in docker
#### This is pushed to dockerhub.
```
docker run --rm -p 5000:5000 --name weather-checker hembhardwaj6/weather-checker:0.0.1
```
### Build on your own
```
docker build -t weather-checker:0.0.1 .
```
#### Run Docker container
```
docker run --rm -p 5000:5000 --name weather-checker weather-checker:0.0.1
```
### Deploy in kubernetes
User kustomize tool to deploy it in kubernetes dev environment
```
kubectl apply -k kube/overlays/dev/
```
### Deploy in EKS on aws with Loadbalancer Service
```
kubectl apply -k kube/overlays/aws/
```

### Create infrastructure with terraform
```
terraform apply -var-file terraform.tfvars
```