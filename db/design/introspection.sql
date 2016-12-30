-- drop schema if exists `mildred_introspection`;
-- create schema `mildred_introspection`;
use `mildred_introspection`;

DROP TABLE IF EXISTS `mode_state_default_param`;
-- DROP TABLE IF EXISTS `mode_state_default_operation`;
DROP TABLE IF EXISTS `mode_state_default`;
DROP TABLE IF EXISTS `mode_default`;
DROP TABLE IF EXISTS `mode_state_param`;
DROP TABLE IF EXISTS `mode_state`;
DROP TABLE IF EXISTS `transition_rule`;
DROP TABLE IF EXISTS `switch_rule`;
DROP TABLE IF EXISTS `state`;
DROP TABLE IF EXISTS `mode`;
-- DROP TABLE IF EXISTS `operation`;
-- DROP TABLE IF EXISTS `operator`;
DROP TABLE IF EXISTS `dispatch_target`;
DROP TABLE IF EXISTS `introspection_dispatch`;
DROP TABLE IF EXISTS `exec_rec`;

DROP VIEW IF EXISTS `v_mode_default_dispatch`;
DROP VIEW IF EXISTS `v_mode_default_dispatch_w_id`;
DROP VIEW IF EXISTS `v_mode_dispatch`;
DROP VIEW IF EXISTS `v_mode_state_default_dispatch`;
DROP VIEW IF EXISTS `v_mode_state_default_dispatch_w_id`;
DROP VIEW IF EXISTS `v_mode_state_default_transition_rule_dispatch`;
DROP VIEW IF EXISTS `v_mode_state_default_transition_rule_dispatch_w_id`;
DROP VIEW IF EXISTS `v_mode_switch_rule_dispatch`;
DROP VIEW IF EXISTS `v_mode_switch_rule_dispatch_w_id`;
-- DROP TABLE IF EXISTS op_record;

-- CREATE TABLE `op_record` (
--   `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
--   `index_name` varchar(128) CHARACTER SET utf8 NOT NULL,
--   `pid` varchar(32) NOT NULL,
--   `operator_name` varchar(64) NOT NULL,
--   `operation_name` varchar(64) NOT NULL,
--   `target_esid` varchar(64) NOT NULL,
--   `target_path` varchar(1024) NOT NULL,
--   `status` varchar(64) NOT NULL,
--   `start_time` datetime NOT NULL,
--   `end_time` datetime DEFAULT NULL,
--   `effective_dt` datetime DEFAULT NULL,
--   `expiration_dt` datetime NOT NULL DEFAULT '9999-12-31 23:59:59',
--   `target_hexadecimal_key` varchar(640) CHARACTER SET utf8 DEFAULT NULL,
--   PRIMARY KEY (`id`)
-- );

DROP TABLE IF EXISTS `op_record_param`;
DROP TABLE IF EXISTS `op_record_param_type`;

CREATE TABLE IF NOT EXISTS `op_record_param_type` (
  `id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `vector_param_name` VARCHAR(128) NOT NULL,
  PRIMARY KEY (`id`)
);


CREATE TABLE IF NOT EXISTS `op_record_param` (
  `id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `param_type_id` int(11) UNSIGNED NOT NULL,
  `op_record_id` INT(11) UNSIGNED NOT NULL,
  `name` VARCHAR(128) NOT NULL,
  `value` VARCHAR(1024) NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_op_record_param_type_idx` (`param_type_id` ASC),
  CONSTRAINT `fk_op_record_param_type`
    FOREIGN KEY (`param_type_id`)
    REFERENCES `op_record_param_type` (`id`),
  INDEX `fk_op_record_param` (`op_record_id` ASC),
  CONSTRAINT `fk_op_record_param`
    FOREIGN KEY (`op_record_id`)
    REFERENCES `op_record` (`id`)
);
    
CREATE TABLE `introspection_dispatch` (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `identifier` varchar(128) DEFAULT NULL,
  `category` varchar(128) DEFAULT NULL,
  `package` varchar(128) DEFAULT NULL,
  `module` varchar(128) NOT NULL,
  `class_name` varchar(128) DEFAULT NULL,
  `func_name` varchar(128) NOT NULL,
  PRIMARY KEY (`id`)
);

# service process
INSERT INTO introspection_dispatch (identifier, category, module, func_name) VALUES ('service', 'process', 'mockserv', 'create_service_process');
INSERT INTO introspection_dispatch (identifier, category, module, class_name) VALUES ('service', 'process.handler', 'mockserv', 'DocumentServiceProcessHandler');
INSERT INTO introspection_dispatch (identifier, category, module, class_name, func_name) VALUES ('service', 'process.before', 'mockserv', 'DocumentServiceProcessHandler', 'before_switch');
INSERT INTO introspection_dispatch (identifier, category, module, class_name, func_name) VALUES ('service', 'process.after', 'mockserv', 'DocumentServiceProcessHandler', 'after_switch');

# modes
INSERT INTO introspection_dispatch (identifier, category, module, class_name, func_name) VALUES ('startup', 'effect', 'mockserv', 'StartupHandler', 'start'); 
INSERT INTO introspection_dispatch (identifier, category, module, class_name, func_name) VALUES ('startup.switch.condition', 'condition', 'mockserv', 'DocumentServiceProcessHandler', 'definitely');
INSERT INTO introspection_dispatch (identifier, category, module, class_name, func_name) VALUES ('startup.switch.before', 'switch', 'mockserv', 'StartupHandler', 'starting'); 
INSERT INTO introspection_dispatch (identifier, category, module, class_name, func_name) VALUES ('startup.switch.after', 'switch', 'mockserv', 'StartupHandler', 'started'); 

INSERT INTO introspection_dispatch (identifier, category, module, class_name, func_name) VALUES ('eval', 'effect', 'mockserv', 'EvalModeHandler', 'do_eval'); 
INSERT INTO introspection_dispatch (identifier, category, module, class_name, func_name) VALUES ('eval.switch.condition', 'condition', 'mockserv', 'DocumentServiceProcessHandler', 'mode_is_available');
INSERT INTO introspection_dispatch (identifier, category, module, class_name, func_name) VALUES ('eval.switch.before', 'switch', 'mockserv', 'EvalModeHandler', 'before_eval'); 
INSERT INTO introspection_dispatch (identifier, category, module, class_name, func_name) VALUES ('eval.switch.after', 'switch', 'mockserv', 'EvalModeHandler', 'after_eval'); 

