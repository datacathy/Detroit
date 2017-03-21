# Detroit
Predicting blight in the city.

This repository contains files to accompany the capstone project "Predicting Blighted Buildings in Detroit."

Jupyter Notebook (Python) files:
* detroit_visualization.ipynb: code to visualize crimes, complaints, violations, and blight in Detroit in 2015
* modeling.ipynb: code for naive and full decision trees using count and/or MCM data
* vgg16.ipynb: image recognition using vgg16 as feature extractor
* xception.ipynb: image recognition using xception as feature extractor
* joined_model.ipynb: decision tree using all features plus result of image recognition

SQL files for PostgreSQL backend:
* neighborhoods.sql: load Detroit neighborhoods
* matches.sql: function to perform address matching
* crimes.sql: load crime incident data
* complaints.sql: load 311 complaint data
* violations.sql: load blight violations
* permits.sql: load demolition permit data
* parcels.sql: load parcel data and compute counts for modeling

JavaScript for interactive visualization:
* interface.html: JavaScript for interactive visualization
* parcels.json: Geojson file for interactive visualization
* neighborhoods.json: Geojson file for interactive visualization

For more information, refer to the project writeup available through Coursera.
