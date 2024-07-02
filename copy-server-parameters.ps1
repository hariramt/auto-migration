# Command to execute
# .\copy-server-parameters.ps1 -JsonFilePath "Path\To\Your\JsonFile.json" -SourceSubscriptionId "Value1" -SourceResourceGroup "Value2" -SingleServerName "Value3" -TargetSubscriptionId "Value4" -TargetResourceGroup "Value5" -FlexibleServerName "Value6"
# Example:
#  .\copy-server-parameters.ps1 -JsonFilePath "C:\Automigration\JsonFile.json" -SourceSubscriptionId "11111111-1111-1111-1111-111111111111" -SourceResourceGroup "my-source-rg" -SingleServerName "source-server-single" -TargetSubscriptionId "11111111-1111-1111-1111-111111111111" -TargetResourceGroup "my-target-rg" -FlexibleServerName "target-server-flexible"


param (
    [string]$JsonFilePath,
	[string]$SourceSubscriptionId,
    [string]$SourceResourceGroup,
    [string]$SingleServerName,
	[string]$TargetSubscriptionId,
	[string]$TargetResourceGroup,
	[string]$FlexibleServerName
)

# Generates a JSON file with all custom settings from the Single Server
az postgres server configuration list --subscription $SourceSubscriptionId --resource-group $SourceResourceGroup --server-name $SingleServerName > $JsonFilePath

# Read the JSON file content
$jsonContent = Get-Content -Path $JsonFilePath -Raw

# Convert JSON content to PowerShell object
$jsonObject = $jsonContent | ConvertFrom-Json

# Arrays of strings - Parameters that will not be copied as Flexible server setting is optimal
$DoNotOverwrite = @("backend_flush_after","backslash_quote","bgwriter_delay","bgwriter_flush_after","bgwriter_lru_maxpages","bgwriter_lru_multiplier","bytea_output","checkpoint_completion_target","checkpoint_timeout","client_encoding","commit_delay","commit_siblings","cpu_index_tuple_cost","cpu_operator_cost","cpu_tuple_cost","cursor_tuple_fraction","datestyle","deadlock_timeout","default_tablespace","effective_cache_size","hot_standby_feedback","intervalstyle","lc_monetary","lc_numeric","lo_compat_privileges","maintenance_work_mem","max_wal_size","old_snapshot_threshold","operator_precedence_warning","parallel_setup_cost","parallel_tuple_cost","pg_stat_statements.track","quote_all_identifiers","random_page_cost","row_security","search_path","seq_page_cost","session_replication_role","shared_buffers","standard_conforming_strings","synchronize_seqscans","synchronous_commit","tcp_keepalives_count","tcp_keepalives_idle","tcp_keepalives_interval","temp_buffers","temp_tablespaces","timezone","track_io_timing","transform_null_equals","vacuum_cost_delay","vacuum_cost_limit","vacuum_cost_page_dirty","vacuum_cost_page_hit","vacuum_cost_page_miss","vacuum_defer_cleanup_age","vacuum_freeze_min_age","vacuum_freeze_table_age","vacuum_multixact_freeze_min_age","vacuum_multixact_freeze_table_age","wal_buffers","wal_writer_delay","wal_writer_flush_after","work_mem")
# Arrays of strings - Parameters that will be copied to the Flexible server
$Overwrite = @("application_name","array_nulls","auto_explain.log_analyze","auto_explain.log_buffers","auto_explain.log_format","auto_explain.log_min_duration","auto_explain.log_nested_statements","auto_explain.log_timing","auto_explain.log_triggers","auto_explain.log_verbose","auto_explain.sample_rate","autovacuum","autovacuum_analyze_scale_factor","autovacuum_analyze_threshold","autovacuum_freeze_max_age","autovacuum_max_workers","autovacuum_multixact_freeze_max_age","autovacuum_naptime","autovacuum_vacuum_cost_delay","autovacuum_vacuum_cost_limit","autovacuum_vacuum_scale_factor","autovacuum_vacuum_threshold","autovacuum_work_mem","check_function_bodies","checkpoint_warning","client_min_messages","constraint_exclusion","debug_pretty_print","debug_print_parse","debug_print_plan","debug_print_rewritten","default_statistics_target","default_text_search_config","default_transaction_deferrable","default_transaction_isolation","default_transaction_read_only","default_with_oids","enable_bitmapscan","enable_gathermerge","enable_hashagg","enable_hashjoin","enable_indexonlyscan","enable_indexscan","enable_material","enable_mergejoin","enable_nestloop","enable_partitionwise_aggregate","enable_partitionwise_join","enable_seqscan","enable_sort","enable_tidscan","escape_string_warning","exit_on_error","extra_float_digits","force_parallel_mode","from_collapse_limit","geqo","geqo_effort","geqo_generations","geqo_pool_size","geqo_seed","geqo_selection_bias","geqo_threshold","gin_fuzzy_search_limit","gin_pending_list_limit","idle_in_transaction_session_timeout","join_collapse_limit","lock_timeout","log_autovacuum_min_duration","log_checkpoints","log_connections","log_destination","log_disconnections","log_duration","log_error_verbosity","log_line_prefix","log_lock_waits","log_min_duration_statement","log_min_error_statement","log_min_messages","log_replication_commands","log_retention_days","log_statement","log_statement_stats","log_temp_files","max_connections","max_locks_per_transaction","max_parallel_workers","max_parallel_workers_per_gather","max_pred_locks_per_page","max_pred_locks_per_relation","max_pred_locks_per_transaction","max_prepared_transactions","max_replication_slots","max_standby_archive_delay","max_standby_streaming_delay","max_sync_workers_per_subscription","max_wal_senders","pg_qs.interval_length_minutes","pg_qs.max_query_text_length","pg_qs.query_capture_mode","pg_qs.replace_parameter_placeholders","pg_qs.retention_period_in_days","pg_qs.track_utility","pg_stat_statements.max","pg_stat_statements.save","pg_stat_statements.track_utility","pgaudit.log","pgaudit.log_catalog","pgaudit.log_client","pgaudit.log_level","pgaudit.log_parameter","pgaudit.log_relation","pgaudit.log_statement_once","pgaudit.role","pgms_wait_sampling.history_period","pgms_wait_sampling.query_capture_mode","postgis.gdal_enabled_drivers","shared_preload_libraries","statement_timeout","track_activities","track_activity_query_size","track_commit_timestamp","track_counts","track_functions","wal_receiver_status_interval","xmlbinary","xmloption")

# Iterate over each item in the JSON array
foreach ($item in $jsonObject) {
    # Check if 'name' is present in 'Overwrite' array
    if ($Overwrite -contains $item.name) {
        # Pass 'name' and corresponding 'value' to along with Subscription, Resource group and server name
		az postgres flexible-server parameter set --name $item.name --value $item.value --subscription $TargetSubscriptionId --resource-group $TargetResourceGroup --server-name $FlexibleServerName 
    }
}