/*
 * Dec 2024
 * 
 * 
 * Migration script for the FoodcoopAmsterdam fork back to the upstream Foodsoft version 4.9 
 * 
 * This scripts removes and alters all tables/columns to fit the upstream state _before_ its migration scripts run
 * This will prevent ActiveRecord from updating schema.rb with the FCA fork changes.
 * 
 * =>>>>
 * =>>>> 
 * =>>>> !!! BE AWARE of the final generated SQL of this script which needs to be executed too !!!
 * =>>>> 
 * =>>>>
 * 
 * After running this script execute the `bin/rails db:migrate RAILS_ENV=<env> command to run the migration scripts
 *
 * SUMMARY APPROACH
 * ----------------
 *
 * - Run _this_ script (which initially is empty) ;-)
 * - Run rake migration 
 * -- Errors ?: Add actions to fix issues in _this_ script 
 * -- Success ?: 
 * 		-- compare schemas from clean development db and resulting db
 * 			-- Differences ?: add actions to _this_ script
 * 		-- compare schemas from clean development and resulting db
 * 			-- Differences ?: add actions to _this_ script
 * - Rinse - restore original foodsoft_adam db
 * - Repeat until no meaningfull differences are found
 * - Start application and check if all runs as expected
 * --------------------------------------------------------------------------------------------
 * 
 * !!!!!! CHECK and DOUBLE CHECK
 * 
 * When done: compare the newly created schema with a clean v4.9 to be sure they align. Correct when needed and rerun the script on a fork DB
 * 
 * Some tricks, run `mariadb-dump --compact --add-drop-table --no-data --quick foodsoft_db > fs_db.sql` for both this newly migrated DB and the clean v49 one.
 * Use a file compare to check the difference. 
 * The only differences which can be safely ignored are the `ENGINE=InnoDB AUTO_INCREMENT=<42>` ones as they are expected.   
 * 
 * 
 * TODO
 * - CHECK all dropped columns. Is it safe or are alternatives needed?
 * 	-- articles -> fc_note, info_url
 *  -- financial_transactions -> payment-* columns
 * - GROUP_ORDERS column DEPOSIT has values but does not exist in v49. A new column TRANSFER is introduced -> same funtion? Something else needed?
 * - DELIVERIES is removed. No alternative?? Relation to STOCK_EVENTS?
 * - STOCK_CHANGES has DELIVERY_ID removed. Similar function as STOCK_EVENT_ID? -> ALTER instead of DROP?? Something else?
 * - STOCK_TAKINGS is removed. Similar function as STOCK_EVENTS? -> ALTER instead of DROP?? Something else?
 * RESOLUTION
 * - ARTICLE_PRICES `article_id` which are NULL and are mandatory in v49 => set to default '0'
 * - invoice -> order_id, delivery_id => retained, will me migrated by v4.9 scripts
 *   
 * 
 * ????? active_storage_attachments different from clean install. How??
 * ????? FK defs after migration but not in clean install. How?
 * ?????? BUG in schema for STOCK_EVENTS collating on swedish. Correct for table AND type column
 * */
 
-- Explicit to force error when on the wrong connection
USE foodsoft_adam;

-- ---------------

START TRANSACTION;

-- ---------------

ALTER DATABASE foodsoft_adam
	CHARACTER SET utf8mb4
	COLLATE = utf8mb4_general_ci;

-- adyen_notifications
drop table if exists foodsoft_adam.adyen_notifications ;

-- article_categories

ALTER table foodsoft_adam.article_categories
	CHARACTER SET utf8mb4,
	COLLATE = utf8mb4_general_ci;

ALTER TABLE article_categories 
	DROP COLUMN IF EXISTS scope, 
	DROP COLUMN IF EXISTS ancestry,
	DROP COLUMN IF EXISTS position,
	DROP INDEX IF EXISTS index_article_categories_on_scope,
	DROP INDEX IF EXISTS  index_article_categories_on_ancestry,
	DROP INDEX IF EXISTS  index_article_categories_on_position;
	
-- article_prices

ALTER table foodsoft_adam.article_prices
	CHARACTER SET utf8mb4,
	COLLATE = utf8mb4_general_ci;

-- TODO MODIFY sets NOT NULL
update foodsoft_adam.article_prices 
	set article_id=0 where article_id is null;

-- TODO existing article_id == NULL 
ALTER TABLE foodsoft_adam.article_prices 
	MODIFY COLUMN article_id int(11) NOT NULL;

-- articles

ALTER table foodsoft_adam.articles
	CHARACTER SET utf8mb4,
	COLLATE = utf8mb4_general_ci;

ALTER TABLE foodsoft_adam.articles
	ADD max_quantity integer,
	DROP COLUMN IF EXISTS info_url, 
	DROP COLUMN IF EXISTS fc_note, 
	MODIFY COLUMN quantity int(11) DEFAULT 0; 

-- assignments

ALTER table foodsoft_adam.assignments
	CHARACTER SET utf8mb4,
	COLLATE = utf8mb4_general_ci;

