DROP TABLE IF EXISTS `mode_state_default_param`;
DROP TABLE IF EXISTS `mode_state_default_operation`;
DROP TABLE IF EXISTS `mode_state_default`;
DROP TABLE IF EXISTS `mode_default`;
DROP TABLE IF EXISTS `mode_state_param`;
DROP TABLE IF EXISTS `mode_state`;
DROP TABLE IF EXISTS `transition_rule`;
DROP TABLE IF EXISTS `switch_rule`;
DROP TABLE IF EXISTS `state`;
DROP TABLE IF EXISTS `mode`;
DROP TABLE IF EXISTS `operation`;
DROP TABLE IF EXISTS `operator`;
DROP TABLE IF EXISTS `dispatch_target`;
DROP TABLE IF EXISTS `dispatch`;

drop view if exists `v_mode_default_dispatch`;
drop view if exists `v_mode_dispatch`;

CREATE TABLE `dispatch` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `identifier` varchar(128) DEFAULT NULL,
  `category` varchar(128) DEFAULT NULL,
  `package` varchar(128) DEFAULT NULL,
  `module` varchar(128) NOT NULL,
  `class_name` varchar(128) DEFAULT NULL,
  `func_name` varchar(128) NOT NULL,
  PRIMARY KEY (`id`)
);

# service process
insert into dispatch (identifier, module, func_name) values ('service_create_proc', 'mockserv', 'create_service_process');

# modes
insert into dispatch (identifier, category, module, class_name, func_name) values ('startup', 'effect', 'mockserv', 'StartupHandler', 'start'); 
insert into dispatch (identifier, category, module, class_name, func_name) values ('eval', 'effect', 'mockserv', 'EvalModeHandler', 'do_eval'); 
-- insert into dispatch (identifier, category, module, class_name, func_name) values ('scan.should_update', 'effect', 'mockserv', 'ScanModeHandler', 'should_update');
insert into dispatch (identifier, category, module, class_name, func_name) values ('scan', 'effect', 'mockserv', 'ScanModeHandler', 'do_scan');
insert into dispatch (identifier, category, module, class_name, func_name) values ('scan.discover', 'effect', 'mockserv', 'ScanModeHandler', 'do_scan_discover');
insert into dispatch (identifier, category, module, class_name, func_name) values ('scan.update', 'effect', 'mockserv', 'ScanModeHandler', 'do_scan');
insert into dispatch (identifier, category, module, class_name, func_name) values ('scan.monitor', 'effect', 'mockserv', 'ScanModeHandler', 'do_scan_monitor');
-- insert into dispatch (identifier, category, module, class_name, func_name) values ('scan.after', 'effect', 'mockserv', 'ScanModeHandler', 'after_scan'); 
insert into dispatch (identifier, category, module, class_name, func_name) values ('match', 'effect', 'mockserv', 'MatchModeHandler', 'do_match'); 
insert into dispatch (identifier, category, module, class_name, func_name) values ('fix', 'effect', 'mockserv', 'FixModeHandler', 'do_fix'); 
insert into dispatch (identifier, category, module, class_name, func_name) values ('report', 'effect', 'mockserv', 'ReportModeHandler', 'do_report'); 
insert into dispatch (identifier, category, module, class_name, func_name) values ('requests', 'effect', 'mockserv', 'RequestsModeHandler', 'do_do_reqs'); 
insert into dispatch (identifier, category, module, class_name, func_name) values ('shutdown', 'effect', 'mockserv', 'ShutdownHandler', 'end'); 

# mode states

-- CREATE TABLE `dispatch_target` (
--   `id` int(11) unsigned NOT NULL AUTO_INCREMENT,s
--   `dispatch_id` int(11) unsigned NOT NULL,
--   `target` varchar(128) DEFAULT NULL,
--   PRIMARY KEY (`id`),
--   KEY `fk_dispatch_target_dispatch` (`dispatch_id`),
--   CONSTRAINT `fk_dispatch_target_dispatch` FOREIGN KEY (`dispatch_id`) REFERENCES `dispatch` (`id`)
-- );

-- drop view if exists `v_dispatch_target`;

