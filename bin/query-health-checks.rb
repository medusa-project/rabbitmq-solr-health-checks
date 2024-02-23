#!/usr/bin/env ruby
require 'net/http'
require 'logger'
require 'json'

ACTIVE = "active"
HTTP_OK = "200"

logger = Logger.new('/home/rocky/log/health-checks/health_check_status.log', 1, 500000)

instance_id = File.open('/var/lib/cloud/data/instance-id', &:readline).strip

rabbitmq_status = `systemctl is-active rabbitmq-server`.strip
rabbitmq_is_active = rabbitmq_status == ACTIVE

solr_uri = URI('http://localhost:8983/solr/admin/cores?action=STATUS')
solr_response_code = Net::HTTP.get_response(solr_uri).code
solr_status = `systemctl is-active solr.service`.strip
solr_is_active = (solr_status == ACTIVE and solr_response_code == HTTP_OK)

status_log = {"InstanceId" => instance_id, "rabbitmq_status" => rabbitmq_status, "solr_status" => solr_status}.to_json
rabbitmq_is_active and solr_is_active ? logger.info(status_log) : logger.error(status_log)