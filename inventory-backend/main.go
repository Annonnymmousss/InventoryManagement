// main.go
package main

import (
    "inventory-backend/config"
    "inventory-backend/routes"
    "log"
    "os"

    "github.com/joho/godotenv"
    "github.com/labstack/echo/v4"
    "github.com/labstack/echo/v4/middleware"
)

func main() {
  
    err := godotenv.Load()
    if err != nil {
        log.Println("Warning: .env file not found, using system environment variables")
    }


    if os.Getenv("MONGODB_URI") == "" {
        os.Setenv("MONGODB_URI", "mongodb://localhost:27017")
    }
    if os.Getenv("DATABASE_NAME") == "" {
        os.Setenv("DATABASE_NAME", "inventory_db")
    }

    
    config.ConnectDB()

 
    e := echo.New()

    
    e.Use(middleware.CORSWithConfig(middleware.CORSConfig{
        AllowOrigins: []string{"*"},
        AllowMethods: []string{echo.GET, echo.PUT, echo.POST, echo.DELETE, echo.OPTIONS},
        AllowHeaders: []string{echo.HeaderOrigin, echo.HeaderContentType, echo.HeaderAccept, echo.HeaderAuthorization},
        AllowCredentials: true,
    }))

    
    e.Use(middleware.Logger())
    e.Use(middleware.Recover())

    
    routes.SetupRoutes(e)

  
    port := os.Getenv("PORT")
    if port == "" {
        port = "8080"
    }
  
    
    e.Logger.Fatal(e.Start(":" + port))
}