-- create view `v_dispatch_target` as
--   select d.identifier, d.package, d.module, d.class_name, d.func_name, dt.target
--   from dispatch d, dispatch_target dt
--   where dt.dispatch_id = d.id
--   order by d.identifier;

CREATE TABLE `operator` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `index_name` varchar(128) CHARACTER SET utf8 NOT NULL,
  `name` varchar(128) NOT NULL,
  `effective_dt` datetime DEFAULT NULL,
  `expiration_dt` datetime NOT NULL DEFAULT '9999-12-31 23:59:59',
  PRIMARY KEY (`id`)
);

insert into operator (index_name, name, effective_dt) values ('media', 'scan', now());
insert into operator (index_name, name, effective_dt) values ('media', 'calc', now());
insert into operator (index_name, name, effective_dt) values ('media', 'clean', now());
insert into operator (index_name, name, effective_dt) values ('media', 'eval', now());
insert into operator (index_name, name, effective_dt) values ('media', 'fix', now());
insert into operator (index_name, name, effective_dt) values ('media', 'report', now());

CREATE TABLE `operation` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `index_name` varchar(128) CHARACTER SET utf8 NOT NULL,
  `operator_id` int(11) unsigned NOT NULL,
  `name` varchar(128) NOT NULL,
  `effective_dt` datetime DEFAULT NULL,
  `expiration_dt` datetime NOT NULL DEFAULT '9999-12-31 23:59:59',
  PRIMARY KEY (`id`),
  KEY `fk_operation_operator` (`operator_id`),
  CONSTRAINT `fk_operation_operator` FOREIGN KEY (`operator_id`) REFERENCES `operator` (`id`)
);

-- insert into operation (index_name, name, operator, effective_dt) values ('media', 'scan', (select id from operator where name = 'scan'), now());
insert into operation (index_name, name, operator_id, effective_dt) values ('media', 'discover', (select id from operator where name = 'scan'), now());
insert into operation (index_name, name, operator_id, effective_dt) values ('media', 'update', (select id from operator where name = 'scan'), now());
insert into operation (index_name, name, operator_id, effective_dt) values ('media', 'monitor', (select id from operator where name = 'scan'), now());
-- insert into operation (index_name, name, operator, effective_dt) values ('media', 'fix', (select id from operator where name = 'fix'), now());
-- insert into operation (index_name, name, operator, effective_dt) values ('media', 'eval', (select id from operator where name = 'eval'), now());
-- insert into operation (index_name, name, operator, effective_dt) values ('media', 'clean', (select id from operator where name = 'clean'), now());

-- insert into operation (index_name, name, effective_dt) values ('media', 'clean', now());
-- insert into operation (index_name, name, effective_dt) values ('media', 'eval', now());
-- insert into operation (index_name, name, effective_dt) values ('media', 'fix', now());
-- insert into operation (index_name, name, effective_dt) values ('media', 'match', now());
-- insert into operation (index_name, name, effective_dt) values ('media', 'scan', now());
-- insert into operation (index_name, name, effective_dt) values ('media', 'sync', now());
-- insert into operation (index_name, name, effective_dt) values ('media', 'report', now());
-- insert into operation (index_name, name, effective_dt) values ('media', 'requests', now());


CREATE TABLE `mode` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `index_name` varchar(128) CHARACTER SET utf8 NOT NULL,
  `name` varchar(128) NOT NULL,
  `effective_dt` datetime DEFAULT NULL,
  `expiration_dt` datetime NOT NULL DEFAULT '9999-12-31 23:59:59',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_mode_name` (`index_name`,`name`)
);

insert into mode (index_name, name, effective_dt) values ('media', 'startup', now());
insert into mode (index_name, name, effective_dt) values ('media', 'scan', now());
insert into mode (index_name, name, effective_dt) values ('media', 'match', now());
insert into mode (index_name, name, effective_dt) values ('media', 'eval', now());
insert into mode (index_name, name, effective_dt) values ('media', 'fix', now());
insert into mode (index_name, name, effective_dt) values ('media', 'clean', now());
insert into mode (index_name, name, effective_dt) values ('media', 'sync', now());
insert into mode (index_name, name, effective_dt) values ('media', 'requests', now());
insert into mode (index_name, name, effective_dt) values ('media', 'sleep', now());
insert into mode (index_name, name, effective_dt) values ('media', 'shutdown', now());

CREATE TABLE `state` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `index_name` varchar(128) CHARACTER SET utf8 NOT NULL default 'media',
  `name` varchar(128) NOT NULL,
  `terminal_state_flag` tinyint(1) NOT NULL DEFAULT '0',
  `initial_state_flag` tinyint(1) NOT NULL DEFAULT '0',
  `effective_dt` datetime DEFAULT NULL,
  `expiration_dt` datetime DEFAULT '9999-12-31 23:59:59',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_state_name` (`index_name`,`name`)
);

