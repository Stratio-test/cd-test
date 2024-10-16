-- SQL script to migrate a dg-jdbc-agent to dg-sscc-agent
-- The script assumes the existence of some host variables:
--  * tenant: Tenant where the agents are located
--  * dg_jdbc_agent_name: Jdbc agent name to migrate
--  * dg_sscc_agent_name: sscc agent new name
--  * ds_type: datastore type. E.g mssql, db2, oracle

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

-- Table data_asset
--- Update datastore
UPDATE "dg_metadata"."data_asset"
  SET name = replace(name, :dg_jdbc_agent_name, :dg_sscc_agent_name),
      metadata_path = replace(metadata_path, :dg_jdbc_agent_name || ':', :dg_sscc_agent_name || ':'),
      type = replace(type, 'SQL', :ds_type)
  WHERE type='SQL' AND subtype='DS' AND tenant=:tenant AND metadata_path=:dg_jdbc_agent_name || ':';

--- Update schemas
UPDATE "dg_metadata"."data_asset"
  SET metadata_path = replace(metadata_path, :dg_jdbc_agent_name || ':/>', :dg_sscc_agent_name || ':/>')
  WHERE tenant=:tenant AND subtype='PATH' AND metadata_path LIKE :dg_jdbc_agent_name || ':/>%';

--- Update resources, fields and subfields
UPDATE "dg_metadata"."data_asset"
  SET metadata_path = replace(metadata_path, :dg_jdbc_agent_name || '://', :dg_sscc_agent_name || '://')
  WHERE tenant=:tenant AND subtype IN ('RESOURCE', 'FIELD') AND metadata_path LIKE :dg_jdbc_agent_name || '://%';

--- Update path in properties column
UPDATE "dg_metadata"."data_asset"
  SET properties = replace(properties::TEXT, :dg_jdbc_agent_name || ':', :dg_sscc_agent_name || ':')::jsonb
  WHERE tenant=:tenant AND properties::text LIKE '%' || :dg_jdbc_agent_name || ':%';

--- Update collections properties
UPDATE "dg_metadata"."data_asset"
  SET properties = jsonb_set(properties, '{crossDataResource,partition}', '"-"' , false)
  WHERE tenant=:tenant AND subtype='RESOURCE' AND properties::text LIKE '%' || :dg_sscc_agent_name || ':%' AND jsonb_extract_path_text(properties, 'crossDataResource', 'partition')='na';

UPDATE "dg_metadata"."data_asset"
  SET properties = jsonb_set(properties, '{crossDataResource,discoveryMode}', '"CUSTOM"' , false)
  WHERE tenant=:tenant AND subtype='RESOURCE' AND properties::text LIKE '%' || :dg_sscc_agent_name || ':%' AND jsonb_extract_path_text(properties, 'crossDataResource', 'discoveryMode')='JDBC';

UPDATE "dg_metadata"."data_asset"
  SET properties = jsonb_set(properties, '{crossDataResource,resourceType}', ('"' || :ds_type || '"')::jsonb, false)
  WHERE tenant=:tenant AND subtype='RESOURCE' AND properties::text LIKE '%' || :dg_sscc_agent_name || ':%' AND jsonb_extract_path_text(properties, 'crossDataResource', 'resourceType')='SQL';

-- Update schema property with the current schema instead of ´SQL´
-- Regex used: '\/:([^:]+)\..+:', extracts schema from a metadata_path given by the json contained in properties column. e.g. dg-mssql-jdbc-agent://migracion>/:dbo.work: -> dbo
UPDATE "dg_metadata"."data_asset"
  SET properties = jsonb_set(
    properties,
    '{crossDataResource,schema}',
    to_jsonb(
      (regexp_match(
        jsonb_extract_path_text(
          properties,
          'crossDataResource',
          'link',
          'link',
          '0'
        ),
        '\/:([^:]+)\..+:'
      ))[1]
    ),
  false)
  WHERE tenant=:tenant AND subtype='RESOURCE' AND properties::text LIKE '%' || :dg_sscc_agent_name || ':%' AND jsonb_extract_path_text(properties, 'crossDataResource', 'schema')='SQL';

