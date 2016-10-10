-- update op record
-- No Params
--
--   UPDATE op_record ops
--LEFT JOIN es_document esd
--       ON ops.target_path = esd.absolute_path
--      SET ops.target_esid = esd.id
--    WHERE ops.target_esid = 'None'
--      AND esd.id IS NOT NULL

DROP TABLE IF EXISTS op_record_temp;

CREATE TEMPORARY TABLE op_record_temp (
  `id` int(11) unsigned NOT NULL,
  `target_esid` varchar(64) NOT NULL,
  `target_path` varchar(1024) NOT NULL,
  PRIMARY KEY (`id`)
);

INSERT INTO op_record_temp (id, target_esid, target_path)
SELECT id, target_esid, target_path 
  FROM op_record opr
 WHERE opr.target_esid = "None";
 
DROP TABLE IF EXISTS es_document_temp;

CREATE TEMPORARY TABLE es_document_temp (
  `id` varchar(128) NOT NULL,
  `absolute_path` varchar(1024) NOT NULL,
  PRIMARY KEY (`id`)
);

INSERT INTO es_document_temp (id, absolute_path)
SELECT id, absolute_path 
  FROM es_document esd
 WHERE esd.absolute_path IN (SELECT DISTINCT absolute_path FROM op_record_temp);

   UPDATE op_record_temp ops
LEFT JOIN es_document_temp esd
       ON ops.target_path = esd.absolute_path
      SET ops.target_esid = esd.id;
      
   UPDATE op_record ops
LEFT JOIN op_record_temp opt
       ON ops.target_path = opt.target_path
      SET ops.target_esid = opt.id
 