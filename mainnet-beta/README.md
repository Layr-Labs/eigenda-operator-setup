## Mainnet Beta

## Create new mainnet-beta BLS key
To prevent relay attacks, you must create a new BLS key for mainnet-beta.
```bash
$ eigenlayer keys create --key-type bls mainnet-beta
? Enter password to encrypt the bls private key: ********************************
? Please confirm your password: ********************************
```
## Import your mainnet ECDSA key
Your ECDSA key from mainnet needs to be imported so that your delegated stake is shared between mainnet and mainnet-beta.
```bash
$ eigenlayer keys import --key-type ecdsa mainnet <private-key>
? Enter password to encrypt the ecdsa private key: ********************************
? Please confirm your password: ********************************
```

## Confirm key locations
```bash
$ eigenlayer keys list | grep location
Key location: /home/ubuntu/.eigenlayer/operator_keys/mainnet-beta.bls.key.json
Key location: /home/ubuntu/.eigenlayer/operator_keys/mainnet.ecdsa.key.json
```

## Create a new env
```bash
cp .env.example .env
```
Go thru the `.env` and update any TODOs listed in comments

In your `.env` ensure that the key vars map to the correct key names/locations created earlier
```
# NOTE: Your mainnet-beta ECDSA key should match your mainnet ECDSA key
NODE_ECDSA_KEY_FILE_HOST=${EIGENLAYER_HOME}/operator_keys/mainnet.ecdsa.key.json
# NOTE: Make sure to reference the mainnet-beta specific BLS key
NODE_BLS_KEY_FILE_HOST=${EIGENLAYER_HOME}/operator_keys/mainnet-beta.bls.key.json
```

## Node Runtime Mode
The mainnet-beta environment only supports V2 Blazar

Ensure your `NODE_RUNTIME_MODE=v2-only` in your `.env`

## Socket registration
You will still need to declare V1 ports (they will not be used) because socket registration still requires them.

```bash
$ ./run.sh update-socket
```
## Optional - Multi drive support for V2 LittDB

LittDB is capable of partitioning the chunks DB across multiple drives. See https://github.com/Layr-Labs/eigenda/blob/master/node/database-paths.md for more details.

### Example .env that defines 2 littDB partitions
```
NODE_LITT_DB_STORAGE_HOST_PATH_1=${NODE_DB_PATH_HOST}/chunk_v2_litt_1
NODE_LITT_DB_STORAGE_HOST_PATH_2=${NODE_DB_PATH_HOST}/chunk_v2_litt_2
NODE_LITT_DB_STORAGE_PATHS=/data/operator/db/chunk_v2_litt_1,/data/operator/db/chunk_v2_litt_2
```
The `NODE_LITT_DB_STORAGE_HOST_PATH_X` should map to a separately mounted drive folder for each partition.
The `NODE_LITT_DB_STORAGE_PATHS` needs to map to the docker volume mounts defined in `docker-compose.yaml`
#### Example docker-compose volume mounts
```
   volumes:
      - "${NODE_ECDSA_KEY_FILE_HOST}:/app/operator_keys/ecdsa_key.json:readonly"
      - "${NODE_BLS_KEY_FILE_HOST}:/app/operator_keys/bls_key.json:readonly"
      - "${NODE_G1_PATH_HOST}:/app/g1.point:readonly"
      - "${NODE_G2_PATH_HOST}:/app/g2.point.powerOf2:readonly"
      - "${NODE_CACHE_PATH_HOST}:/app/cache:rw"
      - "${NODE_LOG_PATH_HOST}:/app/logs:rw"
      - "${NODE_DB_PATH_HOST}:/data/operator/db:rw"
      - "${NODE_LITT_DB_STORAGE_HOST_PATH_1}:/data/operator/db/chunk_v2_litt_1:rw"
      - "${NODE_LITT_DB_STORAGE_HOST_PATH_2}:/data/operator/db/chunk_v2_litt_2:rw"
```
#### Example node output after loading both partitions
```
eigenda-native-node  | Jun  2 18:11:47.430 INF node/validator_store.go:108 Using littDB at paths /data/operator/db/chunk_v2_litt_1, /data/operator/db/chunk_v2_litt_2
eigenda-native-node  | Jun  2 18:11:47.430 INF littbuilder/db_impl.go:118 LittDB started, current data size: 0
eigenda-native-node  | Jun  2 18:11:47.430 INF littbuilder/db_impl.go:169 creating table chunks
```