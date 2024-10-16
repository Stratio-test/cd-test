-- The script assumes the existence of some host variables:
-- * databases_with_tables_to_be_migrated: a list with the catalog databases names
--     containing tables to be migrated (optional, all databases will be considered if not informed)
-- * old_cloud_agent_location_prefix: the file system url prefix of cloud agent(s) about to be migrated.
--   * for example 's3a://my-bucket-name/%'
-- * vault_secret_name: the name of the secret containing specific authentication info
--                          used by the new sscc connector
begin transaction;
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
    select "NAME" as "DB_NAME", "TBL_ID", "TBL_NAME", "SERDE_ID"
    from tables_not_governed
    where "PARAM_KEY" = 'path' and "PARAM_VALUE" like :old_cloud_agent_location_prefix and
          "SERDE_ID" not in (select "TBL_OPTS"."SERDE_ID" from "public"."SERDE_PARAMS" as "TBL_OPTS"
                       where "PARAM_KEY" = 'stratiosecuritymode' and "PARAM_VALUE" = 'custom_sscc')
    group by "NAME", "TBL_ID", "TBL_NAME", "SERDE_ID"
  ),
  modifications as (
  	select "SERDE_ID", 'stratiosecurity' as "PARAM_KEY", 'true' as "PARAM_VALUE"
    from tables_to_migrate
    union
    select "SERDE_ID", 'stratiosecuritymode' as "PARAM_KEY", 'custom_sscc' as "PARAM_VALUE"
    from tables_to_migrate
    union
    select "SERDE_ID", 'stratiossccdriver' as "PARAM_KEY", 'com.stratio.connectors.ssccs3.S3DriverAssumeRole' as "PARAM_VALUE"
    from tables_to_migrate
    union
    select "SERDE_ID", 'stratiocredentials' as "PARAM_KEY", :vault_secret_name as "PARAM_VALUE"
    from tables_to_migrate
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
    where coalesce(:databases_with_tables_to_be_migrated, '') = ''  or
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
      ("PARAM_KEY" = 'stratiossccdriver' and "PARAM_VALUE" ='com.stratio.connectors.ssccs3.S3DriverAssumeRole') or
      ("PARAM_KEY" = 'path' and "PARAM_VALUE" like :old_cloud_agent_location_prefix) or
      ("PARAM_KEY" = 'stratiocredentials' and "PARAM_VALUE" = :vault_secret_name)
group by "NAME", "TBL_ID", "TBL_NAME", "SERDE_ID"
having COUNT(distinct("PARAM_KEY")) = 5;

-- once you have checked modifications you should do `rollback` or `commit`
