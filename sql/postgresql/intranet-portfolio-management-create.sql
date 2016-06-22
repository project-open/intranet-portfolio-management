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




-----------------------------------------------------------
-- Menu for Portfolio Management
--
-- Create a menu item and set some default permissions
-- for various groups who whould be able to see the menu.


create or replace function inline_0 ()
returns integer as $$
declare
	v_menu			integer;
	v_main_menu		integer;
	v_employees		integer;
BEGIN
	select group_id into v_employees from groups where group_name = 'Employees';
	select menu_id into v_main_menu from im_menus where label = 'main';
	v_menu := im_menu__new (
		null, 'im_menu', now(), null, null, null, -- meta information
		'intranet-portfolio-management',	-- package_name
		'portfolio',				-- label
		'Portfolio',				-- name
		'/intranet-portfolio-management/',	-- url
		45,					-- sort_order
		v_main_menu,				-- parent_menu_id
		null					-- p_visible_tcl
	);
	PERFORM acs_permission__grant_permission(v_menu, v_employees, 'read');
	return 0;
end;$$ language 'plpgsql';
select inline_0 ();
drop function inline_0 ();




create or replace function inline_0 ()
returns integer as $$
declare
	v_menu				integer;
	v_portfolio_menu		integer;
	v_employees			integer;
BEGIN
	select group_id into v_employees from groups where group_name = 'Employees';
	select menu_id into v_portfolio_menu from im_menus where label = 'portfolio';
	v_menu := im_menu__new (
		null, 'im_menu', now(), null, null, null,	-- meta information
		'intranet-portfolio-management',		-- package_name
		'strategic_vs_roi',				-- label
		'Strategic Value vs. ROI',			-- name
		'/intranet-portfolio-management/strategic-value-vs-roi', -- url
		45,						-- sort_order
		v_portfolio_menu,				-- parent_menu_id
		null						-- p_visible_tcl
	);
	PERFORM acs_permission__grant_permission(v_menu, v_employees, 'read');
	return 0;
end;$$ language 'plpgsql';
select inline_0 ();
drop function inline_0 ();





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
-- 300			program_portfolio_list - displayed in a portlet of a project
-- 301			portfolio_strategic_vs_roi

--
delete from im_view_columns where view_id = 300;
delete from im_views where view_id = 300;
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








-------------------------------------------------------------
-- ROI + Strategic value
--


alter table im_projects add column project_strategic_value numeric(12,1);
alter table im_projects add column project_roi numeric(12,1);

SELECT im_dynfield_attribute_new ('im_project', 'project_strategic_value', 'Strategic Value', 'numeric', 'float', 'f');
SELECT im_dynfield_attribute_new ('im_project', 'project_roi', 'ROI', 'numeric', 'float', 'f');



-------------------------------------------------------------
-- ROI + Strategic value views
--



-- Strategic Value vs. ROI
--
delete from im_view_columns where view_id = 301;
delete from im_views where view_id = 301;
insert into im_views (view_id, view_name, visible_for)
values (301, 'portfolio_strategic_vs_roi', 'view_projects');


insert into im_view_columns (column_id, view_id, column_name, column_render_tcl, sort_order) 
values (30100, 301, 'Ok', '"<center>[im_project_on_track_bb $on_track_status_id]</center>"', 0);

insert into im_view_columns (column_id, view_id, column_name, column_render_tcl, sort_order) 
values (30110, 301, 'Project Name', '"<A HREF=/intranet/projects/view?project_id=$project_id>[string range $project_name 0 30]</A>"', 10);

-- insert into im_view_columns (column_id, view_id, column_name, column_render_tcl, 
-- sort_order) values (30120, 301, 'Start', '$start_date_formatted', 20);

-- insert into im_view_columns (column_id, view_id, column_name, column_render_tcl, 
-- sort_order) values (30130, 301, 'End', '$end_date_formatted', 30);

insert into im_view_columns (column_id, view_id, column_name, column_render_tcl, 
sort_order) values (30140, 301, 'Budget', '$project_budget', 40);

insert into im_view_columns (column_id, view_id, column_name, column_render_tcl, 
sort_order) values (30150, 301, 'Done', '"$percent_completed_rounded%"', 50);

insert into im_view_columns (column_id, view_id, column_name, column_render_tcl, 
sort_order) values (30160, 301, 'Strategic<br>Value', '$project_strategic_value', 60);

insert into im_view_columns (column_id, view_id, column_name, column_render_tcl, 
sort_order) values (30170, 301, 'ROI', '$project_roi', 70);




-- ------------------------------------------------------------
-- Add Strategic vs. ROI Portlet to ProjectListPage
-- ------------------------------------------------------------

-- SELECT im_component_plugin__new (
-- 	null,					-- plugin_id
-- 	'im_component_plugin',			-- object_type
-- 	now(),					-- creation_date
-- 	null,					-- creation_user
-- 	null,					-- creation_ip
-- 	null,					-- context_id
-- 	'Strategic vs. ROI',			-- plugin_name
-- 	'intranet-portfolio-management',	-- package_name
-- 	'right',				-- location
-- 	'/intranet/projects/index',		-- page_url
-- 	null,					-- view_name
-- 	10,					-- sort_order
-- 	'sencha_scatter_diagram -diagram_width 600 -diagram_height 600 -sql "
-- 		select	p.project_strategic_value as x_axis,
-- 			p.project_roi as y_axis,
-- 			case	when p.on_track_status_id = 66 then ''green''
-- 				when p.on_track_status_id = 67 then ''yellow''
-- 				when p.on_track_status_id = 68 then ''red''
-- 			end as color,
-- 			sqrt(coalesce(p.project_budget, p.presales_value, 200.0)) / 10.0 as diameter,
-- 			p.project_name as title
-- 		from	im_projects p
-- 		where	p.parent_id is null and
-- 			p.project_status_id not in (select * from im_sub_categories([im_project_status_closed])) and
-- 			p.project_roi is not null
-- 		order by p.project_id
-- 	" -diagram_caption "Strategic value vs. ROI"'
-- );

