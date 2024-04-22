# Holesky

> **_INFO:_**
Please ensure you have reviewed the [current Active Operator Set cap](https://docs.eigenlayer.xyz/operator-guides/avs-installation-and-registration/eigenda-operator-guide#eigenda-churn-approver) and ensure you have sufficient delegated restaked ETH TVL before proceeding.
<!-- ::: -->

#### Step 1: Complete EigenLayer Operator Registration

- Complete the EigenLayer CLI installation and registration [here](https://docs.eigenlayer.xyz/operator-guides/operator-installation).

#### Step 2: Install Docker

- Install [Docker Engine on Linux](https://docs.docker.com/engine/install/ubuntu/).

#### Step 3: Prepare Local EigenDA files

##### Step 3.1: Clone this repo and execute the following commands:

```
git clone https://github.com/Layr-Labs/eigenda-operator-setup.git
cd eigenda-operator-setup/holesky
cp .env.example .env
```


##### Step 3.2: Manually update the `.env` file downloaded in the steps above. Modify all sections marked with `TODO` to match your environment.

##### Step 3.3: Create local folders which are required by EigenDA:

```
mkdir -p $HOME/.eigenlayer/eigenda/holesky/logs
mkdir -p $HOME/.eigenlayer/eigenda/holesky/db
```

##### Step 3.4 Test the values of your environment variables $USER_HOME, $EIGENLAYER_HOME, $EIGENDA_HOME to ensure all the folders exist as expected. Review the resulting values Correct any folders whose paths are not set as expected.

```
source .env
ls $USER_HOME $EIGENLAYER_HOME $EIGENDA_HOME
```


> **_WARNING:_** Do not modify the docker-compose.yml file. If you choose to modify this file, unexpected behaviors can result.


#### Step 4: Operator Networking Security Setup

Retrieval Setup:

In order for users to retrieve data from your node, you will need to open access to retrieval ports.

Ensure the port specified as `NODE_RETRIEVAL_PORT` in the [.env](https://github.com/Layr-Labs/eigenda-operator-setup/blob/a069ad58a33222e12130e9989d743215a9293549/holesky/.env.example#L16) has open access to the public internet.

Dispersal Setup:

In order to limit traffic from the EigenLabs hosted Disperser, please restrict your node's ingress traffic to be allowed by the list provided below and port number set as `NODE_DISPERSAL_PORT` in the [.env](https://github.com/Layr-Labs/eigenda-operator-setup/blob/a069ad58a33222e12130e9989d743215a9293549/holesky/.env.example#L13) in the below setup.

- `54.144.24.178/32`
- `34.232.117.230/32`
- `18.214.113.214/32`

Node API Port Setup:

In order to consolidate Operator metrics to measure the health of the network, please also open NODE_API_PORT in .env to the internet if possible. Please see Node API Spec for more detail on the data made available via this port.


#### Step 5: Quorum Configuration

EigenDA maintains two [quorums](https://docs.eigenlayer.xyz/eigenlayer/operator-guides/operator-introduction#quorums): Restaked ETH (including Native and LST Restaked ETH) and Restaked WETH. EigenDA allows the Operator to opt-in to either quorum or both quorums at once (aka dual-quorum).

- ETH (Native & LST) Quorum:  `0`
- WrappedEth (WETH) Quorum: `1`
- Dual Quorum: `0,1`


#### Step 6: Opt-in into EigenDA

In order to opt-in into EigenDA as an Operator, you must meet the following delegated TVL requirements:

- Have a minimum of 32 ETH delegated.
- Have more than 1.1x current lowest-stake Operator in the active Operator set. Please see [EigenDA Churn Approver](https://docs.eigenlayer.xyz/operator-guides/avs-installation-and-registration/eigenda-operator-guide#eigenda-churn-approver) for more detail.
- The operator to churn out has less than 10.01% of the total stake

Execute the following command based on the quorum you want to opt-in in EigenDA AVS:

```
./run.sh opt-in <quorum>

# for opting in to quorum 0:
./run.sh opt-in 0

# for opting in to quorum 0 and 1:
./run.sh opt-in 0,1 

```
You only need to provide the quorum which you want to opt into. For example if you are already registered to quorum `0` and want to opt-in one more quorum `1`, then you just need to set `<quorum>` as `1` while opting in again.

If you attempt to opt-in to both quorums ('`0,1`') you must have sufficient TVL to opt-in to the active Operator set for both quorums, otherwise the entire opt-in attempt will fail for both quorums. The opt-in attempt for both quorums is an "all or nothing" process.

> **_WARNING:_**
Operator must wait up to 6 hours if the delegation happened after you opt-in to the EigenDA AVS. EigenLayer's AVS-Sync component runs at 6 hour batch intervals to update the delegation totals on chain for each operator. If you are unable to opt in despite having sufficient delegated stake, please wait at least 6 hours, then retry opt-in.


The opt-in command also downloads the latest SRS points if they don't exist on the node. The file is approximately 8GB in size and the opt-in process can some time to complete depending on the network bandwidth.

The script will use the `NODE_HOSTNAME` from [.env](https://github.com/Layr-Labs/eigenda-operator-setup/blob/a069ad58a33222e12130e9989d743215a9293549/holesky/.env.example#L67) as your current IP.

If your operator fails to opt-in to EigenDA or is ejected by the Churn Approver then you may run the opt-in command again after the rate limiting threshold has passed. The current rate limiting threshold is 5 minutes.

If you receive the error “error: failed to request churn approval .. Rate Limit Exceeded” you may retry after the threshold has passed. If you receive the error “insufficient funds”, you may increase your Operator’s delegated TVL to the required minimum and retry after the threshold has passed.


#### Step 7: Run EigenDA

Execute the following command to start the docker containers:

```
docker compose up -d
```

The command will start the node and nginx containers and if you do `docker ps` you should see an output indicating all containers have status of “Up” with ports assigned.

You may view the container logs using:

```
docker logs -f <container_id>
```

If you have successfully opted in to EigenDA and correctly running your EigenDA software, you should see the following logs for your EigenDA container:

## EigenDA Logs

The following example log messages confirm that your EigenDA node software is up and running:

```
2024/03/22 19:33:28 maxprocs: Leaving GOMAXPROCS=16: CPU quota undefined
2024/03/22 19:33:30 Initializing Node
time=2024-03-22T19:33:34.503Z level=DEBUG source=/app/core/eth/tx.go:791 msg=Addresses blsOperatorStateRetrieverAddr=0xB4baAfee917fb4449f5ec64804217bccE9f46C67 eigenDAServiceManagerAddr=0xD4A7E1Bd8015057293f0D0A557088c286942e84b registryCoordinatorAddr=0x53012C69A189cfA2D9d29eb6F19B32e0A2EA3490 blsPubkeyRegistryAddr=0x066cF95c1bf0927124DFB8B02B401bc23A79730D
2024/03/22 19:33:34     Reading G1 points (4194304 bytes) takes 5.981866ms
2024/03/22 19:33:37     Parsing takes 3.144064399s
numthread 8
time=2024-03-22T19:33:38.141Z level=INFO source=/go/pkg/mod/github.com/!layr-!labs/eigensdk-go@v0.1.3-0.20240318050546-8d038f135826/metrics/eigenmetrics.go:81 msg="Starting metrics server at port :9092"
time=2024-03-22T19:33:38.141Z level=INFO source=/app/node/node.go:174 msg="Enabled metrics" socket=:9092
time=2024-03-22T19:33:38.141Z level=INFO source=/go/pkg/mod/github.com/!layr-!labs/eigensdk-go@v0.1.3-0.20240318050546-8d038f135826/nodeapi/nodeapi.go:104 msg="Starting node api server at address :9091"
time=2024-03-22T19:33:38.141Z level=INFO source=/app/node/node.go:178 msg="Enabled node api" port=9091
time=2024-03-22T19:33:38.141Z level=INFO source=/app/node/node.go:211 msg="The node has successfully started. Note: if it's not opted in on https://holesky.eigenlayer.xyz/avs/eigenda, then please follow the EigenDA operator guide section in docs.eigenlayer.xyz to register"
time=2024-03-22T19:33:38.141Z level=INFO source=/go/pkg/mod/github.com/!layr-!labs/eigensdk-go@v0.1.3-0.20240318050546-8d038f135826/nodeapi/nodeapi.go:238 msg="node api server running" addr=:9091
time=2024-03-22T19:33:38.141Z level=INFO source=/app/node/node.go:385 msg="Start checkRegisteredNodeIpOnChain goroutine in background to subscribe the operator socket change events onchain"
time=2024-03-22T19:33:38.142Z level=INFO source=/app/node/node.go:231 msg="Start expireLoop goroutine in background to periodically remove expired batches on the node"
time=2024-03-22T19:33:38.142Z level=INFO source=/app/node/node.go:408 msg="Start checkCurrentNodeIp goroutine in background to detect the current public IP of the operator node"
time=2024-03-22T19:33:38.142Z level=INFO source=/app/node/grpc/server.go:123 msg=port 32004=address [::]:32004="GRPC Listening"
time=2024-03-22T19:33:38.142Z level=INFO source=/app/node/grpc/server.go:99 msg=port 32005=address [::]:32005="GRPC Listening"
Batch verify 1 frames of 256 symbols out of 1 blobs
time=2024-03-22T19:34:39.858Z level=DEBUG source=/app/node/node.go:330 msg="Validate batch took" duration:=96.155565ms
time=2024-03-22T19:34:39.858Z level=DEBUG source=/app/node/node.go:340 msg="Store batch took" duration:=0s
time=2024-03-22T19:34:39.859Z level=DEBUG source=/app/node/node.go:346 msg="Signed batch header hash" pubkey=0x00cea342f086977a33b3f1bba57d09c6cdf8eaf20b9dec856dc874ab65414b6e2377a91ab3bc2360224f3ba071eb4753da650e957d9c0535b14922609a9ff052150595f3a89c06e87a78d3e3ebad09771f181b632bd971c1d58deb3e1fde9397087c1cc1097c48b1e900d418ef43538a8abdccde72921c3148ae4de5e0f39ef3
time=2024-03-22T19:34:39.859Z level=DEBUG source=/app/node/node.go:349 msg="Sign batch took" duration=1.32679ms
time=2024-03-22T19:34:39.860Z level=INFO source=/app/node/node.go:351 msg="StoreChunks succeeded"
time=2024-03-22T19:34:39.860Z level=DEBUG source=/app/node/node.go:353 msg="Exiting process batch" duration=97.815499ms
Batch verify 1 frames of 256 symbols out of 1 blobs
time=2024-03-22T19:35:30.062Z level=DEBUG source=/app/node/node.go:330 msg="Validate batch took" duration:=83.890892ms
time=2024-03-22T19:35:30.062Z level=DEBUG source=/app/node/node.go:340 msg="Store batch took" duration:=0s
time=2024-03-22T19:35:30.063Z level=DEBUG source=/app/node/node.go:346 msg="Signed batch header hash" pubkey=0x00cea342f086977a33b3f1bba57d09c6cdf8eaf20b9dec856dc874ab65414b6e2377a91ab3bc2360224f3ba071eb4753da650e957d9c0535b14922609a9ff052150595f3a89c06e87a78d3e3ebad09771f181b632bd971c1d58deb3e1fde9397087c1cc1097c48b1e900d418ef43538a8abdccde72921c3148ae4de5e0f39ef3
time=2024-03-22T19:35:30.063Z level=DEBUG source=/app/node/node.go:349 msg="Sign batch took" duration=1.201012ms
time=2024-03-22T19:35:30.063Z level=INFO source=/app/node/node.go:351 msg="StoreChunks succeeded"
time=2024-03-22T19:35:30.063Z level=DEBUG source=/app/node/node.go:353 msg="Exiting process batch" 
```

#### Step 8 (optional): To bring the containers down, run the following command

```
docker compose down
```

### Opt-Out of EigenDA

> **_WARNING:_**
Please be careful to ensure that you opt-out of your current (or intended) quorum.

The following command can be used to opt out from the EigenDA AVS:

```
./run.sh opt-out <quorum>

# for opting out to quorum 0:
./run.sh opt-out 0

# for opting out to quorum 0 and 1:
./run.sh opt-out 0,1 
```

## Upgrade your node

Please monitor the following channels for updates to EigenDA Operator software:
- [EigenLayer Discord](https://discord.gg/eigenlayer): #support-operators channel.
- [EigenDA Operator Setup](https://github.com/Layr-Labs/eigenda-operator-setup) repository: [configure your watch settings](https://docs.github.com/en/account-and-profile/managing-subscriptions-and-notifications-on-github/setting-up-notifications/configuring-notifications#configuring-your-watch-settings-for-an-individual-repository) for notifications of new releases.

Upgrade the AVS software for your EigenDA service setup by following the steps below:

#### Step 1: Pull the latest repo

```
cd eigenda-operator-setup/holesky
git pull
```

Update the `MAIN_SERVICE_IMAGE` in your `.env` file with the latest EigenDA version as per the release notes.

> **_NOTE:_** If there are any specific instructions that needs to be followed for any upgrade, those instructions will be given with the release notes of the specific release. Please check the latest [release notes](https://github.com/Layr-Labs/eigenda-operator-setup/releases) on GitHub and follow the instructions before starting the services again.

#### Step 2: Pull the latest docker images

```
docker compose pull
```

#### Step 3: Stop the existing services

```
docker compose down
```

#### Step 4: Start your services again

Make sure your `.env` file still has correct values in the [TODO](https://github.com/Layr-Labs/eigenda-operator-setup/blob/a069ad58a33222e12130e9989d743215a9293549/holesky/.env.example#L64) sections before you restart your node.

```
docker compose up -d
```

## Running your node without giving access to operator ECDSA keys
In [EigenDA v0.6.1](https://github.com/Layr-Labs/eigenda-operator-setup/releases/tag/v0.6.1), we added a feature where you can configure your node so that it doesn't need operator's ECDSA keys to run.
Your node still need access to BLS keys for attestation purposes.
>**_NOTE:_** You still need ECDSA and BLS keys to opt-in to EigenDA.

To enable this feature by using our setup, follow the below commands:
* Remove the `"${NODE_ECDSA_KEY_FILE_HOST}:/app/operator_keys/ecdsa_key.json:readonly"` mount from `docker-compose.yml` file.
* Update the `NODE_ECDSA_KEY_FILE` in your `.env` file to be empty.
* Update the `NODE_ECDSA_KEY_PASSWORD` in your `.env` file to be empty.
* Update the `NODE_PUBLIC_IP_CHECK_INTERVAL` in your `.env` file to be `0` (This flag was used to check and update your IP onchain if your IP changes, so if your IP changes it's your responsibility to update).
* Run your node normally using the `docker compose up -d` command.
* Opt-in to EigenDA if not already opted in.