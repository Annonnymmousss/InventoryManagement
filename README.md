# Inventory Management System

A simple inventory management application with a Flutter frontend and Go backend.

## Features

- View, add, edit, and delete products
- Filter products by category or low stock
- Product details: name, category, quantity, price

## Backend (Go)

- REST API with Echo framework
- MongoDB database
- CRUD operations for products
- CORS enabled

## Frontend (Flutter)

- BLoC state management

## Setup

1. **Backend**:
   - Install Go and MongoDB
   - Set up `.env` file with MongoDB credentials
   - Run `go run main.go`

2. **Frontend**:
   - Install Flutter SDK
   - Run `flutter pub get`
   - Run `flutter run`

## API Endpoints

- `GET /api/products` - List all products
- `GET /api/products/:id` - Get single product
- `POST /api/products` - Create product
- `PUT /api/products/:id` - Update product
- `DELETE /api/products/:id` - Delete product

## .env Format 
- PORT=8080
- MONGODB_URI="cluster url"
- DATABASE_NAME="cluster name"
