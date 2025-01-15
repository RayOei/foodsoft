 
CREATE DATABASE foodsoft_adam;

-- CREATE test admin user

insert into foodsoft_adam.users (nick, password_hash, password_salt, first_name, last_name, email, created_on)
   select "fcn_admin", password_hash, password_salt, first_name, last_name, email, NOW() 
      from foodsoft_development.users b 
      where b.id = 1; 
select id from users where nick = 'fcn_admin';

insert into foodsoft_adam.memberships (user_id, group_id) values (893, 1); -- Lijstverwerkers / System admin
insert into foodsoft_adam.memberships (user_id, group_id) values (893, 533); -- Uitgiftecoördinatoren
insert into foodsoft_adam.memberships (user_id, group_id) values (893, 534); -- Bestelteam
insert into foodsoft_adam.memberships (user_id, group_id) values (893, 536); -- Bestuur
insert into foodsoft_adam.memberships (user_id, group_id) values (893, 801); -- Systeem
insert into foodsoft_adam.memberships (user_id, group_id) values (893, 820); -- Ledenadministratie

-- --------------------------------------------------------------------------------------------------
-- OPTIONAL CLEANING BE CAREFULL!!!
-- --------------------------------------------------------------------------------------------------

-- Search / verify
select * from users where deleted_at is not null;
select g.*, m.* from groups g join memberships m on m.group_id = g.id;
select g.* from groups g where id not in (select group_id from memberships);
-- Special groups
select * from groups where deleted_at is not null and type = 'Workgroup';
-- Households
select * from groups where deleted_at is not null and type = 'Ordergroup' order by name;

-- select * from foodsoft_fcn.groups where deleted_at is null and approved=0; >> approved doesn't seem to have a function for FCN

select ap.*, ar.* from article_prices ap inner join articles ar on ap.article_id = ar.id and ar.deleted_at is null and supplier_id > 14;
select * from articles a where deleted_at is not null;

-- ------------------------------------------------------------------------------------------------------------------------------------
-- DELETE
-- ------------------------------------------------------------------------------------------------------------------------------------
delete from users where deleted_at is not null;
delete from memberships where user_id not in (select id from users where users.id = memberships.user_id);
delete from groups where id not in (select group_id from memberships);
delete from group_orders where ordergroup_id not in (select id from groups);
-- ?? group_order_id =?= ordergroup_id ==> leaves only 2014 records
delete from group_order_articles where group_order_id not in (select id from groups);
delete from group_order_article_quantities where group_order_article_id not in (select id from articles);

delete from articles where deleted_at is not null;
delete from article_prices where article_prices.article_id not in (select id from articles where articles.id = article_prices.article_id); 
-- ------------------------------------------------------------------------------------------------------------------------------------

-- Other HELPERS

select * from article_categories ac where ac.id not in (select DISTINCT article_category_id from articles a);

-- Change column with VARCHAR datatype
SELECT * from information_schema.COLUMNS
WHERE COLLATION_NAME IS NOT NULL AND 
	TABLE_SCHEMA = 'foodsoft_adam'; 

select * from foodsoft_development.users;

/**
 * 
 */
insert into foodsoft_adam.users (nick, password_hash, password_salt, first_name, last_name, email, created_on)
	select "fcn_admin", password_hash, password_salt, first_name, last_name, email, NOW() from foodsoft_development.users b where b.id = 1; 

insert into memberships (user_id, group_id) values (..., 801);

-- --

SELECT *
FROM information_schema.COLUMNS 
WHERE TABLE_SCHEMA = 'foodsoft_adam'
AND DATA_TYPE = 'varchar'
AND COLUMN_DEFAULT IS NOT NULL
AND
(
    CHARACTER_SET_NAME != 'utf8mb4'
    OR
    COLLATION_NAME != 'utf8mb4_general_ci'
);


