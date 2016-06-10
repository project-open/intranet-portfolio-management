-- upgrade-5.0.0.0.0-5.0.0.0.1.sql

SELECT acs_log__debug('/packages/intranet-portfolio-management/sql/postgresql/upgrade/upgrade-5.0.0.0.0-5.0.0.0.1.sql','');



update im_component_plugins
set plugin_name = 'Projects in Program'
where plugin_name = 'Program Portfolio List';

