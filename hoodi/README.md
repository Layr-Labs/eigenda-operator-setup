# Hoodi

Head over to our [EigenDA operator guides](https://docs.eigencloud.xyz/products/eigenda/operator-guides/overview) for installation instructions and more details.

## V2 Environment Variable Reference

### `NODE_V2_DISPERSAL_PORT`
<ins>Operators must publically expose this port</ins>. This port will be used to listen for dispersal requests from the EigenDA v2 API. IP whitelisting is no longer required with v2.

### `NODE_V2_RETRIEVAL_PORT`
<ins>Operators must publically expose this port</ins>. This port will be used to listen for retrieval requests from the EigenDA v2 API.

### `NODE_INTERNAL_V2_DISPERSAL_PORT`
This port is intended for Nginx reverse proxy use.

### `NODE_INTERNAL_V2_RETRIEVAL_PORT`
This port is intended for Nginx reverse proxy use.

## V1 Deprecation
As of `v2.7.0` V1 support has been removed from the node client

### New optional flags
```
--node.delete-v1-data                                 When enabled, deletes any existing v1 data on node startup [$NODE_DELETE_V1_DATA]
```

### Removed flags
```
--node.dispersal-port value                           Port at which node registers to listen for dispersal calls [$NODE_DISPERSAL_PORT]
--node.retrieval-port value                           Port at which node registers to listen for retrieval calls [$NODE_RETRIEVAL_PORT]
--node.internal-dispersal-port value                  Port at which node listens for dispersal calls (used when node is behind NGINX) [$NODE_INTERNAL_DISPERSAL_PORT]
--node.internal-retrieval-port value                  Port at which node listens for retrieval calls (used when node is behind NGINX) [$NODE_INTERNAL_RETRIEVAL_PORT]
--node.runtime-mode value                             Node runtime mode (v1-and-v2 (default), v1-only, or v2-only) (default: "v1-and-v2") [$NODE_RUNTIME_MODE]
--node.disable-dispersal-authentication               Disable authentication for StoreChunks() calls from the disperser [$NODE_DISABLE_DISPERSAL_AUTHENTICATION]
--node.leveldb-disable-seeks-compaction-v1            Disable seeks compaction for LevelDB for v1 [$NODE_LEVELDB_DISABLE_SEEKS_COMPACTION_V1]
--node.leveldb-enable-sync-writes-v1                  Enable sync writes for LevelDB for v1 [$NODE_LEVELDB_ENABLE_SYNC_WRITES_V1]
--node.enable-payment-validation                      Whether the validator should perform payment validation. Temporary flag that will be removed once the new payments system is fully in place. default: true. [$NODE_ENABLE_PAYMENT_VALIDATION]
--node.on-demand-meter-refresh-interval value         Interval for refreshing on-demand global rate limit parameters from the payment vault. (default: 5m0s) [$NODE_ON_DEMAND_METER_REFRESH_INTERVAL]
--node.on-demand-meter-fuzz-factor value              Multiplier applied to on-chain on-demand throughput before enforcement; >1.0 allows a small buffer. (default: 1.1) [$NODE_ON_DEMAND_METER_FUZZ_FACTOR]
--chain.retry-delay-increment value                   Time unit for linear retry delay. For instance, if the retries count is 2 and retry delay is 1 second, then 0 second is waited for the first call; 1 seconds are waited before the next retry; 2 seconds are waited for the second retry; if the call failed, the total waited time for retry is 3 seconds. If the retry delay is 0 second, the total waited time for retry is 0 second. (default: 0s) [$NODE_RETRY_DELAY_INCREMENT]
```

## Advanced - Multi drive support for V2 LittDB

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
