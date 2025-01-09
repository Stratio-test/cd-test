-- All scripts assume the presence of some host variables:
-- * databases_with_tables_to_be_migrated: a list with the catalog databases names
--     containing tables to be migrated
-- * old_jdbc_agent_url_prefix: the jdbc url prefix of jdbc agent(s) about to be migrated.
--   * for example 'jdbc:sqlserver://<server>:<port>;database=<my_database>%'

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
    where not exists (select * from "public"."TABLE_PARAMS" as "TBL_PROPS"
                       where "TBL_PROPS"."TBL_ID" = "TBLS"."TBL_ID" and
                             "PARAM_KEY" = 'isGoverned' and
                             "PARAM_VALUE" = 'true')
  ),
  -- We filter tables containing both an appropiate jdbc url and
  -- the specific security mode supported by a jdbc agent (user_pass)
  tables_to_migrate as (
    select "NAME" as "DB_NAME", "TBL_ID", "TBL_NAME", "SERDE_ID"
    from tables_not_governed
    where ("PARAM_KEY" = 'url' and
            (coalesce(:old_jdbc_agent_url_prefix,'') = '' or
             "PARAM_VALUE" like :old_jdbc_agent_url_prefix)) or
          ("PARAM_KEY" = 'stratiosecuritymode' and "PARAM_VALUE" !='custom_sscc')
    group by "NAME", "TBL_ID", "TBL_NAME", "SERDE_ID"
    -- The predicate below ensures tables to be processed contains *both* parameters,
    --   appropiate jdbc url and jdbc agent specific security mode
    -- For example, if we already have tables using the sscc driver,
    -- their security mode param value will be `customsscc`
    -- and this predicate will not hold (will be 1) for them
    -- so they will be not processed
    having COUNT(distinct("PARAM_KEY")) = 2
  )
select * from tables_to_migrate;
