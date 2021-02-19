# /packages/intranet-portfolio-management/lib/project-status.tcl
#
# Copyright (C) 2019 ]project-open[
#
# All rights reserved. Please check
# https://www.project-open.com/license/ for details.

# ----------------------------------------------------------------------
# Variables
# ---------------------------------------------------------------------

# The following variables are expected in the environment
# defined by the calling /tcl/*.tcl libary:
if {![info exists diagram_program_id]} { set diagram_program_id "" }
if {![info exists diagram_width]} { set diagram_width 600 }
if {![info exists diagram_height]} { set diagram_height 500 }
if {![info exists diagram_title] || "" eq $diagram_title} { set diagram_title [lang::message::lookup "" intranet-portfolio-management.Project_Status_Over_Time "Project Status Over Time"] }
if {![info exists diagram_default_interval] || "" eq $diagram_default_interval} { set diagram_default_interval "last_year" }
if {![info exists diagram_default_fact] || "" eq $diagram_default_fact} { set diagram_default_fact "revenue" }
if {![info exists diagram_min_start_date]} { set diagram_min_start_date "2015-01-01" }


# ----------------------------------------------------
# Diagram Setup
# ----------------------------------------------------

# Create a random ID for the diagram
set diagram_rand [expr {round(rand() * 100000000.0)}]
set diagram_id "project_status_$diagram_rand"
set default_currency [im_parameter -package_id [im_package_cost_id] "DefaultCurrency" "" "EUR"]

# Get the list of all departments
set status_sql "
	select	im_category_from_id(c.category_id) as status
	from	im_categories c
	where	c.category_type = 'Intranet Project Status' and
		c.enabled_p = 't' and
		c.category_id not in ([im_project_status_deleted])
	order by
		coalesce(sort_order, category_id)
"
set status_list [db_list status_list $status_sql]
set first_status [lindex $status_list 0]
# ad_return_complaint 1 $status_list



set status_list_json "\['[join $status_list "', '"]'\]"

# The header of the Sencha store:
set header_list [linsert $status_list 0 "Date"]
set header_json "\['[join $header_list "', '"]'\]"

# Show Axis only until 1st of current month.
# Everything within the current month is vague,
# because invoices are probably not yet written...
set axis_from_date [db_string to_date "select to_char(now()::date-31, 'YYYY-MM-01')"]
set axis_to_date [db_string to_date "select to_char(now(), 'YYYY-MM-01')"]
