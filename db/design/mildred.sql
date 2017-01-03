use mildred;

DROP TABLE IF EXISTS `delimited_file_data`;
DROP TABLE IF EXISTS `delimited_file_info`;
DROP TABLE IF EXISTS `matched`;
DROP TABLE IF EXISTS `matcher_field`;
DROP TABLE IF EXISTS `matcher`;
DROP TABLE IF EXISTS `directory`;
DROP TABLE IF EXISTS `directory_amelioration`;
DROP TABLE IF EXISTS `directory_attribute`;
DROP TABLE IF EXISTS `directory_constant`;
DROP TABLE IF EXISTS `document_category`;
DROP TABLE IF EXISTS `path_hierarchy`;
DROP TABLE IF EXISTS `exclude_directory`;
-- DROP TABLE IF EXISTS `document_metadata`;
DROP TABLE IF EXISTS `document_format`;
DROP TABLE IF EXISTS `document_type`;
DROP TABLE IF EXISTS `file_format`;
DROP TABLE IF EXISTS `file_type`;
-- DROP TABLE IF EXISTS `document`;
DROP TABLE IF EXISTS `file_handler_type`;
DROP TABLE IF EXISTS `file_handler`;

-- CREATE TABLE `document` (
--   `id` varchar(128) NOT NULL,
--   `index_name` varchar(128) NOT NULL,
--   `file_type_id` int(11) unsigned DEFAULT NULL,
--   `doc_type` varchar(64) NOT NULL,
--   `absolute_path` varchar(1024) NOT NULL,
--   `hexadecimal_key` varchar(640) NOT NULL,
--   `effective_dt` datetime DEFAULT NULL,
--   `expiration_dt` datetime NOT NULL DEFAULT '9999-12-31 23:59:59',
--   PRIMARY KEY (`id`),
--   UNIQUE KEY `uk_document` (`index_name`,`hexadecimal_key`)
-- );

CREATE TABLE `file_type` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(25) NOT NULL,
  PRIMARY KEY (`id`)
);

CREATE TABLE IF NOT EXISTS `file_format` (
  `id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `file_type_id` INT(11) UNSIGNED NOT NULL,
  `ext` VARCHAR(5) NOT NULL,
  `name` VARCHAR(128) NOT NULL,
  `active_flag` TINYINT(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  INDEX `fk_file_format_file_type` (`file_type_id` ASC),
  CONSTRAINT `fk_file_format_file_type`
    FOREIGN KEY (`file_type_id`)
    REFERENCES `mildred`.`file_type` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
);

CREATE TABLE `delimited_file_info` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `document_id` varchar(128) NOT NULL,
  `delimiter` varchar(1) NOT NULL,
  `column_count` int(3) NOT NULL,
  PRIMARY KEY (`id`)
);

CREATE TABLE `delimited_file_data` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `delimited_file_id` int(11) unsigned NOT NULL,
  `column_num` int(3) NOT NULL,
  `row_num` int(11) NOT NULL,
  `value` varchar(256),
  INDEX `fk_delimited_file_data_delimited_file_info` (`delimited_file_id` ASC),
  CONSTRAINT `fk_delimited_file_data_delimited_file_info`
    FOREIGN KEY (`delimited_file_id`)
    REFERENCES `delimited_file_info` (`id`),
  PRIMARY KEY (`id`)
);

-- CREATE TABLE `document_metadata` (
--   `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
--   `index_name` varchar(128) CHARACTER SET utf8 NOT NULL,
--   `document_format` varchar(32) NOT NULL,
--   `attribute_name` varchar(128) NOT NULL,
--   `active_flag` tinyint(1) NOT NULL DEFAULT '0',
--   PRIMARY KEY (`id`)
-- );

-- CREATE TABLE IF NOT EXISTS `mildred`.`path_hierarchy` (
--   `id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
--   `index_name` VARCHAR(128) CHARACTER SET 'utf8' NOT NULL,
--   `parent_id` INT(11) UNSIGNED NULL DEFAULT NULL,
--   `path` VARCHAR(767) NOT NULL,
--   `hexadecimal_key` VARCHAR(640) NULL DEFAULT NULL,
--   `effective_dt` DATETIME NULL DEFAULT NULL,
--   `expiration_dt` DATETIME NULL DEFAULT '9999-12-31 23:59:59',
--   PRIMARY KEY (`id`),
--   UNIQUE INDEX `uk_path_hierarchy` (`index_name` ASC, `hexadecimal_key` ASC),
--   INDEX `fk_path_hierarchy_parent` (`parent_id` ASC),
--   CONSTRAINT `fk_path_hierarchy_parent`
--     FOREIGN KEY (`parent_id`)
--     REFERENCES `mildred`.`path_hierarchy` (`id`)
-- );

-- CREATE TRIGGER `path_hierarchy_effective_dt` BEFORE INSERT ON  `path_hierarchy` 
-- FOR EACH ROW SET NEW.effective_dt = IFNULL(NEW.effective_dt, NOW());

-- CREATE TABLE `exclude_directory` (
--   `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
--   `index_name` varchar(128) CHARACTER SET utf8 NOT NULL,
--   `name` varchar(767) NOT NULL,
--   `effective_dt` datetime DEFAULT NULL,
--   `expiration_dt` datetime DEFAULT '9999-12-31 23:59:59',
--   PRIMARY KEY (`id`), 
--   UNIQUE KEY `uk_exclude_directory_name` (`index_name`,`name`)
-- );

CREATE TABLE `directory` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `index_name` varchar(128) CHARACTER SET utf8 NOT NULL,
  `name` varchar(767) NOT NULL,
  `file_type` varchar(8) DEFAULT NULL,
  `effective_dt` datetime DEFAULT NULL,
  `expiration_dt` datetime DEFAULT '9999-12-31 23:59:59',
  PRIMARY KEY (`id`), 
  UNIQUE KEY `uk_directory_name` (`index_name`,`name`)
);


CREATE TABLE `matcher` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `index_name` varchar(128) NOT NULL,
  `name` varchar(128) NOT NULL,
  `query_type` varchar(64) NOT NULL,
  `max_score_percentage` float NOT NULL DEFAULT '0',
  `applies_to_file_type` varchar(6) CHARACTER SET utf8 NOT NULL DEFAULT '*',
  `active_flag` tinyint(1) NOT NULL DEFAULT '0',
  `effective_dt` datetime DEFAULT NULL,
  `expiration_dt` datetime DEFAULT '9999-12-31 23:59:59',
  PRIMARY KEY (`id`)
);

