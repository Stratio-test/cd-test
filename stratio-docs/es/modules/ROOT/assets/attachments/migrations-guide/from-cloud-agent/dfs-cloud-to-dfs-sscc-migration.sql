-- SQL script to migrate a dg-cloud-agent to dg-dfs-sscc-agent
-- The script assumes the existence of some host variables:
--  * tenant: Tenant where the agents are located
--  * dg_cloud_agent_name: Agent governance name (cloud bucket)
--  * dg_dfs_sscc_agent_name: DFS SSCC agent new name
--  * ds_old_type: datastore cloud type: ADLS2, BLOB, GCS, S3
--  * ds_type: datastore type. E.g AmazonS3, AzureDLS2, GCloudStorage
--  * account_name: cloud account name
--    ** s3: billing account
--    ** gcs: project
--    ** adls2: storage account
--  * container: Container name. (Fill it only for BLOB and ADLS2 migrations)
-- Tables for business views are not updated. They are relative to collections and not to data dictionary.
BEGIN TRANSACTION;

--Update governance entities in case does not exist in Governance database
--- 1 is not a magic number, it is the id of DATA_ASSET_DICTIONARY
INSERT INTO "dg_metadata"."governance_entity_subtype" (id,entity_subtype,entity_type_id,quality_rules_allowed)
	VALUES (default,:ds_type,1,true)
ON CONFLICT ON CONSTRAINT "uk_governance_entity_subtype_entity_type" DO NOTHING;

INSERT INTO dg_metadata.governance_entity_subtype_dictionary
	select id,false,true from "dg_metadata"."governance_entity_subtype"
	where entity_subtype=:ds_type and entity_type_id=1
ON CONFLICT ON CONSTRAINT "pk_governance_entity_subtype_dictionary" DO NOTHING;

-- Table entity_relation
-- target_metadata_path
WITH target_data AS (
    SELECT
        A.target_metadata_path AS metadata_path,
        CASE
            WHEN :ds_old_type IN ('ADLS2', 'BLOB') THEN
                CASE
                    WHEN B.subtype = 'RESOURCE' OR subtype = 'FIELD' OR subtype LIKE 'SUBFIELD%'
                        THEN regexp_replace(metadata_path, '^(' || :dg_cloud_agent_name || ')(:\/\/)(([^\/>]+\/?)+)(?:\/)([^>]+)(>\/)(:([^:\s]+:)+)', :dg_dfs_sscc_agent_name || '://' || :account_name || '/' || :container || '/\3>/\7')
                    WHEN B.subtype = 'DS'
                        THEN replace(metadata_path, :dg_cloud_agent_name, :dg_dfs_sscc_agent_name)
                    WHEN B.subtype = 'PATH'
                        THEN replace(metadata_path, :dg_cloud_agent_name || ':/', :dg_dfs_sscc_agent_name || '://' || :account_name || '/' || :container)
                END
            ELSE
                CASE
                    WHEN B.subtype = 'RESOURCE' OR subtype = 'FIELD' OR subtype LIKE 'SUBFIELD%'
                        THEN regexp_replace(metadata_path, '^([^:]+)(:\/\/)(([^\/>]+\/?)+)(?:\/)([^>]+)(>\/)(:([^:\s]+:)+)', :dg_dfs_sscc_agent_name || '://' || :account_name || '/\1/\3>/\7')
                    WHEN B.subtype = 'DS'
                        THEN replace(metadata_path, :dg_cloud_agent_name, :dg_dfs_sscc_agent_name)
                    WHEN B.subtype = 'PATH'
                        THEN replace(metadata_path, :dg_cloud_agent_name || ':/', :dg_dfs_sscc_agent_name || '://' || :account_name || '/' || :dg_cloud_agent_name)
                END
        END AS new_metadata_path
    FROM "dg_metadata"."entity_relation" A
    INNER JOIN "dg_metadata"."data_asset" B
        ON A.target_metadata_path = B.metadata_path
)
UPDATE "dg_metadata"."entity_relation" A
SET target_metadata_path = B.new_metadata_path
FROM target_data B
WHERE A.target_metadata_path = B.metadata_path and A.target_metadata_path like :dg_cloud_agent_name || '%' AND tenant = :tenant;

