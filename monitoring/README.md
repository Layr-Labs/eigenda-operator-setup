## Setup monitoring using docker
If you want to set up monitoring using docker, you can use the following commands:

In the folder

* Copy the [.env.example](./.env.example) file to `.env` file:
```bash
cp .env.example .env
```
* Make sure your prometheus config [file](./prometheus.yml) is updated with the metrics port (`NODE_METRICS_PORT`) of the eigenda node.
* Make sure the eigenda container name is also set correctly in the prometheus config file. 
You can find that in eigenda [.env](../.env.example) file (`MAIN_SERVICE_NAME`)
* Make sure the location of prometheus file is correct in [.env](./.env.example) file

Once correct config is set up, run the following command to start the monitoring stack
```bash
docker compose up -d
```

Since eigenda is running in a different docker network, the setup need to have prometheus running in the same network. To do that, run the following command:
```bash
docker network connect eigenda-network prometheus
```
Note: `eigenda-network` is the name of the network in which eigenda is running. You can check the network name in eigenda [.env](../.env.example) file (`NETWORK_NAME`).

This will make sure `prometheus` can scrape the metrics from `eigenda` node.


#### Useful Dashboards
EigenDA offers a set of Grafana dashboards that are automatically imported when initializing the monitoring stack.