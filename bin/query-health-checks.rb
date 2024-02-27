#!/usr/bin/env ruby
require 'net/http'
require 'logger'
require 'json'

ACTIVE = "active"
INACTIVE = "inactive"
SOLR_STOPPED = "No Solr nodes are running."

logger = Logger.new('/home/rocky/log/health-checks/health_check_status.log', 1, 500000)

instance_id = File.open('/var/lib/cloud/data/instance-id', &:readline).strip

rabbitmq_system_status = `systemctl is-active rabbitmq-server`.strip
rabbitmq_is_active = rabbitmq_system_status == ACTIVE

solr_bin_status = `/opt/solr/bin/solr status`.strip.split("\n").first
solr_bin_status_active = (solr_bin_status != SOLR_STOPPED)
solr_system_status = `systemctl is-active solr.service`.strip
solr_system_status_active = solr_system_status == ACTIVE
solr_is_active = (solr_system_status_active and solr_bin_status_active)
solr_status = solr_is_active ? ACTIVE : INACTIVE

status_log = {"InstanceId" => instance_id, "rabbitmq_status" => rabbitmq_system_status, "solr_status" => solr_status}.to_json
rabbitmq_is_active and solr_is_active ? logger.info(status_log) : logger.error(status_log)