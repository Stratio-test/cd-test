-- SQL script to migrate a dg-sscc-agent with `JDBC_DISCOVERY_LEGACY_MODE`parameter
-- set to `true` to dg-sscc-agent with `JDBC_DISCOVERY_LEGACY_MODE` set to false in rocket.
-- The script assumes the existence of some host variables:
--  * dg_cloud_agent_name: dfs cloud agent to be migrated
--  * dg_dfs_sscc_agent_name: dfs sscc agent name
--  * rocket_instance_schema: schema for the rocket instance about to be migrated
--  * ds_old_type: datastore cloud type: ADLS2, BLOB, GCS, S3
--  * account_name: cloud account name
--    ** s3: billing account
--    ** gcs: project
--    ** adls2: storage account
--  * container: Container name. (Fill it only for BLOB and ADLS2 migrations)

BEGIN TRANSACTION;

UPDATE :rocket_instance_schema."workflow_version"
SET pipeline_graph =
    CASE
        WHEN :ds_old_type IN ('ADLS2', 'BLOB') THEN
            regexp_replace(pipeline_graph, '\"metadataPath\":\s*\"(' || :dg_cloud_agent_name || ')(:\/\/)(([^\/>]+\/?)+)(?:\/)([^>]+)(>\/)(:([^:\s]+:)+)\"', '"metadataPath":"' || :dg_dfs_sscc_agent_name || '://' || :account_name || '/' || :container || '/\3>/\7"')
        ELSE
            regexp_replace(pipeline_graph, '\"metadataPath\":\s*\"(' || :dg_cloud_agent_name || ')(:\/\/)(([^\/>]+\/?)+)(?:\/)([^>]+)(>\/)(:([^:\s]+:)+)\"', '"metadataPath":"' || :dg_dfs_sscc_agent_name || '://' || :account_name || '/' || :dg_cloud_agent_name || '/\3>/\7"')
    END
WHERE pipeline_graph LIKE '%"metadataPath"%:%"' || :dg_cloud_agent_name || ':%';

UPDATE :rocket_instance_schema."quality_rule_result"
SET metadata_path =
  CASE
    WHEN :ds_old_type IN ('ADLS2', 'BLOB') THEN
      regexp_replace(metadata_path, '^([^:]+)(:\/\/)(([^\/>]+\/?)+)(?:\/)([^>]+)(>\/)(:([^:\s]+:)+)', :dg_dfs_sscc_agent_name || '://' || :account_name || '/' || :container || '/\3>/\7')
    ELSE
      regexp_replace(metadata_path, '^([^:]+)(:\/\/)(([^\/>]+\/?)+)(?:\/)([^>]+)(>\/)(:([^:\s]+:)+)', :dg_dfs_sscc_agent_name || '://' || :account_name || '/\1/\3>/\7')
  END
WHERE metadata_path LIKE :dg_cloud_agent_name || ':%';

--Print results
SELECT 'workflow_version' AS TABLE, COUNT(*)
    FROM :rocket_instance_schema."workflow_version"
WHERE pipeline_graph LIKE '%"metadataPath"%:%"' || :dg_dfs_sscc_agent_name || ':%'
UNION
SELECT 'quality_rule_result' AS TABLE, COUNT(*)
    FROM :rocket_instance_schema."quality_rule_result"
WHERE metadata_path LIKE :dg_dfs_sscc_agent_name || ':%';
