require 'pg'

if ENV["RACK_ENV"] == "production"
  dd = PG.connect(
    dbname: ENV["POSTGRES_DB"],
    host: ENV["POSTGRES_HOST"],
    password: ENV["POSTGRES_PASS"],
    user: ENV["POSTGRES_USER"]
    )
else
  db = PG.connect(dbname: "forum_project")
end
​

db.exec("DROP TABLE IF EXISTS comments CASCADE")
db.exec("DROP TABLE IF EXISTS posts CASCADE")
db.exec("DROP TABLE IF EXISTS topics CASCADE")
db.exec("DROP TABLE IF EXISTS users CASCADE")


db.exec("CREATE TABLE users(
  id SERIAL PRIMARY KEY,
  user_name VARCHAR(50) UNIQUE NOT NULL,
  user_email VARCHAR NOT NULL,
  user_password_digest VARCHAR,
  img_url VARCHAR 
 )"
)


db.exec("CREATE TABLE topics(
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id),
  topic VARCHAR
)"
)

db.exec("CREATE TABLE posts(
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id),
  topic_id INTEGER REFERENCES topics(id),
  content VARCHAR(255)
)"
)

db.exec("CREATE TABLE comments(
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id),
  topic_id INTEGER REFERENCES topics(id),
  post_id INTEGER REFERENCES posts(id), 
  comment VARCHAR(255),
  count INTEGER 
)"
)


