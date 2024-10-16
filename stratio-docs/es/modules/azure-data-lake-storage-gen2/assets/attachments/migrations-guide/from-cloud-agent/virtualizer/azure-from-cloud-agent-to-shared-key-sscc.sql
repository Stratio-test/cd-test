-- The script assumes the existence of some host variables:
-- * databases_with_tables_to_be_migrated: a list with the catalog databases names
--     containing tables to be migrated (optional, all databases will be considered if not informed)
-- * old_cloud_agent_location_prefix: the file system url prefix of cloud agent(s) about to be migrated.
--   * for example 'abfss://my-bucket-name/%'
-- * vault_secret_name: the name of the secret containing specific authentication info
--                          used by the new sscc connector
begin transaction;

-- update "SDS"."LOCATION" column to move from wasbs to abfss
-- not all external tables with wasbs paths have the location set to wasbs://
with
  db_tables_params as (
    select * from "public"."TBLS"
      inner join "public"."DBS" using ("DB_ID")
      inner join "public"."SDS" using ("SD_ID")
      inner join "public"."SERDE_PARAMS" using ("SERDE_ID")
    where coalesce(:databases_with_tables_to_be_migrated, '') = '' or
          "NAME" in (:databases_with_tables_to_be_migrated)
  ),
  -- We filter tables not governed (not created automatically by eureka)
  tables_not_governed as (
    select * from db_tables_params as "TBLS"
    where "TBL_ID" not in (select "TBL_PROPS"."TBL_ID" from "public"."TABLE_PARAMS" as "TBL_PROPS"
                       where "PARAM_KEY" = 'isGoverned' and "PARAM_VALUE" = 'true')
  ),
  -- We filter tables containing an appropriate location url and
  -- not already handled by sscc
  tables_to_migrate as (
    select "DB_ID", "NAME" as "DB_NAME", "TBL_ID", "TBL_NAME", "SD_ID", "SERDE_ID"
    from tables_not_governed
    where "PARAM_KEY" = 'path' and "PARAM_VALUE" like :old_cloud_agent_location_prefix and
          "SERDE_ID" not in (select "TBL_OPTS"."SERDE_ID" from "public"."SERDE_PARAMS" as "TBL_OPTS"
                       where "PARAM_KEY" = 'stratiosecuritymode' and "PARAM_VALUE" = 'custom_sscc') and
          "LOCATION" like :old_cloud_agent_location_prefix
    group by "DB_ID", "NAME", "TBL_ID", "TBL_NAME", "SD_ID", "SERDE_ID"
  )
update "SDS" set "LOCATION" = replace(replace(replace("SDS"."LOCATION", 'wasb://', 'abfs://'), 'wasbs://', 'abfss://'), 'blob.core.windows.net', 'dfs.core.windows.net')
where "SD_ID" in (select "SD_ID" from tables_to_migrate);

