-- SQL script to migrate a dg-sscc-agent with `JDBC_DISCOVERY_LEGACY_MODE`parameter
-- set to `true` to dg-sscc-agent with `JDBC_DISCOVERY_LEGACY_MODE` set to false in Stratio Governance.
-- The script assumes the existence of some host variables:
--  * tenant: Tenant where the agent is located
--  * dg_sscc_agent_name: sscc agent to migrate

BEGIN TRANSACTION;

-- Table data_asset
UPDATE "dg_metadata"."data_asset"
SET name = regexp_replace(name, '^.*?\.(.*)$', '\1')
WHERE tenant=:tenant AND parent_metadata_path LIKE :dg_sscc_agent_name || ':%';

UPDATE "dg_metadata"."data_asset"
SET metadata_path = regexp_replace(metadata_path, '(?:://)([^>]*)(?:>/:)([^\.]*)(?:\.)', '://\1/\2>/:')
WHERE tenant=:tenant AND parent_metadata_path LIKE :dg_sscc_agent_name || ':%';

--- Update properties for technical tables

UPDATE "dg_metadata"."data_asset"
SET properties =
  regexp_replace(properties::text, '(?:' || :dg_sscc_agent_name || ')(?:://)([^>]*)(?:>/:)([^\.]*)(?:\.)', :dg_sscc_agent_name || '://\1/\2>/:', 'g')::jsonb
WHERE tenant=:tenant AND properties::text LIKE '%' || :dg_sscc_agent_name || ':/%' AND (subtype='RESOURCE' or subtype='FIELD' or subtype like 'SUBFIELD%');

--- Update enriched_properties
UPDATE "dg_metadata"."data_asset"
  SET enriched_properties = regexp_replace(enriched_properties::TEXT, '"pkTable":\s*"' || :dg_sscc_agent_name || '(?:://)([^>]*)(?:>/:)([^\.]*)(?:\.)', '"pkTable": "' || :dg_sscc_agent_name || '://\1/\2>/:')::jsonb
  WHERE tenant=:tenant AND subtype='RESOURCE' AND enriched_properties::TEXT LIKE '%"pkTable":%"' || :dg_sscc_agent_name || ':%';

-- Table entity_relation
UPDATE "dg_metadata"."entity_relation"
SET source_metadata_path = regexp_replace(source_metadata_path, '(?:://)([^>]*)(?:>/:)([^\.]*)(?:\.)', '://\1/\2>/:')
WHERE tenant=:tenant AND source_metadata_path LIKE :dg_sscc_agent_name || ':%';

UPDATE "dg_metadata"."entity_relation"
SET target_metadata_path = regexp_replace(target_metadata_path, '(?:://)([^>]*)(?:>/:)([^\.]*)(?:\.)', '://\1/\2>/:')
WHERE tenant=:tenant AND target_metadata_path LIKE :dg_sscc_agent_name || ':%';

UPDATE "dg_metadata"."entity_relation"
SET target_name = regexp_replace(target_name, '^.*?\.(.*)$', '\1')
where tenant=:tenant AND target_metadata_path LIKE :dg_sscc_agent_name || ':%';

UPDATE "dg_metadata"."entity_relation"
SET source_name = regexp_replace(source_name, '^.*?\.(.*)$', '\1')
where tenant=:tenant AND source_metadata_path LIKE :dg_sscc_agent_name || ':%';

-- Table key_data_asset
UPDATE "dg_metadata"."key_data_asset"
SET metadata_path = regexp_replace(metadata_path, '(?:://)([^>]*)(?:>/:)([^\.]*)(?:\.)', '://\1/\2>/:')
WHERE tenant=:tenant AND metadata_path LIKE :dg_sscc_agent_name || ':%';

-- Table quality
UPDATE "dg_metadata"."quality"
  SET parameters = regexp_replace(parameters::text, '("resource"\s*:\s*")([^"\.]+\.)([^"\.]+"\s*,\s*"metadatapath"\s*:\s*"' || :dg_sscc_agent_name || ':)([^>]+)(>\/:)([^\.]+)(?:\.)([^"]+")',  '\1\3\4/\6\5\7', 'g')::jsonb,
  modified_at = current_timestamp
WHERE tenant=:tenant AND parameters::text LIKE '%"metadatapath":' || '%' || :dg_sscc_agent_name || ':%';

UPDATE "dg_metadata"."quality"
  SET metadata_path = regexp_replace(metadata_path, '(?:://)([^>]*)(?:>/:)([^\.]*)(?:\.)', '://\1/\2>/:'),
  modified_at = current_timestamp
WHERE tenant=:tenant AND metadata_path LIKE :dg_sscc_agent_name || ':%';

-- Table actor_data_asset
UPDATE "dg_metadata"."actor_data_asset"
SET metadata_path = regexp_replace(metadata_path, '(?:://)([^>]*)(?:>/:)([^\.]*)(?:\.)', '://\1/\2>/:')
WHERE tenant=:tenant AND metadata_path LIKE :dg_sscc_agent_name || ':%';

-- Table business_layer_event
UPDATE "dg_metadata"."business_layer_event"
SET metadata_path = regexp_replace(metadata_path, '(?:://)([^>]*)(?:>/:)([^\.]*)(?:\.)', '://\1/\2>/:')
WHERE tenant=:tenant AND metadata_path LIKE :dg_sscc_agent_name || ':%';