--- Update enriched_properties
UPDATE "dg_metadata"."data_asset"
  SET enriched_properties = replace(enriched_properties::TEXT, :dg_jdbc_agent_name || ':', :dg_sscc_agent_name || ':')::jsonb
  WHERE tenant=:tenant AND subtype='RESOURCE' AND metadata_path LIKE :dg_sscc_agent_name || ':%' AND enriched_properties::text NOT LIKE '{}';

--- Update type
UPDATE "dg_metadata"."data_asset"
  SET type = replace(type, 'SQL', :ds_type)
  WHERE tenant=:tenant AND metadata_path LIKE :dg_sscc_agent_name || ':%';

-- Table entity_relation
UPDATE "dg_metadata"."entity_relation"
  SET source_metadata_path = replace(source_metadata_path, :dg_jdbc_agent_name || ':', :dg_sscc_agent_name || ':')
  WHERE tenant=:tenant AND source_type='DATA_ASSET_DICTIONARY' AND source_metadata_path LIKE :dg_jdbc_agent_name || ':%';

UPDATE "dg_metadata"."entity_relation"
  SET source_name = replace(source_name , :dg_jdbc_agent_name, :dg_sscc_agent_name)
  WHERE tenant=:tenant AND source_type='DATA_ASSET_DICTIONARY' AND source_name=:dg_jdbc_agent_name;

UPDATE "dg_metadata"."entity_relation"
  SET target_metadata_path = replace(target_metadata_path, :dg_jdbc_agent_name || ':', :dg_sscc_agent_name || ':')
  WHERE tenant=:tenant AND target_type='DATA_ASSET_DICTIONARY' AND target_metadata_path LIKE :dg_jdbc_agent_name || ':%';

UPDATE "dg_metadata"."entity_relation"
  SET target_name = replace(target_name , :dg_jdbc_agent_name, :dg_sscc_agent_name)
  WHERE tenant=:tenant AND target_type='DATA_ASSET_DICTIONARY' AND target_name=:dg_jdbc_agent_name;

-- Table key_data_asset
UPDATE "dg_metadata"."key_data_asset"
  SET metadata_path = replace(metadata_path, :dg_jdbc_agent_name || ':', :dg_sscc_agent_name || ':')
  WHERE tenant=:tenant AND metadata_path LIKE :dg_jdbc_agent_name || ':%';

-- Table quality
UPDATE "dg_metadata"."quality"
  SET metadata_path = replace(metadata_path, :dg_jdbc_agent_name || ':', :dg_sscc_agent_name || ':')
  WHERE tenant=:tenant AND metadata_path LIKE :dg_jdbc_agent_name || ':%';

-- Print results

SELECT 'data_asset' AS TABLE, COUNT(*) FROM "dg_metadata"."data_asset" WHERE id in (SELECT id FROM "dg_metadata"."data_asset" WHERE "metadata_path" LIKE :dg_sscc_agent_name || ':%' AND tenant=:tenant)
UNION
 SELECT 'entity_relation' AS TABLE, COUNT(*) FROM "dg_metadata"."entity_relation" WHERE id in (SELECT id FROM "dg_metadata"."entity_relation"
   WHERE "source_metadata_path" LIKE :dg_sscc_agent_name || ':%'
   or "target_metadata_path" LIKE :dg_sscc_agent_name || ':%' AND tenant=:tenant)
UNION
 SELECT 'key_data_asset' AS TABLE, COUNT(*) FROM "dg_metadata"."key_data_asset" WHERE id in (SELECT id FROM "dg_metadata"."key_data_asset" WHERE "metadata_path" LIKE :dg_sscc_agent_name || ':%' AND tenant=:tenant)
UNION
 SELECT 'quality' AS TABLE, COUNT(*) FROM "dg_metadata"."quality"
   WHERE id IN (SELECT id FROM "dg_metadata"."quality" WHERE "metadata_path" LIKE :dg_sscc_agent_name || ':%'  AND tenant=:tenant);

-- once you have checked modifications you should do `rollback` or `commit`
