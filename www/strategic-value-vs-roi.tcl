# /packages/intranet-portfolio-management/www/strategic-value-vs-roi.tcl
#
# Copyright (C) 1998-2013 various parties
# The software is based on ArsDigita ACS 3.4
#
# This program is free software. You can redistribute it
# and/or modify it under the terms of the GNU General
# Public License as published by the Free Software Foundation;
# either version 2 of the License, or (at your option)
# any later version. This program is distributed in the
# hope that it will be useful, but WITHOUT ANY WARRANTY;
# without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details.

# ---------------------------------------------------------------
# 1. Page Contract
# ---------------------------------------------------------------

ad_page_contract { 
    Shows a 2x2 Sencha diagram
    @author frank.bergmann@project-open.com
} {
}

# ---------------------------------------------------------------
# 2. Defaults & Security
# ---------------------------------------------------------------

set current_user_id [auth::require_login]
set subsite_id [ad_conn subsite_id]
set page_title [lang::message::lookup "" intranet-portfolio-management.Strategic_Value_vs_ROI "Strategic Value vs. ROI"] 
set context_bar [im_context_bar $page_title]
set main_navbar_label "portfolio"
set page_focus "im_header_form.keywords"
set page_url [im_url_with_query]

set left_navbar_html ""
set sub_navbar ""

if {![im_permission $current_user_id "view_projects_all"]} {
    ad_return_complaint 1 "You don't have the right to see all projects"
}

set html ""

set sql "
	select	coalesce(p.score_strategic, 0.0) as y_axis,
		coalesce(p.score_roi, 0.0) as x_axis,
		case	when p.on_track_status_id = 66 then 'green'
			when p.on_track_status_id = 67 then 'yellow'
			when p.on_track_status_id = 68 then 'red'
		end as color,
		sqrt(coalesce(p.project_budget, p.presales_value, 200.0)) / 10.0 as diameter,
		p.project_name as title,
		(select url from im_biz_object_urls where object_type = 'im_project' and url_type = 'view') || p.project_id as url
	from	im_projects p
	where	p.parent_id is null and
		p.project_status_id not in (select * from im_sub_categories([im_project_status_closed]))
	order by p.project_id
"

# Sencha check and permissions
if {[im_sencha_extjs_installed_p]} {

    im_sencha_extjs_load_libraries

    set params [list \
		    [list diagram_width 800] \
		    [list diagram_height 500] \
		    [list diagram_caption $page_title] \
		    [list diagram_x_title "ROI"] \
		    [list diagram_y_title "Strategic Value"] \
		    [list sql $sql] \
    ]
    set html [ad_parse_template -params $params "/packages/intranet-reporting-dashboard/lib/scatter-diagram"]
}




# ---------------------------------------------------------------
# Sub-Navbar
# ---------------------------------------------------------------

set bind_vars [ns_set create]
set parent_menu_id [im_menu_id_from_label $main_navbar_label]
set sub_navbar [im_sub_navbar \
		    -components \
                    -base_url $page_url \
                    -plugin_url $page_url \
                    -menu_gif_type "none" \
                    $parent_menu_id \
		    $bind_vars "" \
		    "pagedesriptionbar" \
		    "strategic_vs_roi" \
]