insert into state(index_name, name, effective_dt, initial_state_flag) values ('media', 'initial', now(), 1);
insert into state(index_name, name, effective_dt) values ('media', 'discover', now());
insert into state(index_name, name, effective_dt) values ('media', 'update', now());
insert into state(index_name, name, effective_dt) values ('media', 'monitor', now());
insert into state(index_name, name, effective_dt, initial_state_flag) values ('media', 'terminal', now(), 2);


CREATE TABLE `transition_rule` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  -- `index_name` varchar(128) CHARACTER SET utf8 NOT NULL,
  `name` varchar(128) NOT NULL,
  `mode_id` int(11) unsigned NOT NULL,
  `begin_state_id` int(11) unsigned NOT NULL,
  `end_state_id` int(11) unsigned NOT NULL,
  `condition_dispatch_id` int(11) unsigned NOT NULL,
  -- `effective_dt` datetime DEFAULT NULL,
  -- `expiration_dt` datetime NOT NULL DEFAULT '9999-12-31 23:59:59',
  PRIMARY KEY (`id`),
  KEY `fk_transition_rule_mode` (`mode_id`),
  CONSTRAINT `fk_transition_rule_mode` FOREIGN KEY (`mode_id`) REFERENCES `mode` (`id`),
  KEY `fk_transition_rule_begin_state` (`begin_state_id`),
  CONSTRAINT `fk_transition_rule_begin_state` FOREIGN KEY (`begin_state_id`) REFERENCES `state` (`id`),
  KEY `fk_transition_rule_end_state` (`end_state_id`),
  CONSTRAINT `fk_transition_rule_end_state` FOREIGN KEY (`end_state_id`) REFERENCES `state` (`id`),
  KEY `fk_transition_rule_condition_dispatch` (`condition_dispatch_id`),
  CONSTRAINT `fk_transition_rule_condition_dispatch` FOREIGN KEY (`condition_dispatch_id`) REFERENCES `dispatch` (`id`)
  -- UNIQUE KEY `uk_rule_name` (`index_name`,`name`)
);


CREATE TABLE `switch_rule` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  -- `index_name` varchar(128) CHARACTER SET utf8 NOT NULL,
  `name` varchar(128) NOT NULL,
  `begin_mode_id` int(11) unsigned NOT NULL,
  `end_mode_id` int(11) unsigned NOT NULL,
  `before_dispatch_id` int(11) unsigned NOT NULL,
  `action_dispatch_id` int(11) unsigned NOT NULL,
  `after_dispatch_id` int(11) unsigned NOT NULL,
  -- `effective_dt` datetime DEFAULT NULL,
  -- `expiration_dt` datetime NOT NULL DEFAULT '9999-12-31 23:59:59',
  PRIMARY KEY (`id`),
  KEY `fk_switch_rule_begin_mode` (`begin_mode_id`),
  CONSTRAINT `fk_switch_rule_begin_mode` FOREIGN KEY (`begin_mode_id`) REFERENCES `mode` (`id`),
  KEY `fk_switch_rule_end_mode` (`end_mode_id`),
  CONSTRAINT `fk_switch_rule_end_mode` FOREIGN KEY (`end_mode_id`) REFERENCES `mode` (`id`),
  KEY `fk_switch_rule_before_dispatch` (`before_dispatch_id`),
  CONSTRAINT `fk_switch_rule_before_dispatch` FOREIGN KEY (`before_dispatch_id`) REFERENCES `dispatch` (`id`),
  KEY `fk_switch_rule_action_dispatch` (`action_dispatch_id`),
  CONSTRAINT `fk_switch_rule_action_dispatch` FOREIGN KEY (`action_dispatch_id`) REFERENCES `dispatch` (`id`),
  KEY `fk_switch_rule_after_dispatch` (`after_dispatch_id`),
  CONSTRAINT `fk_switch_rule_after_dispatch` FOREIGN KEY (`after_dispatch_id`) REFERENCES `dispatch` (`id`)
  -- UNIQUE KEY `uk_switch_rule_name` (`index_name`,`name`)
);



