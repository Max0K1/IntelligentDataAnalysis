CREATE TABLE subjects (
  subject_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE topics (
  topic_id INT AUTO_INCREMENT PRIMARY KEY,
  subject_id INT NOT NULL,
  name VARCHAR(120) NOT NULL,
  UNIQUE (subject_id, name),
  FOREIGN KEY (subject_id) REFERENCES subjects(subject_id)
) ENGINE=InnoDB;

CREATE TABLE difficulty_levels (
  level_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(30) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE authors (
  author_id INT AUTO_INCREMENT PRIMARY KEY,
  full_name VARCHAR(120) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE students (
  student_id INT AUTO_INCREMENT PRIMARY KEY,
  full_name VARCHAR(120) NOT NULL,
  group_name VARCHAR(30)
) ENGINE=InnoDB;

CREATE TABLE questions (
  question_id INT AUTO_INCREMENT PRIMARY KEY,
  topic_id INT NOT NULL,
  level_id INT NOT NULL,
  author_id INT NOT NULL,
  question_text TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (topic_id) REFERENCES topics(topic_id),
  FOREIGN KEY (level_id) REFERENCES difficulty_levels(level_id),
  FOREIGN KEY (author_id) REFERENCES authors(author_id)
) ENGINE=InnoDB;

CREATE TABLE answers (
  answer_id INT AUTO_INCREMENT PRIMARY KEY,
  question_id INT NOT NULL,
  answer_text TEXT NOT NULL,
  is_correct TINYINT(1) NOT NULL DEFAULT 0,
  FOREIGN KEY (question_id) REFERENCES questions(question_id)
) ENGINE=InnoDB;

CREATE TABLE tests (
  test_id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(150) NOT NULL,
  subject_id INT NOT NULL,
  created_by INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (subject_id) REFERENCES subjects(subject_id),
  FOREIGN KEY (created_by) REFERENCES authors(author_id)
) ENGINE=InnoDB;

CREATE TABLE test_questions (
  test_id INT NOT NULL,
  question_id INT NOT NULL,
  points DECIMAL(5,2) NOT NULL DEFAULT 1.00,
  PRIMARY KEY (test_id, question_id),
  FOREIGN KEY (test_id) REFERENCES tests(test_id),
  FOREIGN KEY (question_id) REFERENCES questions(question_id)
) ENGINE=InnoDB;

CREATE TABLE test_attempts (
  attempt_id INT AUTO_INCREMENT PRIMARY KEY,
  test_id INT NOT NULL,
  student_id INT NOT NULL,
  started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  finished_at TIMESTAMP NULL,
  total_score DECIMAL(6,2) DEFAULT 0,
  max_score DECIMAL(6,2) DEFAULT 0,
  FOREIGN KEY (test_id) REFERENCES tests(test_id),
  FOREIGN KEY (student_id) REFERENCES students(student_id)
) ENGINE=InnoDB;

CREATE TABLE attempt_questions (
  attempt_question_id INT AUTO_INCREMENT PRIMARY KEY,
  attempt_id INT NOT NULL,
  question_id INT NOT NULL,
  points DECIMAL(5,2) NOT NULL DEFAULT 1.00,
  UNIQUE (attempt_id, question_id),
  FOREIGN KEY (attempt_id) REFERENCES test_attempts(attempt_id),
  FOREIGN KEY (question_id) REFERENCES questions(question_id)
) ENGINE=InnoDB;

CREATE TABLE attempt_answers (
  attempt_answer_id INT AUTO_INCREMENT PRIMARY KEY,
  attempt_question_id INT NOT NULL,
  answer_id INT NOT NULL,
  UNIQUE (attempt_question_id, answer_id),
  FOREIGN KEY (attempt_question_id) REFERENCES attempt_questions(attempt_question_id),
  FOREIGN KEY (answer_id) REFERENCES answers(answer_id)
) ENGINE=InnoDB;

-- Дані
INSERT INTO subjects (name) VALUES ('Бази даних'), ('Мережі');
INSERT INTO topics (subject_id, name) VALUES (1,'Нормалізація'), (1,'SQL'), (2,'IP-адресація');
INSERT INTO difficulty_levels (name) VALUES ('Easy'), ('Medium');
INSERT INTO authors (full_name) VALUES ('Максим К');
INSERT INTO students (full_name, group_name) VALUES ('Максим К','І-23');

INSERT INTO questions (topic_id, level_id, author_id, question_text) VALUES
(1,1,1,'Що таке нормалізація бази даних?'),
(2,1,1,'Який SQL оператор використовується для вибірки даних?');

INSERT INTO answers (question_id, answer_text, is_correct) VALUES
(1,'Процес усунення надлишковості даних',1),
(1,'Процес резервного копіювання',0),
(2,'SELECT',1),
(2,'INSERT',0);

INSERT INTO tests (title, subject_id, created_by) VALUES ('Тест з БД',1,1);
INSERT INTO test_questions (test_id, question_id, points) VALUES (1,1,1.00),(1,2,1.00);