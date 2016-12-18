    -- DROP TABLE IF EXISTS `reason_type`;
    -- DROP TABLE IF EXISTS `reason_type_field`;
    -- DROP TABLE IF EXISTS `reason_field`;
    -- DROP TABLE IF EXISTS `reason`;
    -- DROP TABLE IF EXISTS `action_type`;
    -- DROP TABLE IF EXISTS `action_status`;
    -- DROP TABLE IF EXISTS `action_element`;
    -- DROP TABLE IF EXISTS `action_element_type`;
    -- DROP TABLE IF EXISTS `action`;

drop database if exists `mildred_action`;
create database `mildred_action`;
use `mildred_action`;
    
CREATE TABLE IF NOT EXISTS `dispatch` (
    `id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
    `identifier` VARCHAR(128) NULL DEFAULT NULL,
    `category` VARCHAR(128) NULL DEFAULT NULL,
    `package` VARCHAR(128) NULL DEFAULT NULL,
    `module` VARCHAR(128) NOT NULL,
    `class_name` VARCHAR(128) NULL DEFAULT NULL,
    `func_name` VARCHAR(128) NOT NULL,
    PRIMARY KEY (`id`)
);

CREATE TABLE IF NOT EXISTS `action_type` (
  `id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) NULL DEFAULT NULL,
  `dispatch_id` INT(11) UNSIGNED NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_action_type_dispatch_idx` (`dispatch_id` ASC),
  CONSTRAINT `fk_action_type_dispatch`
    FOREIGN KEY (`dispatch_id`)
    REFERENCES `mildred_introspection`.`dispatch` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);

insert into action_type (name) values ('move'), ('delete'), ('scan'), ('match'), ('retag'), ('consolidate');

CREATE TABLE `action_status` (
    `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
    `name` varchar(255),
    PRIMARY KEY (`id`)
);

insert into action_status (name) values ('proposed'), ('accepted'), ('pending'), ('complete'), ('aborted'), ('canceled');

CREATE TABLE `action_element_type` (
    `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
    `name` varchar(255),
    PRIMARY KEY (`id`)
);

CREATE TABLE `reason_type` (
    `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
	`action_type_id` int(11) unsigned,                  
    `name` varchar(255),
	FOREIGN KEY(`action_type_id`) REFERENCES `action_type` (`id`),
    PRIMARY KEY (`id`)
);

CREATE TABLE `reason_type_field` (
    `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
	`reason_type_id` int(11) unsigned,                  
	`field_name` varchar(255),
    PRIMARY KEY (`id`),
	FOREIGN KEY(`reason_type_id`) REFERENCES `reason_type` (`id`)
);

CREATE TABLE `reason` (
	`id` int(11) unsigned NOT NULL AUTO_INCREMENT,
	`reason_type_id` int(11) unsigned,
	`action_id` int(11) unsigned,
    PRIMARY KEY (`id`),
	FOREIGN KEY(`reason_type_id`) REFERENCES `reason_type` (`id`),
	FOREIGN KEY(`action_id`) REFERENCES `action` (`id`)
);


CREATE TABLE `reason_param` (
	`id` int(11) unsigned NOT NULL AUTO_INCREMENT,
	`reason_id` int(11) unsigned,
	`name` varchar(255),
	PRIMARY KEY (`id`),
	FOREIGN KEY(`reason_id`) REFERENCES `reason` (`id`)
);


CREATE TABLE `action` (
	`id` int(11) unsigned NOT NULL AUTO_INCREMENT,
	`action_type_id` int(11) unsigned,
	`action_status_id` int(11) unsigned,
	`parent_action_id` int(11) unsigned,
    PRIMARY KEY (`id`),
	FOREIGN KEY(`action_type_id`) REFERENCES `action_type` (`id`),
	FOREIGN KEY(`action_status_id`) REFERENCES `action_status` (`id`),
	FOREIGN KEY(`parent_action_id`) REFERENCES `action` (`id`)
);


CREATE TABLE `reason_field` (
    `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
	`action_id` int(11) unsigned,
	`reason_id` int(11) unsigned,
	`reason_type_field_id` int(11) unsigned,
	`value` varchar(255),
    PRIMARY KEY (`id`),
	FOREIGN KEY(`action_id`) REFERENCES `action` (`id`),
	FOREIGN KEY(`reason_id`) REFERENCES `reason` (`id`),
	FOREIGN KEY(`reason_type_field_id`) REFERENCES `reason_type_field` (`id`)
);


CREATE TABLE `action_element` (
	`id` int(11) unsigned NOT NULL AUTO_INCREMENT,
	`action_id` int(11) unsigned,
	`action_element_type_id` int(11) unsigned,
	`value` varchar(255),
    PRIMARY KEY (`id`),
	FOREIGN KEY(`action_id`) REFERENCES `action` (`id`),
	FOREIGN KEY(`action_element_type_id`) REFERENCES `action_element_type` (`id`)
);