-- source_metadata_path
WITH target_data AS (
    SELECT
        A.source_metadata_path AS metadata_path,
        CASE
            WHEN :ds_old_type IN ('ADLS2', 'BLOB') THEN
                CASE
                    WHEN B.subtype = 'RESOURCE' OR subtype = 'FIELD' OR subtype LIKE 'SUBFIELD%'
                        THEN regexp_replace(metadata_path, '^(' || :dg_cloud_agent_name || ')(:\/\/)(([^\/>]+\/?)+)(?:\/)([^>]+)(>\/)(:([^:\s]+:)+)', :dg_dfs_sscc_agent_name || '://' || :account_name || '/' || :container || '/\3>/\7')
                    WHEN B.subtype = 'DS'
                        THEN replace(metadata_path, :dg_cloud_agent_name, :dg_dfs_sscc_agent_name)
                    WHEN B.subtype = 'PATH'
                        THEN replace(metadata_path, :dg_cloud_agent_name || ':/', :dg_dfs_sscc_agent_name || '://' || :account_name || '/' || :container)
                END
            ELSE
                CASE
                    WHEN B.subtype = 'RESOURCE' OR subtype = 'FIELD' OR subtype LIKE 'SUBFIELD%'
                        THEN regexp_replace(metadata_path, '^([^:]+)(:\/\/)(([^\/>]+\/?)+)(?:\/)([^>]+)(>\/)(:([^:\s]+:)+)', :dg_dfs_sscc_agent_name || '://' || :account_name || '/\1/\3>/\7')
                    WHEN B.subtype = 'DS'
                        THEN replace(metadata_path, :dg_cloud_agent_name, :dg_dfs_sscc_agent_name)
                    WHEN B.subtype = 'PATH'
                        THEN replace(metadata_path, :dg_cloud_agent_name || ':/', :dg_dfs_sscc_agent_name || '://' || :account_name || '/' || :dg_cloud_agent_name)
                END
        END AS new_metadata_path
    FROM "dg_metadata"."entity_relation" A
    INNER JOIN "dg_metadata"."data_asset" B
        ON A.source_metadata_path = B.metadata_path
)
UPDATE "dg_metadata"."entity_relation" A
SET source_metadata_path = B.new_metadata_path
FROM target_data B
WHERE A.source_metadata_path = B.metadata_path AND A.source_metadata_path like :dg_cloud_agent_name || '%' AND tenant = :tenant;

-- Table data_asset
--- Update DS
UPDATE "dg_metadata"."data_asset"
  SET metadata_path = replace(metadata_path, :dg_cloud_agent_name, :dg_dfs_sscc_agent_name),
      name = :dg_dfs_sscc_agent_name,
      type = :ds_type
WHERE tenant=:tenant AND metadata_path LIKE :dg_cloud_agent_name || ':' AND subtype='DS';

-- Update resources, fields and subfields
-- This updates metadata paths prepending the new agent name, the account name an the container name if it is a BLOB or ADLS2
-- Also remove the last segment of the path as the legacy agent adds an additional virtual path segment with the same name as the file
UPDATE "dg_metadata"."data_asset"
SET metadata_path =
  CASE
    WHEN :ds_old_type IN ('ADLS2', 'BLOB') THEN
      regexp_replace(metadata_path, '^([^:]+)(:\/\/)(([^\/>]+\/?)+)(?:\/)([^>]+)(>\/)(:([^:\s]+:)+)', :dg_dfs_sscc_agent_name || '://' || :account_name || '/' || :container || '/\3>/\7')
    ELSE
      regexp_replace(metadata_path, '^([^:]+)(:\/\/)(([^\/>]+\/?)+)(?:\/)([^>]+)(>\/)(:([^:\s]+:)+)', :dg_dfs_sscc_agent_name || '://' || :account_name || '/\1/\3>/\7')
  END,
    type = :ds_type
WHERE tenant= :tenant AND metadata_path LIKE :dg_cloud_agent_name || ':/%' AND (subtype='RESOURCE' or subtype='FIELD' or subtype like 'SUBFIELD%') AND
      -- only if the last path segment is the same as the file name
      (regexp_match(metadata_path,'\/:([^\/>]*?):'))[1] = (regexp_match(metadata_path,'\/([^\/>]*?)>\/:'))[1];

