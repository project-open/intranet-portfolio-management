-- /packages/intranet-portfolio-management/sql/postgresql/intranet-portfolio-management-drop.sql
--
-- Copyright (c) 2003-2010 ]project-open[
--
-- All rights reserved. Please check
-- https://www.project-open.com/license/ for details.
--
-- @author frank.bergmann@project-open.com


-- Drop plugins and menus for the module
update im_menus set parent_menu_id = null where package_name = 'intranet-portfolio-management';
update im_menus set parent_menu_id = null where parent_menu_id in (
	select menu_id from im_menus where package_name = 'intranet-portfolio-management'
);
select  im_component_plugin__del_module('intranet-portfolio-management');
select  im_menu__del_module('intranet-portfolio-management');

-- Views
delete from im_view_columns where view_id in (300, 301);
delete from im_views where view_id in (300, 301);


-- Delete predefined score_* fields
create or replace function inline_0 ()
returns integer as $body$
declare
	row		RECORD;
	v_count		integer;
	v_sql		varchar;
	v_attribute_id	integer;
BEGIN
	FOR row IN
	    	select	lower(table_name) as table_name,
			lower(column_name) as column_name
		from	user_tab_columns
		where	lower(table_name) = 'im_projects' and lower(column_name) like 'score_%'
	LOOP
		select	count(*) into v_count from user_tab_columns
		where	lower(table_name) = 'im_projects' and lower(column_name) = row.column_name;
		IF (v_count > 0) THEN
			v_sql = 'alter table im_projects drop column ' || row.column_name;
			EXECUTE v_sql;
		END IF;
	END LOOP;
	return 0;
end;$body$ language 'plpgsql';
select inline_0();
drop function inline_0();





-- Delete predefined score_* dynfield_attributes
create or replace function inline_0 ()
returns integer as $body$
declare
	row		RECORD;
BEGIN
	FOR row IN
	    	select	attribute_id
		from	im_dynfield_attributes
		where	acs_attribute_id in (
			select	attribute_id
			from	acs_attributes
			where	object_type = 'im_project' and attribute_name like 'score_%'
		)
	LOOP
		RAISE NOTICE 'intranet-portfolio-management-drop.sql: Deleting %', row.attribute_id;
		PERFORM im_dynfield_attribute__delete(row.attribute_id);
	END LOOP;

	FOR row IN
	    	select	attribute_id
		from	acs_attributes
		where	object_type = 'im_project' and attribute_name like 'score_%'
	LOOP
		RAISE NOTICE 'intranet-portfolio-management-drop.sql: Deleting %', row.attribute_id;
		delete from acs_attributes where attribute_id = row.attribute_id;
	END LOOP;


	return 0;
end;$body$ language 'plpgsql';
select inline_0();
drop function inline_0();






