# /packages/intranet-portfolio-management/www/project_status.json.tcl
#
# Copyright (C) 2019 ]project-open[
#
# All rights reserved. Please check
# http://www.project-open.com/license/ for details.

# ----------------------------------------------------------------------
#
# ---------------------------------------------------------------------

ad_page_contract {
    Datasource for project-status Sencha line chart.
    <ul>
    <li>diagram_interval options include "all_time", "last_year", "last_quarter" and "last_month"
    <li>diagram_fact options include "number" and "volume"
    </ul>
} {
    { diagram_program_id "" }
    { diagram_interval "all_time" }
    { diagram_fact "revenue" }
    { diagram_min_start_date "2015-01-01" }
}

# ----------------------------------------------------
# Defaults & Permissions
# ----------------------------------------------------

set current_user_id [ad_conn user_id]
if {![im_permission $current_user_id view_companies_all] || ![im_permission $current_user_id view_finance]} { 
    set json "{\"success\": false, \"message\": \"Insufficient permissions - you need view_companies_all and view_finance.\" }"
    doc_return 400 "application/json" $json
    ad_script_abort
}

set default_currency [im_parameter -package_id [im_package_cost_id] "DefaultCurrency" "" "EUR"]

# ----------------------------------------------------
#
# ----------------------------------------------------

switch $diagram_interval {
    all_time { set diagram_start_date [db_string all_time "
	select greatest(min(start_date)::date, :diagram_min_start_date::date) from im_projects where parent_id is null
    "] }
    last_year { set diagram_start_date [db_string year "select now()::date - 365 - 31"] }
    last_two_years { set diagram_start_date [db_string year "select now()::date - 365*2 - 31"] }
    last_quarter { set diagram_start_date [db_string year "select now()::date - 90 - 31"] }
    default {
	set json "{\"success\": false, \"message\": \"Invalid diagram_interval option: '$diagram_interval'.\" }"
	doc_return 400 "application/json" $json
	ad_script_abort
    }
}
# ad_return_complaint 1 $diagram_start_date
set diagram_end_date [db_string year "select now()::date"]

# ----------------------------------------------------
# <fact> by department
# ----------------------------------------------------

set program_sql ""
if {"" ne $diagram_program_id} { set program_sql "and p.program_id = :diagram_program_id" }

set audit_sql "
	select	count(*) as cnt,
		audit_date,
		project_status_id
	from
		(select	p.project_id,
			im_month_enumerator::date as audit_date,
			im_audit_value(p.project_id, 'project_status_id', im_month_enumerator)::integer as project_status_id
		from	im_projects p,
			im_month_enumerator(:diagram_start_date::date, :diagram_end_date::date)
		where	p.parent_id is null and
			p.project_status_id not in ([im_project_status_deleted]) and
			p.project_type_id not in ([im_project_type_program]) and
			p.end_date > :diagram_start_date
			$program_sql
		) a
	group by
		audit_date,
		project_status_id
	order by
		audit_date,
		project_status_id
"
#ad_return_complaint 1 "<pre>$audit_sql</pre><br>[im_ad_hoc_query -format html "$audit_sql"]"
db_foreach audit $audit_sql {
    set key "$project_status_id-$audit_date"
    set hash($key) $cnt
    set date_hash($audit_date) $audit_date
    set status_hash($project_status_id) $project_status_id
}
# ad_return_complaint 1 "[array get hash]"

# ----------------------------------------------------
# Dimensions
# ----------------------------------------------------

# Get the list of all departments
set status_sql "
	select	c.category_id as status_id
	from	im_categories c
	where	c.category_type = 'Intranet Project Status' and
		c.enabled_p = 't'
	order by
		coalesce(sort_order, category_id)
"

set status_list {""}
db_foreach status $status_sql {
    if {[info exists status_hash($status_id)]} { lappend status_list $status_id }
}
# ad_return_complaint 1 $status_list


# Get the month dimension
set months [qsort [array names date_hash]]


# ----------------------------------------------------
# Start looping
# ----------------------------------------------------


set cnt 0
foreach month $months {
    set line [list "'Date': new Date(\"$month\")"]

    foreach status_id $status_list {
        set value ""
	set key "$status_id-$month"
	if {[info exists hash($key)]} { set value $hash($key) }
	if {"" eq $value} { set value 0 }
	lappend line "'[im_category_from_id $status_id]': $value"
    }

    lappend rows "\{[join $line ", "]\}"
    incr cnt
}


# ----------------------------------------------------
# Create JSON for data source
# ----------------------------------------------------

set json "{\"success\": true, \"message\": \"Data loaded\", \"data\": \[\n[join $rows ",\n"]\n\]}"
doc_return 200 "application/json" $json