CREATE TABLE `matcher_field` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `index_name` varchar(128) CHARACTER SET utf8 NOT NULL,
  `document_type` varchar(64) NOT NULL DEFAULT 'media_file',
  `matcher_id` int(11) unsigned NOT NULL,
  `field_name` varchar(128) NOT NULL,
  `boost` float NOT NULL DEFAULT '0',
  `bool_` varchar(16) DEFAULT NULL,
  `operator` varchar(16) DEFAULT NULL,
  `minimum_should_match` float NOT NULL DEFAULT '0',
  `analyzer` varchar(64) DEFAULT NULL,
  `query_section` varchar(128) CHARACTER SET utf8 DEFAULT 'should',
  `default_value` varchar(128) CHARACTER SET utf8 DEFAULT NULL,
  `effective_dt` datetime DEFAULT NULL,
  `expiration_dt` datetime DEFAULT '9999-12-31 23:59:59',
  PRIMARY KEY (`id`),
  KEY `fk_matcher_field_matcher` (`matcher_id`),
  CONSTRAINT `fk_matcher_field_matcher` FOREIGN KEY (`matcher_id`) REFERENCES `matcher` (`id`)
);

CREATE TABLE `directory_amelioration` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(128) NOT NULL,
  `index_name` varchar(128) CHARACTER SET utf8 NOT NULL,
  `use_tag_flag` tinyint(1) DEFAULT '0',
  `replacement_tag` varchar(32) DEFAULT NULL,
  `use_parent_folder_flag` tinyint(1) DEFAULT '1',
  `effective_dt` datetime DEFAULT NULL,
  `expiration_dt` datetime DEFAULT '9999-12-31 23:59:59',
  PRIMARY KEY (`id`)
);

CREATE TABLE `directory_attribute` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `index_name` varchar(128) CHARACTER SET utf8 NOT NULL,
  `directory_id` int(11) NOT NULL,
  `attribute_name` varchar(256) NOT NULL,
  `attribute_value` varchar(512) DEFAULT NULL,
  `effective_dt` datetime DEFAULT NULL,
  `expiration_dt` datetime DEFAULT '9999-12-31 23:59:59',
  PRIMARY KEY (`id`)
);

CREATE TABLE `directory_constant` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `index_name` varchar(128) CHARACTER SET utf8 NOT NULL,
  `pattern` varchar(256) NOT NULL,
  `location_type` varchar(64) NOT NULL,
  `effective_dt` datetime DEFAULT NULL,
  `expiration_dt` datetime DEFAULT '9999-12-31 23:59:59',
  PRIMARY KEY (`id`)
);

CREATE TABLE `document_category` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `index_name` varchar(128) CHARACTER SET utf8 NOT NULL,
  `name` varchar(256) NOT NULL,
  `doc_type` varchar(128) CHARACTER SET utf8 NOT NULL,
  `effective_dt` datetime DEFAULT NULL,
  `expiration_dt` datetime DEFAULT '9999-12-31 23:59:59',
  PRIMARY KEY (`id`)
);

CREATE TABLE `file_handler` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `package` varchar(128) DEFAULT NULL,
  `module` varchar(128) NOT NULL,
  `class_name` varchar(128) DEFAULT NULL,
  `active_flag` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
);


