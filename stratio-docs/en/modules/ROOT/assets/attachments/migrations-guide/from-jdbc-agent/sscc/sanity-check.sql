-- SQL script to migrate a dg-jdbc-agent to dg-sscc-agent
-- The script assumes the existence of some host variables:
--  * tenant: tenant where the agents are located
--  * dg_agent_name: agent name to check

-- Sanity check: this select will report which tables are going to be migrated
-- and it is will be used in the scripts doing the actual changes

SELECT 'data_asset' AS TABLE, COUNT(*) FROM "dg_metadata"."data_asset" WHERE id in (SELECT id FROM "dg_metadata"."data_asset" WHERE "metadata_path" LIKE :dg_jdbc_agent_name || ':%' AND tenant=:tenant)
UNION
 SELECT 'entity_relation' AS TABLE, COUNT(*) FROM "dg_metadata"."entity_relation" WHERE id in (SELECT id FROM "dg_metadata"."entity_relation"
   WHERE "source_metadata_path" LIKE :dg_jdbc_agent_name || ':%'
   or "target_metadata_path" LIKE :dg_jdbc_agent_name || ':%' AND tenant=:tenant)
UNION
 SELECT 'key_data_asset' AS TABLE, COUNT(*) FROM "dg_metadata"."key_data_asset" WHERE id in (SELECT id FROM "dg_metadata"."key_data_asset" WHERE "metadata_path" LIKE :dg_jdbc_agent_name || ':%' AND tenant=:tenant)
UNION
 SELECT 'quality' AS TABLE, COUNT(*) FROM "dg_metadata"."quality"
   WHERE id IN (SELECT id FROM "dg_metadata"."quality" WHERE "metadata_path" LIKE :dg_jdbc_agent_name || ':%'  AND tenant=:tenant);

