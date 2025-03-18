# Mobile Final Project - Sales Management App

A Flutter application for managing sales data with a Python Flask backend. This application allows users to record product sales, track inventory, and analyze sales data through a user-friendly mobile interface.

## Screenshots

Here are some screenshots of the application:

| Home Screen | Add Sale | Sales Details |
|-------------|----------|---------------|
| ![Home Screen](screenshots/home_screen.png) | ![Add Sale](screenshots/add_sale.png) | ![Sales Details](screenshots/sales_details.png) |

*Note: Replace these placeholder images with actual screenshots of your application.*

## About This Application

### Overview
This sales management application is designed to help small businesses track their product sales efficiently. The app provides a simple interface for recording sales transactions, viewing sales history, and monitoring total revenue.

### Key Features
- **Product Sales Recording**: Add new sales with product name, price, quantity, and automatically calculate total price
- **Sales History**: View a chronological list of all sales transactions
- **Sales Analytics**: See total revenue and sales statistics
- **CRUD Operations**: Create, read, update, and delete sales records
- **Offline Capability**: Store data locally when offline and sync when connected
- **Real-time Updates**: Instantly reflect changes in the UI when data is modified

### Technical Architecture
The application follows a client-server architecture:

#### Frontend (Flutter)
- **State Management**: Uses Provider pattern for efficient state management
- **Models**: Structured data models for sales records
- **Services**: API services for backend communication
- **Screens**: User interface components for different app functions
- **Widgets**: Reusable UI components

#### Backend (Python Flask)
- **RESTful API**: Endpoints for data operations
- **Database**: MySQL for persistent data storage
- **Data Validation**: Server-side validation of all inputs
- **Error Handling**: Comprehensive error handling and reporting

## SDK Requirements

This project requires:
- Dart SDK: >=3.6.0 <4.0.0
- Flutter SDK: 3.29.2 or compatible version
- Python 3.x for the backend server

## Backend Server Setup

The application uses a Python Flask server with MySQL for data storage.

### Dependencies

Install the required Python packages:
```
pip install mysql-connector-python flask flask-cors
```

### Database Configuration

The server is configured to connect to a MySQL database with the following settings:
- Host: localhost
- User: root
- Password: (empty)
- Database: dbshop

The server will automatically create the database and required tables if they don't exist.

### Database Schema

The application uses a simple database schema:

**tbsale Table**:
- `id` (INT, Primary Key): Unique identifier for each sale
- `productName` (TEXT): Name of the product sold
- `productPrice` (INT): Price per unit of the product
- `amount` (INT): Quantity of products sold
- `totalPrice` (INT): Total price of the sale (productPrice × amount)
- `createdAt` (TIMESTAMP): When the sale was recorded

### Running the Server

Start the backend server:
```
python server.py
```

The server will run on:
- http://127.0.0.1:5000 (localhost)
- http://your-local-ip:5000 (your network)

## Flutter App Setup

1. Make sure you have Flutter installed. If not, follow the [Flutter installation guide](https://docs.flutter.dev/get-started/install).

2. Clone this repository:
   ```
   git clone <repository-url>
   ```

3. Navigate to the project directory:
   ```
   cd mobile_final_f2
   ```

4. Get dependencies:
   ```
   flutter pub get
   ```

5. Configure the API endpoint:
   - Open `lib/services/api_service.dart`
   - Update the `baseUrl` variable if needed:
     - For Android emulator: `http://10.0.2.2:5000/api` (default)
     - For physical device: `http://<your-computer-ip>:5000/api`
     - For iOS simulator: `http://localhost:5000/api`

6. Run the application:
   ```
   flutter run
   ```

## Application Workflow

1. **Home Screen**:
   - View list of all sales
   - See total revenue
   - Add new sales
   - Edit or delete existing sales

2. **Add/Edit Sale Form**:
   - Enter product name
   - Set product price
   - Specify quantity
   - Total price is calculated automatically

3. **Sale Details**:
   - View detailed information about a specific sale
   - Options to edit or delete the sale

## API Endpoints

The backend provides the following API endpoints:

- `GET /api/sales` - Get all sales records
- `GET /api/sales/<id>` - Get a specific sale by ID
- `POST /api/sales` - Create a new sale record
- `PUT /api/sales/<id>` - Update an existing sale record
- `DELETE /api/sales/<id>` - Delete a sale record
- `GET /api/total` - Get the total sales amount

## Project Structure

```
lib/
├── main.dart              # Application entry point
├── models/                # Data models
│   └── sale_model.dart    # Sale data model
├── providers/             # State management
│   └── sale_provider.dart # Sale state provider
├── screens/               # UI screens
│   ├── home_screen.dart   # Main screen with sales list
│   └── sale_form_screen.dart # Form for adding/editing sales
├── services/              # Backend communication
│   ├── api_service.dart   # API client for server communication
│   └── sale_service.dart  # Business logic for sales
└── widgets/               # Reusable UI components
```

## Additional Resources

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)
- [Flutter documentation](https://docs.flutter.dev/)
- [Flask documentation](https://flask.palletsprojects.com/)
- [MySQL Connector/Python documentation](https://dev.mysql.com/doc/connector-python/en/)