-- This updates metadata paths prepending the new agent name, the account name an the container name if it is a BLOB or ADLS2
-- It does not any path modification to cover the possible corner cases where the legacy agent did not add any path segment
UPDATE "dg_metadata"."data_asset"
SET metadata_path =
    CASE
        WHEN :ds_old_type IN ('ADLS2', 'BLOB') THEN
            regexp_replace(metadata_path, '^([^:\s]+)(:\/\/)([^>]+)(>\/)(:([^:\s]+:)+)', :dg_dfs_sscc_agent_name || '://' || :account_name || '/' || :container || '/\3>/\5')
        ELSE
            regexp_replace(metadata_path, '^([^:\s]+)(:\/\/)([^>]+)(>\/)(:([^:\s]+:)+)', :dg_dfs_sscc_agent_name || '://' || :account_name || '/\1/\3>/\5')
    END,
    type = :ds_type
WHERE tenant = :tenant AND metadata_path LIKE :dg_cloud_agent_name || ':/%' AND (subtype='RESOURCE' or subtype='FIELD' or subtype like 'SUBFIELD%');

--- Update paths
UPDATE "dg_metadata"."data_asset"
SET metadata_path =
    CASE
        WHEN :ds_old_type IN ('ADLS2', 'BLOB') THEN
            replace(metadata_path, :dg_cloud_agent_name || ':/', :dg_dfs_sscc_agent_name || '://' || :account_name || '/' || :container)
        ELSE
            replace(metadata_path, :dg_cloud_agent_name || ':/', :dg_dfs_sscc_agent_name || '://' || :account_name || '/' || :dg_cloud_agent_name)
    END,
    type = :ds_type
WHERE tenant = :tenant AND metadata_path LIKE :dg_cloud_agent_name || ':/%' AND subtype = 'PATH';

--- Update enriched_properties
UPDATE "dg_metadata"."data_asset"
SET enriched_properties =
    CASE
        WHEN :ds_old_type IN ('ADLS2', 'BLOB') THEN
            regexp_replace(enriched_properties::TEXT, '"pkTable":\s*"(' || :dg_cloud_agent_name || ')(:\/\/)(([^\/>]+\/?)+)(?:\/)([^>]+)(>\/)(:([^:\s]+:)+)', '"pkTable": "' || :dg_dfs_sscc_agent_name || '://' || :account_name || '/' || :container || '/\3>/\7')::jsonb
        ELSE
            regexp_replace(enriched_properties::TEXT, '"pkTable":\s*"(' || :dg_cloud_agent_name || ')(:\/\/)(([^\/>]+\/?)+)(?:\/)([^>]+)(>\/)(:([^:\s]+:)+)', '"pkTable": "' || :dg_dfs_sscc_agent_name || '://' || :account_name || '/' || :dg_cloud_agent_name || '/\3>/\7')::jsonb
    END
WHERE tenant=:tenant AND subtype='RESOURCE' AND enriched_properties::TEXT LIKE '%"pkTable":%"' || :dg_cloud_agent_name || ':%';

-- Update collection properties
--Update crossDataResource
UPDATE "dg_metadata"."data_asset"
  SET properties = regexp_replace(properties::text, '("resourceType":\s*")(' || :ds_old_type ||')', '\1' || :ds_type ||'", "discoveryMode": "CUSTOM')::jsonb
WHERE tenant=:tenant AND subtype='RESOURCE' AND properties::text LIKE '%' || :dg_cloud_agent_name || ':%' AND jsonb_extract_path_text(properties, 'crossDataResource', 'resourceType')=:ds_old_type;

--Update crossDataColumn
UPDATE "dg_metadata"."data_asset"
  SET properties = regexp_replace(properties::text, '(.*?)(hdfsColumn)(.*?)(\"properties\":.*?)("datastoreType":\s*")('|| :ds_old_type ||')(.*)$', '\1customField\3"attributes": [{"key": "type", "value": "' || :ds_type || '"}], \4\5' || :ds_type || '\7' )::jsonb
  WHERE tenant=:tenant AND properties::text LIKE '{"crossDataColumn":%' || :dg_cloud_agent_name || '%';

