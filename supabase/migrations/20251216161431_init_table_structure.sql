CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TYPE status AS ENUM ('active', 'cancelled');

CREATE TABLE users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  username varchar UNIQUE NOT NULL,
  password varchar NOT NULL,
  salt varchar NOT NULL
);

CREATE TABLE roles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name varchar UNIQUE NOT NULL
);

CREATE TABLE user_roles (
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  role_id uuid NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
  PRIMARY KEY (user_id, role_id)
);

CREATE TABLE movies (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title varchar NOT NULL,
  description varchar NOT NULL,
  poster_image varchar NOT NULL,
  genre varchar NOT NULL
);

CREATE TABLE room (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  room_number int UNIQUE NOT NULL,
  capacity int NOT NULL
);

CREATE TABLE seat (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  room_id uuid NOT NULL REFERENCES room(id) ON DELETE CASCADE,
  "row" int NOT NULL,
  number int NOT NULL,
  UNIQUE (room_id, "row", number)
);

CREATE TABLE showtime (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  movie_id uuid NOT NULL REFERENCES movies(id) ON DELETE CASCADE,
  room_id uuid NOT NULL REFERENCES room(id) ON DELETE RESTRICT,
  starting_time timestamptz NOT NULL,
  UNIQUE (room_id, starting_time)
);

CREATE TABLE reservation (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  showtime_id uuid NOT NULL REFERENCES showtime(id) ON DELETE CASCADE,
  status status NOT NULL DEFAULT 'active',
  created_at timestamptz NOT NULL DEFAULT now(),
  cancelled_at timestamptz,

  UNIQUE (id, showtime_id)
);

CREATE TABLE reservation_seats (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  reservation_id uuid NOT NULL,
  showtime_id uuid NOT NULL,
  seat_id uuid NOT NULL REFERENCES seat(id) ON DELETE RESTRICT,

  UNIQUE (reservation_id, seat_id),

  UNIQUE (showtime_id, seat_id),

  FOREIGN KEY (reservation_id, showtime_id)
    REFERENCES reservation(id, showtime_id)
    ON DELETE CASCADE,

  FOREIGN KEY (showtime_id)
    REFERENCES showtime(id)
    ON DELETE CASCADE
);
