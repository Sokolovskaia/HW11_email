CREATE TABLE users
(
    id      INTEGER PRIMARY KEY AUTOINCREMENT,
    surname TEXT NOT NULL,
    name    TEXT NOT NULL,
    email   TEXT NOT NULL UNIQUE CHECK (email like '%@%')
);

CREATE TABLE letters
(
    letter_id        INTEGER PRIMARY KEY AUTOINCREMENT,
    sender_id        INTEGER NOT NULL,                                       --отправитель
    recipient_id     INTEGER,                                                --получатель
    topic            TEXT,                                                   --тема письма
    letter_body      TEXT,                                                   --текст письма
    letter_date      NUMERIC,                                                --дата
    reading_status   NUMERIC CHECK ( reading_status IN (1, 0)) DEFAULT 1,    --статус должен меняться в зависимости от того, кто просматривает
    draft            NUMERIC CHECK ( reading_status IN (1, 0)),              --черновик
    parent_letter_id INTEGER                                   DEFAULT NULL, --id письма, на которо отвечает текущее письмо
    FOREIGN KEY (sender_id) REFERENCES users (id),
    FOREIGN KEY (recipient_id) REFERENCES users (id),
    FOREIGN KEY (parent_letter_id) REFERENCES letters (letter_id)
);

----------------------- TEST_DATA --------------------

INSERT INTO users (surname, name, email)
VALUES ('Скворцов', 'Александр', 'skvorec@rmail.ru'),
       ('Голубева', 'Нина', 'golubeva@rmail.ru'),
       ('Кукушкин', 'Петр', 'kukushka@rmail.ru'),
       ('Орлова', 'Надежда', 'orlova@rmail.ru'),
       ('Воробьев', 'Олег', 'vorobey@rmail.ru'),
       ('Ястребова', 'Дарья', 'yastrebova@rmail.ru');



INSERT INTO letters (sender_id, recipient_id, topic, letter_body, letter_date, draft)
VALUES ('1', '2', 'Письмо 1', 'Как дела?', '01.01.2010', 0),
       ('1', '4', 'Письмо 2', 'Жду тебя', '01.02.2010', 0),
       ('1', '3', 'Письмо 3', 'Ты где', '10.03.2010', 0),
       ('3', '1', 'Письмо 4', 'Приходи', '18.04.2010', 0),
       ('4', '1', 'Письмо 5', 'Начать работу', '25.05.2010', 0),
       ('4', '3', 'Отчет', 'Отчет готов?', '01.06.2010', 0),
       ('4', NULL, 'Тест', 'Написать текст', '01.07.2010', 1),
       ('4', NULL, 'Тест еще', 'Написать еще', '02.07.2010', 1);

INSERT INTO letters (sender_id, recipient_id, topic, letter_body, letter_date, draft, parent_letter_id)
VALUES ('3', '4', 'RE: Отчет', 'Сейчас отправлю', '02.06.2010', 0, '6'),
       ('4', '3', 'RE: RE: Отчет', 'Спасибо, получил', '03.06.2010', 0, '7');



INSERT INTO letters (sender_id, recipient_id, topic, letter_body, letter_date, reading_status, draft)
VALUES ('5', '6', 'Письмо 6', 'Жду ответ', '01.08.2010', 0, 0),
       ('6', '4', 'Письмо 7', 'Отправлена задача', '10.08.2010', 0, 0),
       ('1', '2', 'Письмо 8', 'Товар пришел', '15.08.2010', 0, 0),
       ('2', '3', 'Письмо 9', 'Самолет завтра', '17.08.2010', 0, 0),
       ('5', '1', 'Письмо 10', 'Совещание', '18.08.2010', 0, 0),
       ('1', '5', 'Письмо 11', 'Да', '01.09.2010', 0, 1),
       ('5', NULL, 'Письмо 12', 'Нет', '10.09.2010', 0, 1),
       ('2', '3', 'Письмо 13', 'Добрый день', '15.09.2010', 0, 1),
       ('4', '3', 'Письмо 14', 'Как', '17.09.2010', 0, 1),
       ('4', '1', 'Письмо 15', 'Что', '18.09.2010', 0, 1);


----------------- REQUESTS -------------------------------

SELECT l.letter_date      Date, --просматривать входящие непрочитанные письма
       l.reading_status   Read,
       u.email            Sender_address,
       u.surname          Sender_surname,
       l.topic            Topic,
       l.letter_body      Text,
       l.parent_letter_id Previous_letter
FROM letters l,
     users u
WHERE l.recipient_id = '1'
  AND l.sender_id = u.id
  AND l.reading_status = 0
  AND l.draft = 0
ORDER BY l.letter_id DESC;


SELECT l.letter_date      Date, -- просматривать входящие письма (по 50 штук)
       l.reading_status   Read,
       u.email            Sender_address,
       u.surname          Sender_surname,
       l.topic            Topic,
       l.letter_body      Text,
       l.parent_letter_id Previous_letter
FROM letters l,
     users u
WHERE l.recipient_id = '3'
  AND l.sender_id = u.id
  AND l.draft = 0
ORDER BY l.letter_id DESC
LIMIT 50;

SELECT l.letter_date      Date, -- просматривать исходящие письма (по 50 штук)
       u.email            Recipient_address,
       u.surname          Recipient_surname,
       l.topic            Topic,
       l.letter_body      Text,
       l.parent_letter_id Previous_letter
FROM letters l,
     users u
WHERE l.sender_id = '1'
  AND l.recipient_id = u.id
  AND l.draft = 0
ORDER BY l.letter_id DESC
LIMIT 50;


SELECT l.letter_date      Date, -- просматривать черновики
       u.email            Recipient_address,
       u.surname          Recipient_surname,
       l.topic            Topic,
       l.letter_body      Text,
       l.parent_letter_id Previous_letter
FROM letters l
         LEFT JOIN users u on l.recipient_id = u.id
WHERE l.sender_id = '4'
  AND l.draft = 1
ORDER BY l.letter_id DESC
LIMIT 50;