-- Table business_layer_event_historic
UPDATE "dg_metadata"."business_layer_event_historic"
SET metadata_path = regexp_replace(metadata_path, '(?:://)([^>]*)(?:>/:)([^\.]*)(?:\.)', '://\1/\2>/:')
WHERE tenant=:tenant AND metadata_path LIKE :dg_sscc_agent_name || ':%';

-- Table data_asset_enriched
UPDATE "dg_metadata"."data_asset_enriched"
SET metadata_path = regexp_replace(metadata_path, '(?:://)([^>]*)(?:>/:)([^\.]*)(?:\.)', '://\1/\2>/:')
WHERE tenant=:tenant AND metadata_path LIKE :dg_sscc_agent_name || ':%';

-- Table metrics
UPDATE "dg_metadata"."metrics"
SET metadata_path = regexp_replace(metadata_path, '(?:://)([^>]*)(?:>/:)([^\.]*)(?:\.)', '://\1/\2>/:')
WHERE tenant=:tenant AND metadata_path LIKE :dg_sscc_agent_name || ':%';

-- Table metrics_mdp_execution_aggregation
UPDATE "dg_metadata"."metrics_mdp_execution_aggregation"
SET metadata_path = regexp_replace(metadata_path, '(?:://)([^>]*)(?:>/:)([^\.]*)(?:\.)', '://\1/\2>/:')
WHERE tenant=:tenant AND metadata_path LIKE :dg_sscc_agent_name || ':%';


-- Print results

SELECT 'data_asset' AS TABLE, COUNT(*) FROM "dg_metadata"."data_asset"
    WHERE id IN (
	    SELECT id FROM "dg_metadata"."data_asset"
	    WHERE ("metadata_path" LIKE :dg_sscc_agent_name || ':%' OR
			    (properties::text LIKE '%' || :dg_sscc_agent_name || ':/%' AND (subtype='RESOURCE' OR subtype='FIELD' OR subtype LIKE 'SUBFIELD%'))
		      ) AND tenant=:tenant)
UNION
SELECT 'enriched_properties_modified' AS TABLE, COUNT(*) FROM "dg_metadata"."data_asset" WHERE tenant=:tenant AND subtype='RESOURCE' AND enriched_properties::TEXT LIKE '%"pkTable":%"' || :dg_sscc_agent_name || ':%'
UNION
 SELECT 'entity_relation' AS TABLE, COUNT(*) FROM "dg_metadata"."entity_relation" WHERE id in (SELECT id FROM "dg_metadata"."entity_relation"
   WHERE "source_metadata_path" LIKE :dg_sscc_agent_name || ':%'
   OR "target_metadata_path" LIKE :dg_sscc_agent_name || ':%' AND tenant=:tenant)
UNION
 SELECT 'key_data_asset' AS TABLE, COUNT(*) FROM "dg_metadata"."key_data_asset" WHERE id in (SELECT id FROM "dg_metadata"."key_data_asset" WHERE "metadata_path" LIKE :dg_sscc_agent_name || ':%' AND tenant=:tenant)
UNION
 SELECT 'quality' AS TABLE, COUNT(*) FROM "dg_metadata"."quality"
   WHERE id IN (SELECT id FROM "dg_metadata"."quality" WHERE "metadata_path" LIKE :dg_sscc_agent_name || ':%' OR parameters::text LIKE '%' || :dg_sscc_agent_name || ':%' AND tenant=:tenant)
UNION
 SELECT 'actor_data_asset' AS TABLE, COUNT(*) FROM "dg_metadata"."actor_data_asset"
   WHERE id IN (SELECT id FROM "dg_metadata"."actor_data_asset" WHERE "metadata_path" LIKE :dg_sscc_agent_name || ':%'  AND tenant=:tenant)
UNION
 SELECT 'business_layer_event' AS TABLE, COUNT(*) FROM "dg_metadata"."business_layer_event"
   WHERE id IN (SELECT id FROM "dg_metadata"."business_layer_event" WHERE "metadata_path" LIKE :dg_sscc_agent_name || ':%'  AND tenant=:tenant)
UNION
 SELECT 'business_layer_event_historic' AS TABLE, COUNT(*) FROM "dg_metadata"."business_layer_event_historic"
   WHERE id IN (SELECT id FROM "dg_metadata"."business_layer_event_historic" WHERE "metadata_path" LIKE :dg_sscc_agent_name || ':%'  AND tenant=:tenant)
UNION
 SELECT 'data_asset_enriched' AS TABLE, COUNT(*) FROM "dg_metadata"."data_asset_enriched"
   WHERE id IN (SELECT id FROM "dg_metadata"."data_asset_enriched" WHERE "metadata_path" LIKE :dg_sscc_agent_name || ':%'  AND tenant=:tenant)
UNION
 SELECT 'metrics' AS TABLE, COUNT(*) FROM "dg_metadata"."metrics"
   WHERE id IN (SELECT id FROM "dg_metadata"."metrics" WHERE "metadata_path" LIKE :dg_sscc_agent_name || ':%'  AND tenant=:tenant)
UNION
 SELECT 'metrics_mdp_execution_aggregation' AS TABLE, COUNT(*) FROM "dg_metadata"."metrics_mdp_execution_aggregation"
   WHERE id IN (SELECT id FROM "dg_metadata"."metrics_mdp_execution_aggregation" WHERE "metadata_path" LIKE :dg_sscc_agent_name || ':%' AND tenant=:tenant);

-- once you have checked modifications you should do `rollback` or `commit`
