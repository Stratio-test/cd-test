-- SQL script to migrate a dg-cloud-agent to dg-sscc-dfs-agent
-- The script assumes the existence of some host variables:
--  * tenant: Tenant where the agents are located
--  * dg_cloud_agent_name: Agent governance name (cloud bucket)
--  * dg_dfs_sscc_agent_name: DFS SSCC agent new name
--  * ds_old_type: datastore cloud type: ADLS2, GCS, S3
--  * ds_type: datastore type. E.g AmazonS3, AzureDLS2, GCloudStorage
--  * account_name: cloud account name
-- Sanity check: this select will report which tables are going to be migrated
-- and it is will be used in the scripts doing the actual changes


SELECT 'data_asset' AS TABLE, COUNT(*) FROM "dg_metadata"."data_asset" WHERE id IN (SELECT id FROM "dg_metadata"."data_asset" WHERE "metadata_path" LIKE :dg_cloud_agent_name || ':%' AND tenant=:tenant)
UNION
SELECT 'enriched_properties_modified' AS TABLE, COUNT(*) FROM "dg_metadata"."data_asset" WHERE tenant=:tenant AND subtype='RESOURCE' AND enriched_properties::TEXT LIKE '%"pkTable":%"' || :dg_cloud_agent_name || ':%'
UNION
 SELECT 'entity_relation' AS TABLE, COUNT(*) FROM "dg_metadata"."entity_relation" WHERE id IN (SELECT id FROM "dg_metadata"."entity_relation"
   WHERE "source_metadata_path" LIKE :dg_cloud_agent_name || ':%'
   OR "target_metadata_path" LIKE :dg_cloud_agent_name || ':%' AND tenant=:tenant)
UNION
 SELECT 'key_data_asset' AS TABLE, COUNT(*) FROM "dg_metadata"."key_data_asset" WHERE id IN (SELECT id FROM "dg_metadata"."key_data_asset" WHERE "metadata_path" LIKE :dg_cloud_agent_name || ':%' AND tenant=:tenant)
UNION
SELECT 'key_data_asset' AS TABLE, COUNT(*) FROM "dg_metadata"."key_external_asset" WHERE id IN (SELECT id FROM "dg_metadata"."key_external_asset" WHERE "metadata_path" LIKE :dg_cloud_agent_name || ':%' AND tenant=:tenant)
UNION
 SELECT 'quality' AS TABLE, COUNT(*) FROM "dg_metadata"."quality"
   WHERE id IN (SELECT id FROM "dg_metadata"."quality" WHERE "metadata_path" LIKE :dg_cloud_agent_name || ':%' OR parameters::text LIKE '%"metadatapath":' || '%' || :dg_cloud_agent_name || ':%' AND tenant=:tenant)
UNION
 SELECT 'actor_data_asset' AS TABLE, COUNT(*) FROM "dg_metadata"."actor_data_asset"
   WHERE id IN (SELECT id FROM "dg_metadata"."actor_data_asset" WHERE "metadata_path" LIKE :dg_cloud_agent_name || ':%' AND tenant=:tenant)
UNION
 SELECT 'business_layer_event' AS TABLE, COUNT(*) FROM "dg_metadata"."business_layer_event"
   WHERE id IN (SELECT id FROM "dg_metadata"."business_layer_event" WHERE "metadata_path" LIKE :dg_cloud_agent_name || ':%' AND tenant=:tenant)
UNION
 SELECT 'business_layer_event_historic' AS TABLE, COUNT(*) FROM "dg_metadata"."business_layer_event_historic"
   WHERE id IN (SELECT id FROM "dg_metadata"."business_layer_event_historic" WHERE "metadata_path" LIKE :dg_cloud_agent_name || ':%' AND tenant=:tenant)
UNION
 SELECT 'data_asset_enriched' AS TABLE, COUNT(*) FROM "dg_metadata"."data_asset_enriched"
   WHERE id IN (SELECT id FROM "dg_metadata"."data_asset_enriched" WHERE "metadata_path" LIKE :dg_cloud_agent_name || ':%' AND tenant=:tenant)
UNION
 SELECT 'metrics' AS TABLE, COUNT(*) FROM "dg_metadata"."metrics"
   WHERE id IN (SELECT id FROM "dg_metadata"."metrics" WHERE "metadata_path" LIKE :dg_cloud_agent_name || ':%'  AND tenant=:tenant)
UNION
 SELECT 'metrics_mdp_execution_aggregation' AS TABLE, COUNT(*) FROM "dg_metadata"."metrics_mdp_execution_aggregation"
   WHERE id IN (SELECT id FROM "dg_metadata"."metrics_mdp_execution_aggregation" WHERE "metadata_path" LIKE :dg_cloud_agent_name || ':%' AND tenant=:tenant);