--Update metadata paths
UPDATE "dg_metadata"."data_asset"
SET properties =
  CASE
    WHEN :ds_old_type IN ('ADLS2', 'BLOB') THEN
      regexp_replace(properties::text, '(' || :dg_cloud_agent_name || ')(:\/\/)(([^\/>]+\/?)+)(?:\/)([^>]+)(>\/)(:([^:\s]+:)+)', :dg_dfs_sscc_agent_name || '://' || :account_name || '/' || :container || '/\3>/\7', 'g')::jsonb
    ELSE
      regexp_replace(properties::text, '(' || :dg_cloud_agent_name || ')(:\/\/)(([^\/>]+\/?)+)(?:\/)([^>]+)(>\/)(:([^:\s]+:)+)', :dg_dfs_sscc_agent_name || '://' || :account_name || '/\1/\3>/\7', 'g')::jsonb
  END
WHERE tenant=:tenant AND properties::text LIKE '%' || :dg_cloud_agent_name || ':/%' AND (subtype='RESOURCE' or subtype='FIELD' or subtype like 'SUBFIELD%');


-- Table key_data_asset
UPDATE "dg_metadata"."key_data_asset"
SET metadata_path =
    CASE
        WHEN :ds_old_type IN ('ADLS2', 'BLOB') THEN
            regexp_replace(metadata_path, '^([^:]+)(:\/\/)(([^\/>]+\/?)+)(?:\/)([^>]+)(>\/)(:([^:\s]+:)+)', :dg_dfs_sscc_agent_name || '://' || :account_name || '/' || :container || '/\3>/\7')
        ELSE
            regexp_replace(metadata_path, '^([^:]+)(:\/\/)(([^\/>]+\/?)+)(?:\/)([^>]+)(>\/)(:([^:\s]+:)+)', :dg_dfs_sscc_agent_name || '://' || :account_name || '/\1/\3>/\7')
    END
WHERE tenant=:tenant AND metadata_path LIKE :dg_cloud_agent_name || ':%';

-- Table key_external_asset
-- Table added in governance 1.12, universe 14.1/R4.1, comment the sentence if you are in a previous version
UPDATE "dg_metadata"."key_external_asset"
SET metadata_path =
    CASE
        WHEN :ds_old_type IN ('ADLS2', 'BLOB') THEN
            regexp_replace(metadata_path, '^([^:]+)(:\/\/)(([^\/>]+\/?)+)(?:\/)([^>]+)(>\/)(:([^:\s]+:)+)', :dg_dfs_sscc_agent_name || '://' || :account_name || '/' || :container || '/\3>/\7')
        ELSE
            regexp_replace(metadata_path, '^([^:]+)(:\/\/)(([^\/>]+\/?)+)(?:\/)([^>]+)(>\/)(:([^:\s]+:)+)', :dg_dfs_sscc_agent_name || '://' || :account_name || '/\1/\3>/\7')
    END
WHERE tenant=:tenant AND metadata_path LIKE :dg_cloud_agent_name || ':%';

-- Table quality
  -- Embedded
UPDATE "dg_metadata"."quality"
  SET parameters = regexp_replace(parameters::text, '(\{\s*"table": {"type"\s*:\s*")([[[:alnum:]]+)("})', '\1':ds_type'\3')::jsonb
  WHERE tenant=:tenant AND metadata_path LIKE :dg_cloud_agent_name || ':%';

  -- Scheduled
UPDATE "dg_metadata"."quality"
SET parameters =
    CASE
        WHEN :ds_old_type IN ('ADLS2', 'BLOB') THEN
            regexp_replace(parameters::text, '\"metadatapath\":\s*\"(' || :dg_cloud_agent_name || ')(:\/\/)(([^\/>]+\/?)+)(?:\/)([^>]+)(>\/)(:([^:\s]+:)+)\"', '"metadatapath": "' || :dg_dfs_sscc_agent_name || '://' || :account_name || '/' || :container || '/\3>/\7"')::jsonb
        ELSE
            regexp_replace(parameters::text, '\"metadatapath\":\s*\"(' || :dg_cloud_agent_name || ')(:\/\/)(([^\/>]+\/?)+)(?:\/)([^>]+)(>\/)(:([^:\s]+:)+)\"', '"metadatapath": "' || :dg_dfs_sscc_agent_name || '://' || :account_name || '/' || :dg_cloud_agent_name || '/\3>/\7"')::jsonb
    END
