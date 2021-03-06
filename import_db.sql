DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS questions;
DROP TABLE IF EXISTS question_follows;
DROP TABLE IF EXISTS question_replies;
DROP TABLE IF EXISTS question_likes;

CREATE TABLE
  users(
    id INTEGER PRIMARY KEY,
    fname VARCHAR(255) NOT NULL,
    lname VARCHAR(255) NOT NULL
  );

CREATE TABLE
  questions(
    id INTEGER PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    body VARCHAR(255) NOT NULL,
    creator_id INTEGER NOT NULL,
    FOREIGN KEY(creator_id)
    REFERENCES
      users(id)
  );

CREATE TABLE
  question_follows(
    id INTEGER PRIMARY KEY,
    question_id INTEGER NOT NULL,
    follower_id INTEGER,
    FOREIGN KEY(question_id)
    REFERENCES
      questions(id),
    FOREIGN KEY(follower_id)
    REFERENCES
      users(id)
  );

CREATE TABLE
  question_replies(
    id INTEGER PRIMARY KEY,
    question_id INTEGER NOT NULL,
    parent_id INTEGER,
    replier_id INTEGER NOT NULL,
    body VARCHAR(255) NOT NULL,
    FOREIGN KEY(question_id)
    REFERENCES
      questions(id),
    FOREIGN KEY(parent_id)
    REFERENCES
      replies(id)
    FOREIGN KEY(replier_id)
    REFERENCES
      users(id)
  );

CREATE TABLE
  question_likes(
    id INTEGER PRIMARY KEY,
    question_id INTEGER NOT NULL,
    liker_id INTEGER NOT NULL,
    FOREIGN KEY(question_id)
    REFERENCES
      questions(id),
    FOREIGN KEY(liker_id)
    REFERENCES
      users(id)
  );

INSERT INTO
  users(fname, lname)
  VALUES
  ('Alfred', 'Aioli'),
  ('Bob', 'Barker'),
  ('Caroline', 'Coons');

INSERT INTO
  questions(title, body, creator_id)
  VALUES
  ('Question 1', 'Why?', 1),
  ('Question 2', 'How?', 1),
  ('Question 3', 'What?', 1);

INSERT INTO
  question_replies(question_id, parent_id, replier_id, body)
  VALUES
  (1, NULL, 1, "First!"),
  (1, 1, 2, "SECOND");

INSERT INTO
  question_follows(question_id, follower_id)
  VALUES
  (1, 2),
  (1, 3),
  (2, 1);

INSERT INTO
  question_likes(question_id, liker_id)
  VALUES
  (1, 2),
  (1, 3),
  (2, 1);
