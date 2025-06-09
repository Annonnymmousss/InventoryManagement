package routes

import (
    "inventory-backend/controllers"
    "net/http"

    "github.com/labstack/echo/v4"
)

func SetupRoutes(e *echo.Echo) {
  
    e.GET("/", func(c echo.Context) error {
        return c.JSON(http.StatusOK, map[string]string{
            "message": "Inventory Management API is running!",
        })
    })


    api := e.Group("/api")


    products := api.Group("/products")
    products.GET("", controllers.GetProducts)
    products.GET("/:id", controllers.GetProduct)
    products.POST("", controllers.CreateProduct)
    products.PUT("/:id", controllers.UpdateProduct)
    products.DELETE("/:id", controllers.DeleteProduct)
}