WHERE tenant=:tenant AND parameters::text LIKE '%"metadatapath":%' || :dg_cloud_agent_name || ':%';

UPDATE "dg_metadata"."quality"
  SET parameters = regexp_replace(parameters::text, '("type"\s*:\s*")(' || :ds_old_type ||')(")', '\1' || :ds_type || '\3')::jsonb,
  modified_at = current_timestamp
  WHERE tenant=:tenant AND parameters::text LIKE '%"metadatapath":' || '%' || :dg_dfs_sscc_agent_name || ':%';

UPDATE "dg_metadata"."quality"
SET metadata_path =
    CASE
        WHEN :ds_old_type IN ('ADLS2', 'BLOB') THEN
            regexp_replace(metadata_path, '^([^:]+)(:\/\/)(([^\/>]+\/?)+)(?:\/)([^>]+)(>\/)(:([^:\s]+:)+)', :dg_dfs_sscc_agent_name || '://' || :account_name || '/' || :container || '/\3>/\7')
        ELSE
            regexp_replace(metadata_path, '^([^:]+)(:\/\/)(([^\/>]+\/?)+)(?:\/)([^>]+)(>\/)(:([^:\s]+:)+)', :dg_dfs_sscc_agent_name || '://' || :account_name || '/\1/\3>/\7')
    END,
    modified_at = current_timestamp
WHERE tenant=:tenant AND metadata_path LIKE :dg_cloud_agent_name || ':%';

-- Table actor_data_asset
UPDATE "dg_metadata"."actor_data_asset"
SET metadata_path =
    CASE
        WHEN :ds_old_type IN ('ADLS2', 'BLOB') THEN
            regexp_replace(metadata_path, '^([^:]+)(:\/\/)(([^\/>]+\/?)+)(?:\/)([^>]+)(>\/)(:([^:\s]+:)+)', :dg_dfs_sscc_agent_name || '://' || :account_name || '/' || :container || '/\3>/\7')
        ELSE
            regexp_replace(metadata_path, '^([^:]+)(:\/\/)(([^\/>]+\/?)+)(?:\/)([^>]+)(>\/)(:([^:\s]+:)+)', :dg_dfs_sscc_agent_name || '://' || :account_name || '/\1/\3>/\7')
    END
WHERE tenant=:tenant AND metadata_path LIKE :dg_cloud_agent_name || ':%';

-- Table business_layer_event
UPDATE "dg_metadata"."business_layer_event"
SET metadata_path =
    CASE
        WHEN :ds_old_type IN ('ADLS2', 'BLOB') THEN
            regexp_replace(metadata_path, '^([^:]+)(:\/\/)(([^\/>]+\/?)+)(?:\/)([^>]+)(>\/)(:([^:\s]+:)+)', :dg_dfs_sscc_agent_name || '://' || :account_name || '/' || :container || '/\3>/\7')
        ELSE
            regexp_replace(metadata_path, '^([^:]+)(:\/\/)(([^\/>]+\/?)+)(?:\/)([^>]+)(>\/)(:([^:\s]+:)+)', :dg_dfs_sscc_agent_name || '://' || :account_name || '/\1/\3>/\7')
    END
WHERE tenant=:tenant AND metadata_path LIKE :dg_cloud_agent_name || ':%';

-- Table business_layer_event_historic
UPDATE "dg_metadata"."business_layer_event_historic"
SET metadata_path =
    CASE
        WHEN :ds_old_type IN ('ADLS2', 'BLOB') THEN
            regexp_replace(metadata_path, '^([^:]+)(:\/\/)(([^\/>]+\/?)+)(?:\/)([^>]+)(>\/)(:([^:\s]+:)+)', :dg_dfs_sscc_agent_name || '://' || :account_name || '/' || :container || '/\3>/\7')
        ELSE
            regexp_replace(metadata_path, '^([^:]+)(:\/\/)(([^\/>]+\/?)+)(?:\/)([^>]+)(>\/)(:([^:\s]+:)+)', :dg_dfs_sscc_agent_name || '://' || :account_name || '/\1/\3>/\7')
    END
WHERE tenant=:tenant AND metadata_path LIKE :dg_cloud_agent_name || ':%';


