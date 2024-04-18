#!/bin/bash
pipelineID=xx
accessToken="xx"
project="xx"
organisation="xx"
pipeline="azure-pipelines.yml"

yamlContent=$(cat $pipeline | sed 's/"/\\"/g' | awk '{printf "%s\\n", $0}')
jsonBody=$(cat <<EOF
{
    "previewRun": true,
    "resources": {
        "repositories": {
            "self": {
                "refName": "refs/heads/master"
            }
        }
    },
    "yamlOverride": "$yamlContent",
    "stagesToSkip": [],
    "templateParameters": {},
    "variables": {}
}
EOF
)
authHeader="Authorization: Basic $(echo -n ":$accessToken" | base64)"
uri="https://dev.azure.com/$organisation/$project/_apis/pipelines/$pipelineID/preview?api-version=6.1-preview.1"
response=$(curl -s -X POST "$uri" \
    -H "$authHeader" \
    -H "Content-Type: application/json" \
    -d "$jsonBody")
if echo "$response" | grep -q "finalYaml"; then
    echo "Preview YAML:"
    echo "$response" | jq -r '.finalYaml' | sed 's/\\n/\n/g'
else
    echo "An error occurred:"
    echo "$response" | jq .
fi
