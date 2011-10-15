CREATE OR REPLACE VIEW reports.collectors AS
     SELECT boundaries.name AS country, users.login as username, user.id as user_id, sum(
            CASE
                WHEN locations.status::text = 'new'::text THEN 1
                ELSE 0
            END) AS "New", sum(
            CASE
                WHEN locations.status::text = 'invalid'::text THEN 1
                ELSE 0
            END) AS "Invalid", sum(
            CASE
                WHEN locations.status::text = 'corrected'::text THEN 1
                ELSE 0
            END) AS "Corrected", sum(
            CASE
                WHEN locations.status::text = 'audited'::text THEN 1
                ELSE 0
            END) AS "Audited", sum(
            CASE
                WHEN locations.status::text = 'field_checked'::text THEN 1
                ELSE 0
            END) AS "Field Checked"
       FROM locations
       JOIN users ON users.id = locations.user_id
       LEFT JOIN boundaries ON locations.level_0 = boundaries.id
      GROUP BY boundaries.name, users.login;