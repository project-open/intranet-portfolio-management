-- /packages/intranet-portfolio-management/sql/postgresql/intranet-portfolio-management-create.sql
--
-- Copyright (c) 2003-2010 ]project-open[
--
-- All rights reserved. Please check
-- http://www.project-open.com/license/ for details.
--
-- @author frank.bergmann@project-open.com


-- Define the value range for categories
-- The aux_int1 value will include a numeric value for the priorites
--
-- 70000-70999  Portfolio Management (1000)
-- 70000-70099  Intranet Department Planner Project Priority (100)
-- 70100-71999  Intranet Department Planner Action (100)

-- Define value range for views
-- 300-309              intranet-portfolio-management


-- ----------------------------------------------------------------
-- Program Portfolio Portlet
-- ----------------------------------------------------------------

SELECT	im_component_plugin__new (
	null,				-- plugin_id
	'im_component_plugin',		-- object_type
	now(),				-- creation_date
	null,				-- creation_user
	null,				-- creation_ip
	null,				-- context_id
	'Program Portfolio List',	-- plugin_name
	'intranet-portfolio-management', -- package_name
	'right',			-- location
	'/intranet/projects/view',	-- page_url
	null,				-- view_name
	15,				-- sort_order
	'im_program_portfolio_list_component -program_id $project_id'	-- component_tcl
);

SELECT acs_permission__grant_permission(
	(select plugin_id from im_component_plugins where plugin_name = 'Program Portfolio List'),
	(select group_id from groups where group_name = 'Employees'),
	'read'
);





-- 300-309              intranet-portfolio-management
-- 300			program_portfolio_list

--
delete from im_view_columns where column_id > 30000 and column_id < 30099;
delete from im_views where view_id > 30000 and view_id < 30099;
--
insert into im_views (view_id, view_name, visible_for, view_type_id)
values (300, 'program_portfolio_list', 'view_projects', 1400);

insert into im_view_columns (column_id, view_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (30000,300,'Ok',
'"<center>[im_project_on_track_bb $on_track_status_id]</center>"','','',0,'');

-- insert into im_view_columns (column_id, view_id, column_name, column_render_tcl,
-- extra_select, extra_where, sort_order, visible_for) values (30001,300,'Project nr',
-- '"<A HREF=/intranet/projects/view?project_id=$project_id>$project_nr</A>"','','',1,'');
insert into im_view_columns (column_id, view_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (30010,300,'Project Name',
'"<A HREF=/intranet/projects/view?project_id=$project_id>[string range $project_name 0 30]</A>"','','',10,'');
insert into im_view_columns (column_id, view_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (30020,300,'Start','$start_date_formatted','','',20,'');
insert into im_view_columns (column_id, view_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (30025,300,'End','$end_date_formatted','','',25,'');


insert into im_view_columns (column_id, view_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (30030,300,'Budget','$project_budget','','',30,'');
insert into im_view_columns (column_id, view_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (30035,300,'Quoted','$cost_quotes_cache','','',35,'');

insert into im_view_columns (column_id, view_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (30050,300,'Done','"$percent_completed_rounded%"','','',50,'');

insert into im_view_columns (column_id, view_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (30080,300,'Plan Costs','$planned_costs','','',80,'');
insert into im_view_columns (column_id, view_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (30085,300,'Cur Costs','$real_costs','','',85,'');

