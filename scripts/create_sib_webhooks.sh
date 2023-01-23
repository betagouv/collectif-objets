api_key=`rails runner "puts Rails.application.credentials.sendinblue.api_key"`
echo "got api_key ${api_key:0:20}..."

curl --url 'https://api.sendinblue.com/v3/webhooks?type=inbound' \
  --header 'accept: application/json' \
 --header "api-key: $api_key" | jq -s

# curl --request POST \
#     --url 'https://api.sendinblue.com/v3/webhooks' \
#     --header 'accept: application/json' \
#     --header 'content-type: application/json' \
#     --header "api-key: $api_key" \
#     --data '
# {
#  "type": "inbound",
#  "events": ["inboundEmailProcessed"],
#  "url": "https://collectifobjets.beta.gouv.fr/api/v3/inbound_emails",
#  "domain": "reponse.collectifobjets.org",
#  "description": "[PROD] inbound emails webhook"
# }
# ' | jq -s
