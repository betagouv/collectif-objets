
API_TOKEN=`cat ~/.scalingo-api-token`
echo "API_TOKEN is $API_TOKEN"
BEARER_TOKEN=`
curl -H "Accept: application/json" -H "Content-Type: application/json" \
 -u ":$API_TOKEN" \
 -X POST https://auth.scalingo.com/v1/tokens/exchange \
 | jq -r .token
`
echo "BEARER_TOKEN is $BEARER_TOKEN"

curl \
  -H "Accept: application/json" -H "Content-Type: application/json" \
  -H "Authorization: Bearer $BEARER_TOKEN" \
  -X POST https://api.osc-fr1.scalingo.com/v1/apps/collectif-objets-staging/child_apps -d \
  '{
    "app": {
      "name": "collectif-objets-review-app-test"
    }
  }'
