api_key=`rails runner "puts Rails.application.credentials.sendinblue.api_key"`
echo "got api_key ${api_key:0:20}..."

# curl --request POST \
#      --url 'https://api.sendinblue.com/v3/webhooks' \
#      --header 'accept: application/json' \
#      --header 'content-type: application/json' \
#      --header 'api-key: xkeysib-xxxx' \
#      --data '
# {
#   "type": "inbound",
#   "events": ["inboundEmailProcessed"],
#   "url": "https://collectifobjets-mail-inbound.loophole.site",
#   "domain": "reponse-loophole.collectifobjets.org",
#   "description": "Debug inbound email webhook tunneled to localhost"
# }
# '

curl --url 'https://api.sendinblue.com/v3/webhooks/702843' --header 'accept: application/json' --header 'content-type: application/json' --header "api-key: $api_key"
