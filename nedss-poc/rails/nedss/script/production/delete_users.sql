SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

SET search_path = public, pg_catalog;

delete from entitlements; 
delete from role_memberships; 
delete from privileges_roles; 
delete from privileges; 
delete from roles; 
delete from users;