-- deliveries
 ALTER table foodsoft_adam.stock_takings
	CHARACTER SET utf8mb4,
	COLLATE = utf8mb4_general_ci;

-- drop table if exists deliveries ;

-- financial_transactions

ALTER table foodsoft_adam.financial_transactions
	CONVERT TO 
		CHARACTER SET utf8mb4,
		COLLATE = utf8mb4_general_ci;

ALTER TABLE foodsoft_adam.financial_transactions
	DROP COLUMN IF EXISTS payment_acct_number, 
	DROP COLUMN IF EXISTS payment_acct_name, 
	DROP COLUMN IF EXISTS payment_info, 
	MODIFY COLUMN ordergroup_id int(11) DEFAULT NULL, 
	MODIFY COLUMN updated_on timestamp NULL DEFAULT NULL; 

-- group_order_article_quantities

ALTER table foodsoft_adam.group_order_article_quantities
	CHARACTER SET utf8mb4,
	COLLATE = utf8mb4_general_ci;

ALTER TABLE foodsoft_adam.group_order_article_quantities
	DROP COLUMN IF EXISTS financial_transaction_id, 
	DROP COLUMN IF EXISTS confirmed;
	
-- group_order_articles
ALTER table foodsoft_adam.group_order_articles
	CHARACTER SET utf8mb4,
	COLLATE = utf8mb4_general_ci;

-- group_orders

ALTER table foodsoft_adam.group_orders
	CHARACTER SET utf8mb4,
	COLLATE = utf8mb4_general_ci;

ALTER TABLE foodsoft_adam.group_orders
	DROP COLUMN IF EXISTS net_price,
	DROP COLUMN IF EXISTS gross_price,
	DROP COLUMN IF EXISTS deposit,
	MODIFY COLUMN ordergroup_id int(11) DEFAULT NULL;

-- groups

ALTER table foodsoft_adam.groups
	CHARACTER SET utf8mb4,
	COLLATE = utf8mb4_general_ci;

ALTER TABLE foodsoft_adam.groups
	DROP COLUMN IF EXISTS approved,
	DROP COLUMN IF EXISTS scope,
	DROP COLUMN IF EXISTS price_markup_key,
	MODIFY COLUMN account_balance decimal(12,2) NOT NULL DEFAULT 0.00;

-- invites

ALTER table foodsoft_adam.invites
	CHARACTER SET utf8mb4,
	COLLATE = utf8mb4_general_ci;

-- SET first before contraint is added
update foodsoft_adam.invites 
	set group_id=0 where group_id is null; 

ALTER TABLE foodsoft_adam.invites
	DROP COLUMN IF EXISTS scope,
	DROP INDEX IF EXISTS index_invites_on_scope,
	MODIFY COLUMN group_id int(11) DEFAULT 0 NOT NULL;

-- invoices

ALTER table foodsoft_adam.invoices
	CHARACTER SET utf8mb4,
	COLLATE = utf8mb4_general_ci;

 /** ALTER TABLE foodsoft_adam.invoices
	-- DROP COLUMN IF EXISTS delivery_id,
	-- DROP COLUMN IF EXISTS order_id,
	-- DROP INDEX IF EXISTS index_invoices_on_delivery;
*/
-- memberships
ALTER table foodsoft_adam.memberships
	CHARACTER SET utf8mb4,
	COLLATE = utf8mb4_general_ci;

-- messages

ALTER table foodsoft_adam.messages
	CHARACTER SET utf8mb4,
	COLLATE = utf8mb4_general_ci;

ALTER TABLE foodsoft_adam.messages
	-- DROP COLUMN IF EXISTS recipients_ids,
	-- DROP COLUMN IF EXISTS body,
	-- DROP COLUMN IF EXISTS email_state,
	DROP COLUMN IF EXISTS scope,
	DROP INDEX IF EXISTS index_messages_on_scope;

-- order_articles

ALTER table foodsoft_adam.order_articles
	CHARACTER SET utf8mb4,
	COLLATE = utf8mb4_general_ci;

ALTER TABLE foodsoft_adam.order_articles
	MODIFY COLUMN units_billed decimal(8,3) DEFAULT NULL,
    MODIFY COLUMN units_received decimal(8,3) DEFAULT NULL;

-- order_comments

ALTER table foodsoft_adam.order_comments
	CHARACTER SET utf8mb4,
	COLLATE = utf8mb4_general_ci;

-- orders

ALTER table foodsoft_adam.orders
	CHARACTER SET utf8mb4,
	COLLATE = utf8mb4_general_ci;

ALTER TABLE foodsoft_adam.orders
	-- ADD invoice_id int DEFAULT NULL, 
	-- DROP COLUMN IF EXISTS pickup,
	DROP COLUMN IF EXISTS scope,
	DROP INDEX IF EXISTS index_orders_on_scope;

-- page_versions

ALTER table foodsoft_adam.page_versions
	CHARACTER SET utf8mb4,
	COLLATE = utf8mb4_general_ci;

-- pages

