#!/usr/bin/env ruby
require 'logger'
require 'json'

ACTIVE = "active"
logger = Logger.new('/home/rocky/log/health-checks/health_check_status.log', 1, 500000)

instance_id = File.open('/var/lib/cloud/data/instance-id', &:readline).strip

rabbitmq_status = `systemctl is-active rabbitmq-server`.strip
rabbitmq_is_active = rabbitmq_status == ACTIVE

solr_status = `systemctl is-active solr.service`.strip
solr_is_active = solr_status == ACTIVE

status_log = {"InstanceId" => instance_id, "rabbitmq_status" => rabbitmq_status, "solr_status" => solr_status}.to_json
rabbitmq_is_active and solr_is_active ? logger.info(status_log) : logger.error(status_log)