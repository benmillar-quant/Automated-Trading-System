import os
import logging
from google.cloud import storage
from flask import Flask, request, jsonify

app = Flask(__name__)

BUCKET_NAME = 'trading-webhook-bucket'  # Replace with your actual bucket name
COMMAND_FILE_PATH = 'command.txt'

logging.basicConfig(level=logging.INFO)

def upload_to_gcs(data):
    try:
        client = storage.Client()
        bucket = client.bucket(BUCKET_NAME)
        blob = bucket.blob(COMMAND_FILE_PATH)
        blob.upload_from_string(data)
        logging.info(f"Successfully uploaded data to {COMMAND_FILE_PATH}")
    except Exception as e:
        logging.error(f"Error uploading to GCS: {e}")

@app.route('/webhook', methods=['POST'])
def webhook():
    try:
        data = request.get_json()
        logging.info(f"Received data: {data}")
        command = data.get('action', '').lower()
        upload_to_gcs(command)
        logging.info(f"Processed command: {command}")
        return jsonify({"status": "success"}), 200
    except Exception as e:
        logging.error(f"Error processing webhook: {e}")
        return jsonify({"status": "error", "message": str(e)}), 500

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 8080))
    app.run(host='0.0.0.0', port=port)