CREATE TABLE `file_handler_type` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `file_handler_id` int(11) unsigned NOT NULL,
  `ext` varchar(128) DEFAULT NULL,
  `name` varchar(128) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_file_handler_type_file_handler` (`file_handler_id`),
  CONSTRAINT `fk_file_handler_type_file_handler` FOREIGN KEY (`file_handler_id`) REFERENCES `file_handler` (`id`)
);


drop view if exists `v_file_handler`;

create view `v_file_handler` as
  select fh.package, fh.module, fh.class_name, ft.ext 
  from file_handler fh, file_handler_type ft
  where ft.file_handler_id = fh.id
  order by fh.package, fh.module, fh.class_name;
  
create table `matched` (
  `index_name` varchar(128) NOT NULL,
  `doc_id` varchar(128) NOT NULL,
  `match_doc_id` varchar(128) NOT NULL,
  `matcher_name` varchar(128) NOT NULL,
  `percentage_of_max_score` float NOT NULL,
  `comparison_result` char(1) CHARACTER SET utf8 NOT NULL,
  `same_ext_flag` tinyint(1) NOT NULL DEFAULT '0',
  `effective_dt` datetime DEFAULT NULL,
  `expiration_dt` datetime DEFAULT '9999-12-31 23:59:59',
  CONSTRAINT `fk_doc_document`
    FOREIGN KEY (`doc_id`)
    REFERENCES `document` (`id`),
  CONSTRAINT `fk_match_doc_document`
    FOREIGN KEY (`match_doc_id`)
    REFERENCES `document` (`id`),
  PRIMARY KEY (`doc_id`,`match_doc_id`)
);

drop view if exists `v_matched`;

create view `v_matched` as

select d1.absolute_path document_path, m.comparison_result, d2.absolute_path match_path, m.percentage_of_max_score pct, m.same_ext_flag
from document d1, document d2, matched m
where m.doc_id = d1.id and
    m.match_doc_id = d2.id
union
select d2.absolute_path document_path, m.comparison_result, d1.absolute_path match_path, m.percentage_of_max_score pct, m.same_ext_flag
from document d1, document d2, matched m
where m.doc_id = d2.id and
    m.match_doc_id = d1.id;

INSERT INTO `directory` (`index_name`, `name`, `file_type`, `effective_dt`, `expiration_dt`) VALUES ('media','/media/removable/Audio/music/live recordings [wav]','wav',now(),'9999-12-31 23:59:59');
INSERT INTO `directory` (`index_name`, `name`, `file_type`, `effective_dt`, `expiration_dt`) VALUES ('media','/media/removable/Audio/music/albums','mp3',now(),'9999-12-31 23:59:59');
INSERT INTO `directory` (`index_name`, `name`, `file_type`, `effective_dt`, `expiration_dt`) VALUES ('media','/media/removable/Audio/music/albums [ape]','ape',now(),'9999-12-31 23:59:59');
INSERT INTO `directory` (`index_name`, `name`, `file_type`, `effective_dt`, `expiration_dt`) VALUES ('media','/media/removable/Audio/music/albums [flac]','flac',now(),'9999-12-31 23:59:59');
INSERT INTO `directory` (`index_name`, `name`, `file_type`, `effective_dt`, `expiration_dt`) VALUES ('media','/media/removable/Audio/music/albums [iso]','iso',now(),'9999-12-31 23:59:59');
INSERT INTO `directory` (`index_name`, `name`, `file_type`, `effective_dt`, `expiration_dt`) VALUES ('media','/media/removable/Audio/music/albums [mpc]','mpc',now(),'9999-12-31 23:59:59');
INSERT INTO `directory` (`index_name`, `name`, `file_type`, `effective_dt`, `expiration_dt`) VALUES ('media','/media/removable/Audio/music/albums [ogg]','ogg',now(),'9999-12-31 23:59:59');
INSERT INTO `directory` (`index_name`, `name`, `file_type`, `effective_dt`, `expiration_dt`) VALUES ('media','/media/removable/Audio/music/albums [wav]','wav',now(),'9999-12-31 23:59:59');
INSERT INTO `directory` (`index_name`, `name`, `file_type`, `effective_dt`, `expiration_dt`) VALUES ('media','/media/removable/Audio/music/compilations','mp3',now(),'9999-12-31 23:59:59');
INSERT INTO `directory` (`index_name`, `name`, `file_type`, `effective_dt`, `expiration_dt`) VALUES ('media','/media/removable/Audio/music/compilations [aac]','aac',now(),'9999-12-31 23:59:59');
INSERT INTO `directory` (`index_name`, `name`, `file_type`, `effective_dt`, `expiration_dt`) VALUES ('media','/media/removable/Audio/music/compilations [flac]','flac',now(),'9999-12-31 23:59:59');
INSERT INTO `directory` (`index_name`, `name`, `file_type`, `effective_dt`, `expiration_dt`) VALUES ('media','/media/removable/Audio/music/compilations [iso]','iso',now(),'9999-12-31 23:59:59');
INSERT INTO `directory` (`index_name`, `name`, `file_type`, `effective_dt`, `expiration_dt`) VALUES ('media','/media/removable/Audio/music/compilations [ogg]','ogg',now(),'9999-12-31 23:59:59');
INSERT INTO `directory` (`index_name`, `name`, `file_type`, `effective_dt`, `expiration_dt`) VALUES ('media','/media/removable/Audio/music/compilations [wav]','wav',now(),'9999-12-31 23:59:59');
INSERT INTO `directory` (`index_name`, `name`, `file_type`, `effective_dt`, `expiration_dt`) VALUES ('media','/media/removable/Audio/music/random compilations','mp3',now(),'9999-12-31 23:59:59');
INSERT INTO `directory` (`index_name`, `name`, `file_type`, `effective_dt`, `expiration_dt`) VALUES ('media','/media/removable/Audio/music/random tracks','mp3',now(),'9999-12-31 23:59:59');
INSERT INTO `directory` (`index_name`, `name`, `file_type`, `effective_dt`, `expiration_dt`) VALUES ('media','/media/removable/Audio/music/recently downloaded albums','mp3',now(),'9999-12-31 23:59:59');
INSERT INTO `directory` (`index_name`, `name`, `file_type`, `effective_dt`, `expiration_dt`) VALUES ('media','/media/removable/Audio/music/recently downloaded albums [flac]','flac',now(),'9999-12-31 23:59:59');
INSERT INTO `directory` (`index_name`, `name`, `file_type`, `effective_dt`, `expiration_dt`) VALUES ('media','/media/removable/Audio/music/recently downloaded albums [wav]','wav',now(),'9999-12-31 23:59:59');
INSERT INTO `directory` (`index_name`, `name`, `file_type`, `effective_dt`, `expiration_dt`) VALUES ('media','/media/removable/Audio/music/recently downloaded compilations','mp3',now(),'9999-12-31 23:59:59');
INSERT INTO `directory` (`index_name`, `name`, `file_type`, `effective_dt`, `expiration_dt`) VALUES ('media','/media/removable/Audio/music/recently downloaded compilations [flac]','flac',now(),'9999-12-31 23:59:59');
INSERT INTO `directory` (`index_name`, `name`, `file_type`, `effective_dt`, `expiration_dt`) VALUES ('media','/media/removable/Audio/music/recently downloaded discographies','mp3',now(),'9999-12-31 23:59:59');
INSERT INTO `directory` (`index_name`, `name`, `file_type`, `effective_dt`, `expiration_dt`) VALUES ('media','/media/removable/Audio/music/recently downloaded discographies [flac]','flac',now(),'9999-12-31 23:59:59');
INSERT INTO `directory` (`index_name`, `name`, `file_type`, `effective_dt`, `expiration_dt`) VALUES ('media','/media/removable/Audio/music/webcasts and custom mixes','mp3',now(),'9999-12-31 23:59:59');
INSERT INTO `directory` (`index_name`, `name`, `file_type`, `effective_dt`, `expiration_dt`) VALUES ('media','/media/removable/Audio/music/live recordings','mp3',now(),'9999-12-31 23:59:59');
INSERT INTO `directory` (`index_name`, `name`, `file_type`, `effective_dt`, `expiration_dt`) VALUES ('media','/media/removable/Audio/music/live recordings [flac]','flac',now(),'9999-12-31 23:59:59');
INSERT INTO `directory` (`index_name`, `name`, `file_type`, `effective_dt`, `expiration_dt`) VALUES ('media','/media/removable/Audio/music/temp','*',now(),'9999-12-31 23:59:59');
INSERT INTO `directory` (`index_name`, `name`, `file_type`, `effective_dt`, `expiration_dt`) VALUES ('media','/media/removable/SG932/media/music/incoming/complete','*',now(),'9999-12-31 23:59:59');
INSERT INTO `directory` (`index_name`, `name`, `file_type`, `effective_dt`, `expiration_dt`) VALUES ('media','/media/removable/SG932/media/music/mp3','mp3',now(),'9999-12-31 23:59:59');
INSERT INTO `directory` (`index_name`, `name`, `file_type`, `effective_dt`, `expiration_dt`) VALUES ('media','/media/removable/SG932/media/music/shared','*',now(),'9999-12-31 23:59:59');
INSERT INTO `directory` (`index_name`, `name`, `file_type`, `effective_dt`, `expiration_dt`) VALUES ('media','/media/removable/SG932/media/radio','*',now(),'9999-12-31 23:59:59');
INSERT INTO `directory` (`index_name`, `name`, `file_type`, `effective_dt`, `expiration_dt`) VALUES ('media','/media/removable/Audio/music/incoming','*',now(),'9999-12-31 23:59:59');
INSERT INTO `directory` (`index_name`, `name`, `file_type`, `effective_dt`, `expiration_dt`) VALUES ('media','/media/removable/Audio/music [noscan]/albums','mp3',now(),'9999-12-31 23:59:59');
INSERT INTO `directory` (`index_name`, `name`, `file_type`, `effective_dt`, `expiration_dt`) VALUES ('media','/media/removable/SG932/media/music [iTunes]','mp3',now(),'9999-12-31 23:59:59');
INSERT INTO `directory` (`index_name`, `name`, `file_type`, `effective_dt`, `expiration_dt`) VALUES ('media','/media/removable/SG932/media/spoken word','',now(),'9999-12-31 23:59:59');

INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (1,'cd1','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (2,'cd2','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (3,'cd3','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (4,'cd4','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (5,'cd5','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (6,'cd6','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (7,'cd7','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (8,'cd8','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (9,'cd9','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (10,'cd10','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (11,'cd11','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (12,'cd12','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (13,'cd13','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (14,'cd14','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (15,'cd15','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (16,'cd16','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (17,'cd17','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (18,'cd18','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (19,'cd19','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (20,'cd20','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (21,'cd21','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (22,'cd22','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (23,'cd23','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (24,'cd24','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (25,'cd01','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (26,'cd02','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (27,'cd03','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (28,'cd04','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (29,'cd05','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (30,'cd06','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (31,'cd07','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (32,'cd08','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (33,'cd09','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (34,'cd-1','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (35,'cd-2','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (36,'cd-3','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (37,'cd-4','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (38,'cd-5','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (39,'cd-6','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (40,'cd-7','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (41,'cd-8','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (42,'cd-9','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (43,'cd-10','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (44,'cd-11','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (45,'cd-12','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (46,'cd-13','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (47,'cd-14','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (48,'cd-15','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (49,'cd-16','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (50,'cd-17','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (51,'cd-18','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (52,'cd-19','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (53,'cd-20','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (54,'cd-21','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (55,'cd-22','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (56,'cd-23','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (57,'cd-24','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (58,'cd-01','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (59,'cd-02','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (60,'cd-03','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (61,'cd-04','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (62,'cd-05','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (63,'cd-06','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (64,'cd-07','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (65,'cd-08','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (66,'cd-09','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (67,'disk 1','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (68,'disk 2','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (69,'disk 3','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (70,'disk 4','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (71,'disk 5','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (72,'disk 6','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (73,'disk 7','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (74,'disk 8','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (75,'disk 9','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (76,'disk 10','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (77,'disk 11','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (78,'disk 12','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (79,'disk 13','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (80,'disk 14','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (81,'disk 15','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (82,'disk 16','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (83,'disk 17','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (84,'disk 18','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (85,'disk 19','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (86,'disk 20','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (87,'disk 21','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (88,'disk 22','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (89,'disk 23','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (90,'disk 24','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (91,'disk 01','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (92,'disk 02','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (93,'disk 03','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (94,'disk 04','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (95,'disk 05','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (96,'disk 06','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (97,'disk 07','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (98,'disk 08','media',0,NULL,1,NULL,'9999-12-31 23:59:59');
INSERT INTO `directory_amelioration` (`id`, `name`, `index_name`, `use_tag_flag`, `replacement_tag`, `use_parent_folder_flag`, `effective_dt`, `expiration_dt`) VALUES (99,'disk 09','media',0,NULL,1,NULL,'9999-12-31 23:59:59');

INSERT INTO `directory_constant` (`id`, `index_name`, `pattern`, `location_type`, `effective_dt`, `expiration_dt`) VALUES (1,'media','/compilations','compilation',now(),'9999-12-31 23:59:59');
INSERT INTO `directory_constant` (`id`, `index_name`, `pattern`, `location_type`, `effective_dt`, `expiration_dt`) VALUES (2,'media','compilations/','compilation',now(),'9999-12-31 23:59:59');
INSERT INTO `directory_constant` (`id`, `index_name`, `pattern`, `location_type`, `effective_dt`, `expiration_dt`) VALUES (3,'media','/various','compilation',now(),'9999-12-31 23:59:59');
INSERT INTO `directory_constant` (`id`, `index_name`, `pattern`, `location_type`, `effective_dt`, `expiration_dt`) VALUES (4,'media','/bak/','ignore',now(),'9999-12-31 23:59:59');
INSERT INTO `directory_constant` (`id`, `index_name`, `pattern`, `location_type`, `effective_dt`, `expiration_dt`) VALUES (5,'media','/webcasts and custom mixes','extended',now(),'9999-12-31 23:59:59');
INSERT INTO `directory_constant` (`id`, `index_name`, `pattern`, `location_type`, `effective_dt`, `expiration_dt`) VALUES (6,'media','/downloading','incomplete',now(),'9999-12-31 23:59:59');
INSERT INTO `directory_constant` (`id`, `index_name`, `pattern`, `location_type`, `effective_dt`, `expiration_dt`) VALUES (7,'media','/live','live_recording',now(),'9999-12-31 23:59:59');
INSERT INTO `directory_constant` (`id`, `index_name`, `pattern`, `location_type`, `effective_dt`, `expiration_dt`) VALUES (8,'media','/slsk/','new',now(),'9999-12-31 23:59:59');
INSERT INTO `directory_constant` (`id`, `index_name`, `pattern`, `location_type`, `effective_dt`, `expiration_dt`) VALUES (9,'media','/incoming/','new',now(),'9999-12-31 23:59:59');
INSERT INTO `directory_constant` (`id`, `index_name`, `pattern`, `location_type`, `effective_dt`, `expiration_dt`) VALUES (10,'media','/random','random',now(),'9999-12-31 23:59:59');
INSERT INTO `directory_constant` (`id`, `index_name`, `pattern`, `location_type`, `effective_dt`, `expiration_dt`) VALUES (11,'media','/recently','recent',now(),'9999-12-31 23:59:59');
INSERT INTO `directory_constant` (`id`, `index_name`, `pattern`, `location_type`, `effective_dt`, `expiration_dt`) VALUES (12,'media','/unsorted','unsorted',now(),'9999-12-31 23:59:59');
INSERT INTO `directory_constant` (`id`, `index_name`, `pattern`, `location_type`, `effective_dt`, `expiration_dt`) VALUES (13,'media','[...]','side_projects',now(),'9999-12-31 23:59:59');

INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (1,'media','dark classical','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (2,'media','funk','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (3,'media','mash-ups','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (4,'media','rap','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (5,'media','acid jazz','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (6,'media','afro-beat','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (7,'media','ambi-sonic','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (8,'media','ambient','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (9,'media','ambient noise','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (10,'media','ambient soundscapes','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (11,'media','art punk','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (12,'media','art rock','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (13,'media','avant-garde','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (14,'media','black metal','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (15,'media','blues','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (16,'media','chamber goth','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (17,'media','classic rock','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (18,'media','classical','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (19,'media','classics','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (20,'media','contemporary classical','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (21,'media','country','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (22,'media','dark ambient','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (23,'media','deathrock','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (24,'media','deep ambient','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (25,'media','disco','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (26,'media','doom jazz','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (27,'media','drum & bass','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (28,'media','dubstep','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (29,'media','electroclash','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (30,'media','electronic','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (31,'media','electronic [abstract hip-hop, illbient]','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (32,'media','electronic [ambient groove]','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (33,'media','electronic [armchair techno, emo-glitch]','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (34,'media','electronic [minimal]','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (35,'media','ethnoambient','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (36,'media','experimental','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (37,'media','folk','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (38,'media','folk-horror','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (39,'media','garage rock','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (40,'media','goth metal','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (41,'media','gothic','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (42,'media','grime','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (43,'media','gun rock','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (44,'media','hardcore','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (45,'media','hip-hop','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (46,'media','hip-hop (old school)','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (47,'media','hip-hop [chopped & screwed]','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (48,'media','house','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (49,'media','idm','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (50,'media','incidental','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (51,'media','indie','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (52,'media','industrial','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (53,'media','industrial rock','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (54,'media','industrial [soundscapes]','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (55,'media','jazz','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (56,'media','krautrock','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (57,'media','martial ambient','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (58,'media','martial folk','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (59,'media','martial industrial','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (60,'media','modern rock','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (61,'media','neo-folk, neo-classical','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (62,'media','new age','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (63,'media','new soul','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (64,'media','new wave, synthpop','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (65,'media','noise, powernoise','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (66,'media','oldies','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (67,'media','pop','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (68,'media','post-pop','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (69,'media','post-rock','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (70,'media','powernoise','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (71,'media','psychedelic rock','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (72,'media','punk','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (73,'media','punk [american]','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (74,'media','rap (chopped & screwed)','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (75,'media','rap (old school)','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (76,'media','reggae','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (77,'media','ritual ambient','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (78,'media','ritual industrial','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (79,'media','rock','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (80,'media','roots rock','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (81,'media','russian hip-hop','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (82,'media','ska','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (83,'media','soul','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (84,'media','soundtracks','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (85,'media','surf rock','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (86,'media','synthpunk','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (87,'media','trip-hop','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (88,'media','urban','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (89,'media','visual kei','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (90,'media','world fusion','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (91,'media','world musics','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (92,'media','alternative','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (93,'media','atmospheric','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (94,'media','new wave','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (95,'media','noise','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (96,'media','synthpop','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (97,'media','unsorted','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (98,'media','coldwave','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (99,'media','film music','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (100,'media','garage punk','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (101,'media','goth','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (102,'media','mash-up','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (103,'media','minimal techno','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (104,'media','mixed','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (105,'media','nu jazz','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (106,'media','post-punk','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (107,'media','psytrance','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (108,'media','ragga soca','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (109,'media','reggaeton','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (110,'media','ritual','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (111,'media','rockabilly','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (112,'media','smooth jazz','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (113,'media','techno','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (114,'media','tributes','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (115,'media','various','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (116,'media','celebrational','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (117,'media','classic ambient','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (118,'media','electronic rock','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (119,'media','electrosoul','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (120,'media','fusion','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (121,'media','glitch','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (122,'media','go-go','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (123,'media','hellbilly','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (124,'media','illbient','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (125,'media','industrial [rare]','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (126,'media','jpop','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (127,'media','mashup','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (128,'media','minimal','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (129,'media','modern soul','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (130,'media','neo soul','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (131,'media','neo-folk','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (132,'media','new beat','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (133,'media','satire','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (134,'media','dark jazz','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (135,'media','classic hip-hop','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (136,'media','electronic dance','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (137,'media','minimal house','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (138,'media','minimal wave','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (139,'media','afrobeat','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (140,'media','heavy metal','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (141,'media','new wave, goth, synthpop, alternative','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (142,'media','ska, reggae','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (143,'media','soul & funk','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (144,'media','psychedelia','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (145,'media','americana','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (146,'media','dance','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (147,'media','glam','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (148,'media','gothic & new wave','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (149,'media','punk & new wave','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (150,'media','random','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (151,'media','rock, metal, pop','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (152,'media','sound track','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (153,'media','soundtrack','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (154,'media','spacerock','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (155,'media','tribute','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (156,'media','unclassifiable','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (157,'media','unknown','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (158,'media','weird','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (159,'media','darkwave','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (160,'media','experimental-noise','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (161,'media','general alternative','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (162,'media','girl group','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (163,'media','gospel & religious','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (164,'media','alternative & punk','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (165,'media','bass','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (166,'media','beat','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (167,'media','black rock','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (168,'media','classic','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (169,'media','japanese','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (170,'media','kanine','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (171,'media','metal','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (172,'media','moderne','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (173,'media','noise rock','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (174,'media','other','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (175,'media','post-punk & minimal wave','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (176,'media','progressive rock','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (177,'media','psychic tv','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (178,'media','punk & oi','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (179,'media','radio','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (180,'media','rock\'n\'soul','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (181,'media','spoken word','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (182,'media','temp','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (183,'media','trance','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (184,'media','vocal','directory',now(),'9999-12-31 23:59:59');
INSERT INTO `document_category` (`id`, `index_name`, `name`, `doc_type`, `effective_dt`, `expiration_dt`) VALUES (185,'media','world','directory',now(),'9999-12-31 23:59:59');

INSERT INTO `matcher` (`id`, `index_name`, `name`, `query_type`, `max_score_percentage`, `active_flag`, `applies_to_file_type`) VALUES (1,'media','filename_match_matcher','match',75,1,'*');
INSERT INTO `matcher` (`id`, `index_name`, `name`, `query_type`, `max_score_percentage`, `active_flag`, `applies_to_file_type`) VALUES (2,'media','tag_term_matcher_artist_album_song','term',0,0,'*');
INSERT INTO `matcher` (`id`, `index_name`, `name`, `query_type`, `max_score_percentage`, `active_flag`, `applies_to_file_type`) VALUES (3,'media','filesize_term_matcher','term',0,0,'flac');
INSERT INTO `matcher` (`id`, `index_name`, `name`, `query_type`, `max_score_percentage`, `active_flag`, `applies_to_file_type`) VALUES (4,'media','artist_matcher','term',0,0,'*');
INSERT INTO `matcher` (`id`, `index_name`, `name`, `query_type`, `max_score_percentage`, `active_flag`, `applies_to_file_type`) VALUES (5,'media','match_artist_album_song','match',75,1,'*');

INSERT INTO `matcher_field` (`id`, `index_name`, `document_type`, `field_name`, `boost`, `bool_`, `operator`, `minimum_should_match`, `analyzer`, `query_section`, `default_value`, `matcher_id`) VALUES (1,'media','media_file','TPE1',5,NULL,NULL,0,NULL,'should',NULL,2);
INSERT INTO `matcher_field` (`id`, `index_name`, `document_type`, `field_name`, `boost`, `bool_`, `operator`, `minimum_should_match`, `analyzer`, `query_section`, `default_value`, `matcher_id`) VALUES (2,'media','media_file','TIT2',7,NULL,NULL,0,NULL,'should',NULL,2);
INSERT INTO `matcher_field` (`id`, `index_name`, `document_type`, `field_name`, `boost`, `bool_`, `operator`, `minimum_should_match`, `analyzer`, `query_section`, `default_value`, `matcher_id`) VALUES (3,'media','media_file','TALB',3,NULL,NULL,0,NULL,'should',NULL,2);
INSERT INTO `matcher_field` (`id`, `index_name`, `document_type`, `field_name`, `boost`, `bool_`, `operator`, `minimum_should_match`, `analyzer`, `query_section`, `default_value`, `matcher_id`) VALUES (4,'media','media_file','file_name',0,NULL,NULL,0,NULL,'should',NULL,1);
INSERT INTO `matcher_field` (`id`, `index_name`, `document_type`, `field_name`, `boost`, `bool_`, `operator`, `minimum_should_match`, `analyzer`, `query_section`, `default_value`, `matcher_id`) VALUES (5,'media','media_file','deleted',0,NULL,NULL,0,NULL,'should',NULL,2);
INSERT INTO `matcher_field` (`id`, `index_name`, `document_type`, `field_name`, `boost`, `bool_`, `operator`, `minimum_should_match`, `analyzer`, `query_section`, `default_value`, `matcher_id`) VALUES (6,'media','media_file','file_size',3,NULL,NULL,0,NULL,'should',NULL,3);
INSERT INTO `matcher_field` (`id`, `index_name`, `document_type`, `field_name`, `boost`, `bool_`, `operator`, `minimum_should_match`, `analyzer`, `query_section`, `default_value`, `matcher_id`) VALUES (7,'media','media_file','TPE1',3,NULL,NULL,0,NULL,'should',NULL,4);
INSERT INTO `matcher_field` (`id`, `index_name`, `document_type`, `field_name`, `boost`, `bool_`, `operator`, `minimum_should_match`, `analyzer`, `query_section`, `default_value`, `matcher_id`) VALUES (8,'media','media_file','TPE1',0,NULL,NULL,0,NULL,'must',NULL,5);
INSERT INTO `matcher_field` (`id`, `index_name`, `document_type`, `field_name`, `boost`, `bool_`, `operator`, `minimum_should_match`, `analyzer`, `query_section`, `default_value`, `matcher_id`) VALUES (9,'media','media_file','TIT2',5,NULL,NULL,0,NULL,'should',NULL,5);
INSERT INTO `matcher_field` (`id`, `index_name`, `document_type`, `field_name`, `boost`, `bool_`, `operator`, `minimum_should_match`, `analyzer`, `query_section`, `default_value`, `matcher_id`) VALUES (10,'media','media_file','TALB',0,NULL,NULL,0,NULL,'should',NULL,5);
INSERT INTO `matcher_field` (`id`, `index_name`, `document_type`, `field_name`, `boost`, `bool_`, `operator`, `minimum_should_match`, `analyzer`, `query_section`, `default_value`, `matcher_id`) VALUES (11,'media','media_file','deleted',0,NULL,NULL,0,NULL,'must_not','true',5);
INSERT INTO `matcher_field` (`id`, `index_name`, `document_type`, `field_name`, `boost`, `bool_`, `operator`, `minimum_should_match`, `analyzer`, `query_section`, `default_value`, `matcher_id`) VALUES (12,'media','media_file','TRCK',0,NULL,NULL,0,NULL,'should','',5);
INSERT INTO `matcher_field` (`id`, `index_name`, `document_type`, `field_name`, `boost`, `bool_`, `operator`, `minimum_should_match`, `analyzer`, `query_section`, `default_value`, `matcher_id`) VALUES (13,'media','media_file','TPE2',0,NULL,NULL,0,NULL,'','should',5);

# file handlers
insert into file_handler (module, class_name) values ('pathogen', 'MutagenAAC');
insert into file_handler (module, class_name, active_flag) values ('pathogen', 'MutagenAPEv2', 1);
insert into file_handler (module, class_name, active_flag) values ('pathogen', 'MutagenFLAC', 1);
insert into file_handler (module, class_name, active_flag) values ('pathogen', 'MutagenID3', 1);
insert into file_handler (module, class_name, active_flag) values ('pathogen', 'MutagenMP4', 1);
insert into file_handler (module, class_name) values ('pathogen', 'MutagenOggFlac');
insert into file_handler (module, class_name, active_flag) values ('pathogen', 'MutagenOggVorbis', 1);

insert into file_handler_type (file_handler_id, ext, name) values ((select id from file_handler where class_name = 'MutagenAAC'), 'aac', 'mutagen-aac');
insert into file_handler_type (file_handler_id, ext, name) values ((select id from file_handler where class_name = 'MutagenAPEv2'), 'ape', 'mutagen-ape');
insert into file_handler_type (file_handler_id, ext, name) values ((select id from file_handler where class_name = 'MutagenAPEv2'), 'mpc', 'mutagen-mpc');
insert into file_handler_type (file_handler_id, ext, name) values ((select id from file_handler where class_name = 'MutagenFLAC'), 'flac', 'mutagen-flac');
insert into file_handler_type (file_handler_id, ext, name) values ((select id from file_handler where class_name = 'MutagenID3'), 'mp3', 'mutagen-id3-mp3');
insert into file_handler_type (file_handler_id, ext, name) values ((select id from file_handler where class_name = 'MutagenID3'), 'flac', 'mutagen-id3-flac');
insert into file_handler_type (file_handler_id, ext, name) values ((select id from file_handler where class_name = 'MutagenMP4'), 'mp4', 'mutagen-mp4');
insert into file_handler_type (file_handler_id, ext, name) values ((select id from file_handler where class_name = 'MutagenMP4'), 'm4a', 'mutagen-m4a');
insert into file_handler_type (file_handler_id, ext, name) values ((select id from file_handler where class_name = 'MutagenOggFlac'), 'ogg', 'mutagen-ogg');
insert into file_handler_type (file_handler_id, ext, name) values ((select id from file_handler where class_name = 'MutagenOggFlac'), 'flac', 'mutagen-ogg-flac');
insert into file_handler_type (file_handler_id, ext, name) values ((select id from file_handler where class_name = 'MutagenOggVorbis'), 'ogg', 'mutagen-ogg-vorbis');
insert into file_handler_type (file_handler_id, ext, name) values ((select id from file_handler where class_name = 'MutagenOggVorbis'), 'oga', 'mutagen-ogg-oga');


INSERT INTO `document_metadata` (`index_name`, `document_format`, `attribute_name`, `active_flag`) VALUES ('media','ID3V2','COMM',1);
INSERT INTO `document_metadata` (`index_name`, `document_format`, `attribute_name`, `active_flag`) VALUES ('media','ID3V2','MCDI',1);
INSERT INTO `document_metadata` (`index_name`, `document_format`, `attribute_name`, `active_flag`) VALUES ('media','ID3V2','PRIV',1);
INSERT INTO `document_metadata` (`index_name`, `document_format`, `attribute_name`, `active_flag`) VALUES ('media','ID3V2','TALB',1);
INSERT INTO `document_metadata` (`index_name`, `document_format`, `attribute_name`, `active_flag`) VALUES ('media','ID3V2','TCOM',1);
INSERT INTO `document_metadata` (`index_name`, `document_format`, `attribute_name`, `active_flag`) VALUES ('media','ID3V2','TCON',1);
INSERT INTO `document_metadata` (`index_name`, `document_format`, `attribute_name`, `active_flag`) VALUES ('media','ID3V2','TDRC',1);
INSERT INTO `document_metadata` (`index_name`, `document_format`, `attribute_name`, `active_flag`) VALUES ('media','ID3V2','TIT2',1);
INSERT INTO `document_metadata` (`index_name`, `document_format`, `attribute_name`, `active_flag`) VALUES ('media','ID3V2','TLEN',1);
INSERT INTO `document_metadata` (`index_name`, `document_format`, `attribute_name`, `active_flag`) VALUES ('media','ID3V2','TPE1',1);
INSERT INTO `document_metadata` (`index_name`, `document_format`, `attribute_name`, `active_flag`) VALUES ('media','ID3V2','TPE2',1);
INSERT INTO `document_metadata` (`index_name`, `document_format`, `attribute_name`, `active_flag`) VALUES ('media','ID3V2','TPUB',1);
INSERT INTO `document_metadata` (`index_name`, `document_format`, `attribute_name`, `active_flag`) VALUES ('media','ID3V2','TRCK',1);
-- INSERT INTO `document_metadata` (`index_name`, `document_format`, `attribute_name`, `active_flag`) VALUES (14,'media','ID3V2','POPM',1);
INSERT INTO `document_metadata` (`index_name`, `document_format`, `attribute_name`, `active_flag`) VALUES ('media','ID3V2','TDOR',1);
INSERT INTO `document_metadata` (`index_name`, `document_format`, `attribute_name`, `active_flag`) VALUES ('media','ID3V2','TMED',1);
INSERT INTO `document_metadata` (`index_name`, `document_format`, `attribute_name`, `active_flag`) VALUES ('media','ID3V2','TPOS',1);
INSERT INTO `document_metadata` (`index_name`, `document_format`, `attribute_name`, `active_flag`) VALUES ('media','ID3V2','TSO2',1);
INSERT INTO `document_metadata` (`index_name`, `document_format`, `attribute_name`, `active_flag`) VALUES ('media','ID3V2','TSOP',1);
-- INSERT INTO `document_metadata` (`index_name`, `document_format`, `attribute_name`, `active_flag`) VALUES (20,'media','ID3V2','TXXX',1);
INSERT INTO `document_metadata` (`index_name`, `document_format`, `attribute_name`, `active_flag`) VALUES ('media','ID3V2','UFID',1);
INSERT INTO `document_metadata` (`index_name`, `document_format`, `attribute_name`, `active_flag`) VALUES ('media','ID3V2','APIC',1);
INSERT INTO `document_metadata` (`index_name`, `document_format`, `attribute_name`, `active_flag`) VALUES ('media','ID3V2','TIT1',1);
INSERT INTO `document_metadata` (`index_name`, `document_format`, `attribute_name`, `active_flag`) VALUES ('media','ID3V2','TIPL',1);
INSERT INTO `document_metadata` (`index_name`, `document_format`, `attribute_name`, `active_flag`) VALUES ('media','ID3V2','TENC',1);
INSERT INTO `document_metadata` (`index_name`, `document_format`, `attribute_name`, `active_flag`) VALUES ('media','ID3V2','TLAN',1);
-- INSERT INTO `document_metadata` (`index_name`, `document_format`, `attribute_name`, `active_flag`) VALUES (27,'media','ID3V2','TSRC',1);
-- INSERT INTO `document_metadata` (`index_name`, `document_format`, `attribute_name`, `active_flag`) VALUES (28,'media','ID3V2','GEOB',1);
-- INSERT INTO `document_metadata` (`index_name`, `document_format`, `attribute_name`, `active_flag`) VALUES (29,'media','ID3V2','TFLT',1);
-- INSERT INTO `document_metadata` (`index_name`, `document_format`, `attribute_name`, `active_flag`) VALUES (30,'media','ID3V2','TSSE',1);
-- INSERT INTO `document_metadata` (`index_name`, `document_format`, `attribute_name`, `active_flag`) VALUES (31,'media','ID3V2','WXXX',1);
-- INSERT INTO `document_metadata` (`index_name`, `document_format`, `attribute_name`, `active_flag`) VALUES (32,'media','ID3V2','TCOP',1);
-- INSERT INTO `document_metadata` (`index_name`, `document_format`, `attribute_name`, `active_flag`) VALUES (33,'media','ID3V2','TBPM',1);
-- INSERT INTO `document_metadata` (`index_name`, `document_format`, `attribute_name`, `active_flag`) VALUES (34,'media','ID3V2','TOPE',1);
-- INSERT INTO `document_metadata` (`index_name`, `document_format`, `attribute_name`, `active_flag`) VALUES (35,'media','ID3V2','TYER',1);
-- INSERT INTO `document_metadata` (`index_name`, `document_format`, `attribute_name`, `active_flag`) VALUES (36,'media','ID3V2','PCNT',1);
-- INSERT INTO `document_metadata` (`index_name`, `document_format`, `attribute_name`, `active_flag`) VALUES (37,'media','ID3V2','TKEY',1);
-- INSERT INTO `document_metadata` (`index_name`, `document_format`, `attribute_name`, `active_flag`) VALUES (38,'media','ID3V2','USER',1);
-- INSERT INTO `document_metadata` (`index_name`, `document_format`, `attribute_name`, `active_flag`) VALUES (39,'media','ID3V2','TDRL',1);
INSERT INTO `document_metadata` (`index_name`, `document_format`, `attribute_name`, `active_flag`) VALUES ('media','ID3V2','TIT3',1);
-- INSERT INTO `document_metadata` (`index_name`, `document_format`, `attribute_name`, `active_flag`) VALUES (41,'media','ID3V2','TOFN',1);
-- INSERT INTO `document_metadata` (`index_name`, `document_format`, `attribute_name`, `active_flag`) VALUES (42,'media','ID3V2','TSOA',1);
-- INSERT INTO `document_metadata` (`index_name`, `document_format`, `attribute_name`, `active_flag`) VALUES (43,'media','ID3V2','WOAR',1);
-- INSERT INTO `document_metadata` (`index_name`, `document_format`, `attribute_name`, `active_flag`) VALUES (44,'media','ID3V2','TSOT',1);
-- INSERT INTO `document_metadata` (`index_name`, `document_format`, `attribute_name`, `active_flag`) VALUES (62,'media','ID3V2','WCOM',1);
-- INSERT INTO `document_metadata` (`index_name`, `document_format`, `attribute_name`, `active_flag`) VALUES (68,'media','ID3V2','RVA2',1);
-- INSERT INTO `document_metadata` (`index_name`, `document_format`, `attribute_name`, `active_flag`) VALUES (69,'media','ID3V2','WOAF',1);
-- INSERT INTO `document_metadata` (`index_name`, `document_format`, `attribute_name`, `active_flag`) VALUES (70,'media','ID3V2','WOAS',1);
-- INSERT INTO `document_metadata` (`index_name`, `document_format`, `attribute_name`, `active_flag`) VALUES (90,'media','ID3V2','TDTG',1);
-- INSERT INTO `document_metadata` (`index_name`, `document_format`, `attribute_name`, `active_flag`) VALUES (91,'media','ID3V2','USLT',1);
-- INSERT INTO `document_metadata` (`index_name`, `document_format`, `attribute_name`, `active_flag`) VALUES (92,'media','ID3V2','TCMP',1);
INSERT INTO `document_metadata` (`index_name`, `document_format`, `attribute_name`, `active_flag`) VALUES ('media','ID3V2','TPE3',1);
-- INSERT INTO `document_metadata` (`index_name`, `document_format`, `attribute_name`, `active_flag`) VALUES (132,'media','ID3V2','TOAL',1);
-- INSERT INTO `document_metadata` (`index_name`, `document_format`, `attribute_name`, `active_flag`) VALUES (149,'media','ID3V2','TDEN',1);
-- INSERT INTO `document_metadata` (`index_name`, `document_format`, `attribute_name`, `active_flag`) VALUES (168,'media','ID3V2','WCOP',1);
INSERT INTO `document_metadata` (`index_name`, `document_format`, `attribute_name`, `active_flag`) VALUES ('media','ID3V2','TPE4',1);
-- INSERT INTO `document_metadata` (`index_name`, `document_format`, `attribute_name`, `active_flag`) VALUES (256,'media','ID3V2','TEXT',1);
-- INSERT INTO `document_metadata` (`index_name`, `document_format`, `attribute_name`, `active_flag`) VALUES (257,'media','ID3V2','TSST',1);
-- INSERT INTO `document_metadata` (`index_name`, `document_format`, `attribute_name`, `active_flag`) VALUES (258,'media','ID3V2','WORS',1);
-- INSERT INTO `document_metadata` (`index_name`, `document_format`, `attribute_name`, `active_flag`) VALUES (259,'media','ID3V2','WPAY',1);
-- INSERT INTO `document_metadata` (`index_name`, `document_format`, `attribute_name`, `active_flag`) VALUES (260,'media','ID3V2','WPUB',1);
-- INSERT INTO `document_metadata` (`index_name`, `document_format`, `attribute_name`, `active_flag`) VALUES (261,'media','ID3V2','LINK',1);
-- INSERT INTO `document_metadata` (`index_name`, `document_format`, `attribute_name`, `active_flag`) VALUES (263,'media','ID3V2','TOLY',1);
-- INSERT INTO `document_metadata` (`index_name`, `document_format`, `attribute_name`, `active_flag`) VALUES (264,'media','ID3V2','TRSN',1);

