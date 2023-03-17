"""
 * © 2021 Stratio Big Data Inc., Sucursal en España. All rights reserved.
 *
 * This software – including all its source code – contains proprietary
 * information of Stratio Big Data Inc., Sucursal en España and
 * may not be revealed, sold, transferred, modified, distributed or
 * otherwise made available, licensed or sublicensed to third parties;
 * nor reverse engineered, disassembled or decompiled, without express
 * written authorization from Stratio Big Data Inc., Sucursal en España.
"""
import os
import logging
import urllib.parse
from http.client import HTTPSConnection, HTTPResponse
from ssl import SSLContext, PROTOCOL_TLS, CERT_NONE
import json
import dns.resolver

from airflow.utils.decorators import apply_defaults
from airflow.operators.bash import BashOperator
from airflow.exceptions import AirflowException
from airflow.hooks.base_hook import BaseHook

log = logging.getLogger(__name__)
key_name = "airflow" if not (os.environ.get('APP_ID')) else os.environ['APP_ID']


class RocketOperator(BashOperator):
    """Airflow RocketOPerator y run WFs."""

    @staticmethod
    def get_params(project_id: str,
                   workflow_id: str,
                   host,
                   retries_status: int = 12,
                   status_polling_frequency: int = 15,
                   backoff_start: str = 300,
                   paramsLists: list = None,
                   extra_params=None) -> dict:
        """GET rocket.sh params by ID."""
        return {
            "host": "https://" + host + ":7777",
            'retries_status': retries_status,
            'frecuency': status_polling_frequency,
            'backoff_start': backoff_start,
            'cmd': {
                "workflowId": workflow_id,
                "projectId": project_id,
                "executionContext": {
                    "extraParams": extra_params,
                    "name": "",
                    "paramsLists": paramsLists
                }
            }
        }

    def get_params_by_name(self,
                           host: str,
                           group_name: str,
                           workflow_name: str,
                           workflow_version: str,
                           retries_status: int = 12,
                           status_polling_frequency: int = 15,
                           backoff_start: str = 300,
                           paramsLists: list = None,
                           extra_params=None) -> dict:
        """GET rocket.sh params by name.
        Args:
            host
            group_name
            workflow_name
            workflow_version
            retries-rocket
            status_polling_frequency
            backoff_start
            paramslists
            extra_params
        Raises:
            AirflowException
        Returns:
            :obj:`dict`: rocket.sh params
        """
        if group_name is None or workflow_name is None:
            raise AirflowException(
                "Unable to find workflow, project_name or workflow_name "
                "cannot be None"
                )

        log.debug("finding WF: %s:%s in %s",
                  workflow_name, workflow_version, group_name)
        project_id = self.__get_project_id_by_group_name(group_name)
        workflow = self.__get_workflow_by_name(group_name, workflow_name)
        workflow_id = self.__get_workflow_id_by_version(workflow["id"])
        return self.get_params(
            host=host,
            project_id=project_id,
            workflow_id=workflow_id,
            retries_status=retries_status,
            status_polling_frequency=status_polling_frequency,
            backoff_start=backoff_start,
            paramsLists=paramsLists,
            extra_params=extra_params
            )

    def __get_project_id_by_group_name(self, group_name: str) -> str:
        """GET Rocket project_id given workflow asset group_name."""
        # TODO analizar [:1]
        group_name_tokenized = group_name.split("/")[1:]
        if len(group_name_tokenized[:2]) != 2:
            raise AirflowException(
                f"Group name format must be: /home/<project_name>. "
                f"Group name:{group_name}"
                )
        if group_name_tokenized[0] != "home":
            raise AirflowException(
                f"Group name format must be: /home/<project_name>. "
                f"home not found in {group_name}"
                )
        url = "/projects/findByName/"
        uri = url + group_name_tokenized[1]
        try:
            response = self.__create_connection_get_request(uri)
        except Exception as proyect_err:
            log.error(
                "Unable to get project from %s",
                uri
                )
            raise AirflowException(
                "Rocket Server not available"
                ) from proyect_err
        if response.status == 200:
            try:
                return json.loads(response.read())["id"]
            except json.JSONDecodeError as json_error:
                log.error("Invalid Project asset response from Rocket")
                raise AirflowException(
                    "Rocket response not valid"
                    ) from json_error
            except Exception as unhandled:
                log.error("Unhandled error %s", unhandled)
                raise AirflowException(
                    f"Unable to get asset id for project from {uri}"
                    ) from unhandled
        else:
            log.error("Asset %s Not Found", uri)
            raise AirflowException(
                f"Asset {uri} Not Found [{response.status}] => {response.reason}"
                )

    def __get_workflow_id_by_version(self,
                                     workflow_id: str,
                                     workflow_version: str = None) -> str:
        """GET WF Versions by asset ID.
        Args:
            workflow_id (:obj:`str`): Rocket workflow id
            workflow_version (:obj:`str`): Rocket workflow version
        Raises:
            AirflowException
        Returns:
            :obj:`str`: Rocket asset ID
        """
        url = "/assets/findAllVersions/"
        uri = url + workflow_id
        try:
            response = self.__create_connection_get_request(uri)
        except Exception as versions_not_found:
            log.error(
                "Unable to get asset versions from %s",
                workflow_id
                )
            raise AirflowException(
                "Rocket Server not available"
                ) from versions_not_found
        if response.status == 200:
            try:
                list_assets = list(json.loads(response.read()))
                if workflow_version is None:
                    asset = max(list_assets, key=lambda x: x["version"])["id"]
                    if len(asset) < 1:
                        raise AirflowException(
                            f"Rocket Asset {workflow_version} not found"
                            )
                    return asset
                return [
                    a["id"] for a in list_assets
                    if a["version"] == int(workflow_version)
                    ][0]
            except json.JSONDecodeError as json_err:
                log.error("Invalid WF Asset response from Rocket")
                raise AirflowException(
                    "Rokcet response not valid"
                    ) from json_err
            except IndexError as version_not_found:
                raise AirflowException(
                    f"Rocket Asset {workflow_version} Not Found"
                    ) from version_not_found
            except Exception as unknown_err:
                log.error("Unhandled error %s", unknown_err)
                raise AirflowException(
                    f"Unable to get asset id for version {workflow_version}"
                    f"from {workflow_id}"
                    ) from unknown_err
        else:
            log.error("Asset %s Not Found", workflow_id)
            raise AirflowException(
                f"Asset {workflow_id} Not Found"
                )

    def __get_workflow_by_name(self,
                               group_name: str,
                               workflow_name: str) -> str:
        """GET Rocket WF Object by name.
        Args:
            group_name (:obj:`str`): Rocket group or project
        Raises:
            AirflowException
        Returns:
            :obj:`str`: Rocket Workflow ID
        """
        normalized_group_name_path = self.to_normalized_name(group_name)
        workflow_group_id = self.__get_group_by_name(group_name)
        url = "/assets/findAllByGroup/"
        uri = url + workflow_group_id + "?assetType=Workflow"

        try:
            response = self.__create_connection_get_request(uri)
        except Exception as rocket_error:
            log.error("Unable to get Workflows from %s", group_name)
            raise AirflowException(
                "Rocket Server not available"
                ) from rocket_error
        if response.status == 200:
            try:
                log.debug("Getting workflowAsset from %s with id: %s",
                          group_name,
                          workflow_group_id
                          )
                dict_response = json.loads(response.read())
                list_workflows = [
                    wf for wf in dict_response
                    if wf["workflowAsset"]["group"]["name"] == normalized_group_name_path
                    and wf["workflowAsset"]["name"] == workflow_name
                    ]
                if len(list_workflows) < 1:
                    raise AirflowException(
                        f"Rocket asset {workflow_name} "
                        f"not Found in {dict_response}"
                        )
                return list_workflows[0]["workflowAsset"]
            except json.JSONDecodeError as json_error:
                log.error("Invalid WF Asset response from Rocket")
                raise AirflowException(
                    "Rokcet response not valid"
                    ) from json_error
            except Exception as workflow_error:
                log.error("Unhandled error %s", workflow_error)
                raise AirflowException(
                    f"Rocket asset: {workflow_name} "
                    f"not found in project: {group_name}."
                    ) from workflow_error
        else:
            log.error("Group %s Asset Not Found", group_name)
            raise AirflowException(
                f"Project {normalized_group_name_path} not found "
                f"[{response.status}] => {response.reason}"
                )

    def __get_group_by_name(self, group_name: str) -> str:
        """GET group ID from Rocket by name.
        Args:
            group_name (:obj:`str`): Rocket group or project
        Raises:
            AirflowException
        Returns:
            :obj:`dict`: Rocket group ID
        """
        normalized_group_name_path = self.to_normalized_name(group_name)
        url = "/groups/findByName/"
        uri = url + urllib.parse.quote_plus(normalized_group_name_path)

        try:
            response = self.__create_connection_get_request(uri)
        except Exception as rocket_error:
            log.error("Rocket Server not available")
            raise AirflowException(
                "Rocket Server not available"
                ) from rocket_error
        if response.status == 200:
            try:
                return json.loads(response.read())["id"]
            except json.JSONDecodeError as json_error:
                log.error("Invalid group response from Rocket")
                raise AirflowException(
                    "Rokcet response not valid"
                    ) from json_error
        else:
            log.error("Rocket group %s Not Found", group_name)
            raise AirflowException(
                f"Rocket group {normalized_group_name_path} not found "
                f"[{response.status}] => {response.reason}"
                )

    @staticmethod
    def to_normalized_name(group_name: str) -> str:
        """Normalize project name to Rocket rules.
        Args:
           group_name (str): Rocket path. ie: /home/01---test
        Returns:
            (str): group_name with project normalized
        """
        normalized_group_name = group_name.split("/")[2].lower() \
                                                        .replace(" ", "-") \
                                                        .replace("_", "-") \
                                                        .replace("/", "-")
        return group_name.replace(
            group_name.split("/")[2], normalized_group_name
        )

    @staticmethod
    def __dns_resolver(hostname, resolvers) -> str:
        """Resolve host to IPv4 address.
        Args:
           hostname (str): hostname to be resolved,
           resolvers (list): List of IPv4 address where
                             DNS servers are listening.
        Returns:
            (str): IPv4  address
        """
        try:
            resolver = dns.resolver.Resolver(configure=False)
            resolver.nameservers = resolvers
            answer = resolver.resolve(hostname, "A")
            return answer[0].address
        except dns.resolver.NoNameservers as resolver_err:
            raise AirflowException(
                f"resolve DNS error: {resolver_err}"
                ) from resolver_err

    def __configure_connection(self) -> None:
        """Configure Rocket connection from Airflow connection.
        Config from airflow connection
        Host:
           s000002-rocket-conectores.rocket-conectores.s000002.marathon.mesos
        Extra:
           {
            "ssl": {"check_hostname": true},
            "dns": {"resolvers": ["10.200.24.7"]}
           }
        # TODO headers
            "request_headers": {"User-Agent": "Airflow/RocketOperator"},
        """
        self.host = self.connection.host
        self.check_hostname = True
        resolvers = []
        if self.connection.extra:
            try:
                con_extra_params = json.loads(self.connection.extra)
                if "ssl" in con_extra_params.keys():
                    self.check_hostname = con_extra_params["ssl"]["check_hostname"]
                if "dns" in con_extra_params.keys():
                    resolvers = con_extra_params["dns"]["resolvers"]
            except json.decoder.JSONDecodeError as json_err:
                raise AirflowException(
                    f"connection configuration error: {self.connection.extra}"
                    ) from json_err
            except KeyError as key_configuration_error:
                raise AirflowException(
                    f"connection configuration error: "
                    f"key {key_configuration_error} not found"
                ) from key_configuration_error
        if resolvers:
            self.host = self.__dns_resolver(self.host, resolvers)

    def __create_connection_get_request(self,
                                        request_uri) -> HTTPResponse:
        """Create mTLS GET connection.
        Args:
           request_uri (str): Rocket resource URI,
               ex: /groups/findByName/{name}
        Returns:
            (HTTPResponse): Response object
        """
        request_headers = {}
        # TODO configure from connection.extra
        # request_headers = {} if request_headers is None else request_headers
        # export AIRFLOW_HOME="~/src/airflow/resources"

        key_file = os.environ['AIRFLOW_HOME'] + "/pki/" + key_name + ".key"
        cert_file = os.environ['AIRFLOW_HOME'] + "/pki/" + key_name + ".pem"
        ca_file = os.environ['AIRFLOW_HOME'] + "/pki/ca-bundle.pem"

        context = SSLContext(PROTOCOL_TLS)
        context.load_cert_chain(certfile=cert_file,
                                keyfile=key_file)
        if not self.check_hostname:
            context.verify_mode = CERT_NONE
            context.check_hostname = False
        else:
            context.load_verify_locations(cafile=ca_file)

        connection = HTTPSConnection(host=self.host,
                                     port=7777,
                                     context=context)
        request_headers.update({
            "accept": "application/json",
            "User-Agent": "Airflow/RocketOperator"})
        connection.request(method="GET",
                           url=request_uri,
                           headers=request_headers)

        return connection.getresponse()

    bash_command = """/opt/airflow/dags/providers/stratio/rocket/scripts/rocket.sh \
    -e local \
    --url {{ params.host }} \
    --cacert /opt/airflow/pki/ca-bundle.pem \
    --key /opt/airflow/pki/%(s)s.key \
    --cert /opt/airflow/pki/%(s)s.pem \
    --retries-status {{ params.retries_status}} \
    -f {{ params.frecuency }} \
    --backoff-start {{ params.backoff_start }} \
    -b "{{ params.cmd | tojson | replace('"', '\\\\"') }}" """ % {'s': key_name}

    ui_color = '#00ccff'

    @apply_defaults
    def __init__(
            self,
            connection_id: str,
            project_id: str = None,
            workflow_id: str = None,
            group_name: str = None,
            workflow_name: str = None,
            workflow_version: str = None,
            retries_status: int = 12,
            status_polling_frequency: int = 15,
            backoff_start: int = 300,
            paramsLists: list = None,
            extra_params: list = None,
            *args,
            **kwargs):
        """Rocketoperator Constructor.
        Args:
            connection_id
            project_id default None
            workflow_id default None
            group_name default None
            workflow_name default None
            workflow_version: default None
            retries_status: default 12
            status_polling_frequency: default 15
            backoff_start: default 300
            paramsLists:
               default ["Environment", "SparkConfigurations", "SparkResources"]
            extra_params: default []
        """
        try:
            self.connection = BaseHook.get_connection(connection_id)
        except Exception as connection_id_not_exists:
            raise AirflowException(
                "Rocket Service connection_id not found"
                ) from connection_id_not_exists

        self.__configure_connection()
        params_lists = ["Environment", "SparkConfigurations", "SparkResources"] if paramsLists is None else paramsLists
        extra_params = [] if paramsLists is None else extra_params

        if (group_name is not None
                or workflow_name is not None
                or workflow_version is not None):

            kwargs.update({
               "params": self.get_params_by_name(
                   host=self.host,
                   group_name=group_name,
                   workflow_name=workflow_name,
                   workflow_version=workflow_version,
                   retries_status=retries_status,
                   status_polling_frequency=status_polling_frequency,
                   backoff_start=backoff_start,
                   paramsLists=params_lists,
                   extra_params=extra_params)
               })
        elif (project_id is not None
              or workflow_id is not None):
            kwargs.update({
                "params": RocketOperator.get_params(
                    host=self.host,
                    workflow_id=workflow_id,
                    project_id=project_id,
                    retries_status=retries_status,
                    status_polling_frequency=status_polling_frequency,
                    backoff_start=backoff_start,
                    paramsLists=params_lists,
                    extra_params=extra_params)
            })
        else:
            raise AirflowException(
                "Arguments ['project_id', 'workflow_id'] "
                "or ['group_name', 'workflow_name', 'workflow_version'] "
                "are required"
                )

        super().__init__(bash_command=RocketOperator.bash_command,
                         *args,
                         **kwargs)