CREATE TABLE `mode_state` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `index_name` varchar(128) CHARACTER SET utf8 NOT NULL default 'media',
  `pid` varchar(32) NOT NULL,
  `mode_id` int(11) unsigned NOT NULL,
  `state_id` int(11) unsigned NOT NULL DEFAULT '0',
  `times_activated` int(11) unsigned NOT NULL DEFAULT '0',
  `times_completed` int(11) unsigned NOT NULL DEFAULT '0',
  `error_count` int(3) unsigned NOT NULL DEFAULT '0',
  `cum_error_count` int(11) unsigned NOT NULL DEFAULT '0',
  `status` varchar(64) NOT NULL,
  `last_activated` datetime DEFAULT NULL,
  `last_completed` datetime DEFAULT NULL,
  `effective_dt` datetime DEFAULT NULL,
  `expiration_dt` datetime NOT NULL DEFAULT '9999-12-31 23:59:59',
  PRIMARY KEY (`id`),
  KEY `fk_mode_state_mode` (`mode_id`),
  KEY `fk_mode_state_state` (`state_id`),
  CONSTRAINT `fk_mode_state_mode` FOREIGN KEY (`mode_id`) REFERENCES `mode` (`id`),
  CONSTRAINT `fk_mode_state_state` FOREIGN KEY (`state_id`) REFERENCES `state` (`id`)
);


CREATE TABLE `mode_default` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `index_name` varchar(128) CHARACTER SET utf8 NOT NULL default 'media',
  `mode_id` int(11) unsigned NOT NULL,
  `priority` int(3) unsigned NOT NULL DEFAULT '0',
  `effect_dispatch_id` int(11) unsigned,
  `times_to_complete` int(3) unsigned NOT NULL DEFAULT '1',
  `dec_priority_amount` int(3) unsigned NOT NULL DEFAULT '1',
  `inc_priority_amount` int(3) unsigned NOT NULL DEFAULT '0',
  `error_tolerance` int(3) unsigned NOT NULL DEFAULT '0',
  `effective_dt` datetime DEFAULT NULL,
  `expiration_dt` datetime NOT NULL DEFAULT '9999-12-31 23:59:59',
  PRIMARY KEY (`id`),
  KEY `fk_mode_default_dispatch` (`effect_dispatch_id`),
  CONSTRAINT `fk_mode_default_dispatch` FOREIGN KEY (`effect_dispatch_id`) REFERENCES `dispatch` (`id`),
  KEY `fk_mode_default_mode` (`mode_id`),
  CONSTRAINT `fk_mode_default_mode` FOREIGN KEY (`mode_id`) REFERENCES `mode` (`id`));

create view `v_mode_default_dispatch` as
  select m.name, d.package, d.module, d.class_name, d.func_name 
  from mode m, mode_default md, dispatch d
  where md.mode_id = m.id and md.effect_dispatch_id = d.id 
  order by m.name;