with
  db_tables_params as (
    select * from "public"."TBLS"
      inner join "public"."DBS" using ("DB_ID")
      inner join "public"."SDS" using ("SD_ID")
      inner join "public"."SERDE_PARAMS" using ("SERDE_ID")
    where coalesce(:databases_with_tables_to_be_migrated, '') = '' or
          "NAME" in (:databases_with_tables_to_be_migrated)
  ),
  -- We filter tables not governed (not created automatically by eureka)
  tables_not_governed as (
    select * from db_tables_params as "TBLS"
    where "TBL_ID" not in (select "TBL_PROPS"."TBL_ID" from "public"."TABLE_PARAMS" as "TBL_PROPS"
                       where "PARAM_KEY" = 'isGoverned' and "PARAM_VALUE" = 'true')
  ),
  -- We filter tables containing an appropriate location url and
  -- not already handled by sscc
  tables_to_migrate as (
    select "DB_ID", "NAME" as "DB_NAME", "TBL_ID", "TBL_NAME", "SERDE_ID"
    from tables_not_governed
    where "PARAM_KEY" = 'path' and "PARAM_VALUE" like :old_cloud_agent_location_prefix and
          "SERDE_ID" not in (select "TBL_OPTS"."SERDE_ID" from "public"."SERDE_PARAMS" as "TBL_OPTS"
                       where "PARAM_KEY" = 'stratiosecuritymode' and "PARAM_VALUE" = 'custom_sscc')
    group by "DB_ID", "NAME", "TBL_ID", "TBL_NAME", "SERDE_ID"
  ),
  modifications as (
    select "SERDE_ID", 'stratiosecurity' as "PARAM_KEY", 'true' as "PARAM_VALUE"
    from tables_to_migrate
    union
    select "SERDE_ID", 'stratiosecuritymode' as "PARAM_KEY", 'custom_sscc' as "PARAM_VALUE"
    from tables_to_migrate
    union
    select "SERDE_ID", 'stratiossccdriver' as "PARAM_KEY", 'com.stratio.connectors.ssccadls2.ADLS2DriverSharedKey' as "PARAM_VALUE"
    from tables_to_migrate
    union
    select "SERDE_ID", 'stratiocredentials' as "PARAM_KEY", :vault_secret_name as "PARAM_VALUE"
    from tables_to_migrate
    union
    select "SERDE_ID", 'path' as "PARAM_KEY", replace(replace(replace("PARAM_VALUE", 'wasb://', 'abfs://'), 'wasbs://', 'abfss://'), 'blob.core.windows.net', 'dfs.core.windows.net') as "PARAM_VALUE"
    from tables_to_migrate inner join tables_not_governed using ("DB_ID", "TBL_ID", "SERDE_ID")
    where "PARAM_KEY" = 'path'
    union
    select "SERDE_ID", 'accountName' as "PARAM_KEY", (regexp_match("PARAM_VALUE", '@(.*)\.(?:dfs|blob)'))[1] as "PARAM_VALUE"
    from tables_to_migrate inner join tables_not_governed using ("DB_ID", "TBL_ID", "SERDE_ID")
    where "PARAM_KEY" = 'path'
  )
insert into "public"."SERDE_PARAMS" as serde_params
select * from modifications
on conflict on constraint "SERDE_PARAMS_pkey" do
  update set "PARAM_VALUE" = excluded."PARAM_VALUE"
  where serde_params."SERDE_ID" = excluded."SERDE_ID" and
        serde_params."PARAM_KEY" = excluded."PARAM_KEY";


-- check migrated tables with
with
  db_tables_params as (
  	select * from "public"."TBLS"
	  inner join "public"."DBS" using ("DB_ID")
	  inner join "public"."SDS" using ("SD_ID")
	  inner join "public"."SERDE_PARAMS" using ("SERDE_ID")
      where coalesce(:databases_with_tables_to_be_migrated, '') = '' or
          "NAME" in (:databases_with_tables_to_be_migrated)
  ),
  tables_not_governed as (
    select * from db_tables_params as "TBLS"
    where "TBL_ID" not in (select "TBL_PROPS"."TBL_ID" from "public"."TABLE_PARAMS" as "TBL_PROPS"
                       where "PARAM_KEY" = 'isGoverned' and "PARAM_VALUE" = 'true')
  )
select "NAME" as "DB_NAME", "TBL_ID", "TBL_NAME", "SERDE_ID" from tables_not_governed
where ("PARAM_KEY" = 'stratiosecurity' and "PARAM_VALUE" ='true') or
      ("PARAM_KEY" = 'stratiosecuritymode' and "PARAM_VALUE" ='custom_sscc') or
      ("PARAM_KEY" = 'stratiossccdriver' and "PARAM_VALUE" ='com.stratio.connectors.ssccadls2.ADLS2DriverSharedKey') or
      ("PARAM_KEY" = 'path' and "PARAM_VALUE" like replace(replace(replace(:old_cloud_agent_location_prefix, 'wasb://', 'abfs://'), 'wasbs://', 'abfss://'), 'blob.core.windows.net', 'dfs.core.windows.net')) or
      ("PARAM_KEY" = 'stratiocredentials' and "PARAM_VALUE" = :vault_secret_name) or
      ("PARAM_KEY" = 'accountName' and coalesce("PARAM_VALUE",'') <> '')
group by "NAME", "TBL_ID", "TBL_NAME", "SERDE_ID"
having COUNT(distinct("PARAM_KEY")) = 6;

-- once you have checked modifications you should do `rollback` or `commit`
