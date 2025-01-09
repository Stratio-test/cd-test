-- All scripts assume the presence of some host variables:
-- * databases_with_tables_to_be_migrated: a list with the catalog databases names
--     containing tables to be migrated (optional, all databases will be considered if not informed)
-- * old_cloud_agent_location_prefix: the file system url prefix of cloud agent(s) about to be migrated.
--   * for example 's3a://my-bucket-name/%'

-- Sanity check: this select will report which tables are going to be migrated
-- and it is will be used in the scripts doing the actual changes
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
  )
select * from tables_to_migrate;
