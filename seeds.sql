DROP TABLE IF EXISTS likes CASCADE;
DROP TABLE IF EXISTS comments CASCADE;
DROP TABLE IF EXISTS posts CASCADE;
DROP TABLE IF EXISTS topics CASCADE;
DROP TABLE IF EXISTS users CASCADE;


CREATE TABLE users(
  id SERIAL PRIMARY KEY,
  user_name VARCHAR(50) UNIQUE NOT NULL,
  user_email VARCHAR NOT NULL,
  user_password_digest VARCHAR,
  img_url VARCHAR 
 );


CREATE TABLE topics(
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id),
  topic VARCHAR
);

CREATE TABLE posts(
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id),
  topic_id INTEGER REFERENCES topics(id),
  content VARCHAR(255)
);

CREATE TABLE comments(
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id),
  topic_id INTEGER REFERENCES topics(id),
  post_id INTEGER REFERENCES posts(id), 
  comment VARCHAR(255),
  count INTEGER 
);

CREATE TABLE likes(
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id),
  topic_id INTEGER REFERENCES topics(id),
  post_id INTEGER REFERENCES posts(id),
  comment_id INTEGER REFERENCES comments(id),
  count INTEGER
);