INSERT INTO introspection_dispatch (identifier, category, module, class_name, func_name) VALUES ('scan.update.condition', 'condition', 'mockserv', 'ScanModeHandler', 'should_update');
INSERT INTO introspection_dispatch (identifier, category, module, class_name, func_name) VALUES ('scan.monitor.condition', 'condition', 'mockserv', 'ScanModeHandler', 'should_monitor');
INSERT INTO introspection_dispatch (identifier, category, module, class_name, func_name) VALUES ('scan.switch.condition', 'condition', 'mockserv', 'ScanModeHandler', 'can_scan');
INSERT INTO introspection_dispatch (identifier, category, module, class_name, func_name) VALUES ('scan', 'effect', 'mockserv', 'ScanModeHandler', 'do_scan');
INSERT INTO introspection_dispatch (identifier, category, module, class_name, func_name) VALUES ('scan.discover', 'action', 'mockserv', 'ScanModeHandler', 'do_scan_discover');
INSERT INTO introspection_dispatch (identifier, category, module, class_name, func_name) VALUES ('scan.update', 'action', 'mockserv', 'ScanModeHandler', 'do_scan');
INSERT INTO introspection_dispatch (identifier, category, module, class_name, func_name) VALUES ('scan.monitor', 'action', 'mockserv', 'ScanModeHandler', 'do_scan_monitor');
INSERT INTO introspection_dispatch (identifier, category, module, class_name, func_name) VALUES ('scan.switch.before', 'switch', 'mockserv', 'ScanModeHandler', 'before_scan'); 
INSERT INTO introspection_dispatch (identifier, category, module, class_name, func_name) VALUES ('scan.switch.after', 'switch', 'mockserv', 'ScanModeHandler', 'after_scan'); 

INSERT INTO introspection_dispatch (identifier, category, module, class_name, func_name) VALUES ('match', 'effect', 'mockserv', 'MatchModeHandler', 'do_match'); 
INSERT INTO introspection_dispatch (identifier, category, module, class_name, func_name) VALUES ('match.switch.condition', 'condition', 'mockserv', 'DocumentServiceProcessHandler', 'mode_is_available');
INSERT INTO introspection_dispatch (identifier, category, module, class_name, func_name) VALUES ('match.switch.before', 'switch', 'mockserv', 'MatchModeHandler', 'before_match'); 
INSERT INTO introspection_dispatch (identifier, category, module, class_name, func_name) VALUES ('match.switch.after', 'switch', 'mockserv', 'MatchModeHandler', 'after_match'); 

INSERT INTO introspection_dispatch (identifier, category, module, class_name, func_name) VALUES ('fix.switch.condition', 'condition', 'mockserv', 'DocumentServiceProcessHandler', 'mode_is_available');
INSERT INTO introspection_dispatch (identifier, category, module, class_name, func_name) VALUES ('fix', 'effect', 'mockserv', 'FixModeHandler', 'do_fix'); 
INSERT INTO introspection_dispatch (identifier, category, module, class_name, func_name) VALUES ('fix.switch.before', 'switch', 'mockserv', 'FixModeHandler', 'before_fix'); 
INSERT INTO introspection_dispatch (identifier, category, module, class_name, func_name) VALUES ('fix.switch.after', 'switch', 'mockserv', 'FixModeHandler', 'after_fix'); 

INSERT INTO introspection_dispatch (identifier, category, module, class_name, func_name) VALUES ('report.switch.condition', 'condition', 'mockserv', 'DocumentServiceProcessHandler', 'mode_is_available');
INSERT INTO introspection_dispatch (identifier, category, module, class_name, func_name) VALUES ('report', 'effect', 'mockserv', 'ReportModeHandler', 'do_report'); 
INSERT INTO introspection_dispatch (identifier, category, module, class_name, func_name) VALUES ('report.switch.before', 'switch', 'mockserv', 'DocumentServiceProcessHandler', 'before'); 
INSERT INTO introspection_dispatch (identifier, category, module, class_name, func_name) VALUES ('report.switch.after', 'switch', 'mockserv', 'DocumentServiceProcessHandler', 'after'); 

INSERT INTO introspection_dispatch (identifier, category, module, class_name, func_name) VALUES ('requests', 'effect', 'mockserv', 'RequestsModeHandler', 'do_reqs'); 
INSERT INTO introspection_dispatch (identifier, category, module, class_name, func_name) VALUES ('requests.switch.condition', 'condition', 'mockserv', 'DocumentServiceProcessHandler', 'mode_is_available');
INSERT INTO introspection_dispatch (identifier, category, module, class_name, func_name) VALUES ('requests.switch.before', 'switch', 'mockserv', 'DocumentServiceProcessHandler', 'before'); 
INSERT INTO introspection_dispatch (identifier, category, module, class_name, func_name) VALUES ('requests.switch.after', 'switch', 'mockserv', 'DocumentServiceProcessHandler', 'after'); 

INSERT INTO introspection_dispatch (identifier, category, module, class_name, func_name) VALUES ('shutdown', 'effect', 'mockserv', 'ShutdownHandler', 'end'); 
INSERT INTO introspection_dispatch (identifier, category, module, class_name, func_name) VALUES ('shutdown.switch.before', 'switch', 'mockserv', 'ShutdownHandler', 'ending'); 
INSERT INTO introspection_dispatch (identifier, category, module, class_name, func_name) VALUES ('shutdown.switch.after', 'switch', 'mockserv', 'ShutdownHandler', 'ended'); 
INSERT INTO introspection_dispatch (identifier, category, module, class_name, func_name) VALUES ('shutdown.switch.condition', 'condition', 'mockserv', 'DocumentServiceProcessHandler', 'maybe'); 


