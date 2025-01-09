-- SQL script to migrate a dg-sscc-agent with `JDBC_DISCOVERY_LEGACY_MODE`parameter
-- set to `true` to dg-sscc-agent with `JDBC_DISCOVERY_LEGACY_MODE` set to false in rocket.
-- The script assumes the existence of some host variables:
--  * dg_jdbc_agent_name: Jdbc agent name to migrate
--  * dg_sscc_agent_name: sscc agent to migrate
--  * rocket_instance_schema: schema for the rocket instance about to be migrated

BEGIN TRANSACTION;

update :rocket_instance_schema."workflow_version"
set  pipeline_graph = regexp_replace(pipeline_graph, :dg_jdbc_agent_name, :dg_sscc_agent_name, 'g')
where pipeline_graph like '%"metadataPath":"' || :dg_jdbc_agent_name || '%';

update :rocket_instance_schema."quality_rule_result"
set metadata_path = regexp_replace(metadata_path, :dg_jdbc_agent_name, :dg_sscc_agent_name, 'g')
where metadata_path like :dg_jdbc_agent_name || ':%';

-- Print results
select 'workflow_version' as TABLE, count(*)
from :rocket_instance_schema."workflow_version"
where pipeline_graph like '%"metadataPath":"' || :dg_sscc_agent_name || '%'
union
select 'quality_rule_result' as TABLE, count(*)
from :rocket_instance_schema."quality_rule_result"
where metadata_path like :dg_sscc_agent_name || ':%';