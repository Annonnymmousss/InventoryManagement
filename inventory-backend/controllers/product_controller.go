package controllers

import (
    "context"
    "inventory-backend/config"
    "inventory-backend/models"
    "net/http"
    "time"

    "github.com/labstack/echo/v4"
    "go.mongodb.org/mongo-driver/bson"
    "go.mongodb.org/mongo-driver/bson/primitive"
    "go.mongodb.org/mongo-driver/mongo"
)

var productCollection *mongo.Collection

func GetProductCollection() *mongo.Collection {
    if productCollection == nil {
        productCollection = config.GetCollection("products")
    }
    return productCollection
}

func GetProducts(c echo.Context) error {
    ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
    defer cancel()

    var products []models.Product
    cursor, err := GetProductCollection().Find(ctx, bson.M{})
    if err != nil {
        return c.JSON(http.StatusInternalServerError, map[string]string{
            "error": "Failed to fetch products",
        })
    }
    defer cursor.Close(ctx)

    if err = cursor.All(ctx, &products); err != nil {
        return c.JSON(http.StatusInternalServerError, map[string]string{
            "error": "Failed to decode products",
        })
    }

    var productResponses []models.ProductResponse
    for _, product := range products {
        productResponses = append(productResponses, product.ToResponse())
    }

    return c.JSON(http.StatusOK, productResponses)
}


func GetProduct(c echo.Context) error {
    ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
    defer cancel()

    id := c.Param("id")
    objectId, err := primitive.ObjectIDFromHex(id)
    if err != nil {
        return c.JSON(http.StatusBadRequest, map[string]string{
            "error": "Invalid product ID",
        })
    }

    var product models.Product
    err = GetProductCollection().FindOne(ctx, bson.M{"_id": objectId}).Decode(&product)
    if err != nil {
        if err == mongo.ErrNoDocuments {
            return c.JSON(http.StatusNotFound, map[string]string{
                "error": "Product not found",
            })
        }
        return c.JSON(http.StatusInternalServerError, map[string]string{
            "error": "Failed to fetch product",
        })
    }

    return c.JSON(http.StatusOK, product.ToResponse())
}


func CreateProduct(c echo.Context) error {
    ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
    defer cancel()

    var product models.Product
    if err := c.Bind(&product); err != nil {
        return c.JSON(http.StatusBadRequest, map[string]string{
            "error": "Invalid request body",
        })
    }

    if product.Name == "" {
        return c.JSON(http.StatusBadRequest, map[string]string{
            "error": "Product name is required",
        })
    }
    if product.Category == "" {
        return c.JSON(http.StatusBadRequest, map[string]string{
            "error": "Product category is required",
        })
    }

    product.ID = primitive.NewObjectID()

    result, err := GetProductCollection().InsertOne(ctx, product)
    if err != nil {
        return c.JSON(http.StatusInternalServerError, map[string]string{
            "error": "Failed to create product",
        })
    }

    var createdProduct models.Product
    err = GetProductCollection().FindOne(ctx, bson.M{"_id": result.InsertedID}).Decode(&createdProduct)
    if err != nil {
        return c.JSON(http.StatusInternalServerError, map[string]string{
            "error": "Failed to fetch created product",
        })
    }

    return c.JSON(http.StatusCreated, createdProduct.ToResponse())
}


func UpdateProduct(c echo.Context) error {
    ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
    defer cancel()

    id := c.Param("id")
    objectId, err := primitive.ObjectIDFromHex(id)
    if err != nil {
        return c.JSON(http.StatusBadRequest, map[string]string{
            "error": "Invalid product ID",
        })
    }

    var product models.Product
    if err := c.Bind(&product); err != nil {
        return c.JSON(http.StatusBadRequest, map[string]string{
            "error": "Invalid request body",
        })
    }

    if product.Name == "" {
        return c.JSON(http.StatusBadRequest, map[string]string{
            "error": "Product name is required",
        })
    }
    if product.Category == "" {
        return c.JSON(http.StatusBadRequest, map[string]string{
            "error": "Product category is required",
        })
    }

    update := bson.M{
        "$set": bson.M{
            "name":     product.Name,
            "category": product.Category,
            "quantity": product.Quantity,
            "price":    product.Price,
        },
    }

    result, err := GetProductCollection().UpdateOne(ctx, bson.M{"_id": objectId}, update)
    if err != nil {
        return c.JSON(http.StatusInternalServerError, map[string]string{
            "error": "Failed to update product",
        })
    }

    if result.MatchedCount == 0 {
        return c.JSON(http.StatusNotFound, map[string]string{
            "error": "Product not found",
        })
    }

    var updatedProduct models.Product
    err = GetProductCollection().FindOne(ctx, bson.M{"_id": objectId}).Decode(&updatedProduct)
    if err != nil {
        return c.JSON(http.StatusInternalServerError, map[string]string{
            "error": "Failed to fetch updated product",
        })
    }

    return c.JSON(http.StatusOK, updatedProduct.ToResponse())
}

func DeleteProduct(c echo.Context) error {
    ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
    defer cancel()

    id := c.Param("id")
    objectId, err := primitive.ObjectIDFromHex(id)
    if err != nil {
        return c.JSON(http.StatusBadRequest, map[string]string{
            "error": "Invalid product ID",
        })
    }

    result, err := GetProductCollection().DeleteOne(ctx, bson.M{"_id": objectId})
    if err != nil {
        return c.JSON(http.StatusInternalServerError, map[string]string{
            "error": "Failed to delete product",
        })
    }

    if result.DeletedCount == 0 {
        return c.JSON(http.StatusNotFound, map[string]string{
            "error": "Product not found",
        })
    }

    return c.JSON(http.StatusOK, map[string]string{
        "message": "Product deleted successfully",
    })
}