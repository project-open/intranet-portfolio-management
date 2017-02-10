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
	v_portfolio_menu	integer;
	v_employees		integer;
BEGIN
	select group_id into v_employees from groups where group_name = 'Employees';
	select menu_id into v_main_menu from im_menus where label = 'main';
	v_portfolio_menu := im_menu__new (
		null, 'im_menu', now(), null, null, null, -- meta information
		'intranet-portfolio-management',	-- package_name
		'portfolio',				-- label
		'Portfolio',				-- name
		'/intranet-portfolio-management/',	-- url
		45,					-- sort_order
		v_main_menu,				-- parent_menu_id
		null					-- p_visible_tcl
	);
	PERFORM acs_permission__grant_permission(v_portfolio_menu, v_employees, 'read');

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

	v_menu := im_menu__new (
		null, 'im_menu', now(), null, null, null,	-- meta information
		'intranet-portfolio-management',		-- package_name
		'risk_vs_roi',					-- label
		'Risk vs. ROI',					-- name
		'/intranet-portfolio-management/risk-vs-roi',	-- url
		55,						-- sort_order
		v_portfolio_menu,				-- parent_menu_id
		null						-- p_visible_tcl
	);
	PERFORM acs_permission__grant_permission(v_menu, v_employees, 'read');

        v_menu := im_menu__new (
                null,'im_menu',now(),null,null,null,
                'intranet-portfolio-management',	-- package_name
                'project_programs',			-- label
                'Programs', 				-- name
                '/intranet-portfolio-management/index',   -- url
                35,                                     -- sort_order
                (select menu_id from im_menus where label = 'projects'), -- parent_menu_id
                null                                    -- p_visible_tcl
        );
        PERFORM acs_permission__grant_permission(v_menu, v_employees, 'read');

        v_menu := im_menu__new (
                null,'im_menu',now(),null,null,null,
                'intranet-portfolio-management',	-- package_name
                'project_portfolio_list',		-- label
                'Portfolio List', 			-- name
                '/intranet/projects/index?view_name=project_portfolio_list',   -- url
                55,                                     -- sort_order
                (select menu_id from im_menus where label = 'portfolio'), -- parent_menu_id
                null                                    -- p_visible_tcl
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
	null,'im_component_plugin',now(),null,null,null,
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



-- ----------------------------------------------------------------
-- Views
-- ----------------------------------------------------------------

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
'"<A HREF=/intranet/projects/index?&filter_advanced_p=1&program_id=$project_id>[string range $project_name 0 30]</A>"','','',10,'');

insert into im_view_columns (column_id, view_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (30020,300,'Start','$start_date_formatted','','',20,'');

insert into im_view_columns (column_id, view_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (30025,300,'End','$end_date_formatted','','',25,'');

insert into im_view_columns (column_id, view_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (30030,300,'Budget','$project_budget','','',30,'');

insert into im_view_columns (column_id, view_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (30035,300,'Quoted','$cost_quotes_cache','','',35,'');

insert into im_view_columns (column_id, view_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (30050,300,'Done','"$percent_completed%"','','',50,'');

insert into im_view_columns (column_id, view_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (30080,300,'Plan Costs','$planned_costs','','',80,'');

insert into im_view_columns (column_id, view_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (30085,300,'Cur Costs','$real_costs','','',85,'');





-------------------------------------------------------------
-- ROI + Strategic value views in ProjectListPage
-------------------------------------------------------------


-- Strategic Value vs. ROI
--
delete from im_view_columns where view_id = 301;
delete from im_views where view_id = 301;
insert into im_views (view_id, view_name, visible_for)
values (301, 'project_portfolio_list', 'view_projects');


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
sort_order) values (30150, 301, 'Done', '"[expr int(10.0 * $percent_completed) / 10.0]%"', 50);




-------------------------------------------------------------
-- ROI + Strategic value
-------------------------------------------------------------


-- Create a number of predefined score_* fields
create or replace function inline_0 ()
returns integer as $body$
declare
	row		RECORD;
	v_count		integer;
	v_sql		varchar;
	v_pos		integer;
BEGIN
	v_pos	:= 0;
	FOR row IN
	        select * from (
		select  10 as sort_order, 'score_strategic' as field, 'numeric' as widget, 'Score: Strategic' as name UNION
		select  20 as sort_order, 'score_revenue' as field, 'numeric' as widget, 'Score: Revenue' as name UNION
		select  30 as sort_order, 'score_customers' as field, 'numeric' as widget, 'Score: Customer Related Benefits' as name UNION
		select  40 as sort_order, 'score_risk' as field, 'numeric' as widget, 'Score: Risk' as name UNION
		select  50 as sort_order, 'score_capabilities' as field, 'numeric' as widget, 'Score: Capabilities' as name UNION

		select 100 as sort_order, 'score_finance_roi' as field, 'numeric' as widget, 'Financial Score: ROI' as name UNION
		select 110 as sort_order, 'score_finance_npv' as field, 'numeric' as widget, 'Financial Score: NPV' as name UNION
		select 120 as sort_order, 'score_finance_cost' as field, 'numeric' as widget, 'Financial Score: Cost' as name
                ) t order by sort_order
	LOOP
		select	count(*) into v_count from user_tab_columns
		where	lower(table_name) = 'im_projects' and lower(column_name) = row.field;
		IF (v_count = 0) THEN
			v_sql = 'alter table im_projects add ' || row.field || ' numeric';
			EXECUTE v_sql;
		END IF;

		-- DynField - a float value defined as also_hard_coded_p in table im_projects
		select	count(*) into v_count from acs_attributes
		where	pretty_name = row.name and object_type = 'im_project';
		IF (v_count = 0) THEN
			RAISE NOTICE 'creating % % %', row.field, row.name, row.widget;
			PERFORM im_dynfield_attribute_new ('im_project', row.field, row.name, row.widget, 'float', 'f', 1000 + v_pos, 'f', 'im_projects');
		ELSE
			RAISE NOTICE 'already there: % % %', row.field, row.name, row.widget;
		END IF;

		insert into im_view_columns (column_id, view_id, column_name, column_render_tcl, sort_order) 
		values (30200+v_pos, 301, row.name, '$'||row.field, 50+v_pos);

		v_pos := v_pos + 10;
	END LOOP;
	return 0;
end;$body$ language 'plpgsql';
select inline_0();
drop function inline_0();