SELECT CONCAT('ALTER TABLE `', table_name,
        '` MODIFY `', column_name, '` ', 
        DATA_TYPE, 
        (CASE WHEN data_type = 'varchar' THEN CONCAT('(', CHARACTER_MAXIMUM_LENGTH, ')') ELSE '' END), 
		' CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci',
        (CASE WHEN COLUMN_DEFAULT IS NOT NULL THEN CONCAT(' DEFAULT ', COLUMN_DEFAULT) ELSE '' END),
        (CASE WHEN IS_NULLABLE = 'NO' THEN ' NOT NULL' ELSE '' END), ';')
FROM information_schema.COLUMNS 
WHERE TABLE_SCHEMA = 'foodsoft_adam'
	AND COLLATION_NAME IS NOT NULL
ORDER BY table_name;

ALTER TABLE `articles` MODIFY `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT '' NOT NULL;
ALTER TABLE `articles` MODIFY `unit` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT '' NOT NULL;
ALTER TABLE `articles` MODIFY `note` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE `articles` MODIFY `manufacturer` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE `articles` MODIFY `origin` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE `articles` MODIFY `order_number` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE `articles` MODIFY `type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE `article_categories` MODIFY `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT '' NOT NULL;
ALTER TABLE `article_categories` MODIFY `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE `financial_transactions` MODIFY `note` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL;
ALTER TABLE `financial_transactions` MODIFY `payment_method` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE `financial_transactions` MODIFY `payment_plugin` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE `financial_transactions` MODIFY `payment_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE `financial_transactions` MODIFY `payment_currency` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE `financial_transactions` MODIFY `payment_state` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE `groups` MODIFY `type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT '' NOT NULL;
ALTER TABLE `groups` MODIFY `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT '' NOT NULL;
ALTER TABLE `groups` MODIFY `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE `groups` MODIFY `contact_person` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE `groups` MODIFY `contact_phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE `groups` MODIFY `contact_address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE `groups` MODIFY `stats` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE `invites` MODIFY `token` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT '' NOT NULL;
ALTER TABLE `invites` MODIFY `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT '' NOT NULL;
ALTER TABLE `invoices` MODIFY `number` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE `invoices` MODIFY `note` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE `messages` MODIFY `subject` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL;
ALTER TABLE `messages` MODIFY `body` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE `orders` MODIFY `note` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE `orders` MODIFY `state` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT 'open';
ALTER TABLE `order_comments` MODIFY `text` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE `pages` MODIFY `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE `pages` MODIFY `body` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE `pages` MODIFY `permalink` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE `page_versions` MODIFY `body` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE `schema_migrations` MODIFY `version` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL;
ALTER TABLE `settings` MODIFY `var` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL;
ALTER TABLE `settings` MODIFY `value` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE `settings` MODIFY `thing_type` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE `suppliers` MODIFY `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT '' NOT NULL;
ALTER TABLE `suppliers` MODIFY `address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT '' NOT NULL;
ALTER TABLE `suppliers` MODIFY `phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT '' NOT NULL;
ALTER TABLE `suppliers` MODIFY `phone2` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE `suppliers` MODIFY `fax` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE `suppliers` MODIFY `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE `suppliers` MODIFY `url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE `suppliers` MODIFY `contact_person` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE `suppliers` MODIFY `customer_number` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE `suppliers` MODIFY `delivery_days` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE `suppliers` MODIFY `order_howto` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE `suppliers` MODIFY `note` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE `suppliers` MODIFY `min_order_quantity` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE `suppliers` MODIFY `shared_sync_method` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE `tasks` MODIFY `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT '' NOT NULL;
ALTER TABLE `tasks` MODIFY `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE `users` MODIFY `nick` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE `users` MODIFY `password_hash` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT '' NOT NULL;
ALTER TABLE `users` MODIFY `password_salt` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT '' NOT NULL;
ALTER TABLE `users` MODIFY `first_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT '' NOT NULL;
ALTER TABLE `users` MODIFY `last_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT '' NOT NULL;
ALTER TABLE `users` MODIFY `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT '' NOT NULL;
ALTER TABLE `users` MODIFY `phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE `users` MODIFY `reset_password_token` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