-- Table data_asset_enriched
UPDATE "dg_metadata"."data_asset_enriched"
SET metadata_path =
    CASE
        WHEN :ds_old_type IN ('ADLS2', 'BLOB') THEN
            regexp_replace(metadata_path, '^([^:]+)(:\/\/)(([^\/>]+\/?)+)(?:\/)([^>]+)(>\/)(:([^:\s]+:)+)', :dg_dfs_sscc_agent_name || '://' || :account_name || '/' || :container || '/\3>/\7')
        ELSE
            regexp_replace(metadata_path, '^([^:]+)(:\/\/)(([^\/>]+\/?)+)(?:\/)([^>]+)(>\/)(:([^:\s]+:)+)', :dg_dfs_sscc_agent_name || '://' || :account_name || '/\1/\3>/\7')
    END
WHERE tenant=:tenant AND metadata_path LIKE :dg_cloud_agent_name || ':%';

-- Table metrics
UPDATE "dg_metadata"."metrics"
SET metadata_path =
    CASE
        WHEN :ds_old_type IN ('ADLS2', 'BLOB') THEN
            regexp_replace(metadata_path, '^([^:]+)(:\/\/)(([^\/>]+\/?)+)(?:\/)([^>]+)(>\/)(:([^:\s]+:)+)', :dg_dfs_sscc_agent_name || '://' || :account_name || '/' || :container || '/\3>/\7')
        ELSE
            regexp_replace(metadata_path, '^([^:]+)(:\/\/)(([^\/>]+\/?)+)(?:\/)([^>]+)(>\/)(:([^:\s]+:)+)', :dg_dfs_sscc_agent_name || '://' || :account_name || '/\1/\3>/\7')
    END
WHERE tenant=:tenant AND metadata_path LIKE :dg_cloud_agent_name || ':%';

-- Table metrics_mdp_execution_aggregation
UPDATE "dg_metadata"."metrics_mdp_execution_aggregation"
SET metadata_path =
    CASE
        WHEN :ds_old_type IN ('ADLS2', 'BLOB') THEN
            regexp_replace(metadata_path, '^([^:]+)(:\/\/)(([^\/>]+\/?)+)(?:\/)([^>]+)(>\/)(:([^:\s]+:)+)', :dg_dfs_sscc_agent_name || '://' || :account_name || '/' || :container || '/\3>/\7')
        ELSE
            regexp_replace(metadata_path, '^([^:]+)(:\/\/)(([^\/>]+\/?)+)(?:\/)([^>]+)(>\/)(:([^:\s]+:)+)', :dg_dfs_sscc_agent_name || '://' || :account_name || '/\1/\3>/\7')
    END
WHERE tenant=:tenant AND metadata_path LIKE :dg_cloud_agent_name || ':%';

-- Vendors
update "dg_metadata"."data_asset"
SET vendor = CASE WHEN :ds_type = 'AmazonS3' THEN 'Amazon'
                WHEN :ds_type = 'AzureDLS2' THEN 'Microsoft Azure'
                WHEN :ds_type = 'GCloudStorage' THEN 'Google'
END
WHERE :ds_type IN ('AmazonS3', 'AzureDLS2', 'GCloudStorage')
AND tenant=:tenant AND metadata_path LIKE :dg_dfs_sscc_agent_name || '%';

--Delete of nonexistent paths in sscc
-- TODO: Check paths without children. Check it in sanity check too
with pathstodelete as (
	select
		PATHS.id,
		PATHS.metadata_path,
		PATHS.subtype
	from "dg_metadata"."data_asset" PATHS
    left join "dg_metadata"."data_asset" CHILDS
      on CHILDS.parent_metadata_path = PATHS.metadata_path
	where PATHS.metadata_path like :dg_dfs_sscc_agent_name || '%'
	  and PATHS.subtype='PATH'
	  and CHILDS.id is NULL
)
delete from "dg_metadata"."data_asset" where id in (select id from pathstodelete);

