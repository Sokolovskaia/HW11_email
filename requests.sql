CREATE TABLE users
(
    user_id INTEGER PRIMARY KEY AUTOINCREMENT,
    surname TEXT NOT NULL,
    name    TEXT NOT NULL,
    email   TEXT NOT NULL UNIQUE CHECK (email like '%@%')
);

CREATE TABLE letters
(
    letter_id      INTEGER PRIMARY KEY AUTOINCREMENT,
    sender_id      INTEGER NOT NULL,                                        --отправитель
    recipient_id   INTEGER,                                                 --получатель
    topic          TEXT,                                                    --тема письма
    letter_body    TEXT,                                                    --текст письма
    letter_date    NUMERIC,                                                 --дата
    reading_status TEXT CHECK ( reading_status IN ('+', '-')) DEFAULT '+',  --статус должен меняться в зависимости от того, кто просматривает
    draft          TEXT CHECK ( reading_status IN ('+', '-')),              --черновик
    parent_letter  INTEGER                                    DEFAULT NULL, --id письма, на которо отвечает текущее письмо
    FOREIGN KEY (sender_id) REFERENCES users (user_id),
    FOREIGN KEY (recipient_id) REFERENCES users (user_id),
    FOREIGN KEY (parent_letter) REFERENCES letters (letter_id)
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
VALUES ('1', '2', 'Письмо 1', 'Как дела?', '01.01.2010', '-'),
       ('1', '4', 'Письмо 2', 'Жду тебя', '01.02.2010', '-'),
       ('1', '3', 'Письмо 3', 'Ты где', '10.03.2010', '-'),
       ('3', '1', 'Письмо 4', 'Приходи', '18.04.2010', '-'),
       ('4', '1', 'Письмо 5', 'Начать работу', '25.05.2010', '-'),
       ('4', '3', 'Отчет', 'Отчет готов?', '01.06.2010', '-'),
       ('4', NULL, 'Тест', 'Написать текст', '01.07.2010', '+'),
       ('4', NULL, 'Тест еще', 'Написать еще', '02.07.2010', '+');

INSERT INTO letters (sender_id, recipient_id, topic, letter_body, letter_date, draft, parent_letter)
VALUES ('3', '4', 'RE: Отчет', 'Сейчас отправлю', '02.06.2010', '-', '6'),
       ('4', '3', 'RE: RE: Отчет', 'Спасибо, получил', '03.06.2010', '-', '7');



INSERT INTO letters (sender_id, recipient_id, topic, letter_body, letter_date, reading_status, draft)
VALUES ('5', '6', 'Письмо 6', 'Жду ответ', '01.08.2010', '-', '-'),
       ('6', '4', 'Письмо 7', 'Отправлена задача', '10.08.2010', '-', '-'),
       ('1', '2', 'Письмо 8', 'Товар пришел', '15.08.2010', '-', '-'),
       ('2', '3', 'Письмо 9', 'Самолет завтра', '17.08.2010', '-', '-'),
       ('5', '1', 'Письмо 10', 'Совещание', '18.08.2010', '-', '-'),
       ('1', '5', 'Письмо 11', 'Да', '01.09.2010', '-', '+'),
       ('5', NULL, 'Письмо 12', 'Нет', '10.09.2010', '-', '+'),
       ('2', '3', 'Письмо 13', 'Добрый день', '15.09.2010', '-', '+'),
       ('4', '3', 'Письмо 14', 'Как', '17.09.2010', '-', '+'),
       ('4', '1', 'Письмо 15', 'Что', '18.09.2010', '-', '+');


----------------- REQUESTS -------------------------------

SELECT l.letter_date    Date, --просматривать входящие непрочитанные письма
       l.reading_status Read,
       u.email          Sender_address,
       u.surname        Sender_surname,
       l.topic          Topic,
       l.letter_body    Text,
       l.parent_letter  Previous_letter
FROM letters l,
     users u
WHERE l.recipient_id = '1'
  AND l.sender_id = user_id
  AND l.reading_status = '-'
  AND l.draft = '-'
ORDER BY l.letter_id DESC;


SELECT l.letter_date    Date, -- просматривать входящие письма (по 50 штук)
       l.reading_status Read,
       u.email          Sender_address,
       u.surname        Sender_surname,
       l.topic          Topic,
       l.letter_body    Text,
       l.parent_letter  Previous_letter
FROM letters l,
     users u
WHERE l.recipient_id = '3'
  AND l.sender_id = user_id
  AND l.draft = '-'
ORDER BY l.letter_id DESC
LIMIT 50;

SELECT l.letter_date   Date, -- просматривать исходящие письма (по 50 штук)
       u.email         Recipient_address,
       u.surname       Recipient_surname,
       l.topic         Topic,
       l.letter_body   Text,
       l.parent_letter Previous_letter
FROM letters l,
     users u
WHERE l.sender_id = '1'
  AND l.recipient_id = user_id
  AND l.draft = '-'
ORDER BY l.letter_id DESC
LIMIT 50;


SELECT l.letter_date   Date, -- просматривать черновики
       u.email         Recipient_address,
       u.surname       Recipient_surname,
       l.topic         Topic,
       l.letter_body   Text,
       l.parent_letter Previous_letter
FROM letters l
         LEFT JOIN users u on l.recipient_id = u.user_id
WHERE l.sender_id = '4'
  AND l.draft = '+'
ORDER BY l.letter_id DESC
LIMIT 50;