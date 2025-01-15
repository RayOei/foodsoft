
/*
 * -----------------------------------------------------------------------------------------------------
 * !! AFTER RUNNING RAKE MIGRATION -- 
 * ------------------------------------------------------------------------------------------------------
 * Corrections AFTER the running of rake:migrate, this should align the migrated database in full to v4.9
 * ------------------------------------------------------------------------------------------------------- 
 *  
 * 
 * TODO automate further
 * 
 * 
 */


/*
 * !!! => EXECUTE MANUALLY !!!
 * 
 * These will only contain the final columns, therefore at the end
 * 
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
USE foodsoft_adam;

ALTER table foodsoft_adam.stock_events 
	CHARACTER SET utf8mb4,
	COLLATE = utf8mb4_general_ci;

ALTER TABLE foodsoft_adam.`articles` MODIFY `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT '' NOT NULL;
ALTER TABLE foodsoft_adam.`articles` MODIFY `unit` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT '' NOT NULL;
ALTER TABLE foodsoft_adam.`articles` MODIFY `note` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE foodsoft_adam.`articles` MODIFY `manufacturer` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE foodsoft_adam.`articles` MODIFY `origin` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE foodsoft_adam.`articles` MODIFY `order_number` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE foodsoft_adam.`articles` MODIFY `type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE foodsoft_adam.`article_categories` MODIFY `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT '' NOT NULL;
ALTER TABLE foodsoft_adam.`article_categories` MODIFY `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE foodsoft_adam.`financial_transactions` MODIFY `note` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL;
ALTER TABLE foodsoft_adam.`groups` MODIFY `type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT '' NOT NULL;
ALTER TABLE foodsoft_adam.`groups` MODIFY `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT '' NOT NULL;
ALTER TABLE foodsoft_adam.`groups` MODIFY `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE foodsoft_adam.`groups` MODIFY `contact_person` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE foodsoft_adam.`groups` MODIFY `contact_phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE foodsoft_adam.`groups` MODIFY `contact_address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE foodsoft_adam.`groups` MODIFY `stats` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE foodsoft_adam.`invites` MODIFY `token` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT '' NOT NULL;
ALTER TABLE foodsoft_adam.`invites` MODIFY `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT '' NOT NULL;
ALTER TABLE foodsoft_adam.`invoices` MODIFY `number` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE foodsoft_adam.`invoices` MODIFY `note` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE foodsoft_adam.`messages` MODIFY `subject` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL;
ALTER TABLE foodsoft_adam.`orders` MODIFY `note` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE foodsoft_adam.`orders` MODIFY `state` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT 'open';
ALTER TABLE foodsoft_adam.`order_comments` MODIFY `text` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE foodsoft_adam.`pages` MODIFY `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE foodsoft_adam.`pages` MODIFY `body` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE foodsoft_adam.`pages` MODIFY `permalink` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE foodsoft_adam.`page_versions` MODIFY `body` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE foodsoft_adam.`schema_migrations` MODIFY `version` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL;
ALTER TABLE foodsoft_adam.`settings` MODIFY `var` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL;
ALTER TABLE foodsoft_adam.`settings` MODIFY `value` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE foodsoft_adam.`settings` MODIFY `thing_type` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE foodsoft_adam.`stock_events` MODIFY `note` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE foodsoft_adam.`stock_events` MODIFY `type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL;
ALTER TABLE foodsoft_adam.`suppliers` MODIFY `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT '' NOT NULL;
ALTER TABLE foodsoft_adam.`suppliers` MODIFY `address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT '' NOT NULL;
ALTER TABLE foodsoft_adam.`suppliers` MODIFY `phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT '' NOT NULL;
ALTER TABLE foodsoft_adam.`suppliers` MODIFY `phone2` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE foodsoft_adam.`suppliers` MODIFY `fax` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE foodsoft_adam.`suppliers` MODIFY `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE foodsoft_adam.`suppliers` MODIFY `url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE foodsoft_adam.`suppliers` MODIFY `contact_person` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE foodsoft_adam.`suppliers` MODIFY `customer_number` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE foodsoft_adam.`suppliers` MODIFY `delivery_days` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE foodsoft_adam.`suppliers` MODIFY `order_howto` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE foodsoft_adam.`suppliers` MODIFY `note` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE foodsoft_adam.`suppliers` MODIFY `min_order_quantity` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE foodsoft_adam.`suppliers` MODIFY `shared_sync_method` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE foodsoft_adam.`tasks` MODIFY `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT '' NOT NULL;
ALTER TABLE foodsoft_adam.`users` MODIFY `nick` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE foodsoft_adam.`users` MODIFY `password_hash` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT '' NOT NULL;
ALTER TABLE foodsoft_adam.`users` MODIFY `password_salt` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT '' NOT NULL;
ALTER TABLE foodsoft_adam.`users` MODIFY `first_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT '' NOT NULL;
ALTER TABLE foodsoft_adam.`users` MODIFY `last_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT '' NOT NULL;
ALTER TABLE foodsoft_adam.`users` MODIFY `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT '' NOT NULL;
ALTER TABLE foodsoft_adam.`users` MODIFY `phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE foodsoft_adam.`users` MODIFY `reset_password_token` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;


-- --------------------------------------------------------------------------------------------------
-- !! CORRECTIONS as some migration changes are not applied?

ALTER TABLE foodsoft_adam.active_storage_blobs 
	MODIFY `service_name` varchar(255) NOT NULL;
ALTER TABLE foodsoft_adam.supplier_categories 
	MODIFY `financial_transaction_class_id` int(11) DEFAULT NULL;
ALTER TABLE foodsoft_adam.suppliers 
	MODIFY `supplier_category_id` int(11) DEFAULT NULL;
-- --------------------------------------------------------------------------------------------------

