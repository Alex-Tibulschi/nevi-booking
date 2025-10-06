from fastapi import FastAPI
import json
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],            # dev only; tighten later
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def home():
    return None

@app.get("/health")
def health_page():
    return {"status": "ok"}

@app.get("/services")
def services_page():
    
    with open("./services.json") as file:
        
        data = json.load(file)
        
        return data