CREATE TABLE `mode_state_default` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `index_name` varchar(128) CHARACTER SET utf8 NOT NULL default 'media',
  `mode_id` int(11) unsigned NOT NULL,
  `state_id` int(11) unsigned NOT NULL DEFAULT '0',
  `priority` int(3) unsigned NOT NULL DEFAULT '0',
  `effect_dispatch_id` int(11) unsigned,
  `times_to_complete` int(3) unsigned NOT NULL DEFAULT '1',
  `dec_priority_amount` int(3) unsigned NOT NULL DEFAULT '1',
  `inc_priority_amount` int(3) unsigned NOT NULL DEFAULT '0',
  `error_tolerance` int(3) unsigned NOT NULL DEFAULT '0',
  -- `status` varchar(64) NOT NULL,
  `effective_dt` datetime DEFAULT NULL,
  `expiration_dt` datetime NOT NULL DEFAULT '9999-12-31 23:59:59',
  PRIMARY KEY (`id`),
  -- UNIQUE KEY `mode_state_default_status` (`index_name`,`status`),
  KEY `fk_mode_state_default_dispatch` (`effect_dispatch_id`),
  CONSTRAINT `fk_mode_state_default_dispatch` FOREIGN KEY (`effect_dispatch_id`) REFERENCES `dispatch` (`id`),
  KEY `fk_mode_state_default_mode` (`mode_id`),
  KEY `fk_mode_state_default_state` (`state_id`),
  CONSTRAINT `fk_mode_state_default_mode` FOREIGN KEY (`mode_id`) REFERENCES `mode` (`id`),
  CONSTRAINT `fk_mode_state_default_state` FOREIGN KEY (`state_id`) REFERENCES `state` (`id`)
);

insert into mode_state_default(mode_id, state_id, effect_dispatch_id, effective_dt, priority) values ((select id from mode where name = 'scan'), (select id from state where name = 'discover'), (select id from dispatch where identifier = 'scan.discover'),now(), 5);
insert into mode_state_default(mode_id, state_id, effect_dispatch_id, effective_dt, priority) values ((select id from mode where name = 'scan'), (select id from state where name = 'update'), (select id from dispatch where identifier = 'scan.update'),now(), 5);
insert into mode_state_default(mode_id, state_id, effect_dispatch_id, effective_dt, priority) values ((select id from mode where name = 'scan'), (select id from state where name = 'monitor'), (select id from dispatch where identifier = 'scan.monitor'),now(), 5);

CREATE TABLE `mode_state_default_param` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `index_name` varchar(128) CHARACTER SET utf8 NOT NULL default 'media',
  `mode_state_default_id` int(11) unsigned NOT NULL DEFAULT '0',
  `name` varchar(128) NOT NULL,
  `value` varchar(1024) NOT NULL,
  `effective_dt` datetime DEFAULT NULL,
  `expiration_dt` datetime NOT NULL DEFAULT '9999-12-31 23:59:59',
  PRIMARY KEY (`id`),
  KEY `fk_mode_state_default_param` (`mode_state_default_id`),
  CONSTRAINT `fk_mode_state_default_param` FOREIGN KEY (`mode_state_default_id`) REFERENCES `mode_state_default` (`id`)
);

insert into mode_state_default_param(mode_state_default_id, name, value, effective_dt) values 
  ((select id from mode_state_default where state_id = (select id from state where name = 'discover')), 'high.level.scan', 'true', now());

insert into mode_state_default_param(mode_state_default_id, name, value, effective_dt) values 
  ((select id from mode_state_default where state_id = (select id from state where name = 'update')), 'update.scan', 'true', now());
    
insert into mode_state_default_param(mode_state_default_id, name, value, effective_dt) values 
  ((select id from mode_state_default where state_id = (select id from state where name = 'monitor')), 'deep.scan', 'true', now());


CREATE TABLE `mode_state_default_operation` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `index_name` varchar(128) CHARACTER SET utf8 NOT NULL default 'media',
  `mode_state_default_id` int(11) unsigned NOT NULL DEFAULT '0',
  `operation_id` int(11) unsigned NOT NULL DEFAULT '0',
  `effective_dt` datetime DEFAULT NULL,
  `expiration_dt` datetime NOT NULL DEFAULT '9999-12-31 23:59:59',
  PRIMARY KEY (`id`),
  KEY `fk_mode_state_default_operation_mode_state_default` (`mode_state_default_id`),
  CONSTRAINT `fk_mode_state_default_operation_mode_state_default` FOREIGN KEY (`mode_state_default_id`) REFERENCES `mode_state_default` (`id`),
  KEY `fk_mode_state_default_operation_operation` (`operation_id`),
  CONSTRAINT `fk_mode_state_default_operation_operation` FOREIGN KEY (`operation_id`) REFERENCES `operation` (`id`)
);


