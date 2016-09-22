-- retrieve_complete_ops_operator_apply_lifespan: get all matching operations for the specified operator that happened after specified datetime
-- params: operator_name, operation_name, start_time, target_path
--
SELECT DISTINCT target_path
  FROM op_record
 WHERE operator_name = '%s'
   AND operation_name = '%s'
   AND end_time IS NOT NULL
   AND start_time >= '%s'
   AND target_path LIKE '%s*'
 ORDER BY target_path
