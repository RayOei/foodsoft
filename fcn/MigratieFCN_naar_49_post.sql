
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
WHERE TABLE_SCHEMA = 'foodsoft_adam_v2'
	AND COLLATION_NAME IS NOT NULL
	AND  COLLATION_NAME != 'utf8mb4_general_ci'
ORDER by table_name;
*/

-- Final set used (do check!!)
ALTER table foodsoft_adam_v2.suppliers
	MODIFY COLUMN supplier_category_id int(11) DEFAULT NULL;

ALTER table foodsoft_adam_v2.stock_events 
	CHARACTER SET utf8mb4,
	COLLATE = utf8mb4_general_ci;

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
ALTER TABLE `stock_events` MODIFY `note` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL;
ALTER TABLE `stock_events` MODIFY `type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL;
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


-- --------------------------------------------------------------------------------------------------
-- !! CORRECTIONS AS some migration changes are not applied

ALTER TABLE active_storage_blobs MODIFY `service_name` varchar(255) NOT NULL;
ALTER TABLE supplier_categories MODIFY `financial_transaction_class_id` int(11) NOT NULL;
ALTER TABLE suppliers MODIFY `supplier_category_id` int(11) NOT NULL;
-- --------------------------------------------------------------------------------------------------

