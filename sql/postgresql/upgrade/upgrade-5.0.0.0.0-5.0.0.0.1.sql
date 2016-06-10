-- upgrade-5.0.0.0.0-5.0.0.0.1.sql

SELECT acs_log__debug('/packages/intranet-portfolio-management/sql/postgresql/upgrade/upgrade-5.0.0.0.0-5.0.0.0.1.sql','');



update im_component_plugins
set plugin_name = 'Projects in Program'
where plugin_name = 'Program Portfolio List';


-- Fix project name in program view
delete from im_view_columns where column_id = 30010;
insert into im_view_columns (column_id, view_id, column_name, column_render_tcl,
extra_select, extra_where, sort_order, visible_for) values (30010,300,'Project Name',
'"<A HREF=/intranet/projects/view?project_id=$project_id>[string range $project_name 0 30]</A>"','','',10,'');


