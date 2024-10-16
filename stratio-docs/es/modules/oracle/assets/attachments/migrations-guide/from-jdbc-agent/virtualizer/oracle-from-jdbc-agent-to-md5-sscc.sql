-- Migrate jdbc agent to sscc connector using md5 (user/password) authentication
-- The script assumes the existence of some host variables:
-- * databases_with_tables_to_be_migrated: a list with the catalog databases names
--     containing tables to be migrated
-- * old_jdbc_agent_url_prefix: jdbc url prefix matching jdbc agent(s) about to be migrated
--   * for example 'jdbc:oracle://<server>:<port>/<my_database>%'
-- * new_jdbc_url_sscc: cause it could be different from the jdbc url used by the previous jdbc agent
-- * vault_secret_name: the name of the secret containing specific authentication
--    info (user and password) used by the new sscc connector
begin transaction;
with
  db_tables_params as (
    select * from "public"."TBLS"
      inner join "public"."DBS" using ("DB_ID")
      inner join "public"."SDS" using ("SD_ID")
      inner join "public"."SERDE_PARAMS" using ("SERDE_ID")
    where "NAME" in (:databases_with_tables_to_be_migrated)
  ),
  tables_not_governed as (
    select * from db_tables_params as "TBLS"
    where not exists (select * from "public"."TABLE_PARAMS" as "TBL_PROPS"
                       where "TBL_PROPS"."TBL_ID" = "TBLS"."TBL_ID" and
                             "PARAM_KEY" = 'isGoverned' and
                             "PARAM_VALUE" = 'true')
  ),
  tables_to_migrate as (
    select "NAME" as "DB_NAME", "TBL_ID", "TBL_NAME", "SERDE_ID"
    from tables_not_governed
    where ("PARAM_KEY" = 'url' and "PARAM_VALUE" like :old_jdbc_agent_url_prefix) or
          ("PARAM_KEY" = 'stratiosecuritymode' and "PARAM_VALUE" !='custom_sscc')
    group by "NAME", "TBL_ID", "TBL_NAME", "SERDE_ID"
    having COUNT(distinct("PARAM_KEY")) = 2
  ),
  modifications as (
  	select "SERDE_ID", 'stratiosecuritymode' as "PARAM_KEY", 'custom_sscc' as "PARAM_VALUE"
  	from tables_to_migrate
  	union
  	select "SERDE_ID", 'stratiossccdriver' as "PARAM_KEY", 'com.stratio.connectors.ssccoracle.OracleDriverMD5' as "PARAM_VALUE"
  	from tables_to_migrate
    union
    select "SERDE_ID", 'url' as "PARAM_KEY", :new_jdbc_url_sscc as "PARAM_VALUE"
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
    where "NAME" in (:databases_with_tables_to_be_migrated)
  ),
  tables_not_governed as (
    select * from db_tables_params as "TBLS"
    where not exists (select * from "public"."TABLE_PARAMS" as "TBL_PROPS"
                       where "TBL_PROPS"."TBL_ID" = "TBLS"."TBL_ID" and
                             "PARAM_KEY" = 'isGoverned' and
                             "PARAM_VALUE" = 'true')
  )
select "NAME" as "DB_NAME", "TBL_ID", "TBL_NAME", "SERDE_ID" from tables_not_governed
where ("PARAM_KEY" = 'stratiosecuritymode' and "PARAM_VALUE" ='custom_sscc') or
      ("PARAM_KEY" = 'stratiossccdriver' and "PARAM_VALUE" ='com.stratio.connectors.ssccoracle.OracleDriverMD5') or
      ("PARAM_KEY" = 'url' and "PARAM_VALUE" = :new_jdbc_url_sscc) or
      ("PARAM_KEY" = 'stratiocredentials' and "PARAM_VALUE" = :vault_secret_name)
group by "NAME", "TBL_ID", "TBL_NAME", "SERDE_ID"
having COUNT(distinct("PARAM_KEY")) = 4;

-- once you have checked modifications you should do `rollback` or `commit`
