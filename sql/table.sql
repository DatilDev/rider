CREATE TABLE locations (
  id SERIAL PRIMARY KEY,
  latitude FLOAT NOT NULL,
  longitude FLOAT NOT NULL,
  heading FLOAT,
  speed FLOAT,
  accuracy FLOAT,
  user_id INTEGER NOT NULL,
  ride_id INTEGER NOT NULL,
  inserted_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);