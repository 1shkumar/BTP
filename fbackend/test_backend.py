from flask import Flask, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

@app.route('/test', methods=['GET'])
def test():
    return jsonify({"message": "Predicted Disease : Apple Blackrot, Confidence :0.91"})

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5002)

