-- SQL script to migrate a SSCC legacy agent to an SSCC non legacy in rocket
-- The script assumes the existence of some host variables:
--  * dg_sscc_agent_name: agent name to check
--  * rocket_instance_schema: schema for the rocket instance about to be migrated

-- Sanity check: this select will report which tables are going to be migrated
-- and it is will be used in the scripts doing the actual changes

SELECT 'workflow_version' AS TABLE, COUNT(*)
FROM :rocket_instance_schema."workflow_version"
WHERE pipeline_graph LIKE '%"metadataPath":"' || :dg_sscc_agent_name || ':%'
UNION
SELECT 'quality_rule_result' AS TABLE, COUNT(*)
FROM :rocket_instance_schema."quality_rule_result"
WHERE metadata_path LIKE :dg_sscc_agent_name || ':%';
