*Spark History Server* needs to download certain secrets when security is enabled. These secrets must be stored in Vault in the mount points described below:

## Certificates

|Description|Components using the certificate|CN|SAN|Type|Vault URL|
|-----------|--------------------------------|---|---|---|---------|
|Certificate for enabling TLS in History Server| Spark History Server|history-server|history-server.marathon history-server. (example history-server.paas.labs.stratio.com)|client-server|/userland/certificates/history-server|
|CA used to sign the rest of the certificates| Spark History Server|-|-|CA|ca_trust/certificates/_ca|

## Keytabs

|Description|Components using the keytab|Principal|Host|Realm|Vault URL|
|-----------|---------------------------|---------|----|-----|---------|
|Keytab for accessing Kerberized HDFS|Spark History Server|spark|This value it's got from core-site.xml (Hadoop conf file). An example is hdfs-namenode1.labs.stratio.com|Fully qualified domain of the environment. This value it's got as input in the framework deployment descriptor and it's used to build the config file krb5.conf. Example value: DEMO.STRATIO.COM|/userland/kerberos/history-server|

## Passwords

|Description|Components using the certificate|User|Password|Vault URL|
|-----------|--------------------------------|----|--------|---------|
|Oauth ClientId and clientSecret|Spark History Server|ClientId used in *Stratio GoSec* SSO for registering service|SecretId used in *Stratio GoSec* SSO for registering service|/userland/passwords/spark-fw/oauthinfo /userland/passwords/history-server/oauthinfo|
|JWT password|Spark History Server|-|Token used to cypher all the JWT Tokens|/userland/passwords/spark-fw/jwt_secret /userland/passwords/history-server/jwt_secret|
