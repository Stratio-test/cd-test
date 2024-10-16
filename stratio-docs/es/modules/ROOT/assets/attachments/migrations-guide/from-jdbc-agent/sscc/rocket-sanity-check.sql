-- SQL script to migrate a SSCC legacy agent to an SSCC non legacy in rocket
-- The script assumes the existence of some host variables:
--  * dg_jdbc_agent_name: agent name to check
--  * rocket_instance_schema: schema for the rocket instance about to be migrated

-- Sanity check: this select will report which tables are going to be migrated
-- and it is will be used in the scripts doing the actual changes

select 'workflow_version' as TABLE, count(*)
from :rocket_instance_schema."workflow_version"
where pipeline_graph like '%"metadataPath":"' || :dg_jdbc_agent_name || '%'
union
select 'quality_rule_result' as TABLE, count(*)
from :rocket_instance_schema."quality_rule_result"
where metadata_path like :dg_jdbc_agent_name || ':%';
