# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110929221228) do

  create_table "added_modules", :force => true do |t|
    t.string  "module_name"
    t.string  "module_type"
    t.string  "edit_path"
    t.string  "delete_path"
    t.boolean "is_active"
  end

  create_table "general_configurations", :force => true do |t|
    t.integer "scan_history_polling"
    t.integer "scan_history_polling_time_frame"
    t.integer "nsc_polling"
  end

  create_table "jira3_ticket_configs", :force => true do |t|
    t.integer "project_id"
    t.integer "priority_id"
    t.integer "assignee_id"
    t.string  "default_reporter"
    t.integer "issue_type_id"
    t.string  "username"
    t.string  "password"
    t.string  "host"
    t.integer "port"
  end

  create_table "jira4_ticket_configs", :force => true do |t|
    t.string  "assignee"
    t.string  "reporter"
    t.string  "project_name"
    t.integer "issue_id"
    t.integer "priority_id"
    t.string  "username"
    t.string  "password"
    t.string  "host"
    t.integer "port"
  end

  create_table "last_scans", :force => true do |t|
    t.string  "host"
    t.integer "scan_id"
  end

  create_table "module_types", :force => true do |t|
    t.string "view"
    t.string "title"
    t.string "description"
  end

  create_table "nexpose_field_mappings", :force => true do |t|
    t.string "node_address"
    t.string "node_name"
    t.string "vendor"
    t.string "product"
    t.string "family"
    t.string "version"
    t.string "vulnerability_status"
    t.string "vulnerability_id"
    t.string "description"
    t.string "proof"
    t.string "solution"
    t.string "scan_start"
    t.string "scan_end"
  end

  create_table "nexpose_ticket_configs", :force => true do |t|
    t.string  "nexpose_default_user"
    t.integer "nexpose_client_id"
  end

  create_table "nsc_configs", :force => true do |t|
    t.boolean "is_active"
    t.string  "username"
    t.string  "password"
    t.string  "silo_id"
    t.string  "host"
    t.string  "port"
  end

  create_table "remedy_ticket_configs", :force => true do |t|
    t.text "mappings"
  end

  create_table "scan_history_time_frames", :force => true do |t|
    t.string  "time_type"
    t.integer "multiplicate"
  end

  create_table "scans_processed", :force => true do |t|
    t.string "host"
    t.string "scan_id"
    t.string "module"
  end

  create_table "ticket_clients", :force => true do |t|
    t.string "client"
    t.string "client_connector"
    t.string "formatter"
  end

  create_table "ticket_configs", :force => true do |t|
    t.boolean "is_active"
    t.string  "module_name"
    t.integer "ticket_client_id"
    t.string  "ticket_client_type"
  end

  create_table "ticket_mappings", :force => true do |t|
    t.string  "node_address"
    t.string  "node_name"
    t.string  "vendor"
    t.string  "product"
    t.string  "family"
    t.string  "version"
    t.string  "vulnerability_status"
    t.string  "vulnerability_id"
    t.string  "description"
    t.string  "proof"
    t.string  "solution"
    t.string  "scan_start"
    t.string  "scan_end"
    t.string  "cvss_score"
    t.integer "ticket_config_id"
  end

  create_table "ticket_rules", :force => true do |t|
    t.boolean "use_vv"
    t.boolean "use_ve"
    t.boolean "use_vp"
    t.integer "cvss_min"
    t.integer "cvss_max"
    t.integer "ticket_config_id"
  end

  create_table "ticketing_styles", :force => true do |t|
    t.string "name"
    t.string "description"
  end

  create_table "tickets_createds", :force => true do |t|
    t.string "host"
    t.string "module_name"
    t.string "ticket_id"
  end

  create_table "tickets_to_be_createds", :force => true do |t|
    t.string "ticket_id"
    t.text   "ticket_data"
  end

  create_table "vuln_infos", :force => true do |t|
    t.string "vuln_id"
    t.text   "vuln_data"
  end

end