-- CREATE TABLE `dispatch_target` (
--   `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,s
--   `dispatch_id` int(11) UNSIGNED NOT NULL,
--   `target` varchar(128) DEFAULT NULL,
--   PRIMARY KEY (`id`),
--   KEY `fk_dispatch_target_dispatch` (`dispatch_id`),
--   CONSTRAINT `fk_dispatch_target_dispatch` FOREIGN KEY (`dispatch_id`) REFERENCES `introspection_dispatch` (`id`)
-- );

-- DROP VIEW IF EXISTS `v_dispatch_target`;

-- create view `v_dispatch_target` as
--   select d.identifier, d.package, d.module, d.class_name, d.func_name, dt.target
--   from introspection_dispatch d, dispatch_target dt
--   where dt.dispatch_id = d.id
--   order by d.identifier;

-- CREATE TABLE `operator` (
--   `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
--   `index_name` varchar(128) CHARACTER SET utf8 NOT NULL,
--   `name` varchar(128) NOT NULL,
--   `effective_dt` datetime DEFAULT NULL,
--   `expiration_dt` datetime NOT NULL DEFAULT '9999-12-31 23:59:59',
--   PRIMARY KEY (`id`)
-- );

-- INSERT INTO operator (index_name, name, effective_dt) VALUES ('media', 'scan', now());
-- INSERT INTO operator (index_name, name, effective_dt) VALUES ('media', 'calc', now());
-- INSERT INTO operator (index_name, name, effective_dt) VALUES ('media', 'clean', now());
-- INSERT INTO operator (index_name, name, effective_dt) VALUES ('media', 'eval', now());
-- INSERT INTO operator (index_name, name, effective_dt) VALUES ('media', 'fix', now());
-- INSERT INTO operator (index_name, name, effective_dt) VALUES ('media', 'report', now());

-- CREATE TABLE `operation` (
--   `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
--   `index_name` varchar(128) CHARACTER SET utf8 NOT NULL,
--   `operator_id` int(11) UNSIGNED NOT NULL,
--   `name` varchar(128) NOT NULL,
--   `effective_dt` datetime DEFAULT NULL,
--   `expiration_dt` datetime NOT NULL DEFAULT '9999-12-31 23:59:59',
--   PRIMARY KEY (`id`),
--   KEY `fk_operation_operator` (`operator_id`),
--   CONSTRAINT `fk_operation_operator` FOREIGN KEY (`operator_id`) REFERENCES `operator` (`id`)
-- );

-- INSERT INTO operation (index_name, name, operator, effective_dt) VALUES ('media', 'scan', (select id from operator where name = 'scan'), now());
-- INSERT INTO operation (index_name, name, operator_id, effective_dt) VALUES ('media', 'discover', (select id from operator where name = 'scan'), now());
-- INSERT INTO operation (index_name, name, operator_id, effective_dt) VALUES ('media', 'update', (select id from operator where name = 'scan'), now());
-- INSERT INTO operation (index_name, name, operator_id, effective_dt) VALUES ('media', 'monitor', (select id from operator where name = 'scan'), now());
-- INSERT INTO operation (index_name, name, operator, effective_dt) VALUES ('media', 'fix', (select id from operator where name = 'fix'), now());
-- INSERT INTO operation (index_name, name, operator, effective_dt) VALUES ('media', 'eval', (select id from operator where name = 'eval'), now());
-- INSERT INTO operation (index_name, name, operator, effective_dt) VALUES ('media', 'clean', (select id from operator where name = 'clean'), now());

-- INSERT INTO operation (index_name, name, effective_dt) VALUES ('media', 'clean', now());
-- INSERT INTO operation (index_name, name, effective_dt) VALUES ('media', 'eval', now());
-- INSERT INTO operation (index_name, name, effective_dt) VALUES ('media', 'fix', now());
-- INSERT INTO operation (index_name, name, effective_dt) VALUES ('media', 'match', now());
-- INSERT INTO operation (index_name, name, effective_dt) VALUES ('media', 'scan', now());
-- INSERT INTO operation (index_name, name, effective_dt) VALUES ('media', 'sync', now());
-- INSERT INTO operation (index_name, name, effective_dt) VALUES ('media', 'report', now());
-- INSERT INTO operation (index_name, name, effective_dt) VALUES ('media', 'requests', now());


CREATE TABLE `mode` (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `index_name` varchar(128) CHARACTER SET utf8 NOT NULL,
  `name` varchar(128) NOT NULL,
  `stateful_flag` boolean NOT NULL DEFAULT False,
  `effective_dt` datetime DEFAULT NULL,
  `expiration_dt` datetime NOT NULL DEFAULT '9999-12-31 23:59:59',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_mode_name` (`index_name`,`name`)
);

SET @NONE = 'None';
INSERT INTO mode (index_name, name, effective_dt) VALUES ('media', @NONE, now());
INSERT INTO mode (index_name, name, effective_dt) VALUES ('media', 'startup', now());
INSERT INTO mode (index_name, name, stateful_flag, effective_dt) VALUES ('media', 'scan', True, now());
INSERT INTO mode (index_name, name, effective_dt) VALUES ('media', 'match', now());
INSERT INTO mode (index_name, name, effective_dt) VALUES ('media', 'eval', now());
INSERT INTO mode (index_name, name, effective_dt) VALUES ('media', 'fix', now());
INSERT INTO mode (index_name, name, effective_dt) VALUES ('media', 'clean', now());
INSERT INTO mode (index_name, name, effective_dt) VALUES ('media', 'sync', now());
INSERT INTO mode (index_name, name, effective_dt) VALUES ('media', 'requests', now());
INSERT INTO mode (index_name, name, effective_dt) VALUES ('media', 'report', now());
INSERT INTO mode (index_name, name, effective_dt) VALUES ('media', 'sleep', now());
INSERT INTO mode (index_name, name, effective_dt) VALUES ('media', 'shutdown', now());

