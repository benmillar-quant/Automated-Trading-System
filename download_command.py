# Activate your virtual environment
#    cd "C:/Users/benmi/Desktop/Trading View Backtest/Automation/RSI"
#    .venv\Scripts\activate

import time
from google.cloud import storage
import os
import shutil

def download_command_file(bucket_name, source_blob_name, destination_file_name, additional_folder):
    """Downloads a blob from the bucket."""
    storage_client = storage.Client()
    bucket = storage_client.bucket(bucket_name)
    blob = bucket.blob(source_blob_name)
    
    temp_file_name = destination_file_name + ".tmp"

    try:
        # Download the file to a temporary location
        blob.download_to_filename(temp_file_name)

        # Move the temporary file to the original destination
        os.replace(temp_file_name, destination_file_name)
        print(f"Command.txt downloaded TN")

        # Copy the file to the additional location
        additional_file_path = os.path.join(additional_folder, os.path.basename(destination_file_name))
        shutil.copy2(destination_file_name, additional_file_path)
        print(f"Command.txt downloaded FTMO")

    except Exception as e:
        print(f"Failed to download or move the file: {e}")

if __name__ == "__main__":
    bucket_name = "trading-webhook-bucket"  # Replace with your actual bucket name
    source_blob_name = "command.txt"  # The command file name, e.g., command.txt
    destination_file_name = r"C:\Users\benmi\AppData\Roaming\MetaQuotes\Terminal\3AFFD4412460AA66B16CEA957D962993\MQL4\Files\command.txt"  # Use raw string
    additional_folder = r"C:\Users\benmi\AppData\Roaming\MetaQuotes\Terminal\2C68BEE3A904BDCEE3EEF5A5A77EC162\MQL4\Files"  # Additional folder

    while True:
        try:
            download_command_file(bucket_name, source_blob_name, destination_file_name, additional_folder)
        except PermissionError as e:
            print(f"Permission error: {e}. Retrying...")
            time.sleep(1)  # Wait for 1 second before retrying
        except Exception as e:
            print(f"An error occurred: {e}")
        time.sleep(1)  # Wait for 1 second before downloading again
