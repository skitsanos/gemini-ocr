#!/usr/bin/env bash

source "utils.sh"

# Check if the necessary functions are available
log_info "Checking for required functions..."
if ! command -v get_mime_type &> /dev/null || ! command -v base64_encode_file &> /dev/null; then
    log_error "Required functions not found. Ensure 'get_mime_type' and 'base64_encode_file' are defined in utils.sh"
    exit 1
fi

# Verify if the prompt.txt exists
if [ ! -f prompt.txt ]; then
    log_error "prompt.txt not found."
    exit 1
fi

# Read the initial prompt
prompt=$(cat prompt.txt)

# Initialize the contents variable with the initial JSON structure
contents=$(jq -n --arg user_prompt "$prompt" '{contents: [{role: "user", parts: [{text: $user_prompt}]}]}')

# Loop through all files in the data directory
log_info "Processing files in the data directory..."
for file in data/*; do
    if [ -f "$file" ]; then
        log_info "Processing file: $file"
        mime_type=$(get_mime_type "$file")
        base64_encoded=$(base64_encode_file "$file")

        mime_part=$(jq -n --arg mime_type "$mime_type" --arg base64_encoded "$base64_encoded" '{inlineData: {mimeType: $mime_type, data: $base64_encoded}}')

        # Add the mime_part to the parts array in the contents JSON structure
        contents=$(echo "$contents" | jq --argjson mime_part "$mime_part" '.contents[0].parts += [$mime_part]')
    fi
done

# Generate the generation_config JSON
log_info "Creating generation configuration..."
generation_config=$(jq -n '{generationConfig: {topP: 0.95, temperature: 0}}')

# Merge generation_config with the contents JSON
log_info "Preparing payload..."
payload=$(echo "$contents" | jq --argjson generation_config "$generation_config" '. + $generation_config')

# Write the payload to a temporary file
temp_payload_file=$(mktemp)
echo "$payload" > "$temp_payload_file"

# Define the API endpoint and project details
API_ENDPOINT="us-central1-aiplatform.googleapis.com"
PROJECT_ID="skitsanos"
LOCATION_ID="us-central1"
MODEL_ID="gemini-1.5-pro-preview-0409"

# Send the POST request to the API endpoint using the temporary file
log_info "Sending request to the API endpoint, using ${MODEL_ID} model..."
response=$(curl -s -X POST \
    -H "Authorization: Bearer $(gcloud auth print-access-token)" \
    -H "Content-Type: application/json" \
    --data @"$temp_payload_file" \
    "https://${API_ENDPOINT}/v1/projects/${PROJECT_ID}/locations/${LOCATION_ID}/publishers/google/models/${MODEL_ID}:streamGenerateContent")

# Clean up the temporary file
rm "$temp_payload_file"

# Check if the request was successful
if [ $? -eq 0 ]; then
    tokens_count=$(jq -r 'map(.usageMetadata.totalTokenCount) | map(select(. != null)) | add' < response.json)
    log_info "Total token count: $tokens_count"

    log_info "Storing response in response.json..."
    echo "$response" > response.json

    log_info "Storing response in response.txt..."
    jq -r '.[].candidates[].content.parts[].text' < response.json > response.txt
else
    log_error "Request failed"
fi