CREATE TABLE `state` (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `index_name` varchar(128) CHARACTER SET utf8 NOT NULL default 'media',
  `name` varchar(128) NOT NULL,
  `terminal_state_flag` tinyint(1) NOT NULL DEFAULT '0',
  `initial_state_flag` tinyint(1) NOT NULL DEFAULT '0',
  `effective_dt` datetime DEFAULT NULL,
  `expiration_dt` datetime DEFAULT '9999-12-31 23:59:59',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_state_name` (`index_name`,`name`)
);

INSERT INTO state(index_name, name, effective_dt, initial_state_flag) VALUES ('media', 'initial', now(), 1);
INSERT INTO state(index_name, name, effective_dt, initial_state_flag) VALUES ('media', 'discover', now(), 1);
INSERT INTO state(index_name, name, effective_dt) VALUES ('media', 'update', now());
INSERT INTO state(index_name, name, effective_dt) VALUES ('media', 'monitor', now());
INSERT INTO state(index_name, name, effective_dt, initial_state_flag) VALUES ('media', 'terminal', now(), 2);


CREATE TABLE `transition_rule` (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  -- `index_name` varchar(128) CHARACTER SET utf8 NOT NULL,
  `name` varchar(128) NOT NULL,
  `mode_id` int(11) UNSIGNED NOT NULL,
  `begin_state_id` int(11) UNSIGNED NOT NULL,
  `end_state_id` int(11) UNSIGNED NOT NULL,
  `condition_dispatch_id` int(11) UNSIGNED NOT NULL,
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
  CONSTRAINT `fk_transition_rule_condition_dispatch` FOREIGN KEY (`condition_dispatch_id`) REFERENCES `introspection_dispatch` (`id`)
  -- UNIQUE KEY `uk_rule_name` (`index_name`,`name`)
);


CREATE TABLE `switch_rule` (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  -- `index_name` varchar(128) CHARACTER SET utf8 NOT NULL,
  `name` varchar(128) NOT NULL,
  `begin_mode_id` int(11) UNSIGNED NOT NULL,
  `end_mode_id` int(11) UNSIGNED NOT NULL,
  `condition_dispatch_id` int(11) UNSIGNED,
  `before_dispatch_id` int(11) UNSIGNED NOT NULL,
  `after_dispatch_id` int(11) UNSIGNED NOT NULL,
  -- `effective_dt` datetime DEFAULT NULL,
  -- `expiration_dt` datetime NOT NULL DEFAULT '9999-12-31 23:59:59',
  PRIMARY KEY (`id`),
  KEY `fk_switch_rule_begin_mode` (`begin_mode_id`),
  CONSTRAINT `fk_switch_rule_begin_mode` FOREIGN KEY (`begin_mode_id`) REFERENCES `mode` (`id`),
  KEY `fk_switch_rule_end_mode` (`end_mode_id`),
  CONSTRAINT `fk_switch_rule_end_mode` FOREIGN KEY (`end_mode_id`) REFERENCES `mode` (`id`),
  KEY `fk_switch_rule_before_dispatch` (`before_dispatch_id`),
  CONSTRAINT `fk_switch_rule_before_dispatch` FOREIGN KEY (`before_dispatch_id`) REFERENCES `introspection_dispatch` (`id`),
  KEY `fk_switch_rule_condition_dispatch` (`condition_dispatch_id`),
  CONSTRAINT `fk_switch_rule_condition_dispatch` FOREIGN KEY (`condition_dispatch_id`) REFERENCES `introspection_dispatch` (`id`),
  KEY `fk_switch_rule_after_dispatch` (`after_dispatch_id`),
  CONSTRAINT `fk_switch_rule_after_dispatch` FOREIGN KEY (`after_dispatch_id`) REFERENCES `introspection_dispatch` (`id`)
  -- UNIQUE KEY `uk_switch_rule_name` (`index_name`,`name`)
);

create view `v_mode_switch_rule_dispatch` as
select sr.name, m1.name begin_mode, m2.name end_mode, 
    d1.package condition_package, d1.module condition_module, d1.class_name condition_class, d1.func_name condition_func, 
    d2.package before_package, d2.module before_module, d2.class_name before_class, d2.func_name before_func, 
    d3.package after_package, d3.module after_module, d3.class_name after_class, d3.func_name after_func
 from mode m1, mode m2, switch_rule sr, introspection_dispatch d1, introspection_dispatch d2, introspection_dispatch d3
where sr.begin_mode_id = m1.id and 
    sr.end_mode_id = m2.id and 
    sr.condition_dispatch_id = d1.id and
    sr.before_dispatch_id = d2.id and
    sr.after_dispatch_id = d3.id
order by m1.id;

create view `v_mode_switch_rule_dispatch_w_id` as
select sr.name, m1.id begin_mode_id, m1.name begin_mode, m2.id end_mode_id, m2.name end_mode, 
    d1.package condition_package, d1.module condition_module, d1.class_name condition_class, d1.func_name condition_func, 
    d2.package before_package, d2.module before_module, d2.class_name before_class, d2.func_name before_func, 
    d3.package after_package, d3.module after_module, d3.class_name after_class, d3.func_name after_func
 from mode m1, mode m2, switch_rule sr, introspection_dispatch d1, introspection_dispatch d2, introspection_dispatch d3
where sr.begin_mode_id = m1.id and 
    sr.end_mode_id = m2.id and 
    sr.condition_dispatch_id = d1.id and
    sr.before_dispatch_id = d2.id and
    sr.after_dispatch_id = d3.id
order by m1.id;

INSERT INTO transition_rule(name, mode_id, begin_state_id, end_state_id, condition_dispatch_id)
    VALUES('scan.discover::update',
        (select id from mode where name = 'scan'),
        (select id from state where name = 'discover'),
        (select id from state where name = 'update'),
        (select id from introspection_dispatch where identifier = 'scan.update.condition')
    );
    
INSERT INTO transition_rule(name, mode_id, begin_state_id, end_state_id, condition_dispatch_id)
    VALUES('scan.update::monitor',
        (select id from mode where name = 'scan'),
        (select id from state where name = 'update'),
        (select id from state where name = 'monitor'),
        (select id from introspection_dispatch where identifier = 'scan.monitor.condition')
    );
    
CREATE TABLE `mode_state` (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `index_name` varchar(128) CHARACTER SET utf8 NOT NULL default 'media',
  `pid` varchar(32) NOT NULL,
  `mode_id` int(11) UNSIGNED NOT NULL,
  `state_id` int(11) UNSIGNED NOT NULL DEFAULT '0',
  `times_activated` int(11) UNSIGNED NOT NULL DEFAULT '0',
  `times_completed` int(11) UNSIGNED NOT NULL DEFAULT '0',
  `error_count` int(3) UNSIGNED NOT NULL DEFAULT '0',
  `cum_error_count` int(11) UNSIGNED NOT NULL DEFAULT '0',
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
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `index_name` varchar(128) CHARACTER SET utf8 NOT NULL default 'media',
  `mode_id` int(11) UNSIGNED NOT NULL,
  `priority` int(3) UNSIGNED NOT NULL DEFAULT '0',
  `effect_dispatch_id` int(11) UNSIGNED,
  `times_to_complete` int(3) UNSIGNED NOT NULL DEFAULT '1',
  `dec_priority_amount` int(3) UNSIGNED NOT NULL DEFAULT '1',
  `inc_priority_amount` int(3) UNSIGNED NOT NULL DEFAULT '0',
  `error_tolerance` int(3) UNSIGNED NOT NULL DEFAULT '0',
  `effective_dt` datetime DEFAULT NULL,
  `expiration_dt` datetime NOT NULL DEFAULT '9999-12-31 23:59:59',
  PRIMARY KEY (`id`),
  KEY `fk_mode_default_dispatch` (`effect_dispatch_id`),
  CONSTRAINT `fk_mode_default_dispatch` FOREIGN KEY (`effect_dispatch_id`) REFERENCES `introspection_dispatch` (`id`),
  KEY `fk_mode_default_mode` (`mode_id`),
  CONSTRAINT `fk_mode_default_mode` FOREIGN KEY (`mode_id`) REFERENCES `mode` (`id`));

INSERT INTO mode_default(mode_id, effect_dispatch_id, effective_dt, priority) VALUES ((select id from mode where name = 'startup'), (select id from introspection_dispatch where identifier = 'startup'),now(), 0);
INSERT INTO mode_default(mode_id, effect_dispatch_id, effective_dt, priority) VALUES ((select id from mode where name = 'eval'), (select id from introspection_dispatch where identifier = 'eval'),now(), 3);
INSERT INTO mode_default(mode_id, effect_dispatch_id, effective_dt, priority) VALUES ((select id from mode where name = 'match'), (select id from introspection_dispatch where identifier = 'match'),now(), 5);
INSERT INTO mode_default(mode_id, effect_dispatch_id, effective_dt, priority) VALUES ((select id from mode where name = 'scan'), (select id from introspection_dispatch where identifier = 'scan'),now(), 5);
INSERT INTO mode_default(mode_id, effect_dispatch_id, effective_dt, priority) VALUES ((select id from mode where name = 'fix'), (select id from introspection_dispatch where identifier = 'fix'),now(), 1);
INSERT INTO mode_default(mode_id, effect_dispatch_id, effective_dt, priority) VALUES ((select id from mode where name = 'clean'), (select id from introspection_dispatch where identifier = 'clean'),now(), 1);
INSERT INTO mode_default(mode_id, effect_dispatch_id, effective_dt, priority) VALUES ((select id from mode where name = 'requests'), (select id from introspection_dispatch where identifier = 'requests'),now(), 2);
INSERT INTO mode_default(mode_id, effect_dispatch_id, effective_dt, priority) VALUES ((select id from mode where name = 'report'), (select id from introspection_dispatch where identifier = 'report'),now(), 2);
INSERT INTO mode_default(mode_id, effect_dispatch_id, effective_dt, priority) VALUES ((select id from mode where name = 'shutdown'), (select id from introspection_dispatch where identifier = 'shutdown'),now(), 0);

create view `v_mode_default_dispatch` as
  select m.name, d.package, d.module, d.class_name, d.func_name, md.priority, md.dec_priority_amount, md.inc_priority_amount, md.times_to_complete, md.error_tolerance 
  from mode m, mode_default md, introspection_dispatch d
  where md.mode_id = m.id and md.effect_dispatch_id = d.id 
  order by m.name;

create view `v_mode_default_dispatch_w_id` as
  select m.id mode_id, m.name mode_name, m.stateful_flag, d.package  handler_package, d.module handler_module, d.class_name handler_class, d.func_name handler_func, 
    md.priority, md.dec_priority_amount, md.inc_priority_amount, md.times_to_complete, md.error_tolerance 
  from mode m, mode_default md, introspection_dispatch d
  where md.mode_id = m.id and md.effect_dispatch_id = d.id 
  order by m.name;

CREATE TABLE `mode_state_default` (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `index_name` varchar(128) CHARACTER SET utf8 NOT NULL default 'media',
  `mode_id` int(11) UNSIGNED NOT NULL,
  `state_id` int(11) UNSIGNED NOT NULL DEFAULT '0',
  `priority` int(3) UNSIGNED NOT NULL DEFAULT '0',
  `effect_dispatch_id` int(11) UNSIGNED,
  `times_to_complete` int(3) UNSIGNED NOT NULL DEFAULT '1',
  `dec_priority_amount` int(3) UNSIGNED NOT NULL DEFAULT '1',
  `inc_priority_amount` int(3) UNSIGNED NOT NULL DEFAULT '0',
  `error_tolerance` int(3) UNSIGNED NOT NULL DEFAULT '0',
  -- `status` varchar(64) NOT NULL,
  `effective_dt` datetime DEFAULT NULL,
  `expiration_dt` datetime NOT NULL DEFAULT '9999-12-31 23:59:59',
  PRIMARY KEY (`id`),
  -- UNIQUE KEY `mode_state_default_status` (`index_name`,`status`),
  KEY `fk_mode_state_default_dispatch` (`effect_dispatch_id`),
  CONSTRAINT `fk_mode_state_default_dispatch` FOREIGN KEY (`effect_dispatch_id`) REFERENCES `introspection_dispatch` (`id`),
  KEY `fk_mode_state_default_mode` (`mode_id`),
  KEY `fk_mode_state_default_state` (`state_id`),
  CONSTRAINT `fk_mode_state_default_mode` FOREIGN KEY (`mode_id`) REFERENCES `mode` (`id`),
  CONSTRAINT `fk_mode_state_default_state` FOREIGN KEY (`state_id`) REFERENCES `state` (`id`)
);

INSERT INTO mode_state_default(mode_id, state_id, effect_dispatch_id, effective_dt, priority) VALUES ((select id from mode where name = 'scan'), (select id from state where name = 'discover'), (select id from introspection_dispatch where identifier = 'scan.discover'),now(), 5);
INSERT INTO mode_state_default(mode_id, state_id, effect_dispatch_id, effective_dt, priority) VALUES ((select id from mode where name = 'scan'), (select id from state where name = 'update'), (select id from introspection_dispatch where identifier = 'scan.update'),now(), 5);
INSERT INTO mode_state_default(mode_id, state_id, effect_dispatch_id, effective_dt, priority) VALUES ((select id from mode where name = 'scan'), (select id from state where name = 'monitor'), (select id from introspection_dispatch where identifier = 'scan.monitor'),now(), 5);

create view `v_mode_state_default_transition_rule_dispatch` as
select tr.name, m.name mode, s1.name begin_state, s2.name end_state, 
    d1.package condition_package, d1.module condition_module, d1.class_name condition_class, d1.func_name condition_func
 from mode m, mode_state_default md, transition_rule tr, state s1, state s2, introspection_dispatch d1
where m.id = md.mode_id and md.state_id = s1.id and
    tr.begin_state_id = s1.id and 
    tr.end_state_id = s2.id and 
    tr.condition_dispatch_id = d1.id;

create view `v_mode_state_default_transition_rule_dispatch_w_id` as
select tr.name, m.id mode_id, m.name mode, s1.id begin_state_id, s1.name begin_state, s2.id end_state_id, s2.name end_state, 
    d1.package condition_package, d1.module condition_module, d1.class_name condition_class, d1.func_name condition_func
 from mode m, mode_state_default md, transition_rule tr, state s1, state s2, introspection_dispatch d1
where m.id = md.mode_id and md.state_id = s1.id and
    tr.begin_state_id = s1.id and 
    tr.end_state_id = s2.id and 
    tr.condition_dispatch_id = d1.id;

-- order by m.id;

INSERT INTO switch_rule(name, begin_mode_id, end_mode_id, condition_dispatch_id, before_dispatch_id, after_dispatch_id)
    VALUES('startup',
        (select id from mode where name = @NONE),
        (select id from mode where name = 'startup'),
        (select id from introspection_dispatch where identifier = 'startup.switch.condition'),
        (select id from introspection_dispatch where identifier = 'startup.switch.before'),
        (select id from introspection_dispatch where identifier = 'startup.switch.after')
    );


# paths to eval

INSERT INTO switch_rule(name, begin_mode_id, end_mode_id, condition_dispatch_id, before_dispatch_id, after_dispatch_id)
    VALUES('startup.eval',
        (select id from mode where name = 'startup'),
        (select id from mode where name = 'eval'),
        (select id from introspection_dispatch where identifier = 'eval.switch.condition'),
        (select id from introspection_dispatch where identifier = 'eval.switch.before'),
        (select id from introspection_dispatch where identifier = 'eval.switch.after')
    );

INSERT INTO switch_rule(name, begin_mode_id, end_mode_id, condition_dispatch_id, before_dispatch_id, after_dispatch_id)
    VALUES('scan.eval',
        (select id from mode where name = 'scan'),
        (select id from mode where name = 'eval'),
        (select id from introspection_dispatch where identifier = 'eval.switch.condition'),
        (select id from introspection_dispatch where identifier = 'eval.switch.before'),
        (select id from introspection_dispatch where identifier = 'eval.switch.after')
    );

INSERT INTO switch_rule(name, begin_mode_id, end_mode_id, condition_dispatch_id, before_dispatch_id, after_dispatch_id)
    VALUES('match.eval',
        (select id from mode where name = 'match'),
        (select id from mode where name = 'eval'),
        (select id from introspection_dispatch where identifier = 'eval.switch.condition'),
        (select id from introspection_dispatch where identifier = 'eval.switch.before'),
        (select id from introspection_dispatch where identifier = 'eval.switch.after')
    );

INSERT INTO switch_rule(name, begin_mode_id, end_mode_id, condition_dispatch_id, before_dispatch_id, after_dispatch_id)
    VALUES('requests.eval',
        (select id from mode where name = 'requests'),
        (select id from mode where name = 'eval'),
        (select id from introspection_dispatch where identifier = 'eval.switch.condition'),
        (select id from introspection_dispatch where identifier = 'eval.switch.before'),
        (select id from introspection_dispatch where identifier = 'eval.switch.after')
    );

INSERT INTO switch_rule(name, begin_mode_id, end_mode_id, condition_dispatch_id, before_dispatch_id, after_dispatch_id)
    VALUES('report.eval',
        (select id from mode where name = 'report'),
        (select id from mode where name = 'eval'),
        (select id from introspection_dispatch where identifier = 'eval.switch.condition'),
        (select id from introspection_dispatch where identifier = 'eval.switch.before'),
        (select id from introspection_dispatch where identifier = 'eval.switch.after')
    );

INSERT INTO switch_rule(name, begin_mode_id, end_mode_id, condition_dispatch_id, before_dispatch_id, after_dispatch_id)
    VALUES('fix.eval',
        (select id from mode where name = 'fix'),
        (select id from mode where name = 'eval'),
        (select id from introspection_dispatch where identifier = 'eval.switch.condition'),
        (select id from introspection_dispatch where identifier = 'eval.switch.before'),
        (select id from introspection_dispatch where identifier = 'eval.switch.after')
    );

# paths to scan

INSERT INTO switch_rule(name, begin_mode_id, end_mode_id, condition_dispatch_id, before_dispatch_id, after_dispatch_id)
    VALUES('startup.scan',
        (select id from mode where name = 'startup'),
        (select id from mode where name = 'scan'),
        (select id from introspection_dispatch where identifier = 'scan.switch.condition'),
        (select id from introspection_dispatch where identifier = 'scan.switch.before'),
        (select id from introspection_dispatch where identifier = 'scan.switch.after')
    );
    
INSERT INTO switch_rule(name, begin_mode_id, end_mode_id, condition_dispatch_id, before_dispatch_id, after_dispatch_id)
    VALUES('startup.scan',
        (select id from mode where name = 'startup'),
        (select id from mode where name = 'scan'),
        (select id from introspection_dispatch where identifier = 'scan.switch.condition'),
        (select id from introspection_dispatch where identifier = 'scan.switch.before'),
        (select id from introspection_dispatch where identifier = 'scan.switch.after')
    );
    
INSERT INTO switch_rule(name, begin_mode_id, end_mode_id, condition_dispatch_id, before_dispatch_id, after_dispatch_id)
    VALUES('eval.scan',
        (select id from mode where name = 'eval'),
        (select id from mode where name = 'scan'),
        (select id from introspection_dispatch where identifier = 'scan.switch.condition'),
        (select id from introspection_dispatch where identifier = 'scan.switch.before'),
        (select id from introspection_dispatch where identifier = 'scan.switch.after')
    );
    
INSERT INTO switch_rule(name, begin_mode_id, end_mode_id, condition_dispatch_id, before_dispatch_id, after_dispatch_id)
    VALUES('scan.scan',
        (select id from mode where name = 'scan'),
        (select id from mode where name = 'scan'),
        (select id from introspection_dispatch where identifier = 'scan.switch.condition'),
        (select id from introspection_dispatch where identifier = 'scan.switch.before'),
        (select id from introspection_dispatch where identifier = 'scan.switch.after')
    );
    
# paths to match

INSERT INTO switch_rule(name, begin_mode_id, end_mode_id, condition_dispatch_id, before_dispatch_id, after_dispatch_id)
    VALUES('startup.match',
        (select id from mode where name = 'startup'),
        (select id from mode where name = 'match'),
        (select id from introspection_dispatch where identifier = 'match.switch.condition'),
        (select id from introspection_dispatch where identifier = 'match.switch.before'),
        (select id from introspection_dispatch where identifier = 'match.switch.after')
    );

INSERT INTO switch_rule(name, begin_mode_id, end_mode_id, condition_dispatch_id, before_dispatch_id, after_dispatch_id)
    VALUES('eval.match',
        (select id from mode where name = 'eval'),
        (select id from mode where name = 'match'),
        (select id from introspection_dispatch where identifier = 'match.switch.condition'),
        (select id from introspection_dispatch where identifier = 'match.switch.before'),
        (select id from introspection_dispatch where identifier = 'match.switch.after')
    );


INSERT INTO switch_rule(name, begin_mode_id, end_mode_id, condition_dispatch_id, before_dispatch_id, after_dispatch_id)
    VALUES('scan.match',
        (select id from mode where name = 'scan'),
        (select id from mode where name = 'match'),
        (select id from introspection_dispatch where identifier = 'match.switch.condition'),
        (select id from introspection_dispatch where identifier = 'match.switch.before'),
        (select id from introspection_dispatch where identifier = 'match.switch.after')
    );

# paths to report

INSERT INTO switch_rule(name, begin_mode_id, end_mode_id, condition_dispatch_id, before_dispatch_id, after_dispatch_id)
    VALUES('fix.report',
        (select id from mode where name = 'fix'),
        (select id from mode where name = 'report'),
        (select id from introspection_dispatch where identifier = 'report.switch.condition'),
        (select id from introspection_dispatch where identifier = 'report.switch.before'),
        (select id from introspection_dispatch where identifier = 'report.switch.after')
    );

INSERT INTO switch_rule(name, begin_mode_id, end_mode_id, condition_dispatch_id, before_dispatch_id, after_dispatch_id)
    VALUES('requests.report',
        (select id from mode where name = 'requests'),
        (select id from mode where name = 'report'),
        (select id from introspection_dispatch where identifier = 'report.switch.condition'),
        (select id from introspection_dispatch where identifier = 'report.switch.before'),
        (select id from introspection_dispatch where identifier = 'report.switch.after')
    );

# paths to requests

INSERT INTO switch_rule(name, begin_mode_id, end_mode_id, condition_dispatch_id, before_dispatch_id, after_dispatch_id)
    VALUES('scan.requests',
        (select id from mode where name = 'scan'),
        (select id from mode where name = 'requests'),
        (select id from introspection_dispatch where identifier = 'requests.switch.condition'),
        (select id from introspection_dispatch where identifier = 'requests.switch.before'),
        (select id from introspection_dispatch where identifier = 'requests.switch.after')
    );

INSERT INTO switch_rule(name, begin_mode_id, end_mode_id, condition_dispatch_id, before_dispatch_id, after_dispatch_id)
    VALUES('match.requests',
        (select id from mode where name = 'match'),
        (select id from mode where name = 'requests'),
        (select id from introspection_dispatch where identifier = 'requests.switch.condition'),
        (select id from introspection_dispatch where identifier = 'requests.switch.before'),
        (select id from introspection_dispatch where identifier = 'requests.switch.after')
    );

INSERT INTO switch_rule(name, begin_mode_id, end_mode_id, condition_dispatch_id, before_dispatch_id, after_dispatch_id)
    VALUES('eval.requests',
        (select id from mode where name = 'eval'),
        (select id from mode where name = 'requests'),
        (select id from introspection_dispatch where identifier = 'requests.switch.condition'),
        (select id from introspection_dispatch where identifier = 'requests.switch.before'),
        (select id from introspection_dispatch where identifier = 'requests.switch.after')
    );

# paths to fix

INSERT INTO switch_rule(name, begin_mode_id, end_mode_id, condition_dispatch_id, before_dispatch_id, after_dispatch_id)
    VALUES('requests.fix',
        (select id from mode where name = 'requests'),
        (select id from mode where name = 'fix'),
        (select id from introspection_dispatch where identifier = 'fix.switch.condition'),
        (select id from introspection_dispatch where identifier = 'fix.switch.before'),
        (select id from introspection_dispatch where identifier = 'fix.switch.after')
    );

INSERT INTO switch_rule(name, begin_mode_id, end_mode_id, condition_dispatch_id, before_dispatch_id, after_dispatch_id)
    VALUES('report.fix',
        (select id from mode where name = 'report'),
        (select id from mode where name = 'fix'),
        (select id from introspection_dispatch where identifier = 'fix.switch.condition'),
        (select id from introspection_dispatch where identifier = 'fix.switch.before'),
        (select id from introspection_dispatch where identifier = 'fix.switch.after')
    );

# paths to shutdown

INSERT INTO switch_rule(name, begin_mode_id, end_mode_id, condition_dispatch_id, before_dispatch_id, after_dispatch_id)
    VALUES('fix.shutdown',
        (select id from mode where name = 'fix'),
        (select id from mode where name = 'shutdown'),
        (select id from introspection_dispatch where identifier = 'shutdown.switch.condition'),
        (select id from introspection_dispatch where identifier = 'shutdown.switch.before'),
        (select id from introspection_dispatch where identifier = 'shutdown.switch.after')
    );

INSERT INTO switch_rule(name, begin_mode_id, end_mode_id, condition_dispatch_id, before_dispatch_id, after_dispatch_id)
    VALUES('report.shutdown',
        (select id from mode where name = 'report'),
        (select id from mode where name = 'shutdown'),
        (select id from introspection_dispatch where identifier = 'shutdown.switch.condition'),
        (select id from introspection_dispatch where identifier = 'shutdown.switch.before'),
        (select id from introspection_dispatch where identifier = 'shutdown.switch.after')
    );

CREATE TABLE `mode_state_default_param` (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `index_name` varchar(128) CHARACTER SET utf8 NOT NULL default 'media',
  `mode_state_default_id` int(11) UNSIGNED NOT NULL DEFAULT '0',
  `name` varchar(128) NOT NULL,
  `value` varchar(1024) NOT NULL,
  `effective_dt` datetime DEFAULT NULL,
  `expiration_dt` datetime NOT NULL DEFAULT '9999-12-31 23:59:59',
  PRIMARY KEY (`id`),
  KEY `fk_mode_state_default_param` (`mode_state_default_id`),
  CONSTRAINT `fk_mode_state_default_param` FOREIGN KEY (`mode_state_default_id`) REFERENCES `mode_state_default` (`id`)
);

INSERT INTO mode_state_default_param(mode_state_default_id, name, value, effective_dt) VALUES 
  ((select id from mode_state_default where state_id = (select id from state where name = 'discover')), 'high.level.scan', 'true', now());

INSERT INTO mode_state_default_param(mode_state_default_id, name, value, effective_dt) VALUES 
  ((select id from mode_state_default where state_id = (select id from state where name = 'update')), 'update.scan', 'true', now());
    
INSERT INTO mode_state_default_param(mode_state_default_id, name, value, effective_dt) VALUES 
  ((select id from mode_state_default where state_id = (select id from state where name = 'monitor')), 'deep.scan', 'true', now());


-- CREATE TABLE `mode_state_default_operation` (
--   `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
--   `index_name` varchar(128) CHARACTER SET utf8 NOT NULL default 'media',
--   `mode_state_default_id` int(11) UNSIGNED NOT NULL DEFAULT '0',
--   `operation_id` int(11) UNSIGNED NOT NULL DEFAULT '0',
--   `effective_dt` datetime DEFAULT NULL,
--   `expiration_dt` datetime NOT NULL DEFAULT '9999-12-31 23:59:59',
--   PRIMARY KEY (`id`),
--   KEY `fk_mode_state_default_operation_mode_state_default` (`mode_state_default_id`),
--   CONSTRAINT `fk_mode_state_default_operation_mode_state_default` FOREIGN KEY (`mode_state_default_id`) REFERENCES `mode_state_default` (`id`),
--   KEY `fk_mode_state_default_operation_operation` (`operation_id`),
--   CONSTRAINT `fk_mode_state_default_operation_operation` FOREIGN KEY (`operation_id`) REFERENCES `operation` (`id`)
-- );


