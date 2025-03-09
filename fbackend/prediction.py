import os
import tensorflow as tf
from tensorflow.keras.preprocessing import image
import numpy as np
import cv2
from flask import Flask,request, jsonify
from flask_cors import CORS
from PIL import Image
from io import BytesIO

app = Flask(__name__)
CORS(app)
IMAGE_SIZE = 256
BATCH_SIZE = 32
CHANNELS = 3

# Load the trained model
model = tf.keras.models.load_model("plant_disease_model.h5")
print("Model loaded successfully!")

# Set up the test dataset directory
test_dir = "test"  # Update this to your test directory path
class_names = ['Apple___Apple_scab', 'Apple___Black_rot', 'Apple___Cedar_apple_rust', 'Healthy']  # Update with your class names

# Function to preprocess an image for prediction

def preprocess_image(img):
    img = img.resize((IMAGE_SIZE, IMAGE_SIZE))
    img_array = image.img_to_array(img) / 255.0  # Normalize the image
    img_array = np.expand_dims(img_array, axis=0)  # Add batch dimension
    return img_array

# Predict and display results for each image in the test directory
@app.route('/predict', methods=['POST'])
def predict_disease():
    if 'image' not in request.files:
        return jsonify({"error": "No image file provided"}), 400

    file = request.files['image']
    if file.filename == '':
        return jsonify({"error": "No selected file"}), 400

    try:
        img_bytes = file.read()
        img = Image.open(BytesIO(img_bytes))
        img_array = preprocess_image(img)

        # Make prediction
        predictions = model.predict(img_array)
        predicted_class = np.argmax(predictions, axis=1)[0]
        confidence = np.max(predictions)

        predicted_label = class_names[predicted_class]
        
        print(f"Predicted: {predicted_label} (Confidence: {confidence:.2f})")

        return jsonify({
            "predicted_label": predicted_label,
            "confidence": float(confidence)
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    # for folder in os.listdir(test_dir):
    #     folder_path = os.path.join(test_dir, folder)
    #     if os.path.isdir(folder_path):
    #         print(f"\nProcessing folder: {folder}")
    #         image_count = 0
    #         for img_file in os.listdir(folder_path):
    #             img_path = os.path.join(folder_path, img_file)
    #             if img_file.endswith(('.JPG', '.jpg', '.PNG', '.png', '.JPEG', '.jpeg')):
    #                 image_count += 1
    #                 # Load and preprocess the image
    #                 image = cv2.imread(img_path)
    #                 image = cv2.resize(image, (IMAGE_SIZE, IMAGE_SIZE))
    #                 image = image / 255.0  # Normalize to [0, 1]
    #                 image = np.expand_dims(image, axis=0)  # Add batch dimension

    #                 # Make prediction
    #                 predictions = model.predict(image)
    #                 predicted_class = np.argmax(predictions, axis=1)[0]
    #                 confidence = np.max(predictions)

    #                 predicted_label = class_names[predicted_class]

    #                 # Display result
    #                 print(f"Image: {img_file} -> Predicted: {predicted_label} (Confidence: {confidence:.2f})")
    #         if image_count == 0:
    #             print(f"No valid images found in folder: {folder}")

# Run prediction on the test dataset


if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5003)