ALTER table foodsoft_adam.pages
	CHARACTER SET utf8mb4,
	COLLATE = utf8mb4_general_ci;

-- periodic_task_groups

ALTER table foodsoft_adam.periodic_task_groups
	CHARACTER SET utf8mb4,
	COLLATE = utf8mb4_general_ci;

-- schema_migrations

ALTER table foodsoft_adam.schema_migrations
	CHARACTER SET utf8mb4,
	COLLATE = utf8mb4_general_ci;

ALTER table foodsoft_adam.schema_migrations
	DROP KEY IF EXISTS unique_schema_migrations,
	ADD PRIMARY KEY(version); 

-- settings

ALTER table foodsoft_adam.settings
	CHARACTER SET utf8mb4,
	COLLATE = utf8mb4_general_ci;

-- stock_changes

ALTER table foodsoft_adam.stock_changes
	CHARACTER SET utf8mb4,
	COLLATE = utf8mb4_general_ci;

/*
 * 
 *
ALTER table foodsoft_adam.stock_changes
	DROP COLUMN IF EXISTS delivery_id,
	DROP COLUMN IF EXISTS stock_taking_id,
	DROP INDEX IF EXISTS index_stock_changes_on_delivery_id;
*/

-- stock_takings
ALTER table foodsoft_adam.stock_takings
	CHARACTER SET utf8mb4,
	COLLATE = utf8mb4_general_ci;

-- TODO Is stock_takings omgezet in stock_events??
-- DROP TABLE IF EXISTS foodsoft_adam.stock_takings;

-- suppliers

ALTER table foodsoft_adam.suppliers
	CHARACTER SET utf8mb4,
	COLLATE = utf8mb4_general_ci;

ALTER table foodsoft_adam.suppliers
	-- MODIFY COLUMN supplier_category_id int(11) DEFAULT NULL,
	DROP COLUMN IF EXISTS article_info_url,
	DROP COLUMN IF EXISTS scope,
	DROP COLUMN IF EXISTS use_tolerance,
	DROP INDEX IF EXISTS index_suppliers_on_scope;
	
-- tasks

ALTER table foodsoft_adam.tasks
	CHARACTER SET utf8mb4,
	COLLATE = utf8mb4_general_ci;

ALTER table foodsoft_adam.tasks
	DROP COLUMN IF EXISTS scope,
	DROP INDEX IF EXISTS index_tasks_on_scope,
	MODIFY COLUMN description text DEFAULT NULL;

-- users

ALTER table foodsoft_adam.users
	CHARACTER SET utf8mb4,
	COLLATE = utf8mb4_general_ci;

COMMIT;


/*
 *  
 * HELPER Execute generated SQL for correcting collation
 * 
 * !!! => EXECUTE MANUALLY !!!
 * 
 * These will only contain the final columns, therefore at the end
 *  
 * TODO automate further
 * 
 * */

-- -----------------------------------------------------------------------------------------------


/*
 *  HELPER to generate modify for collating. 
 * 
 * !!! Check text type as those are modified with an unwanted type/size. 
 * !!! Eg. text types from FCN may be modified to mediumtext type!
 * 

SELECT CONCAT('ALTER TABLE `', table_name,
        '` MODIFY `', column_name, '` ', DATA_TYPE, '(', CHARACTER_MAXIMUM_LENGTH, 
        ') CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci',
        (CASE WHEN COLUMN_DEFAULT IS NOT NULL THEN CONCAT(' DEFAULT ', COLUMN_DEFAULT) ELSE '' END),
        (CASE WHEN IS_NULLABLE = 'NO' THEN ' NOT NULL' ELSE '' END), ';')
FROM information_schema.COLUMNS 
WHERE TABLE_SCHEMA = 'foodsoft_adam'
	AND COLLATION_NAME IS NOT NULL
	AND  COLLATION_NAME != 'utf8mb4_general_ci'
ORDER by table_name;

*/

-- Final set used (do check!!)
/**
 * 
 *
ALTER TABLE `articles` MODIFY `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT '' NOT NULL;
ALTER TABLE `articles` MODIFY `unit` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT '' NOT NULL;
ALTER TABLE `articles` MODIFY `note` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE `articles` MODIFY `manufacturer` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE `articles` MODIFY `origin` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE `articles` MODIFY `order_number` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE `articles` MODIFY `type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE `article_categories` MODIFY `namfe` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT '' NOT NULL;
ALTER TABLE `article_categories` MODIFY `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE `deliveries` MODIFY `note` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
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
ALTER TABLE `users` MODIFY `nick` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE `users` MODIFY `password_hash` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT '' NOT NULL;
ALTER TABLE `users` MODIFY `password_salt` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT '' NOT NULL;
ALTER TABLE `users` MODIFY `first_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT '' NOT NULL;
ALTER TABLE `users` MODIFY `last_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT '' NOT NULL;
ALTER TABLE `users` MODIFY `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT '' NOT NULL;
ALTER TABLE `users` MODIFY `phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE `users` MODIFY `reset_password_token` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;

*/

