DELETE FROM t_user WHERE id > 1000;
DELETE FROM t_user_email;
DELETE FROM t_email;

INSERT INTO t_user (id, login, created_by, created_date) 
       VALUES (1001, 'testuser', '', NOW());

INSERT INTO t_email (id, email_address)
       VALUES (1000, 'test@nowhere.com');

INSERT INTO t_user_email (id, user_id, email_id, activated)
       VALUES (1000, 1001, 1000, NOW());