-- Print results
-- this should be 0
SELECT 'data_asset old agent' AS TABLE, COUNT(*) FROM "dg_metadata"."data_asset" WHERE id IN (SELECT id FROM "dg_metadata"."data_asset" WHERE "metadata_path" LIKE :dg_cloud_agent_name || ':%' AND tenant=:tenant)
UNION
-- this, plus the deleted orphan paths, should match the number of assets for the old agent in the sanity check script
SELECT 'data_asset new agent' AS TABLE, COUNT(*) FROM "dg_metadata"."data_asset" WHERE id IN (SELECT id FROM "dg_metadata"."data_asset" WHERE "metadata_path" LIKE :dg_dfs_sscc_agent_name || ':%' AND tenant=:tenant)
UNION
SELECT 'enriched_properties_modified' AS TABLE, COUNT(*) FROM "dg_metadata"."data_asset" WHERE tenant=:tenant AND subtype='RESOURCE' AND enriched_properties::TEXT LIKE '%"pkTable":%"' || :dg_dfs_sscc_agent_name || ':%'
UNION
 SELECT 'entity_relation' AS TABLE, COUNT(*) FROM "dg_metadata"."entity_relation" WHERE id IN (SELECT id FROM "dg_metadata"."entity_relation"
   WHERE "source_metadata_path" LIKE :dg_dfs_sscc_agent_name || ':%'
   OR "target_metadata_path" LIKE :dg_dfs_sscc_agent_name || ':%' AND tenant=:tenant)
UNION
 SELECT 'key_data_asset' AS TABLE, COUNT(*) FROM "dg_metadata"."key_data_asset" WHERE id IN (SELECT id FROM "dg_metadata"."key_data_asset" WHERE "metadata_path" LIKE :dg_dfs_sscc_agent_name || ':%' AND tenant=:tenant)
UNION
SELECT 'key_external_asset' AS TABLE, COUNT(*) FROM "dg_metadata"."key_external_asset" WHERE id IN (SELECT id FROM "dg_metadata"."key_external_asset" WHERE "metadata_path" LIKE :dg_dfs_sscc_agent_name || ':%' AND tenant=:tenant)
UNION
 SELECT 'quality' AS TABLE, COUNT(*) FROM "dg_metadata"."quality"
   WHERE id IN (SELECT id FROM "dg_metadata"."quality" WHERE "metadata_path" LIKE :dg_dfs_sscc_agent_name || ':%' OR parameters::text LIKE '%"metadatapath":' || '%' || :dg_dfs_sscc_agent_name || ':%' AND tenant=:tenant)
UNION
 SELECT 'actor_data_asset' AS TABLE, COUNT(*) FROM "dg_metadata"."actor_data_asset"
   WHERE id IN (SELECT id FROM "dg_metadata"."actor_data_asset" WHERE "metadata_path" LIKE :dg_dfs_sscc_agent_name || ':%' AND tenant=:tenant)
UNION
 SELECT 'business_layer_event' AS TABLE, COUNT(*) FROM "dg_metadata"."business_layer_event"
   WHERE id IN (SELECT id FROM "dg_metadata"."business_layer_event" WHERE "metadata_path" LIKE :dg_dfs_sscc_agent_name || ':%' AND tenant=:tenant)
UNION
 SELECT 'business_layer_event_historic' AS TABLE, COUNT(*) FROM "dg_metadata"."business_layer_event_historic"
   WHERE id IN (SELECT id FROM "dg_metadata"."business_layer_event_historic" WHERE "metadata_path" LIKE :dg_dfs_sscc_agent_name || ':%' AND tenant=:tenant)
UNION
 SELECT 'data_asset_enriched' AS TABLE, COUNT(*) FROM "dg_metadata"."data_asset_enriched"
   WHERE id IN (SELECT id FROM "dg_metadata"."data_asset_enriched" WHERE "metadata_path" LIKE :dg_dfs_sscc_agent_name || ':%' AND tenant=:tenant)
UNION
 SELECT 'metrics' AS TABLE, COUNT(*) FROM "dg_metadata"."metrics"
   WHERE id IN (SELECT id FROM "dg_metadata"."metrics" WHERE "metadata_path" LIKE :dg_dfs_sscc_agent_name || ':%'  AND tenant=:tenant)
UNION
 SELECT 'metrics_mdp_execution_aggregation' AS TABLE, COUNT(*) FROM "dg_metadata"."metrics_mdp_execution_aggregation"
   WHERE id IN (SELECT id FROM "dg_metadata"."metrics_mdp_execution_aggregation" WHERE "metadata_path" LIKE :dg_dfs_sscc_agent_name || ':%' AND tenant=:tenant);
-- once you have checked modifications you should do `rollback` or `commit`
