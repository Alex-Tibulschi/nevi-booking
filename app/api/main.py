from fastapi import FastAPI, HTTPException
from sqlalchemy import create_engine, text
from pydantic import BaseModel
from uuid import uuid4

import os, json

import boto3

from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(title="Nevi Booking API")

from mangum import Mangum
handler = Mangum(app)


app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],            # dev only; tighten later
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

REGION = os.getenv("AWS_DEFAULT_REGION", "eu-west-1")
SERVICES_TABLE_NAME = os.getenv("SERVICES_TABLE", "nevi_services_dev")
BOOKINGS_TABLE_NAME = os.getenv("BOOKINGS_TABLE", "nevi_bookings_dev")

dynamodb = boto3.resource("dynamodb", region_name=REGION)  

services_table = dynamodb.Table(SERVICES_TABLE_NAME)
bookings_table = dynamodb.Table(BOOKINGS_TABLE_NAME)



@app.get("/")
def home():
    return {"status": "ok"}

@app.get("/health")
def health_page():
    return {"status": "ok"}

@app.get("/services")
def list_services():
    
    #Read all services from DynamoDB and return services dict
    
    try:
        result = services_table.scan()
        items = result.get("Items", [])
        
        items.sort(key=lambda s: s.get("name", "")) # type: ignore[arg-type]
        
        return {"services": items}
    
    except Exception as e:#
        raise HTTPException(status_code=500, detail=f"DynamoDB error: {e}")
    
class ServiceIn(BaseModel):
    name: str
    duration_min: int
    price_pence: int
    buffer_before_min: int = 0
    buffer_after_min: int = 0
    
@app.post("/services")
def create_service(service: ServiceIn):
    """Insert a new service into DynamoDB

    Args:
        service (ServiceIn): service in the ServiceIn format
    """
    
    item = {
        "id": f"svc_{uuid4().hex[:8]}",
        "name": service.name,
        "duration_min": service.duration_min,
        "price_cents": service.price_pence,
        "buffer_before_min": service.buffer_before_min,
        "buffer_after_min": service.buffer_after_min,
    }
    
    try:
        services_table.put_item(Item=item)
        return {"message": "created", "service": item}
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"DynamoDB error: {e}")