CREATE VIEW `v_mode_state_default_dispatch` AS 
  SELECT m.name mode_name, s.name state_name, d.identifier, d.package, d.module, d.class_name, d.func_name, ms.priority, ms.dec_priority_amount, ms.inc_priority_amount, ms.times_to_complete, ms.error_tolerance, 
    ms.effective_dt, ms.expiration_dt
  FROM mode m, state s, mode_state_default ms, introspection_dispatch d
  WHERE ms.state_id = s.id
    AND ms.effect_dispatch_id = d.id
    AND ms.mode_id = m.id
    AND ms.index_name = 'media' 
  ORDER BY m.name, s.id;


CREATE VIEW `v_mode_state_default_dispatch_w_id` AS 
  SELECT m.id mode_id, s.id state_id, s.name state_name, d.identifier, d.package, d.module, d.class_name, d.func_name, ms.priority, ms.dec_priority_amount, ms.inc_priority_amount, ms.times_to_complete, ms.error_tolerance, 
    ms.effective_dt, ms.expiration_dt
  FROM mode m, state s, mode_state_default ms, introspection_dispatch d
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



CREATE TABLE `exec_rec` (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
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
--   `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
--   `name` varchar(128) NOT NULL,
--   PRIMARY KEY (`id`)
-- );

-- CREATE TABLE `error_attribute` (
--   `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
--   `error_id` int(11) UNSIGNED NOT NULL,
--   `parent_attribute_id` int(11) DEFAULT NULL,
--   `name` varchar(128) CHARACTER SET utf8 NOT NULL,
--   PRIMARY KEY (`id`),
--   KEY `fk_error_attribute_error` (`error_id`),
--   CONSTRAINT `fk_error_attribute_error` FOREIGN KEY (`error_id`) REFERENCES `error` (`id`)
-- );

-- CREATE TABLE `error_attribute_value` (
--   `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
--   `error_id` int(11) UNSIGNED NOT NULL,
--   `error_attribute_id` int(11) UNSIGNED NOT NULL,
--   `attribute_value` varchar(256) NOT NULL,
--   PRIMARY KEY (`id`),
--   KEY `fk_eav_e` (`error_id`),
--   KEY `fk_eav_ea` (`error_attribute_id`),
--   CONSTRAINT `fk_eav_e` FOREIGN KEY (`error_id`) REFERENCES `error` (`id`),
--   CONSTRAINT `fk_eav_ea` FOREIGN KEY (`error_attribute_id`) REFERENCES `error_attribute` (`id`)
-- );