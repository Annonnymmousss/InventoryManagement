package models

import (
    "go.mongodb.org/mongo-driver/bson/primitive"
)

type Product struct {
    ID       primitive.ObjectID `json:"id,omitempty" bson:"_id,omitempty"`
    Name     string             `json:"name" bson:"name"`
    Category string             `json:"category" bson:"category"`
    Quantity int                `json:"quantity" bson:"quantity"`
    Price    float64            `json:"price" bson:"price"`
}

type ProductResponse struct {
    ID       string  `json:"id"`
    Name     string  `json:"name"`
    Category string  `json:"category"`
    Quantity int     `json:"quantity"`
    Price    float64 `json:"price"`
}

func (p *Product) ToResponse() ProductResponse {
    return ProductResponse{
        ID:       p.ID.Hex(),
        Name:     p.Name,
        Category: p.Category,
        Quantity: p.Quantity,
        Price:    p.Price,
    }
}