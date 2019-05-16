#/usr/bin/env sh
# Example Usage: ./setup.sh https://tio-models-test.dev.docai.beer/rest

API_URL=${1:-localhost:8081}

TIMESTAMP=$(date -u +%s)
MODEL="TestModel-$TIMESTAMP"

echo "Setting up API instance at: $API_URL"

echo "Creating model: $MODEL..."
curl -X POST \
    -H "Content-Type: application/json" \
    -d "{\"model\": {\"modelId\": \"$MODEL\", \"description\": \"This model is a test\"}}" \
    $API_URL/v1/repository/models

echo

echo "Creating hyperparameters-1..."
curl -X POST \
    -H "Content-Type: application/json" \
    -d '{"hyperparametersId": "hyperparameters-1", "hyperparameters": {"lol": "rofl"}}' \
    $API_URL/v1/repository/models/$MODEL/hyperparameters

echo

echo "Creating checkpoint-1 for hyperparameters-1..."
curl -X POST \
    -H "Content-Type: application/json" \
    -d '{"checkpointId": "checkpoint-1", "createdAt": "1557790163", "info": {"accuracy": "0.934"}, "link": "https://example.com/h1c1.tiobundle.zip"}' \
    $API_URL/v1/repository/models/$MODEL/hyperparameters/hyperparameters-1/checkpoints

echo

echo "Setting checkpoint-1 as canonicalCheckpoint for hyperparameters-1 and hyperparameters-2 as its upgrade..."
curl -X PUT \
    -H "Content-Type: application/json" \
    -d '{"canonicalCheckpoint": "checkpoint-1", "upgradeTo": "hyperparameters-2"}' \
    $API_URL/v1/repository/models/$MODEL/hyperparameters/hyperparameters-1

echo

echo "Creating hyperparameters-2"
curl -X POST \
    -H "Content-Type: application/json" \
    -d '{"hyperparametersId": "hyperparameters-2", "hyperparameters": {"lol": "wtf"}}' \
    $API_URL/v1/repository/models/$MODEL/hyperparameters

echo

echo "Creating checkpoint-1 for hyperparameters-2..."
curl -X POST \
    -H "Content-Type: application/json" \
    -d '{"checkpointId": "checkpoint-1", "createdAt": "1557790252", "info": {"accuracy": "0.921"}, "link": "https://example.com/h2c1.tiobundle.zip"}' \
    $API_URL/v1/repository/models/$MODEL/hyperparameters/hyperparameters-2/checkpoints

echo

echo "Creating checkpoint-2 for hyperparameters-2..."
curl -X POST \
    -H "Content-Type: application/json" \
    -d '{"checkpointId": "checkpoint-2", "createdAt": "1557790268", "info": {"accuracy": "0.959"}, "link": "https://example.com/h2c2.tiobundle.zip"}' \
    $API_URL/v1/repository/models/$MODEL/hyperparameters/hyperparameters-2/checkpoints

echo

echo "Setting checkpoint-2 as canonicalCheckpoint for hyperparameters-2..."
curl -X PUT \
    -H "Content-Type: application/json" \
    -d '{"canonicalCheckpoint": "checkpoint-2"}' \
    $API_URL/v1/repository/models/$MODEL/hyperparameters/hyperparameters-2