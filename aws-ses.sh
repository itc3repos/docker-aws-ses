#!/bin/bash
export SHELL=/bin/bash

if [[ ! $FROM || ! $TO || ! $SUBJECT || ! -f /tmp/message.txt ]]; then
    echo "FROM, TO, SUBJECT or message.txt are missing."
    echo "Usage: docker run -e FROM=verified-sender@example.com -e TO=\"rcpt1@example.com,rcpt2@example.com\" -e SUBJECT=\"This is a test\" -v </path/to/message.txt>:/tmp/message.txt -v /path/to/.aws:/root/.aws  xueshanf/aws-ses"
    exit 1
fi

for i in $(echo $TO | tr "," "\n")
do
  recipients+="\"$i\","
done
recipients=$(echo $recipients | sed 's/,$//')

body=$(cat /tmp/message.txt | tr "\n" "%" | sed 's#%#\\n#g;s#"#\\"#g')
cat > /tmp/message.json <<EOF
{
  "Subject": {
       "Data": "$SUBJECT",
       "Charset": "UTF-8"
   },
   "Body": {
       "Text": {
           "Data": "$body",
           "Charset": "UTF-8"
       }
   }
}
EOF

cat > /tmp/destination.json <<EOF
{
  "ToAddresses":  [$recipients],
  "CcAddresses":  [],
  "BccAddresses": []
}
EOF

aws ses send-email --from $FROM --destination file:///tmp/destination.json --message file:///tmp/message.json