DROP VIEW IF EXISTS `v_mode_state_default`;

CREATE VIEW `v_mode_state_default` AS 
  SELECT m.name mode_name, s.name state_name, d.identifier, d.package, d.module, d.class_name, d.func_name, ms.priority, ms.dec_priority_amount, ms.inc_priority_amount, ms.times_to_complete, ms.error_tolerance, 
    ms.effective_dt, ms.expiration_dt
  FROM mode m, state s, mode_state_default ms, dispatch d
  WHERE ms.state_id = s.id
    AND ms.effect_dispatch_id = d.id
    AND ms.mode_id = m.id
    AND ms.index_name = 'media' 
  ORDER BY m.name, s.id;


DROP VIEW IF EXISTS `v_mode_state_default_param`;

CREATE VIEW `v_mode_state_default_param` AS 
  SELECT m.name mode_name, s.name state_name, msp.name, msp.value, msp.effective_dt, msp.expiration_dt
    FROM mode m, state s, mode_state_default ms, mode_state_default_param msp
    WHERE ms.state_id = s.id
      AND ms.mode_id = m.id
      AND msp.mode_state_default_id = ms.id
      AND ms.index_name = 'media' 
    ORDER BY m.name, s.id;

DROP VIEW IF EXISTS `v_mode_state`;

CREATE VIEW `v_mode_state` AS 
  SELECT m.name mode_name, s.name state_name, ms.status, ms.pid, ms.times_activated, ms.times_completed, ms.last_activated, ms.last_completed, 
    ms.error_count, ms.cum_error_count, ms.effective_dt, ms.expiration_dt
  FROM mode m, state s, mode_state ms
  WHERE ms.state_id = s.id
    AND ms.mode_id = m.id
    AND ms.index_name = 'media' 
  ORDER BY ms.effective_dt;


DROP TABLE IF EXISTS `exec_rec`;

CREATE TABLE `exec_rec` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `pid` varchar(32) NOT NULL,
  `index_name` varchar(1024) NOT NULL,
  `status` varchar(128) NOT NULL,
  `start_dt` datetime NOT NULL,
  `end_dt` datetime DEFAULT NULL,
  `effective_dt` datetime NOT NULL,
  `expiration_dt` datetime NOT NULL DEFAULT '9999-12-31 23:59:59',
  PRIMARY KEY (`id`)
);


-- DROP TABLE IF EXISTS `error_attribute_value`;
-- DROP TABLE IF EXISTS `error_attribute`;
-- DROP TABLE IF EXISTS `error`;

-- CREATE TABLE `error` (
--   `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
--   `name` varchar(128) NOT NULL,
--   PRIMARY KEY (`id`)
-- );

-- CREATE TABLE `error_attribute` (
--   `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
--   `error_id` int(11) unsigned NOT NULL,
--   `parent_attribute_id` int(11) DEFAULT NULL,
--   `name` varchar(128) CHARACTER SET utf8 NOT NULL,
--   PRIMARY KEY (`id`),
--   KEY `fk_error_attribute_error` (`error_id`),
--   CONSTRAINT `fk_error_attribute_error` FOREIGN KEY (`error_id`) REFERENCES `error` (`id`)
-- );

-- CREATE TABLE `error_attribute_value` (
--   `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
--   `error_id` int(11) unsigned NOT NULL,
--   `error_attribute_id` int(11) unsigned NOT NULL,
--   `attribute_value` varchar(256) NOT NULL,
--   PRIMARY KEY (`id`),
--   KEY `fk_eav_e` (`error_id`),
--   KEY `fk_eav_ea` (`error_attribute_id`),
--   CONSTRAINT `fk_eav_e` FOREIGN KEY (`error_id`) REFERENCES `error` (`id`),
--   CONSTRAINT `fk_eav_ea` FOREIGN KEY (`error_attribute_id`) REFERENCES `error_attribute` (`id`)
-- );