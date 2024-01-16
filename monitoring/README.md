## Setup monitoring using docker
If you want to set up monitoring using docker, you can use the following commands:

In the folder

* Copy the [.env.example](./.env.example) file to `.env` file:
```bash
cp .env.example .env
```
* Make sure your prometheus config [file](./prometheus.yml) is updated with the metrics port (`NODE_METRICS_PORT`) of the eigenda node.
* Make sure the eigenda container name is also set correctly in the prometheus config file. 
You can find that in eigenda [.env](../.env) file (`MAIN_SERVICE_NAME`)
* Make sure the location of prometheus file is correct in [.env](./.env) file

Once correct config is set up, run the following command to start the monitoring stack
```bash
docker compose up -d
```

Since eigenda is running in a different docker network we will need to have prometheus in the same network. To do that, run the following command:
```bash
docker network connect eigenda-network prometheus
```
Note: `eigenda-network` is the name of the network in which eigenda is running. You can check the network name in eigenda [.env](../.env) file (`NETWORK_NAME`).

This will make sure `prometheus` can scrape the metrics from `eigenda` node.


#### Useful Dashboards
We also provide a set of useful Grafana dashboards which would be useful for monitoring the EigenDA node. You can find them [here](dashboards).
Once you have Grafana setup, feel free to import the dashboards.