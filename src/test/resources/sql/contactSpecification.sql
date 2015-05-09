INSERT INTO t_contact (id, last_name) values (1, 'test');
INSERT INTO t_contact (id, last_name) values (2, 'test2');
INSERT INTO t_contact (id, last_name) values (3, 'test3');
INSERT INTO t_contact (id, last_name) values (4, 'test3');

INSERT INTO t_annual(id, contact_id, year, membership, rr, iter) values (1, 2, 2001, 1, 0, false);
INSERT INTO t_annual(id, contact_id, year, membership, rr, iter) values (2, 2, 2003, 1, 0, false);
INSERT INTO t_annual(id, contact_id, year, membership, rr, iter) values (3, 3, 2002, 0, 0, false);
INSERT INTO t_annual(id, contact_id, year, membership, rr, iter) values (4, 4, 2001, 2, 0, false);
