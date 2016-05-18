-- /packages/intranet-portfolio-management/sql/postgresql/intranet-portfolio-management-drop.sql
--
-- Copyright (c) 2003-2010 ]project-open[
--
-- All rights reserved. Please check
-- http://www.project-open.com/license/ for details.
--
-- @author frank.bergmann@project-open.com


-- Drop plugins and menus for the module
select  im_component_plugin__del_module('intranet-portfolio-management');
select  im_menu__del_module('intranet-portfolio-management');

-- Also delete "Department Planner", this used to be part of this package earlier
select  im_component_plugin__del_module('intranet-department-planner');
select  im_menu__del_module('intranet-department-planner');


-- Department Planner Columns
delete from im_view_columns where view_id = 920;
delete from im_views where view_id = 920;


-- Program Columns
delete from im_view_columns where view_id = 300;
delete from im_views where view_id = 300;

delete from im_categories where category_type = 'Intranet Department Planner Project Priority';
delete from im_categories where category_type = 'Intranet Department Planner Action';

-- Delete the project_priority_id
alter table im_projects drop column project_priority_id;
SELECT im_dynfield_attribute__delete ((
	select	attribute_id
	from	im_dynfield_attributes
	where	acs_attribute_id in (
		select	attribute_id
		from	acs_attributes
		where	object_type = 'im_project' and
			attribute_name = 'project_priority_id'
	)
));
SELECT im_dynfield_widget__delete((select widget_id from im_dynfield_widgets where widget_name = 'project_priority'));


-- Delete the department_planner_days_per_year
alter table im_cost_centers drop column department_planner_days_per_year;
SELECT im_dynfield_attribute__delete ((
	select	attribute_id
	from	im_dynfield_attributes
	where	acs_attribute_id in (
		select	attribute_id
		from	acs_attributes
		where	object_type = 'im_cost_center' and
			attribute_name = 'department_planner_days_per_year'
	)
));

