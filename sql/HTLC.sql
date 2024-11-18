CREATE TABLE htlcs (
  id SERIAL PRIMARY KEY,
  payment_hash TEXT NOT NULL,
  preimage TEXT NOT NULL,
  amount_sats INTEGER NOT NULL,
  status TEXT NOT NULL,
  expiry_time TIMESTAMP NOT NULL,
  ride_id INTEGER REFERENCES rides(id),
  inserted_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);