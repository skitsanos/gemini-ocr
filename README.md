# PDF Screenshot OCR Analysis with Google Gemini Pro

This project involves automating converting PDF document screenshots into text using Google's Gemini Pro model. The goal is to perform Optical Character Recognition (OCR) on images extracted from PDF screenshots to analyze and extract textual content.

#### Workflow Overview:

1. **Screenshot Extraction**: Images are taken from PDF documents and stored in a designated directory (`data/`).
2. **Prompt Preparation**: A text prompt is read from `prompt.txt`, which instructs the model on how to process the images.
3. Image Processing:
   - The script determines the MIME type for each image in the data/ directory and encodes it in Base64.
   - These encoded images and the initial user prompt are incorporated into a JSON structure.
4. **Generation Configuration**: A generation configuration is created to fine-tune the model's processing parameters, such as `topP` and `temperature`.
5. **Payload Preparation**: The JSON structure, including the images and configuration, is prepared as a payload for the API request.
6. **API Request**: The payload is sent to the Google Gemini Pro model via an API endpoint to perform OCR.
7. Response Handling
   - The response, containing the extracted text and metadata, is saved to `response.json`.
   - The textual content is extracted and saved to `response.txt`.

#### Key Components:

- **Image Processing**: Functions to get MIME type and encode images in Base64.
- **JSON Structuring**: Using `jq` to build and modify JSON payloads.
- **API Integration**: Sending the payload to Google Gemini Pro and handling the response.

#### Benefits:

- **Automation**: Streamlines the process of converting PDF screenshots to text.
- **Accuracy**: Leverages Google's advanced OCR capabilities for high-quality text extraction.
- **Flexibility**: Configurable processing parameters to optimize OCR results.

This project is ideal for scenarios where automated text extraction from PDF screenshots is needed, such as digitizing documents, extracting data for analysis, or improving accessibility.
