from flask import Flask, request, jsonify
from flask_cors import CORS
import mysql.connector
from mysql.connector import Error
from datetime import datetime
import json

app = Flask(__name__)
CORS(app) 


DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',
    'password': '', 
    'database': 'dbshop'
}


def get_db_connection():
    try:
        connection = mysql.connector.connect(**DB_CONFIG)
        if connection.is_connected():
            return connection
    except Error as e:
        print(f"Error connecting to MySQL: {e}")
        return None


def initialize_database():
    try:
        # First connect without specifying a database
        init_config = DB_CONFIG.copy()
        init_config.pop('database', None)
        
        connection = mysql.connector.connect(**init_config)
        if connection.is_connected():
            cursor = connection.cursor()
            
            # Create database if it doesn't exist
            cursor.execute("CREATE DATABASE IF NOT EXISTS dbshop")
            
            # Switch to the dbshop database
            cursor.execute("USE dbshop")
            
            # Create tbsale table if it doesn't exist
            cursor.execute('''
                CREATE TABLE IF NOT EXISTS tbsale (
                    id INT AUTO_INCREMENT PRIMARY KEY,
                    productName TEXT NOT NULL,
                    productPrice INT NOT NULL,
                    amount INT NOT NULL,
                    totalPrice INT NOT NULL,
                    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                )
            ''')
            
            connection.commit()
            print("Database and tables initialized successfully")
            
            cursor.close()
            connection.close()
    except Error as e:
        print(f"Error initializing database: {e}")

# Initialize the database when the server starts
initialize_database()

# API Routes

# Get all sales
@app.route('/api/sales', methods=['GET'])
def get_all_sales():
    connection = get_db_connection()
    if connection:
        try:
            cursor = connection.cursor(dictionary=True)
            cursor.execute("SELECT * FROM tbsale ORDER BY createdAt DESC")
            sales = cursor.fetchall()
            
            # Convert datetime objects to string for JSON serialization
            for sale in sales:
                if 'createdAt' in sale and sale['createdAt']:
                    sale['createdAt'] = sale['createdAt'].isoformat()
            
            cursor.close()
            connection.close()
            return jsonify(sales)
        except Error as e:
            return jsonify({"error": str(e)}), 500
    return jsonify({"error": "Database connection failed"}), 500

# Get a sale by ID
@app.route('/api/sales/<int:id>', methods=['GET'])
def get_sale_by_id(id):
    connection = get_db_connection()
    if connection:
        try:
            cursor = connection.cursor(dictionary=True)
            cursor.execute("SELECT * FROM tbsale WHERE id = %s", (id,))
            sale = cursor.fetchone()
            
            if not sale:
                return jsonify({"error": "Sale not found"}), 404
            
            # Convert datetime objects to string for JSON serialization
            if 'createdAt' in sale and sale['createdAt']:
                sale['createdAt'] = sale['createdAt'].isoformat()
            
            cursor.close()
            connection.close()
            return jsonify(sale)
        except Error as e:
            return jsonify({"error": str(e)}), 500
    return jsonify({"error": "Database connection failed"}), 500

# Create a new sale
@app.route('/api/sales', methods=['POST'])
def create_sale():
    data = request.get_json()
    
    # Validate required fields
    required_fields = ['productName', 'productPrice', 'amount', 'totalPrice']
    for field in required_fields:
        if field not in data:
            return jsonify({"error": f"Missing required field: {field}"}), 400
    
    connection = get_db_connection()
    if connection:
        try:
            cursor = connection.cursor()
            query = '''
                INSERT INTO tbsale (productName, productPrice, amount, totalPrice)
                VALUES (%s, %s, %s, %s)
            '''
            values = (
                data['productName'],
                data['productPrice'],
                data['amount'],
                data['totalPrice']
            )
            
            cursor.execute(query, values)
            connection.commit()
            
            # Get the ID of the newly created sale
            sale_id = cursor.lastrowid
            
            cursor.close()
            connection.close()
            
            # Return the created sale with its ID
            return jsonify({
                "id": sale_id,
                "productName": data['productName'],
                "productPrice": data['productPrice'],
                "amount": data['amount'],
                "totalPrice": data['totalPrice'],
                "createdAt": datetime.now().isoformat()
            }), 201
        except Error as e:
            return jsonify({"error": str(e)}), 500
    return jsonify({"error": "Database connection failed"}), 500

# Update a sale
@app.route('/api/sales/<int:id>', methods=['PUT'])
def update_sale(id):
    data = request.get_json()
    
    # Validate required fields
    required_fields = ['productName', 'productPrice', 'amount', 'totalPrice']
    for field in required_fields:
        if field not in data:
            return jsonify({"error": f"Missing required field: {field}"}), 400
    
    connection = get_db_connection()
    if connection:
        try:
            cursor = connection.cursor()
            
            # Check if the sale exists
            cursor.execute("SELECT * FROM tbsale WHERE id = %s", (id,))
            if not cursor.fetchone():
                cursor.close()
                connection.close()
                return jsonify({"error": "Sale not found"}), 404
            
            # Update the sale
            query = '''
                UPDATE tbsale
                SET productName = %s, productPrice = %s, amount = %s, totalPrice = %s
                WHERE id = %s
            '''
            values = (
                data['productName'],
                data['productPrice'],
                data['amount'],
                data['totalPrice'],
                id
            )
            
            cursor.execute(query, values)
            connection.commit()
            
            cursor.close()
            connection.close()
            
            # Return the updated sale
            return jsonify({
                "id": id,
                "productName": data['productName'],
                "productPrice": data['productPrice'],
                "amount": data['amount'],
                "totalPrice": data['totalPrice']
            })
        except Error as e:
            return jsonify({"error": str(e)}), 500
    return jsonify({"error": "Database connection failed"}), 500

# Delete a sale
@app.route('/api/sales/<int:id>', methods=['DELETE'])
def delete_sale(id):
    connection = get_db_connection()
    if connection:
        try:
            cursor = connection.cursor()
            
            # Check if the sale exists
            cursor.execute("SELECT * FROM tbsale WHERE id = %s", (id,))
            if not cursor.fetchone():
                cursor.close()
                connection.close()
                return jsonify({"error": "Sale not found"}), 404
            
            # Delete the sale
            cursor.execute("DELETE FROM tbsale WHERE id = %s", (id,))
            connection.commit()
            
            cursor.close()
            connection.close()
            
            return jsonify({"message": f"Sale with ID {id} deleted successfully"})
        except Error as e:
            return jsonify({"error": str(e)}), 500
    return jsonify({"error": "Database connection failed"}), 500

# Get total sales amount
@app.route('/api/sales/total', methods=['GET'])
def get_total_sales_amount():
    connection = get_db_connection()
    if connection:
        try:
            cursor = connection.cursor(dictionary=True)
            cursor.execute("SELECT SUM(totalPrice) as total FROM tbsale")
            result = cursor.fetchone()
            
            total = result['total'] if result and result['total'] else 0
            
            cursor.close()
            connection.close()
            
            return jsonify({"total": total})
        except Error as e:
            return jsonify({"error": str(e)}), 500
    return jsonify({"error": "Database connection failed"}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
