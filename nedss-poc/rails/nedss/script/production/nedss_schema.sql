--
-- PostgreSQL database dump
--

SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

SET search_path = public, pg_catalog;

ALTER TABLE ONLY public.participations DROP CONSTRAINT r_5;
ALTER TABLE ONLY public.participations DROP CONSTRAINT r_4;
ALTER TABLE ONLY public.participations DROP CONSTRAINT r_3;
ALTER TABLE ONLY public.telephones DROP CONSTRAINT r_2;
ALTER TABLE ONLY public.addresses DROP CONSTRAINT r_1;
ALTER TABLE ONLY public.places DROP CONSTRAINT is_place_entity;
ALTER TABLE ONLY public.people DROP CONSTRAINT is_person_entity;
ALTER TABLE ONLY public.materials DROP CONSTRAINT is_material_entity;
ALTER TABLE ONLY public.animals DROP CONSTRAINT is_animal_entity;
ALTER TABLE ONLY public.role_memberships DROP CONSTRAINT fk_userid;
ALTER TABLE ONLY public.entitlements DROP CONSTRAINT fk_userid;
ALTER TABLE ONLY public.treatments DROP CONSTRAINT fk_treatment_type;
ALTER TABLE ONLY public.participations_treatments DROP CONSTRAINT fk_treatment_id;
ALTER TABLE ONLY public.participations_treatments DROP CONSTRAINT fk_treatment_given_yn;
ALTER TABLE ONLY public.lab_results DROP CONSTRAINT fk_testedatuphlynid;
ALTER TABLE ONLY public.addresses DROP CONSTRAINT fk_state;
ALTER TABLE ONLY public.lab_results DROP CONSTRAINT fk_specimensourceid;
ALTER TABLE ONLY public.entity_groups DROP CONSTRAINT fk_secondaryentityid;
ALTER TABLE ONLY public.clusters DROP CONSTRAINT fk_secondary_event_cluster;
ALTER TABLE ONLY public.privileges_roles DROP CONSTRAINT fk_roleid;
ALTER TABLE ONLY public.role_memberships DROP CONSTRAINT fk_roleid;
ALTER TABLE ONLY public.participations DROP CONSTRAINT fk_role;
ALTER TABLE ONLY public.privileges_roles DROP CONSTRAINT fk_privilegeid;
ALTER TABLE ONLY public.entitlements DROP CONSTRAINT fk_privilegeid;
ALTER TABLE ONLY public.entity_groups DROP CONSTRAINT fk_primaryentityid;
ALTER TABLE ONLY public.entities_locations DROP CONSTRAINT fk_primary_yn;
ALTER TABLE ONLY public.people DROP CONSTRAINT fk_primary_language;
ALTER TABLE ONLY public.clusters DROP CONSTRAINT fk_primary_event_cluster;
ALTER TABLE ONLY public.participations_risk_factors DROP CONSTRAINT fk_pregnant;
ALTER TABLE ONLY public.participations DROP CONSTRAINT fk_participation_status;
ALTER TABLE ONLY public.participations_treatments DROP CONSTRAINT fk_participation_id;
ALTER TABLE ONLY public.participations_risk_factors DROP CONSTRAINT fk_participation;
ALTER TABLE ONLY public.hospitals_participations DROP CONSTRAINT fk_participation;
ALTER TABLE ONLY public.entities_locations DROP CONSTRAINT fk_location_type;
ALTER TABLE ONLY public.entities_locations DROP CONSTRAINT fk_location;
ALTER TABLE ONLY public.clinicals DROP CONSTRAINT fk_lab_yn;
ALTER TABLE ONLY public.privileges_roles DROP CONSTRAINT fk_jurisdictionid;
ALTER TABLE ONLY public.role_memberships DROP CONSTRAINT fk_jurisdictionid;
ALTER TABLE ONLY public.entitlements DROP CONSTRAINT fk_jurisdictionid;
ALTER TABLE ONLY public.events DROP CONSTRAINT fk_imported_from;
ALTER TABLE ONLY public.disease_events DROP CONSTRAINT fk_hospitalized;
ALTER TABLE ONLY public.participations_risk_factors DROP CONSTRAINT fk_healthcareworker;
ALTER TABLE ONLY public.participations_risk_factors DROP CONSTRAINT fk_groupliving;
ALTER TABLE ONLY public.participations_risk_factors DROP CONSTRAINT fk_foodhandler;
ALTER TABLE ONLY public.lab_results DROP CONSTRAINT fk_eventid;
ALTER TABLE ONLY public.events DROP CONSTRAINT fk_event_status;
ALTER TABLE ONLY public.referrals DROP CONSTRAINT fk_event_referral;
ALTER TABLE ONLY public.observations DROP CONSTRAINT fk_event_observation;
ALTER TABLE ONLY public.encounters DROP CONSTRAINT fk_event_encounter;
ALTER TABLE ONLY public.clinicals DROP CONSTRAINT fk_event_clinical;
ALTER TABLE ONLY public.events DROP CONSTRAINT fk_event_case_status;
ALTER TABLE ONLY public.cases_events DROP CONSTRAINT fk_event_case;
ALTER TABLE ONLY public.disease_events DROP CONSTRAINT fk_event;
ALTER TABLE ONLY public.people DROP CONSTRAINT fk_ethnicity;
ALTER TABLE ONLY public.laboratories DROP CONSTRAINT fk_entityid;
ALTER TABLE ONLY public.entity_groups DROP CONSTRAINT fk_entitygrouptypecode;
ALTER TABLE ONLY public.entities_locations DROP CONSTRAINT fk_entity;
ALTER TABLE ONLY public.disease_events DROP CONSTRAINT fk_disease;
ALTER TABLE ONLY public.disease_events DROP CONSTRAINT fk_died;
ALTER TABLE ONLY public.participations_risk_factors DROP CONSTRAINT fk_daycareassoc;
ALTER TABLE ONLY public.addresses DROP CONSTRAINT fk_county;
ALTER TABLE ONLY public.people DROP CONSTRAINT fk_code_birthgender;
ALTER TABLE ONLY public.clusters DROP CONSTRAINT fk_cluster_status;
DROP TRIGGER tsvectorupdate ON public.people;
DROP INDEX public.people_fts_vector_index;
DROP INDEX public.index_treatments_on_treatment_type_id;
DROP INDEX public.index_telephones_on_location_id;
DROP INDEX public.index_referrals_on_event_id;
DROP INDEX public.index_places_on_place_type_id;
DROP INDEX public.index_places_on_entity_id;
DROP INDEX public.index_people_races_on_race_id;
DROP INDEX public.index_people_races_on_entity_id;
DROP INDEX public.index_people_on_primary_language_id;
DROP INDEX public.index_people_on_last_name_soundex;
DROP INDEX public.index_people_on_first_name_soundex;
DROP INDEX public.index_people_on_ethnicity_id;
DROP INDEX public.index_people_on_entity_id;
DROP INDEX public.index_people_on_birth_gender_id;
DROP INDEX public.index_people_on_age_type_id;
DROP INDEX public.index_participations_treatments_on_treatment_id;
DROP INDEX public.index_participations_treatments_on_treatment_given_yn_id;
DROP INDEX public.index_participations_treatments_on_participation_id;
DROP INDEX public.index_participations_risk_factors_on_pregnant_id;
DROP INDEX public.index_participations_risk_factors_on_participation_id;
DROP INDEX public.index_participations_risk_factors_on_healthcare_worker_id;
DROP INDEX public.index_participations_risk_factors_on_group_living_id;
DROP INDEX public.index_participations_risk_factors_on_food_handler_id;
DROP INDEX public.index_participations_risk_factors_on_day_care_association_id;
DROP INDEX public.index_participations_on_secondary_entity_id;
DROP INDEX public.index_participations_on_role_id;
DROP INDEX public.index_participations_on_primary_entity_id;
DROP INDEX public.index_participations_on_participation_status_id;
DROP INDEX public.index_participations_on_event_id;
DROP INDEX public.index_observations_on_event_id;
DROP INDEX public.index_materials_on_entity_id;
DROP INDEX public.index_lab_results_on_tested_at_uphl_yn_id;
DROP INDEX public.index_lab_results_on_specimen_source_id;
DROP INDEX public.index_hospitals_participations_on_participation_id;
DROP INDEX public.index_events_on_outbreak_associated_id;
DROP INDEX public."index_events_on_investigation_LHD_status_id";
DROP INDEX public.index_events_on_imported_from_id;
DROP INDEX public.index_events_on_event_status_id;
DROP INDEX public.index_events_on_event_case_status_id;
DROP INDEX public.index_entity_groups_on_secondary_entity_id;
DROP INDEX public.index_entity_groups_on_primary_entity_id;
DROP INDEX public.index_entity_groups_on_entity_group_type_id;
DROP INDEX public.index_encounters_on_event_id;
DROP INDEX public.index_disease_events_on_hospitalized_id;
DROP INDEX public.index_disease_events_on_event_id;
DROP INDEX public.index_disease_events_on_disease_id;
DROP INDEX public.index_disease_events_on_died_id;
DROP INDEX public.index_clusters_on_secondary_event_id;
DROP INDEX public.index_clusters_on_primary_event_id;
DROP INDEX public.index_clusters_on_cluster_status_id;
DROP INDEX public.index_cases_events_on_event_id;
DROP INDEX public.index_animals_on_entity_id;
DROP INDEX public.index_addresses_on_state_id;
DROP INDEX public.index_addresses_on_location_id;
DROP INDEX public.index_addresses_on_county_id;
ALTER TABLE ONLY public.users DROP CONSTRAINT users_pkey;
ALTER TABLE ONLY public.treatments DROP CONSTRAINT treatments_pkey;
ALTER TABLE ONLY public.telephones DROP CONSTRAINT telephones_pkey;
ALTER TABLE ONLY public.roles DROP CONSTRAINT roles_pkey;
ALTER TABLE ONLY public.role_memberships DROP CONSTRAINT role_memberships_pkey;
ALTER TABLE ONLY public.referrals DROP CONSTRAINT referrals_pkey;
ALTER TABLE ONLY public.privileges_roles DROP CONSTRAINT privileges_roles_pkey;
ALTER TABLE ONLY public."privileges" DROP CONSTRAINT privileges_pkey;
ALTER TABLE ONLY public.places DROP CONSTRAINT places_pkey;
ALTER TABLE ONLY public.pg_ts_parser DROP CONSTRAINT pg_ts_parser_pkey;
ALTER TABLE ONLY public.pg_ts_dict DROP CONSTRAINT pg_ts_dict_pkey;
ALTER TABLE ONLY public.pg_ts_cfgmap DROP CONSTRAINT pg_ts_cfgmap_pkey;
ALTER TABLE ONLY public.pg_ts_cfg DROP CONSTRAINT pg_ts_cfg_pkey;
ALTER TABLE ONLY public.people DROP CONSTRAINT people_pkey;
ALTER TABLE ONLY public.participations_treatments DROP CONSTRAINT participations_treatments_pkey;
ALTER TABLE ONLY public.participations_risk_factors DROP CONSTRAINT participations_risk_factors_pkey;
ALTER TABLE ONLY public.participations DROP CONSTRAINT participations_pkey;
ALTER TABLE ONLY public.hospitals_participations DROP CONSTRAINT participation_hospitals_pkey;
ALTER TABLE ONLY public.organizations DROP CONSTRAINT organizations_pkey;
ALTER TABLE ONLY public.observations DROP CONSTRAINT observations_pkey;
ALTER TABLE ONLY public.materials DROP CONSTRAINT materials_pkey;
ALTER TABLE ONLY public.locations DROP CONSTRAINT locations_pkey;
ALTER TABLE ONLY public.laboratories DROP CONSTRAINT laboratories_pkey;
ALTER TABLE ONLY public.lab_results DROP CONSTRAINT lab_results_pkey;
ALTER TABLE ONLY public.events DROP CONSTRAINT events_pkey;
ALTER TABLE ONLY public.cases_events DROP CONSTRAINT event_cases_pkey;
ALTER TABLE ONLY public.entity_groups DROP CONSTRAINT entity_groups_pkey;
ALTER TABLE ONLY public.entitlements DROP CONSTRAINT entitlements_pkey;
ALTER TABLE ONLY public.entities DROP CONSTRAINT entities_pkey;
ALTER TABLE ONLY public.entities_locations DROP CONSTRAINT entities_locations_pkey;
ALTER TABLE ONLY public.encounters DROP CONSTRAINT encounters_pkey;
ALTER TABLE ONLY public.diseases DROP CONSTRAINT diseases_pkey;
ALTER TABLE ONLY public.disease_events DROP CONSTRAINT disease_events_pkey;
ALTER TABLE ONLY public.codes DROP CONSTRAINT codes_pkey;
ALTER TABLE ONLY public.clusters DROP CONSTRAINT clusters_pkey;
ALTER TABLE ONLY public.clinicals DROP CONSTRAINT clinicals_pkey;
ALTER TABLE ONLY public.animals DROP CONSTRAINT animals_pkey;
ALTER TABLE ONLY public.addresses DROP CONSTRAINT addresses_pkey;
ALTER TABLE public.users ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.treatments ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.telephones ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.roles ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.role_memberships ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.referrals ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.privileges_roles ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public."privileges" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.places ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.people ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.participations_treatments ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.participations_risk_factors ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.participations ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.organizations ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.observations ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.materials ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.locations ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.laboratories ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.lab_results ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.hospitals_participations ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.events ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.entity_groups ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.entitlements ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.entities_locations ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.entities ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.encounters ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.diseases ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.disease_events ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.codes ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.clusters ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.clinicals ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.cases_events ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.animals ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.addresses ALTER COLUMN id DROP DEFAULT;
DROP SEQUENCE public.users_id_seq;
DROP TABLE public.users;
DROP SEQUENCE public.treatments_id_seq;
DROP TABLE public.treatments;
DROP SEQUENCE public.telephones_id_seq;
DROP TABLE public.telephones;
DROP TABLE public.schema_info;
DROP SEQUENCE public.roles_id_seq;
DROP TABLE public.roles;
DROP SEQUENCE public.role_memberships_id_seq;
DROP TABLE public.role_memberships;
DROP SEQUENCE public.referrals_id_seq;
DROP TABLE public.referrals;
DROP SEQUENCE public.privileges_roles_id_seq;
DROP TABLE public.privileges_roles;
DROP SEQUENCE public.privileges_id_seq;
DROP TABLE public."privileges";
DROP SEQUENCE public.places_id_seq;
DROP TABLE public.places;
DROP TABLE public.pg_ts_parser;
DROP TABLE public.pg_ts_dict;
DROP TABLE public.pg_ts_cfgmap;
DROP TABLE public.pg_ts_cfg;
DROP TABLE public.people_races;
DROP SEQUENCE public.people_id_seq;
DROP TABLE public.people;
DROP SEQUENCE public.participations_treatments_id_seq;
DROP TABLE public.participations_treatments;
DROP SEQUENCE public.participations_risk_factors_id_seq;
DROP TABLE public.participations_risk_factors;
DROP SEQUENCE public.participations_id_seq;
DROP TABLE public.participations;
DROP SEQUENCE public.participation_hospitals_id_seq;
DROP SEQUENCE public.organizations_id_seq;
DROP TABLE public.organizations;
DROP SEQUENCE public.observations_id_seq;
DROP TABLE public.observations;
DROP SEQUENCE public.materials_id_seq;
DROP TABLE public.materials;
DROP SEQUENCE public.locations_id_seq;
DROP TABLE public.locations;
DROP SEQUENCE public.laboratories_id_seq;
DROP TABLE public.laboratories;
DROP SEQUENCE public.lab_results_id_seq;
DROP TABLE public.lab_results;
DROP TABLE public.hospitals_participations;
DROP SEQUENCE public.events_record_number_seq;
DROP SEQUENCE public.events_id_seq;
DROP TABLE public.events;
DROP SEQUENCE public.event_cases_id_seq;
DROP SEQUENCE public.entity_groups_id_seq;
DROP TABLE public.entity_groups;
DROP SEQUENCE public.entitlements_id_seq;
DROP TABLE public.entitlements;
DROP SEQUENCE public.entities_locations_id_seq;
DROP TABLE public.entities_locations;
DROP SEQUENCE public.entities_id_seq;
DROP TABLE public.entities;
DROP SEQUENCE public.encounters_id_seq;
DROP TABLE public.encounters;
DROP SEQUENCE public.diseases_id_seq;
DROP TABLE public.diseases;
DROP SEQUENCE public.disease_events_id_seq;
DROP TABLE public.disease_events;
DROP SEQUENCE public.codes_id_seq;
DROP TABLE public.codes;
DROP SEQUENCE public.clusters_id_seq;
DROP TABLE public.clusters;
DROP SEQUENCE public.clinicals_id_seq;
DROP TABLE public.clinicals;
DROP TABLE public.cases_events;
DROP SEQUENCE public.animals_id_seq;
DROP TABLE public.animals;
DROP SEQUENCE public.addresses_id_seq;
DROP TABLE public.addresses;
DROP OPERATOR CLASS public.tsvector_ops USING btree;
DROP OPERATOR CLASS public.tsquery_ops USING btree;
DROP OPERATOR CLASS public.gist_tsvector_ops USING gist;
DROP OPERATOR CLASS public.gist_tp_tsquery_ops USING gist;
DROP OPERATOR CLASS public.gin_tsvector_ops USING gin;
DROP OPERATOR public.~ (tsquery, tsquery);
DROP OPERATOR public.|| (tsquery, tsquery);
DROP OPERATOR public.|| (tsvector, tsvector);
DROP OPERATOR public.@@@ (tsvector, tsquery);
DROP OPERATOR public.@@@ (tsquery, tsvector);
DROP OPERATOR public.@@ (tsvector, tsquery);
DROP OPERATOR public.@@ (tsquery, tsvector);
DROP OPERATOR public.@> (tsquery, tsquery);
DROP OPERATOR public.@ (tsquery, tsquery);
DROP OPERATOR public.>= (tsquery, tsquery);
DROP OPERATOR public.>= (tsvector, tsvector);
DROP OPERATOR public.> (tsquery, tsquery);
DROP OPERATOR public.> (tsvector, tsvector);
DROP OPERATOR public.= (tsquery, tsquery);
DROP OPERATOR public.= (tsvector, tsvector);
DROP OPERATOR public.<@ (tsquery, tsquery);
DROP OPERATOR public.<> (tsquery, tsquery);
DROP OPERATOR public.<> (tsvector, tsvector);
DROP OPERATOR public.<= (tsquery, tsquery);
DROP OPERATOR public.<= (tsvector, tsvector);
DROP OPERATOR public.< (tsquery, tsquery);
DROP OPERATOR public.< (tsvector, tsvector);
DROP OPERATOR public.&& (tsquery, tsquery);
DROP OPERATOR public.!! (NONE, tsquery);
DROP AGGREGATE public.rewrite(tsquery[]);
DROP FUNCTION public.tsvector_ne(tsvector, tsvector);
DROP FUNCTION public.tsvector_lt(tsvector, tsvector);
DROP FUNCTION public.tsvector_le(tsvector, tsvector);
DROP FUNCTION public.tsvector_gt(tsvector, tsvector);
DROP FUNCTION public.tsvector_ge(tsvector, tsvector);
DROP FUNCTION public.tsvector_eq(tsvector, tsvector);
DROP FUNCTION public.tsvector_cmp(tsvector, tsvector);
DROP FUNCTION public.tsquery_or(tsquery, tsquery);
DROP FUNCTION public.tsquery_not(tsquery);
DROP FUNCTION public.tsquery_ne(tsquery, tsquery);
DROP FUNCTION public.tsquery_lt(tsquery, tsquery);
DROP FUNCTION public.tsquery_le(tsquery, tsquery);
DROP FUNCTION public.tsquery_gt(tsquery, tsquery);
DROP FUNCTION public.tsquery_ge(tsquery, tsquery);
DROP FUNCTION public.tsquery_eq(tsquery, tsquery);
DROP FUNCTION public.tsquery_cmp(tsquery, tsquery);
DROP FUNCTION public.tsquery_and(tsquery, tsquery);
DROP FUNCTION public.tsq_mcontains(tsquery, tsquery);
DROP FUNCTION public.tsq_mcontained(tsquery, tsquery);
DROP FUNCTION public.tsearch2();
DROP FUNCTION public.ts_debug(text);
DROP FUNCTION public.token_type();
DROP FUNCTION public.token_type(text);
DROP FUNCTION public.token_type(integer);
DROP FUNCTION public.to_tsvector(text);
DROP FUNCTION public.to_tsvector(text, text);
DROP FUNCTION public.to_tsvector(oid, text);
DROP FUNCTION public.to_tsquery(text);
DROP FUNCTION public.to_tsquery(text, text);
DROP FUNCTION public.to_tsquery(oid, text);
DROP FUNCTION public.thesaurus_lexize(internal, internal, integer, internal);
DROP FUNCTION public.thesaurus_init(internal);
DROP FUNCTION public.syn_lexize(internal, internal, integer);
DROP FUNCTION public.syn_init(internal);
DROP FUNCTION public.strip(tsvector);
DROP FUNCTION public.stat(text, text);
DROP FUNCTION public.stat(text);
DROP FUNCTION public.spell_lexize(internal, internal, integer);
DROP FUNCTION public.spell_init(internal);
DROP FUNCTION public.snb_ru_init_utf8(internal);
DROP FUNCTION public.snb_ru_init_koi8(internal);
DROP FUNCTION public.snb_lexize(internal, internal, integer);
DROP FUNCTION public.snb_en_init(internal);
DROP FUNCTION public.show_curcfg();
DROP FUNCTION public.setweight(tsvector, "char");
DROP FUNCTION public.set_curprs(text);
DROP FUNCTION public.set_curprs(integer);
DROP FUNCTION public.set_curdict(text);
DROP FUNCTION public.set_curdict(integer);
DROP FUNCTION public.set_curcfg(text);
DROP FUNCTION public.set_curcfg(integer);
DROP FUNCTION public.rexectsq(tsquery, tsvector);
DROP FUNCTION public.rewrite_finish(tsquery);
DROP FUNCTION public.rewrite_accum(tsquery, tsquery[]);
DROP FUNCTION public.rewrite(tsquery, tsquery, tsquery);
DROP FUNCTION public.rewrite(tsquery, text);
DROP FUNCTION public.reset_tsearch();
DROP FUNCTION public.rank_cd(tsvector, tsquery, integer);
DROP FUNCTION public.rank_cd(tsvector, tsquery);
DROP FUNCTION public.rank_cd(real[], tsvector, tsquery, integer);
DROP FUNCTION public.rank_cd(real[], tsvector, tsquery);
DROP FUNCTION public.rank(tsvector, tsquery, integer);
DROP FUNCTION public.rank(tsvector, tsquery);
DROP FUNCTION public.rank(real[], tsvector, tsquery, integer);
DROP FUNCTION public.rank(real[], tsvector, tsquery);
DROP FUNCTION public.querytree(tsquery);
DROP FUNCTION public.prsd_start(internal, integer);
DROP FUNCTION public.prsd_lextype(internal);
DROP FUNCTION public.prsd_headline(internal, internal, internal);
DROP FUNCTION public.prsd_getlexeme(internal, internal, internal);
DROP FUNCTION public.prsd_end(internal);
DROP FUNCTION public.plainto_tsquery(text);
DROP FUNCTION public.plainto_tsquery(text, text);
DROP FUNCTION public.plainto_tsquery(oid, text);
DROP FUNCTION public.parse(text);
DROP FUNCTION public.parse(text, text);
DROP FUNCTION public.parse(oid, text);
DROP FUNCTION public.numnode(tsquery);
DROP FUNCTION public.lexize(text);
DROP FUNCTION public.lexize(text, text);
DROP FUNCTION public.lexize(oid, text);
DROP FUNCTION public.length(tsvector);
DROP FUNCTION public.headline(text, tsquery);
DROP FUNCTION public.headline(text, tsquery, text);
DROP FUNCTION public.headline(text, text, tsquery);
DROP FUNCTION public.headline(text, text, tsquery, text);
DROP FUNCTION public.headline(oid, text, tsquery);
DROP FUNCTION public.headline(oid, text, tsquery, text);
DROP FUNCTION public.gtsvector_union(internal, internal);
DROP FUNCTION public.gtsvector_same(gtsvector, gtsvector, internal);
DROP FUNCTION public.gtsvector_picksplit(internal, internal);
DROP FUNCTION public.gtsvector_penalty(internal, internal, internal);
DROP FUNCTION public.gtsvector_decompress(internal);
DROP FUNCTION public.gtsvector_consistent(gtsvector, internal, integer);
DROP FUNCTION public.gtsvector_compress(internal);
DROP FUNCTION public.gtsq_union(bytea, internal);
DROP FUNCTION public.gtsq_same(gtsq, gtsq, internal);
DROP FUNCTION public.gtsq_picksplit(internal, internal);
DROP FUNCTION public.gtsq_penalty(internal, internal, internal);
DROP FUNCTION public.gtsq_decompress(internal);
DROP FUNCTION public.gtsq_consistent(gtsq, internal, integer);
DROP FUNCTION public.gtsq_compress(internal);
DROP FUNCTION public.gin_ts_consistent(internal, internal, tsquery);
DROP FUNCTION public.gin_extract_tsvector(tsvector, internal);
DROP FUNCTION public.gin_extract_tsquery(tsquery, internal, internal);
DROP FUNCTION public.get_covers(tsvector, tsquery);
DROP FUNCTION public.exectsq(tsvector, tsquery);
DROP FUNCTION public.dex_lexize(internal, internal, integer);
DROP FUNCTION public.dex_init(internal);
DROP FUNCTION public.concat(tsvector, tsvector);
DROP FUNCTION public._get_parser_from_curcfg();
DROP TYPE public.tsdebug;
DROP TYPE public.tokentype;
DROP TYPE public.tokenout;
DROP TYPE public.statinfo;
DROP TYPE public.tsvector CASCADE;
DROP FUNCTION public.tsvector_out(tsvector);
DROP FUNCTION public.tsvector_in(cstring);
DROP TYPE public.tsquery CASCADE;
DROP FUNCTION public.tsquery_out(tsquery);
DROP FUNCTION public.tsquery_in(cstring);
DROP TYPE public.gtsvector CASCADE;
DROP FUNCTION public.gtsvector_out(gtsvector);
DROP FUNCTION public.gtsvector_in(cstring);
DROP TYPE public.gtsq CASCADE;
DROP FUNCTION public.gtsq_out(gtsq);
DROP FUNCTION public.gtsq_in(cstring);
DROP SCHEMA public;
--
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA public;


--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA public IS 'Standard public schema';


--
-- Name: gtsq; Type: SHELL TYPE; Schema: public; Owner: -
--

CREATE TYPE gtsq;


--
-- Name: gtsq_in(cstring); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION gtsq_in(cstring) RETURNS gtsq
    AS '$libdir/tsearch2', 'gtsq_in'
    LANGUAGE c STRICT;


--
-- Name: gtsq_out(gtsq); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION gtsq_out(gtsq) RETURNS cstring
    AS '$libdir/tsearch2', 'gtsq_out'
    LANGUAGE c STRICT;


--
-- Name: gtsq; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE gtsq (
    INTERNALLENGTH = 8,
    INPUT = gtsq_in,
    OUTPUT = gtsq_out,
    ALIGNMENT = int4,
    STORAGE = plain
);


--
-- Name: gtsvector; Type: SHELL TYPE; Schema: public; Owner: -
--

CREATE TYPE gtsvector;


--
-- Name: gtsvector_in(cstring); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION gtsvector_in(cstring) RETURNS gtsvector
    AS '$libdir/tsearch2', 'gtsvector_in'
    LANGUAGE c STRICT;


--
-- Name: gtsvector_out(gtsvector); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION gtsvector_out(gtsvector) RETURNS cstring
    AS '$libdir/tsearch2', 'gtsvector_out'
    LANGUAGE c STRICT;


--
-- Name: gtsvector; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE gtsvector (
    INTERNALLENGTH = variable,
    INPUT = gtsvector_in,
    OUTPUT = gtsvector_out,
    ALIGNMENT = int4,
    STORAGE = plain
);


--
-- Name: tsquery; Type: SHELL TYPE; Schema: public; Owner: -
--

CREATE TYPE tsquery;


--
-- Name: tsquery_in(cstring); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION tsquery_in(cstring) RETURNS tsquery
    AS '$libdir/tsearch2', 'tsquery_in'
    LANGUAGE c STRICT;


--
-- Name: tsquery_out(tsquery); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION tsquery_out(tsquery) RETURNS cstring
    AS '$libdir/tsearch2', 'tsquery_out'
    LANGUAGE c STRICT;


--
-- Name: tsquery; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE tsquery (
    INTERNALLENGTH = variable,
    INPUT = tsquery_in,
    OUTPUT = tsquery_out,
    ALIGNMENT = int4,
    STORAGE = plain
);


--
-- Name: tsvector; Type: SHELL TYPE; Schema: public; Owner: -
--

CREATE TYPE tsvector;


--
-- Name: tsvector_in(cstring); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION tsvector_in(cstring) RETURNS tsvector
    AS '$libdir/tsearch2', 'tsvector_in'
    LANGUAGE c STRICT;


--
-- Name: tsvector_out(tsvector); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION tsvector_out(tsvector) RETURNS cstring
    AS '$libdir/tsearch2', 'tsvector_out'
    LANGUAGE c STRICT;


--
-- Name: tsvector; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE tsvector (
    INTERNALLENGTH = variable,
    INPUT = tsvector_in,
    OUTPUT = tsvector_out,
    ALIGNMENT = int4,
    STORAGE = extended
);


--
-- Name: statinfo; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE statinfo AS (
	word text,
	ndoc integer,
	nentry integer
);


--
-- Name: tokenout; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE tokenout AS (
	tokid integer,
	token text
);


--
-- Name: tokentype; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE tokentype AS (
	tokid integer,
	alias text,
	descr text
);


--
-- Name: tsdebug; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE tsdebug AS (
	ts_name text,
	tok_type text,
	description text,
	token text,
	dict_name text[],
	tsvector tsvector
);


--
-- Name: _get_parser_from_curcfg(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION _get_parser_from_curcfg() RETURNS text
    AS $$ select prs_name from pg_ts_cfg where oid = show_curcfg() $$
    LANGUAGE sql IMMUTABLE STRICT;


--
-- Name: concat(tsvector, tsvector); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION concat(tsvector, tsvector) RETURNS tsvector
    AS '$libdir/tsearch2', 'concat'
    LANGUAGE c IMMUTABLE STRICT;


--
-- Name: dex_init(internal); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION dex_init(internal) RETURNS internal
    AS '$libdir/tsearch2', 'dex_init'
    LANGUAGE c;


--
-- Name: dex_lexize(internal, internal, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION dex_lexize(internal, internal, integer) RETURNS internal
    AS '$libdir/tsearch2', 'dex_lexize'
    LANGUAGE c STRICT;


--
-- Name: exectsq(tsvector, tsquery); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION exectsq(tsvector, tsquery) RETURNS boolean
    AS '$libdir/tsearch2', 'exectsq'
    LANGUAGE c IMMUTABLE STRICT;


--
-- Name: FUNCTION exectsq(tsvector, tsquery); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION exectsq(tsvector, tsquery) IS 'boolean operation with text index';


--
-- Name: get_covers(tsvector, tsquery); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION get_covers(tsvector, tsquery) RETURNS text
    AS '$libdir/tsearch2', 'get_covers'
    LANGUAGE c STRICT;


--
-- Name: gin_extract_tsquery(tsquery, internal, internal); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION gin_extract_tsquery(tsquery, internal, internal) RETURNS internal
    AS '$libdir/tsearch2', 'gin_extract_tsquery'
    LANGUAGE c STRICT;


--
-- Name: gin_extract_tsvector(tsvector, internal); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION gin_extract_tsvector(tsvector, internal) RETURNS internal
    AS '$libdir/tsearch2', 'gin_extract_tsvector'
    LANGUAGE c STRICT;


--
-- Name: gin_ts_consistent(internal, internal, tsquery); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION gin_ts_consistent(internal, internal, tsquery) RETURNS boolean
    AS '$libdir/tsearch2', 'gin_ts_consistent'
    LANGUAGE c STRICT;


--
-- Name: gtsq_compress(internal); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION gtsq_compress(internal) RETURNS internal
    AS '$libdir/tsearch2', 'gtsq_compress'
    LANGUAGE c;


--
-- Name: gtsq_consistent(gtsq, internal, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION gtsq_consistent(gtsq, internal, integer) RETURNS boolean
    AS '$libdir/tsearch2', 'gtsq_consistent'
    LANGUAGE c;


--
-- Name: gtsq_decompress(internal); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION gtsq_decompress(internal) RETURNS internal
    AS '$libdir/tsearch2', 'gtsq_decompress'
    LANGUAGE c;


--
-- Name: gtsq_penalty(internal, internal, internal); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION gtsq_penalty(internal, internal, internal) RETURNS internal
    AS '$libdir/tsearch2', 'gtsq_penalty'
    LANGUAGE c STRICT;


--
-- Name: gtsq_picksplit(internal, internal); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION gtsq_picksplit(internal, internal) RETURNS internal
    AS '$libdir/tsearch2', 'gtsq_picksplit'
    LANGUAGE c;


--
-- Name: gtsq_same(gtsq, gtsq, internal); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION gtsq_same(gtsq, gtsq, internal) RETURNS internal
    AS '$libdir/tsearch2', 'gtsq_same'
    LANGUAGE c;


--
-- Name: gtsq_union(bytea, internal); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION gtsq_union(bytea, internal) RETURNS integer[]
    AS '$libdir/tsearch2', 'gtsq_union'
    LANGUAGE c;


--
-- Name: gtsvector_compress(internal); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION gtsvector_compress(internal) RETURNS internal
    AS '$libdir/tsearch2', 'gtsvector_compress'
    LANGUAGE c;


--
-- Name: gtsvector_consistent(gtsvector, internal, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION gtsvector_consistent(gtsvector, internal, integer) RETURNS boolean
    AS '$libdir/tsearch2', 'gtsvector_consistent'
    LANGUAGE c;


--
-- Name: gtsvector_decompress(internal); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION gtsvector_decompress(internal) RETURNS internal
    AS '$libdir/tsearch2', 'gtsvector_decompress'
    LANGUAGE c;


--
-- Name: gtsvector_penalty(internal, internal, internal); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION gtsvector_penalty(internal, internal, internal) RETURNS internal
    AS '$libdir/tsearch2', 'gtsvector_penalty'
    LANGUAGE c STRICT;


--
-- Name: gtsvector_picksplit(internal, internal); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION gtsvector_picksplit(internal, internal) RETURNS internal
    AS '$libdir/tsearch2', 'gtsvector_picksplit'
    LANGUAGE c;


--
-- Name: gtsvector_same(gtsvector, gtsvector, internal); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION gtsvector_same(gtsvector, gtsvector, internal) RETURNS internal
    AS '$libdir/tsearch2', 'gtsvector_same'
    LANGUAGE c;


--
-- Name: gtsvector_union(internal, internal); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION gtsvector_union(internal, internal) RETURNS integer[]
    AS '$libdir/tsearch2', 'gtsvector_union'
    LANGUAGE c;


--
-- Name: headline(oid, text, tsquery, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION headline(oid, text, tsquery, text) RETURNS text
    AS '$libdir/tsearch2', 'headline'
    LANGUAGE c IMMUTABLE STRICT;


--
-- Name: headline(oid, text, tsquery); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION headline(oid, text, tsquery) RETURNS text
    AS '$libdir/tsearch2', 'headline'
    LANGUAGE c IMMUTABLE STRICT;


--
-- Name: headline(text, text, tsquery, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION headline(text, text, tsquery, text) RETURNS text
    AS '$libdir/tsearch2', 'headline_byname'
    LANGUAGE c IMMUTABLE STRICT;


--
-- Name: headline(text, text, tsquery); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION headline(text, text, tsquery) RETURNS text
    AS '$libdir/tsearch2', 'headline_byname'
    LANGUAGE c IMMUTABLE STRICT;


--
-- Name: headline(text, tsquery, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION headline(text, tsquery, text) RETURNS text
    AS '$libdir/tsearch2', 'headline_current'
    LANGUAGE c IMMUTABLE STRICT;


--
-- Name: headline(text, tsquery); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION headline(text, tsquery) RETURNS text
    AS '$libdir/tsearch2', 'headline_current'
    LANGUAGE c IMMUTABLE STRICT;


--
-- Name: length(tsvector); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION length(tsvector) RETURNS integer
    AS '$libdir/tsearch2', 'tsvector_length'
    LANGUAGE c IMMUTABLE STRICT;


--
-- Name: lexize(oid, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION lexize(oid, text) RETURNS text[]
    AS '$libdir/tsearch2', 'lexize'
    LANGUAGE c STRICT;


--
-- Name: lexize(text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION lexize(text, text) RETURNS text[]
    AS '$libdir/tsearch2', 'lexize_byname'
    LANGUAGE c STRICT;


--
-- Name: lexize(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION lexize(text) RETURNS text[]
    AS '$libdir/tsearch2', 'lexize_bycurrent'
    LANGUAGE c STRICT;


--
-- Name: numnode(tsquery); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION numnode(tsquery) RETURNS integer
    AS '$libdir/tsearch2', 'tsquery_numnode'
    LANGUAGE c IMMUTABLE STRICT;


--
-- Name: parse(oid, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION parse(oid, text) RETURNS SETOF tokenout
    AS '$libdir/tsearch2', 'parse'
    LANGUAGE c STRICT;


--
-- Name: parse(text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION parse(text, text) RETURNS SETOF tokenout
    AS '$libdir/tsearch2', 'parse_byname'
    LANGUAGE c STRICT;


--
-- Name: parse(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION parse(text) RETURNS SETOF tokenout
    AS '$libdir/tsearch2', 'parse_current'
    LANGUAGE c STRICT;


--
-- Name: plainto_tsquery(oid, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION plainto_tsquery(oid, text) RETURNS tsquery
    AS '$libdir/tsearch2', 'plainto_tsquery'
    LANGUAGE c IMMUTABLE STRICT;


--
-- Name: plainto_tsquery(text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION plainto_tsquery(text, text) RETURNS tsquery
    AS '$libdir/tsearch2', 'plainto_tsquery_name'
    LANGUAGE c IMMUTABLE STRICT;


--
-- Name: plainto_tsquery(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION plainto_tsquery(text) RETURNS tsquery
    AS '$libdir/tsearch2', 'plainto_tsquery_current'
    LANGUAGE c IMMUTABLE STRICT;


--
-- Name: prsd_end(internal); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION prsd_end(internal) RETURNS void
    AS '$libdir/tsearch2', 'prsd_end'
    LANGUAGE c;


--
-- Name: prsd_getlexeme(internal, internal, internal); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION prsd_getlexeme(internal, internal, internal) RETURNS integer
    AS '$libdir/tsearch2', 'prsd_getlexeme'
    LANGUAGE c;


--
-- Name: prsd_headline(internal, internal, internal); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION prsd_headline(internal, internal, internal) RETURNS internal
    AS '$libdir/tsearch2', 'prsd_headline'
    LANGUAGE c;


--
-- Name: prsd_lextype(internal); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION prsd_lextype(internal) RETURNS internal
    AS '$libdir/tsearch2', 'prsd_lextype'
    LANGUAGE c;


--
-- Name: prsd_start(internal, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION prsd_start(internal, integer) RETURNS internal
    AS '$libdir/tsearch2', 'prsd_start'
    LANGUAGE c;


--
-- Name: querytree(tsquery); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION querytree(tsquery) RETURNS text
    AS '$libdir/tsearch2', 'tsquerytree'
    LANGUAGE c STRICT;


--
-- Name: rank(real[], tsvector, tsquery); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rank(real[], tsvector, tsquery) RETURNS real
    AS '$libdir/tsearch2', 'rank'
    LANGUAGE c IMMUTABLE STRICT;


--
-- Name: rank(real[], tsvector, tsquery, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rank(real[], tsvector, tsquery, integer) RETURNS real
    AS '$libdir/tsearch2', 'rank'
    LANGUAGE c IMMUTABLE STRICT;


--
-- Name: rank(tsvector, tsquery); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rank(tsvector, tsquery) RETURNS real
    AS '$libdir/tsearch2', 'rank_def'
    LANGUAGE c IMMUTABLE STRICT;


--
-- Name: rank(tsvector, tsquery, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rank(tsvector, tsquery, integer) RETURNS real
    AS '$libdir/tsearch2', 'rank_def'
    LANGUAGE c IMMUTABLE STRICT;


--
-- Name: rank_cd(real[], tsvector, tsquery); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rank_cd(real[], tsvector, tsquery) RETURNS real
    AS '$libdir/tsearch2', 'rank_cd'
    LANGUAGE c IMMUTABLE STRICT;


--
-- Name: rank_cd(real[], tsvector, tsquery, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rank_cd(real[], tsvector, tsquery, integer) RETURNS real
    AS '$libdir/tsearch2', 'rank_cd'
    LANGUAGE c IMMUTABLE STRICT;


--
-- Name: rank_cd(tsvector, tsquery); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rank_cd(tsvector, tsquery) RETURNS real
    AS '$libdir/tsearch2', 'rank_cd_def'
    LANGUAGE c IMMUTABLE STRICT;


--
-- Name: rank_cd(tsvector, tsquery, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rank_cd(tsvector, tsquery, integer) RETURNS real
    AS '$libdir/tsearch2', 'rank_cd_def'
    LANGUAGE c IMMUTABLE STRICT;


--
-- Name: reset_tsearch(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION reset_tsearch() RETURNS void
    AS '$libdir/tsearch2', 'reset_tsearch'
    LANGUAGE c STRICT;


--
-- Name: rewrite(tsquery, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rewrite(tsquery, text) RETURNS tsquery
    AS '$libdir/tsearch2', 'tsquery_rewrite'
    LANGUAGE c IMMUTABLE STRICT;


--
-- Name: rewrite(tsquery, tsquery, tsquery); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rewrite(tsquery, tsquery, tsquery) RETURNS tsquery
    AS '$libdir/tsearch2', 'tsquery_rewrite_query'
    LANGUAGE c IMMUTABLE STRICT;


--
-- Name: rewrite_accum(tsquery, tsquery[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rewrite_accum(tsquery, tsquery[]) RETURNS tsquery
    AS '$libdir/tsearch2', 'rewrite_accum'
    LANGUAGE c;


--
-- Name: rewrite_finish(tsquery); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rewrite_finish(tsquery) RETURNS tsquery
    AS '$libdir/tsearch2', 'rewrite_finish'
    LANGUAGE c;


--
-- Name: rexectsq(tsquery, tsvector); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rexectsq(tsquery, tsvector) RETURNS boolean
    AS '$libdir/tsearch2', 'rexectsq'
    LANGUAGE c IMMUTABLE STRICT;


--
-- Name: FUNCTION rexectsq(tsquery, tsvector); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION rexectsq(tsquery, tsvector) IS 'boolean operation with text index';


--
-- Name: set_curcfg(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION set_curcfg(integer) RETURNS void
    AS '$libdir/tsearch2', 'set_curcfg'
    LANGUAGE c STRICT;


--
-- Name: set_curcfg(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION set_curcfg(text) RETURNS void
    AS '$libdir/tsearch2', 'set_curcfg_byname'
    LANGUAGE c STRICT;


--
-- Name: set_curdict(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION set_curdict(integer) RETURNS void
    AS '$libdir/tsearch2', 'set_curdict'
    LANGUAGE c STRICT;


--
-- Name: set_curdict(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION set_curdict(text) RETURNS void
    AS '$libdir/tsearch2', 'set_curdict_byname'
    LANGUAGE c STRICT;


--
-- Name: set_curprs(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION set_curprs(integer) RETURNS void
    AS '$libdir/tsearch2', 'set_curprs'
    LANGUAGE c STRICT;


--
-- Name: set_curprs(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION set_curprs(text) RETURNS void
    AS '$libdir/tsearch2', 'set_curprs_byname'
    LANGUAGE c STRICT;


--
-- Name: setweight(tsvector, "char"); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION setweight(tsvector, "char") RETURNS tsvector
    AS '$libdir/tsearch2', 'setweight'
    LANGUAGE c IMMUTABLE STRICT;


--
-- Name: show_curcfg(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION show_curcfg() RETURNS oid
    AS '$libdir/tsearch2', 'show_curcfg'
    LANGUAGE c STRICT;


--
-- Name: snb_en_init(internal); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION snb_en_init(internal) RETURNS internal
    AS '$libdir/tsearch2', 'snb_en_init'
    LANGUAGE c;


--
-- Name: snb_lexize(internal, internal, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION snb_lexize(internal, internal, integer) RETURNS internal
    AS '$libdir/tsearch2', 'snb_lexize'
    LANGUAGE c STRICT;


--
-- Name: snb_ru_init_koi8(internal); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION snb_ru_init_koi8(internal) RETURNS internal
    AS '$libdir/tsearch2', 'snb_ru_init_koi8'
    LANGUAGE c;


--
-- Name: snb_ru_init_utf8(internal); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION snb_ru_init_utf8(internal) RETURNS internal
    AS '$libdir/tsearch2', 'snb_ru_init_utf8'
    LANGUAGE c;


--
-- Name: spell_init(internal); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION spell_init(internal) RETURNS internal
    AS '$libdir/tsearch2', 'spell_init'
    LANGUAGE c;


--
-- Name: spell_lexize(internal, internal, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION spell_lexize(internal, internal, integer) RETURNS internal
    AS '$libdir/tsearch2', 'spell_lexize'
    LANGUAGE c STRICT;


--
-- Name: stat(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION stat(text) RETURNS SETOF statinfo
    AS '$libdir/tsearch2', 'ts_stat'
    LANGUAGE c STRICT;


--
-- Name: stat(text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION stat(text, text) RETURNS SETOF statinfo
    AS '$libdir/tsearch2', 'ts_stat'
    LANGUAGE c STRICT;


--
-- Name: strip(tsvector); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION strip(tsvector) RETURNS tsvector
    AS '$libdir/tsearch2', 'strip'
    LANGUAGE c IMMUTABLE STRICT;


--
-- Name: syn_init(internal); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION syn_init(internal) RETURNS internal
    AS '$libdir/tsearch2', 'syn_init'
    LANGUAGE c;


--
-- Name: syn_lexize(internal, internal, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION syn_lexize(internal, internal, integer) RETURNS internal
    AS '$libdir/tsearch2', 'syn_lexize'
    LANGUAGE c STRICT;


--
-- Name: thesaurus_init(internal); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION thesaurus_init(internal) RETURNS internal
    AS '$libdir/tsearch2', 'thesaurus_init'
    LANGUAGE c;


--
-- Name: thesaurus_lexize(internal, internal, integer, internal); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION thesaurus_lexize(internal, internal, integer, internal) RETURNS internal
    AS '$libdir/tsearch2', 'thesaurus_lexize'
    LANGUAGE c STRICT;


--
-- Name: to_tsquery(oid, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION to_tsquery(oid, text) RETURNS tsquery
    AS '$libdir/tsearch2', 'to_tsquery'
    LANGUAGE c IMMUTABLE STRICT;


--
-- Name: to_tsquery(text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION to_tsquery(text, text) RETURNS tsquery
    AS '$libdir/tsearch2', 'to_tsquery_name'
    LANGUAGE c IMMUTABLE STRICT;


--
-- Name: to_tsquery(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION to_tsquery(text) RETURNS tsquery
    AS '$libdir/tsearch2', 'to_tsquery_current'
    LANGUAGE c IMMUTABLE STRICT;


--
-- Name: to_tsvector(oid, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION to_tsvector(oid, text) RETURNS tsvector
    AS '$libdir/tsearch2', 'to_tsvector'
    LANGUAGE c IMMUTABLE STRICT;


--
-- Name: to_tsvector(text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION to_tsvector(text, text) RETURNS tsvector
    AS '$libdir/tsearch2', 'to_tsvector_name'
    LANGUAGE c IMMUTABLE STRICT;


--
-- Name: to_tsvector(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION to_tsvector(text) RETURNS tsvector
    AS '$libdir/tsearch2', 'to_tsvector_current'
    LANGUAGE c IMMUTABLE STRICT;


--
-- Name: token_type(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION token_type(integer) RETURNS SETOF tokentype
    AS '$libdir/tsearch2', 'token_type'
    LANGUAGE c STRICT;


--
-- Name: token_type(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION token_type(text) RETURNS SETOF tokentype
    AS '$libdir/tsearch2', 'token_type_byname'
    LANGUAGE c STRICT;


--
-- Name: token_type(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION token_type() RETURNS SETOF tokentype
    AS '$libdir/tsearch2', 'token_type_current'
    LANGUAGE c STRICT;


--
-- Name: ts_debug(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION ts_debug(text) RETURNS SETOF tsdebug
    AS $_$
select 
        m.ts_name,
        t.alias as tok_type,
        t.descr as description,
        p.token,
        m.dict_name,
        strip(to_tsvector(p.token)) as tsvector
from
        parse( _get_parser_from_curcfg(), $1 ) as p,
        token_type() as t,
        pg_ts_cfgmap as m,
        pg_ts_cfg as c
where
        t.tokid=p.tokid and
        t.alias = m.tok_alias and 
        m.ts_name=c.ts_name and 
        c.oid=show_curcfg() 
$_$
    LANGUAGE sql STRICT;


--
-- Name: tsearch2(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION tsearch2() RETURNS "trigger"
    AS '$libdir/tsearch2', 'tsearch2'
    LANGUAGE c;


--
-- Name: tsq_mcontained(tsquery, tsquery); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION tsq_mcontained(tsquery, tsquery) RETURNS boolean
    AS '$libdir/tsearch2', 'tsq_mcontained'
    LANGUAGE c IMMUTABLE STRICT;


--
-- Name: tsq_mcontains(tsquery, tsquery); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION tsq_mcontains(tsquery, tsquery) RETURNS boolean
    AS '$libdir/tsearch2', 'tsq_mcontains'
    LANGUAGE c IMMUTABLE STRICT;


--
-- Name: tsquery_and(tsquery, tsquery); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION tsquery_and(tsquery, tsquery) RETURNS tsquery
    AS '$libdir/tsearch2', 'tsquery_and'
    LANGUAGE c IMMUTABLE STRICT;


--
-- Name: tsquery_cmp(tsquery, tsquery); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION tsquery_cmp(tsquery, tsquery) RETURNS integer
    AS '$libdir/tsearch2', 'tsquery_cmp'
    LANGUAGE c IMMUTABLE STRICT;


--
-- Name: tsquery_eq(tsquery, tsquery); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION tsquery_eq(tsquery, tsquery) RETURNS boolean
    AS '$libdir/tsearch2', 'tsquery_eq'
    LANGUAGE c IMMUTABLE STRICT;


--
-- Name: tsquery_ge(tsquery, tsquery); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION tsquery_ge(tsquery, tsquery) RETURNS boolean
    AS '$libdir/tsearch2', 'tsquery_ge'
    LANGUAGE c IMMUTABLE STRICT;


--
-- Name: tsquery_gt(tsquery, tsquery); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION tsquery_gt(tsquery, tsquery) RETURNS boolean
    AS '$libdir/tsearch2', 'tsquery_gt'
    LANGUAGE c IMMUTABLE STRICT;


--
-- Name: tsquery_le(tsquery, tsquery); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION tsquery_le(tsquery, tsquery) RETURNS boolean
    AS '$libdir/tsearch2', 'tsquery_le'
    LANGUAGE c IMMUTABLE STRICT;


--
-- Name: tsquery_lt(tsquery, tsquery); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION tsquery_lt(tsquery, tsquery) RETURNS boolean
    AS '$libdir/tsearch2', 'tsquery_lt'
    LANGUAGE c IMMUTABLE STRICT;


--
-- Name: tsquery_ne(tsquery, tsquery); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION tsquery_ne(tsquery, tsquery) RETURNS boolean
    AS '$libdir/tsearch2', 'tsquery_ne'
    LANGUAGE c IMMUTABLE STRICT;


--
-- Name: tsquery_not(tsquery); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION tsquery_not(tsquery) RETURNS tsquery
    AS '$libdir/tsearch2', 'tsquery_not'
    LANGUAGE c IMMUTABLE STRICT;


--
-- Name: tsquery_or(tsquery, tsquery); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION tsquery_or(tsquery, tsquery) RETURNS tsquery
    AS '$libdir/tsearch2', 'tsquery_or'
    LANGUAGE c IMMUTABLE STRICT;


--
-- Name: tsvector_cmp(tsvector, tsvector); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION tsvector_cmp(tsvector, tsvector) RETURNS integer
    AS '$libdir/tsearch2', 'tsvector_cmp'
    LANGUAGE c IMMUTABLE STRICT;


--
-- Name: tsvector_eq(tsvector, tsvector); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION tsvector_eq(tsvector, tsvector) RETURNS boolean
    AS '$libdir/tsearch2', 'tsvector_eq'
    LANGUAGE c IMMUTABLE STRICT;


--
-- Name: tsvector_ge(tsvector, tsvector); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION tsvector_ge(tsvector, tsvector) RETURNS boolean
    AS '$libdir/tsearch2', 'tsvector_ge'
    LANGUAGE c IMMUTABLE STRICT;


--
-- Name: tsvector_gt(tsvector, tsvector); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION tsvector_gt(tsvector, tsvector) RETURNS boolean
    AS '$libdir/tsearch2', 'tsvector_gt'
    LANGUAGE c IMMUTABLE STRICT;


--
-- Name: tsvector_le(tsvector, tsvector); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION tsvector_le(tsvector, tsvector) RETURNS boolean
    AS '$libdir/tsearch2', 'tsvector_le'
    LANGUAGE c IMMUTABLE STRICT;


--
-- Name: tsvector_lt(tsvector, tsvector); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION tsvector_lt(tsvector, tsvector) RETURNS boolean
    AS '$libdir/tsearch2', 'tsvector_lt'
    LANGUAGE c IMMUTABLE STRICT;


--
-- Name: tsvector_ne(tsvector, tsvector); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION tsvector_ne(tsvector, tsvector) RETURNS boolean
    AS '$libdir/tsearch2', 'tsvector_ne'
    LANGUAGE c IMMUTABLE STRICT;


--
-- Name: rewrite(tsquery[]); Type: AGGREGATE; Schema: public; Owner: -
--

CREATE AGGREGATE rewrite(tsquery[]) (
    SFUNC = rewrite_accum,
    STYPE = tsquery,
    FINALFUNC = rewrite_finish
);


--
-- Name: !!; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR !! (
    PROCEDURE = tsquery_not,
    RIGHTARG = tsquery
);


--
-- Name: &&; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR && (
    PROCEDURE = tsquery_and,
    LEFTARG = tsquery,
    RIGHTARG = tsquery,
    COMMUTATOR = &&,
    RESTRICT = contsel,
    JOIN = contjoinsel
);


--
-- Name: <; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR < (
    PROCEDURE = tsvector_lt,
    LEFTARG = tsvector,
    RIGHTARG = tsvector,
    COMMUTATOR = >,
    NEGATOR = >=,
    RESTRICT = contsel,
    JOIN = contjoinsel
);


--
-- Name: <; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR < (
    PROCEDURE = tsquery_lt,
    LEFTARG = tsquery,
    RIGHTARG = tsquery,
    COMMUTATOR = >,
    NEGATOR = >=,
    RESTRICT = contsel,
    JOIN = contjoinsel
);


--
-- Name: <=; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR <= (
    PROCEDURE = tsvector_le,
    LEFTARG = tsvector,
    RIGHTARG = tsvector,
    COMMUTATOR = >=,
    NEGATOR = >,
    RESTRICT = contsel,
    JOIN = contjoinsel
);


--
-- Name: <=; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR <= (
    PROCEDURE = tsquery_le,
    LEFTARG = tsquery,
    RIGHTARG = tsquery,
    COMMUTATOR = >=,
    NEGATOR = >,
    RESTRICT = contsel,
    JOIN = contjoinsel
);


--
-- Name: <>; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR <> (
    PROCEDURE = tsvector_ne,
    LEFTARG = tsvector,
    RIGHTARG = tsvector,
    COMMUTATOR = <>,
    NEGATOR = =,
    RESTRICT = neqsel,
    JOIN = neqjoinsel
);


--
-- Name: <>; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR <> (
    PROCEDURE = tsquery_ne,
    LEFTARG = tsquery,
    RIGHTARG = tsquery,
    COMMUTATOR = <>,
    NEGATOR = =,
    RESTRICT = neqsel,
    JOIN = neqjoinsel
);


--
-- Name: <@; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR <@ (
    PROCEDURE = tsq_mcontained,
    LEFTARG = tsquery,
    RIGHTARG = tsquery,
    COMMUTATOR = @>,
    RESTRICT = contsel,
    JOIN = contjoinsel
);


--
-- Name: =; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR = (
    PROCEDURE = tsvector_eq,
    LEFTARG = tsvector,
    RIGHTARG = tsvector,
    COMMUTATOR = =,
    NEGATOR = <>,
    RESTRICT = eqsel,
    JOIN = eqjoinsel,
    SORT1 = <,
    SORT2 = <,
    LTCMP = <,
    GTCMP = >
);


--
-- Name: =; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR = (
    PROCEDURE = tsquery_eq,
    LEFTARG = tsquery,
    RIGHTARG = tsquery,
    COMMUTATOR = =,
    NEGATOR = <>,
    RESTRICT = eqsel,
    JOIN = eqjoinsel,
    SORT1 = <,
    SORT2 = <,
    LTCMP = <,
    GTCMP = >
);


--
-- Name: >; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR > (
    PROCEDURE = tsvector_gt,
    LEFTARG = tsvector,
    RIGHTARG = tsvector,
    COMMUTATOR = <,
    NEGATOR = <=,
    RESTRICT = contsel,
    JOIN = contjoinsel
);


--
-- Name: >; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR > (
    PROCEDURE = tsquery_gt,
    LEFTARG = tsquery,
    RIGHTARG = tsquery,
    COMMUTATOR = <,
    NEGATOR = <=,
    RESTRICT = contsel,
    JOIN = contjoinsel
);


--
-- Name: >=; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR >= (
    PROCEDURE = tsvector_ge,
    LEFTARG = tsvector,
    RIGHTARG = tsvector,
    COMMUTATOR = <=,
    NEGATOR = <,
    RESTRICT = contsel,
    JOIN = contjoinsel
);


--
-- Name: >=; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR >= (
    PROCEDURE = tsquery_ge,
    LEFTARG = tsquery,
    RIGHTARG = tsquery,
    COMMUTATOR = <=,
    NEGATOR = <,
    RESTRICT = contsel,
    JOIN = contjoinsel
);


--
-- Name: @; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR @ (
    PROCEDURE = tsq_mcontains,
    LEFTARG = tsquery,
    RIGHTARG = tsquery,
    COMMUTATOR = ~,
    RESTRICT = contsel,
    JOIN = contjoinsel
);


--
-- Name: @>; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR @> (
    PROCEDURE = tsq_mcontains,
    LEFTARG = tsquery,
    RIGHTARG = tsquery,
    COMMUTATOR = <@,
    RESTRICT = contsel,
    JOIN = contjoinsel
);


--
-- Name: @@; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR @@ (
    PROCEDURE = rexectsq,
    LEFTARG = tsquery,
    RIGHTARG = tsvector,
    COMMUTATOR = @@,
    RESTRICT = contsel,
    JOIN = contjoinsel
);


--
-- Name: @@; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR @@ (
    PROCEDURE = exectsq,
    LEFTARG = tsvector,
    RIGHTARG = tsquery,
    COMMUTATOR = @@,
    RESTRICT = contsel,
    JOIN = contjoinsel
);


--
-- Name: @@@; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR @@@ (
    PROCEDURE = rexectsq,
    LEFTARG = tsquery,
    RIGHTARG = tsvector,
    COMMUTATOR = @@@,
    RESTRICT = contsel,
    JOIN = contjoinsel
);


--
-- Name: @@@; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR @@@ (
    PROCEDURE = exectsq,
    LEFTARG = tsvector,
    RIGHTARG = tsquery,
    COMMUTATOR = @@@,
    RESTRICT = contsel,
    JOIN = contjoinsel
);


--
-- Name: ||; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR || (
    PROCEDURE = concat,
    LEFTARG = tsvector,
    RIGHTARG = tsvector
);


--
-- Name: ||; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR || (
    PROCEDURE = tsquery_or,
    LEFTARG = tsquery,
    RIGHTARG = tsquery,
    COMMUTATOR = ||,
    RESTRICT = contsel,
    JOIN = contjoinsel
);


--
-- Name: ~; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR ~ (
    PROCEDURE = tsq_mcontained,
    LEFTARG = tsquery,
    RIGHTARG = tsquery,
    COMMUTATOR = @,
    RESTRICT = contsel,
    JOIN = contjoinsel
);


--
-- Name: gin_tsvector_ops; Type: OPERATOR CLASS; Schema: public; Owner: -
--

CREATE OPERATOR CLASS gin_tsvector_ops
    DEFAULT FOR TYPE tsvector USING gin AS
    STORAGE text ,
    OPERATOR 1 @@(tsvector,tsquery) ,
    OPERATOR 2 @@@(tsvector,tsquery) RECHECK ,
    FUNCTION 1 bttextcmp(text,text) ,
    FUNCTION 2 gin_extract_tsvector(tsvector,internal) ,
    FUNCTION 3 gin_extract_tsquery(tsquery,internal,internal) ,
    FUNCTION 4 gin_ts_consistent(internal,internal,tsquery);


--
-- Name: gist_tp_tsquery_ops; Type: OPERATOR CLASS; Schema: public; Owner: -
--

CREATE OPERATOR CLASS gist_tp_tsquery_ops
    DEFAULT FOR TYPE tsquery USING gist AS
    STORAGE gtsq ,
    OPERATOR 7 @>(tsquery,tsquery) RECHECK ,
    OPERATOR 8 <@(tsquery,tsquery) RECHECK ,
    OPERATOR 13 @(tsquery,tsquery) RECHECK ,
    OPERATOR 14 ~(tsquery,tsquery) RECHECK ,
    FUNCTION 1 gtsq_consistent(gtsq,internal,integer) ,
    FUNCTION 2 gtsq_union(bytea,internal) ,
    FUNCTION 3 gtsq_compress(internal) ,
    FUNCTION 4 gtsq_decompress(internal) ,
    FUNCTION 5 gtsq_penalty(internal,internal,internal) ,
    FUNCTION 6 gtsq_picksplit(internal,internal) ,
    FUNCTION 7 gtsq_same(gtsq,gtsq,internal);


--
-- Name: gist_tsvector_ops; Type: OPERATOR CLASS; Schema: public; Owner: -
--

CREATE OPERATOR CLASS gist_tsvector_ops
    DEFAULT FOR TYPE tsvector USING gist AS
    STORAGE gtsvector ,
    OPERATOR 1 @@(tsvector,tsquery) RECHECK ,
    FUNCTION 1 gtsvector_consistent(gtsvector,internal,integer) ,
    FUNCTION 2 gtsvector_union(internal,internal) ,
    FUNCTION 3 gtsvector_compress(internal) ,
    FUNCTION 4 gtsvector_decompress(internal) ,
    FUNCTION 5 gtsvector_penalty(internal,internal,internal) ,
    FUNCTION 6 gtsvector_picksplit(internal,internal) ,
    FUNCTION 7 gtsvector_same(gtsvector,gtsvector,internal);


--
-- Name: tsquery_ops; Type: OPERATOR CLASS; Schema: public; Owner: -
--

CREATE OPERATOR CLASS tsquery_ops
    DEFAULT FOR TYPE tsquery USING btree AS
    OPERATOR 1 <(tsquery,tsquery) ,
    OPERATOR 2 <=(tsquery,tsquery) ,
    OPERATOR 3 =(tsquery,tsquery) ,
    OPERATOR 4 >=(tsquery,tsquery) ,
    OPERATOR 5 >(tsquery,tsquery) ,
    FUNCTION 1 tsquery_cmp(tsquery,tsquery);


--
-- Name: tsvector_ops; Type: OPERATOR CLASS; Schema: public; Owner: -
--

CREATE OPERATOR CLASS tsvector_ops
    DEFAULT FOR TYPE tsvector USING btree AS
    OPERATOR 1 <(tsvector,tsvector) ,
    OPERATOR 2 <=(tsvector,tsvector) ,
    OPERATOR 3 =(tsvector,tsvector) ,
    OPERATOR 4 >=(tsvector,tsvector) ,
    OPERATOR 5 >(tsvector,tsvector) ,
    FUNCTION 1 tsvector_cmp(tsvector,tsvector);


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: addresses; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE addresses (
    id integer NOT NULL,
    location_id integer,
    county_id integer,
    state_id integer,
    street_number character varying(10),
    street_name character varying(50),
    unit_number character varying(10),
    postal_code character varying(10),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    city character varying(255)
);


--
-- Name: addresses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE addresses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: addresses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE addresses_id_seq OWNED BY addresses.id;


--
-- Name: addresses_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('addresses_id_seq', 1, false);


--
-- Name: animals; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE animals (
    id integer NOT NULL,
    entity_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: animals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE animals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: animals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE animals_id_seq OWNED BY animals.id;


--
-- Name: animals_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('animals_id_seq', 1, false);


--
-- Name: cases_events; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE cases_events (
    id integer NOT NULL,
    event_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: clinicals; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE clinicals (
    id integer NOT NULL,
    event_id integer,
    test_public_health_lab_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: clinicals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE clinicals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: clinicals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE clinicals_id_seq OWNED BY clinicals.id;


--
-- Name: clinicals_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('clinicals_id_seq', 1, false);


--
-- Name: clusters; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE clusters (
    id integer NOT NULL,
    primary_event_id integer,
    secondary_event_id integer,
    cluster_status_id integer,
    "comment" character varying(500),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: clusters_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE clusters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: clusters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE clusters_id_seq OWNED BY clusters.id;


--
-- Name: clusters_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('clusters_id_seq', 1, false);


--
-- Name: codes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE codes (
    id integer NOT NULL,
    code_name character varying(50),
    the_code character varying(20),
    code_description character varying(100),
    sort_order integer
);


--
-- Name: codes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE codes_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: codes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE codes_id_seq OWNED BY codes.id;


--
-- Name: codes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('codes_id_seq', 197, true);


--
-- Name: disease_events; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE disease_events (
    id integer NOT NULL,
    event_id integer,
    disease_id integer,
    hospitalized_id integer,
    died_id integer,
    disease_onset_date date,
    date_diagnosed date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: disease_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE disease_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: disease_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE disease_events_id_seq OWNED BY disease_events.id;


--
-- Name: disease_events_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('disease_events_id_seq', 1, false);


--
-- Name: diseases; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE diseases (
    id integer NOT NULL,
    disease_name character varying(100)
);


--
-- Name: diseases_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE diseases_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: diseases_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE diseases_id_seq OWNED BY diseases.id;


--
-- Name: diseases_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('diseases_id_seq', 133, true);


--
-- Name: encounters; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE encounters (
    id integer NOT NULL,
    event_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: encounters_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE encounters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: encounters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE encounters_id_seq OWNED BY encounters.id;


--
-- Name: encounters_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('encounters_id_seq', 1, false);


--
-- Name: entities; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE entities (
    id integer NOT NULL,
    record_number character varying(20),
    entity_url_number character varying(200),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    entity_type character varying(255)
);


--
-- Name: entities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE entities_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: entities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE entities_id_seq OWNED BY entities.id;


--
-- Name: entities_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('entities_id_seq', 80, true);


--
-- Name: entities_locations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE entities_locations (
    id integer NOT NULL,
    location_id integer,
    entity_id integer,
    entity_location_type_id integer,
    primary_yn_id integer,
    "comment" character varying(500),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: entities_locations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE entities_locations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: entities_locations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE entities_locations_id_seq OWNED BY entities_locations.id;


--
-- Name: entities_locations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('entities_locations_id_seq', 1, false);


--
-- Name: entitlements; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE entitlements (
    id integer NOT NULL,
    user_id integer,
    privilege_id integer,
    jurisdiction_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: entitlements_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE entitlements_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: entitlements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE entitlements_id_seq OWNED BY entitlements.id;


--
-- Name: entitlements_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('entitlements_id_seq', 168, true);


--
-- Name: entity_groups; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE entity_groups (
    id integer NOT NULL,
    entity_group_type_id integer,
    primary_entity_id integer,
    secondary_entity_id integer,
    entity_group_name character varying(50),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: entity_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE entity_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: entity_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE entity_groups_id_seq OWNED BY entity_groups.id;


--
-- Name: entity_groups_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('entity_groups_id_seq', 1, false);


--
-- Name: event_cases_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE event_cases_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: event_cases_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE event_cases_id_seq OWNED BY cases_events.id;


--
-- Name: event_cases_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('event_cases_id_seq', 1, false);


--
-- Name: events; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE events (
    id integer NOT NULL,
    event_status_id integer,
    imported_from_id integer,
    event_case_status_id integer,
    event_name character varying(100),
    event_onset_date date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    outbreak_associated_id integer,
    outbreak_name character varying(255),
    "investigation_LHD_status_id" integer,
    investigation_started_date date,
    "investigation_completed_LHD_date" date,
    "review_completed_UDOH_date" date,
    "first_reported_PH_date" date,
    results_reported_to_clinician_date date,
    record_number character varying(20),
    "MMWR_week" integer,
    "MMWR_year" integer
);


--
-- Name: events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE events_id_seq OWNED BY events.id;


--
-- Name: events_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('events_id_seq', 1, false);


--
-- Name: events_record_number_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE events_record_number_seq
    START WITH 2008000001
    INCREMENT BY 1
    MAXVALUE 2008999999
    MINVALUE 2008000001
    CACHE 1;


--
-- Name: events_record_number_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('events_record_number_seq', 2008000001, false);


--
-- Name: hospitals_participations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE hospitals_participations (
    id integer NOT NULL,
    participation_id integer,
    hospital_record_number character varying(100),
    admission_date date,
    discharge_date date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: lab_results; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE lab_results (
    id integer NOT NULL,
    event_id integer,
    specimen_source_id integer,
    collection_date date,
    lab_test_date date,
    tested_at_uphl_yn_id integer,
    lab_result_text character varying(20),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: lab_results_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE lab_results_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: lab_results_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE lab_results_id_seq OWNED BY lab_results.id;


--
-- Name: lab_results_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('lab_results_id_seq', 1, false);


--
-- Name: laboratories; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE laboratories (
    id integer NOT NULL,
    entity_id integer,
    laboratory_name character varying(50),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: laboratories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE laboratories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: laboratories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE laboratories_id_seq OWNED BY laboratories.id;


--
-- Name: laboratories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('laboratories_id_seq', 1, false);


--
-- Name: locations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE locations (
    id integer NOT NULL,
    location_url_number character varying(200)
);


--
-- Name: locations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE locations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: locations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE locations_id_seq OWNED BY locations.id;


--
-- Name: locations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('locations_id_seq', 1, false);


--
-- Name: materials; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE materials (
    id integer NOT NULL,
    entity_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: materials_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE materials_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: materials_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE materials_id_seq OWNED BY materials.id;


--
-- Name: materials_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('materials_id_seq', 1, false);


--
-- Name: observations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE observations (
    id integer NOT NULL,
    event_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: observations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE observations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: observations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE observations_id_seq OWNED BY observations.id;


--
-- Name: observations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('observations_id_seq', 1, false);


--
-- Name: organizations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE organizations (
    id integer NOT NULL,
    entity_id integer,
    organization_type_id integer,
    organization_status_id integer,
    organization_name character varying(50),
    duration_start_date date,
    duration_end_date date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: organizations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE organizations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: organizations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE organizations_id_seq OWNED BY organizations.id;


--
-- Name: organizations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('organizations_id_seq', 1, false);


--
-- Name: participation_hospitals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE participation_hospitals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: participation_hospitals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE participation_hospitals_id_seq OWNED BY hospitals_participations.id;


--
-- Name: participation_hospitals_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('participation_hospitals_id_seq', 1, false);


--
-- Name: participations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE participations (
    id integer NOT NULL,
    primary_entity_id integer,
    secondary_entity_id integer,
    role_id integer,
    participation_status_id integer,
    "comment" character varying(500),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    event_id integer
);


--
-- Name: participations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE participations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: participations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE participations_id_seq OWNED BY participations.id;


--
-- Name: participations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('participations_id_seq', 1, false);


--
-- Name: participations_risk_factors; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE participations_risk_factors (
    id integer NOT NULL,
    participation_id integer,
    food_handler_id integer,
    healthcare_worker_id integer,
    group_living_id integer,
    day_care_association_id integer,
    pregnant_id integer,
    pregnancy_due_date date,
    risk_factors character varying(25),
    risk_factors_notes character varying(100),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: participations_risk_factors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE participations_risk_factors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: participations_risk_factors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE participations_risk_factors_id_seq OWNED BY participations_risk_factors.id;


--
-- Name: participations_risk_factors_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('participations_risk_factors_id_seq', 1, false);


--
-- Name: participations_treatments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE participations_treatments (
    id integer NOT NULL,
    participation_id integer,
    treatment_id integer,
    treatment_given_yn_id integer,
    treatment_date date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    treatment character varying(255)
);


--
-- Name: participations_treatments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE participations_treatments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: participations_treatments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE participations_treatments_id_seq OWNED BY participations_treatments.id;


--
-- Name: participations_treatments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('participations_treatments_id_seq', 1, false);


--
-- Name: people; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE people (
    id integer NOT NULL,
    entity_id integer,
    birth_gender_id integer,
    ethnicity_id integer,
    primary_language_id integer,
    first_name character varying(25),
    middle_name character varying(25),
    last_name character varying(25),
    birth_date date,
    date_of_death date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    food_handler_id integer,
    age_type_id integer,
    approximate_age_no_birthday integer,
    first_name_soundex character varying(255),
    last_name_soundex character varying(255),
    vector tsvector
);


--
-- Name: people_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE people_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: people_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE people_id_seq OWNED BY people.id;


--
-- Name: people_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('people_id_seq', 1, false);


--
-- Name: people_races; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE people_races (
    race_id integer,
    entity_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


SET default_with_oids = true;

--
-- Name: pg_ts_cfg; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE pg_ts_cfg (
    ts_name text NOT NULL,
    prs_name text NOT NULL,
    locale text
);


--
-- Name: pg_ts_cfgmap; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE pg_ts_cfgmap (
    ts_name text NOT NULL,
    tok_alias text NOT NULL,
    dict_name text[]
);


--
-- Name: pg_ts_dict; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE pg_ts_dict (
    dict_name text NOT NULL,
    dict_init regprocedure,
    dict_initoption text,
    dict_lexize regprocedure NOT NULL,
    dict_comment text
);


--
-- Name: pg_ts_parser; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE pg_ts_parser (
    prs_name text NOT NULL,
    prs_start regprocedure NOT NULL,
    prs_nexttoken regprocedure NOT NULL,
    prs_end regprocedure NOT NULL,
    prs_headline regprocedure NOT NULL,
    prs_lextype regprocedure NOT NULL,
    prs_comment text
);


SET default_with_oids = false;

--
-- Name: places; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE places (
    id integer NOT NULL,
    entity_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    place_type_id integer,
    name character varying(255),
    short_name character varying(255)
);


--
-- Name: places_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE places_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: places_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE places_id_seq OWNED BY places.id;


--
-- Name: places_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('places_id_seq', 80, true);


--
-- Name: privileges; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE "privileges" (
    id integer NOT NULL,
    priv_name character varying(15),
    description character varying(60)
);


--
-- Name: privileges_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE privileges_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: privileges_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE privileges_id_seq OWNED BY "privileges".id;


--
-- Name: privileges_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('privileges_id_seq', 3, true);


--
-- Name: privileges_roles; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE privileges_roles (
    id integer NOT NULL,
    role_id integer,
    privilege_id integer,
    jurisdiction_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: privileges_roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE privileges_roles_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: privileges_roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE privileges_roles_id_seq OWNED BY privileges_roles.id;


--
-- Name: privileges_roles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('privileges_roles_id_seq', 70, true);


--
-- Name: referrals; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE referrals (
    id integer NOT NULL,
    event_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: referrals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE referrals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: referrals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE referrals_id_seq OWNED BY referrals.id;


--
-- Name: referrals_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('referrals_id_seq', 1, false);


--
-- Name: role_memberships; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE role_memberships (
    id integer NOT NULL,
    user_id integer,
    role_id integer,
    jurisdiction_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: role_memberships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE role_memberships_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: role_memberships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE role_memberships_id_seq OWNED BY role_memberships.id;


--
-- Name: role_memberships_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('role_memberships_id_seq', 56, true);


--
-- Name: roles; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE roles (
    id integer NOT NULL,
    role_name character varying(15),
    description character varying(60)
);


--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE roles_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE roles_id_seq OWNED BY roles.id;


--
-- Name: roles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('roles_id_seq', 2, true);


--
-- Name: schema_info; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_info (
    version integer
);


--
-- Name: telephones; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE telephones (
    id integer NOT NULL,
    location_id integer,
    country_code character varying(3),
    area_code character varying(3),
    phone_number character varying(7),
    extension character varying(6),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: telephones_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE telephones_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: telephones_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE telephones_id_seq OWNED BY telephones.id;


--
-- Name: telephones_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('telephones_id_seq', 1, false);


--
-- Name: treatments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE treatments (
    id integer NOT NULL,
    treatment_type_id integer,
    treatment_name character varying(100)
);


--
-- Name: treatments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE treatments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: treatments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE treatments_id_seq OWNED BY treatments.id;


--
-- Name: treatments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('treatments_id_seq', 1, false);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    uid character varying(9),
    given_name character varying(127),
    first_name character varying(32),
    last_name character varying(64),
    initials character varying(8),
    generational_qualifer character varying(8),
    user_name character varying(20),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('users_id_seq', 4, true);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE addresses ALTER COLUMN id SET DEFAULT nextval('addresses_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE animals ALTER COLUMN id SET DEFAULT nextval('animals_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE cases_events ALTER COLUMN id SET DEFAULT nextval('event_cases_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE clinicals ALTER COLUMN id SET DEFAULT nextval('clinicals_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE clusters ALTER COLUMN id SET DEFAULT nextval('clusters_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE codes ALTER COLUMN id SET DEFAULT nextval('codes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE disease_events ALTER COLUMN id SET DEFAULT nextval('disease_events_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE diseases ALTER COLUMN id SET DEFAULT nextval('diseases_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE encounters ALTER COLUMN id SET DEFAULT nextval('encounters_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE entities ALTER COLUMN id SET DEFAULT nextval('entities_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE entities_locations ALTER COLUMN id SET DEFAULT nextval('entities_locations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE entitlements ALTER COLUMN id SET DEFAULT nextval('entitlements_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE entity_groups ALTER COLUMN id SET DEFAULT nextval('entity_groups_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE events ALTER COLUMN id SET DEFAULT nextval('events_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE hospitals_participations ALTER COLUMN id SET DEFAULT nextval('participation_hospitals_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE lab_results ALTER COLUMN id SET DEFAULT nextval('lab_results_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE laboratories ALTER COLUMN id SET DEFAULT nextval('laboratories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE locations ALTER COLUMN id SET DEFAULT nextval('locations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE materials ALTER COLUMN id SET DEFAULT nextval('materials_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE observations ALTER COLUMN id SET DEFAULT nextval('observations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE organizations ALTER COLUMN id SET DEFAULT nextval('organizations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE participations ALTER COLUMN id SET DEFAULT nextval('participations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE participations_risk_factors ALTER COLUMN id SET DEFAULT nextval('participations_risk_factors_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE participations_treatments ALTER COLUMN id SET DEFAULT nextval('participations_treatments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE people ALTER COLUMN id SET DEFAULT nextval('people_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE places ALTER COLUMN id SET DEFAULT nextval('places_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE "privileges" ALTER COLUMN id SET DEFAULT nextval('privileges_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE privileges_roles ALTER COLUMN id SET DEFAULT nextval('privileges_roles_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE referrals ALTER COLUMN id SET DEFAULT nextval('referrals_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE role_memberships ALTER COLUMN id SET DEFAULT nextval('role_memberships_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE roles ALTER COLUMN id SET DEFAULT nextval('roles_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE telephones ALTER COLUMN id SET DEFAULT nextval('telephones_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE treatments ALTER COLUMN id SET DEFAULT nextval('treatments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Data for Name: addresses; Type: TABLE DATA; Schema: public; Owner: -
--

COPY addresses (id, location_id, county_id, state_id, street_number, street_name, unit_number, postal_code, created_at, updated_at, city) FROM stdin;
\.


--
-- Data for Name: animals; Type: TABLE DATA; Schema: public; Owner: -
--

COPY animals (id, entity_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: cases_events; Type: TABLE DATA; Schema: public; Owner: -
--

COPY cases_events (id, event_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: clinicals; Type: TABLE DATA; Schema: public; Owner: -
--

COPY clinicals (id, event_id, test_public_health_lab_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: clusters; Type: TABLE DATA; Schema: public; Owner: -
--

COPY clusters (id, primary_event_id, secondary_event_id, cluster_status_id, "comment", created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: codes; Type: TABLE DATA; Schema: public; Owner: -
--

COPY codes (id, code_name, the_code, code_description, sort_order) FROM stdin;
1	gender	M	Male	10
2	gender	F	Female	5
3	gender	UNK	Unknown	1
4	ethnicity	H	Hispanic or Latino	5
5	ethnicity	NH	Not Hispanic or Latino	10
6	ethnicity	O	Other	15
7	ethnicity	UNK	Unknown	1
8	race	W	White	5
9	race	B	Black / African-American	10
10	race	AA	American Indian	15
11	race	A	Asian	20
12	race	AK	Alaskan Native	25
13	race	H	Native Hawaiian / Pacific Islander	30
14	language	UNK	Unknown	1
15	language	en	English	5
16	language	es	Spanish	10
17	language	ar	Arabic	20
18	language	hy	Armenian	25
19	language	km	Cambodian	30
20	language	cha	Chamorro	35
21	language	zh	Chinese	40
22	language	chk	Chuukese	45
23	language	per	Farsi	50
24	language	fr	French	55
25	language	de	German	60
26	language	gu	Gujarati	65
27	language	hat	Haitian Creole	70
28	language	hi	Hindi	75
29	language	hmn	Hmong	80
30	language	it	Italian	85
31	language	ja	Japanese	100
32	language	ko	Korean	105
33	language	lao	Lao	110
34	language	nai	Native American	125
35	language	pol	Polish	130
36	language	pt	Portugese	135
37	language	ru	Russian	140
38	language	smo	Samoan	145
39	language	hbs	Serbo-Croatian	150
40	language	som	Somali	155
41	language	ton	Tongan	160
42	language	tgl	Tagalog	165
43	language	tha	Thai	170
44	language	vi	Vietnamese	175
45	state	UT	Utah	1
46	state	AL	Alabama	5
47	state	AK	Alaska	10
48	state	AS	American Samoa	15
49	state	AZ	Arizona	20
50	state	CA	California	25
51	state	CO	Colorado	30
52	state	CT	Connecticut	35
53	state	DE	Deleware	40
54	state	DC	District of Columbia	45
55	state	FM	Federated States of Micronesia	50
56	state	FL	Florida	55
57	state	GA	Georgia	60
58	state	GU	Guam	65
59	state	HI	Hawaii	70
60	state	ID	Idaho	75
61	state	IL	Ilinois	80
62	state	IN	Indiana	85
63	state	IA	Iowa	90
64	state	KS	Kansas	100
65	state	KY	Kentucky	105
66	state	LA	Louisiana	110
67	state	ME	Maine	115
68	state	MH	Marshall Islands	120
69	state	MD	Maryland	125
70	state	MA	Massachusetts	150
71	state	MI	Michigan	155
72	state	MN	Minnesota	160
73	state	MS	Mississippi	165
74	state	MO	Missouri	170
75	state	MT	Montana	175
76	state	NE	Nebraska	180
77	state	NV	Nevada	185
78	state	NH	New Hampshire	190
79	state	NJ	New Jersey	195
80	state	NM	New Mexico	200
81	state	NY	New York	205
82	state	NC	North Carolina	210
83	state	ND	North Dakota	215
84	state	MP	Northern Mariana Islands	220
85	state	OH	Ohio	225
86	state	OK	Oklahamo	230
87	state	OR	Oregon	235
88	state	PW	Palau	240
89	state	PA	Pennsylvania	245
90	state	PR	Puerto Rico	250
91	state	RI	Rhode Island	255
92	state	SC	South Carolina	260
93	state	SD	South Dakota	265
94	state	TN	Temmessee	270
95	state	TX	Texas	275
96	state	VT	Vermont	280
97	state	VA	Virginia	285
98	state	WA	Washington	290
99	state	WV	West Virginia	295
100	state	WI	Wisconsin	300
101	state	WY	Wyoming	305
102	county	BV	Beaver	5
103	county	BE	Box Elder	10
104	county	CA	Cache	15
105	county	DG	Daggett	20
106	county	DV	Davis	25
107	county	DU	Duchesne	30
108	county	EM	Emery	35
109	county	GA	Garfield	40
110	county	GR	GRAND	45
111	county	IR	Iron	50
112	county	JU	Juab	55
113	county	KA	Kane	60
114	county	MI	Millard	65
115	county	MO	Morgan	70
116	county	PL	Plute	75
117	county	RI	Rich	80
118	county	SL	Salt Lake	85
119	county	SJ	San Juan	90
120	county	SP	Sanpete	100
121	county	SV	Sevier	105
122	county	TL	Tooele	110
123	county	UI	Uintah	115
124	county	UT	Utah	120
125	county	WS	Wasatch	125
126	county	WA	Washington	130
127	county	WN	Wayne	135
128	county	WB	Weber	140
129	county	OS	Out-of-state	145
130	location	H	Home	5
131	location	W	Work	10
132	location	UNK	Unspecified	1
133	location	M	Mobile	15
134	yesno	UNK	Unknown	1
135	yesno	Y	Yes	5
136	yesno	N	No	10
137	specimen	AB	Abcess	5
138	specimen	AH	Animal head	10
139	specimen	BD	Blood	15
140	specimen	BS	Blood & Stool	20
141	specimen	BT	Brain Tissue	25
142	specimen	BW	Broncial Wash	30
143	specimen	CS	Cervical Swab	35
144	specimen	CSF	CSF	40
145	specimen	CSFB	CSF & Blood	45
146	specimen	EYE	Eye Swab/Wash	50
147	specimen	LA	Lung Aspirate	55
148	specimen	NA	Nasopharyngeal Aspirate	60
149	specimen	NS	Nasopharyngeal Swab	65
150	specimen	RS	Rectal Swab	70
151	specimen	SK	Skin	75
152	specimen	SP	Sputum	80
153	specimen	ST	Stool	85
154	specimen	TS	Throat Swab	90
155	specimen	TW	Throat Wash	95
156	specimen	TI	Tissue	100
157	specimen	UR	Urine	105
158	specimen	US	Urethral Swab	110
159	specimen	OT	Other	115
160	specimen	UNK	Unknown	1
161	investigation	UNK	Unknown	1
162	investigation	NYO	Not Yet Open	5
163	investigation	O	Open	10
164	investigation	C	Closed	15
165	case	UNK	Unknown	1
166	case	C	Confirmed	5
167	case	P	Probable	10
168	case	S	Suspect	15
169	case	NC	Not a Case	20
170	case	CC	Chronic Carrier	25
171	case	D	Discarded	30
172	eventstatus	NEW	New	5
173	eventstatus	ASG	Assigned to Jursidiction	10
174	eventstatus	UI	Under Investigation	15
175	eventstatus	IC	Investigation Complete	20
176	eventstatus	RO	Reopened	25
177	eventstatus	APP	Approved by LHD	30
178	eventstatus	CLO	Approved by State	35
179	imported	UNK	Unknown	1
180	imported	UT	Utah	5
181	imported	F	Outside U.S.	10
182	imported	US	Other U.S. State	15
183	placetype	H	Hospital / ICP	5
184	placetype	J	Jurisdiction	10
185	placetype	L	Laboratory	15
186	placetype	C	Clinic / Doctor's Office	20
187	placetype	O	Other	25
188	participant	I	Interested Party	5
189	participant	H	Hospitalized At	10
190	participant	RB	Reported By	15
191	participant	RA	Reporting Agency	20
192	participant	J	Jurisdiction	25
193	participant	TW	Treated With	30
194	participant	TB	Treated By	35
195	participant	CO	Contact	40
196	participant	SO	Spouse of	45
197	participant	Co	Child of	50
\.


--
-- Data for Name: disease_events; Type: TABLE DATA; Schema: public; Owner: -
--

COPY disease_events (id, event_id, disease_id, hospitalized_id, died_id, disease_onset_date, date_diagnosed, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: diseases; Type: TABLE DATA; Schema: public; Owner: -
--

COPY diseases (id, disease_name) FROM stdin;
1	African Tick Bite Fever
2	AIDS
3	Amebiasis
4	Anaplasma phagocytophilum
5	Anthrax
6	Aseptic meningitis
7	Bacterial meningitis, other
8	Botulism, foodborne
9	Botulism, infant
10	Botulism, other (includes wound)
11	Botulism, other unspecified
12	Botulism, wound
13	Brucellosis
14	Cache Valley virus neuroinvasive disease
15	Cache Valley virus non-neuroinvasive disease
16	California serogroup virus neuroinvasive disease
17	California serogroup virus non-neuroinvasive disease
18	Campylobacteriosis
19	Chancroid
20	Chlamydia trachomatis genital infection
21	Cholera (toxigenic Vibrio cholerae O1 or O139)
22	Coccidioidomycosis
23	Cryptosporidiosis
24	Cyclosporiasis
25	Dengue
26	Dengue hemorrhagic fever
27	Diphtheria
28	Eastern equine encephalitis virus neuroinvasive disease
29	Eastern equine encephalitis virus non-neuroinvasive disease
30	Ehrlichia chaffeensis
31	Ehrlichia ewingii
32	Ehrlichiosis/Anaplasmosis, undetermined
33	Encephalitis, post-chickenpox
34	Encephalitis, post-mumps
35	Encephalitis, post-other
36	Encephalitis, primary
37	Flu activity code (Influenza)
38	Giardiasis
39	Gonorrhea
40	Granuloma inguinale (GI)
41	Haemophilus influenzae, invasive disease
42	Hansen disease (Leprosy)
43	Hantavirus infection
44	Hantavirus pulmonary syndrome
45	Hemolytic uremic syndrome postdiarrheal
46	Hepatitis A, acute
47	Hepatitis B virus infection, chronic
48	Hepatitis B, acute
49	Hepatitis B, virus infection perinatal
50	Hepatitis C virus infection, past or present
51	Hepatitis C, acute
52	Hepatitis Delta co- or super-infection, acute (Hepatitis D)
53	Hepatitis E, acute
54	Hepatitis, viral unspecified
55	HIV Infection, adult
56	HIV Infection, pediatric
57	Human T-Lymphotropic virus type I  infection (HTLV-I)
58	Human T-Lymphotropic virus type II  infection (HTLV-II)
59	Influenza, animal isolates
60	Influenza, human isolates
61	Influenza-associated mortality
62	Japanese encephalitis virus neuroinvasive disease
63	Japanese encephalitis virus non-neuroinvasive disease
64	Lead poisoning
65	Legionellosis
66	Listeriosis
67	Lyme disease
68	Lymphogranuloma venereum (LGV)
69	Malaria
70	Measles (rubeola), total
71	Meningococcal disease (Neisseria meningitidis)
72	Methicillin- or oxicillin- resistant Staphylococcus aureus coagulase-positive (MRSA a.k.a. ORSA)
73	Monkeypox
74	Mucopurulent cervicitis (MPC)
75	Mumps
76	Neurosyphilis
77	Nongonococcal urethritis (NGU)
78	Novel influenza A virus infections
79	Pelvic Inflammatory Disease (PID), Unknown Etiology
80	Pertussis
81	Plague
82	Poliomyelitis, paralytic
83	Poliovirus infection, nonparalytic
84	Powassan virus neuroinvasive disease
85	Powassan virus non-neuroinvasive disease
86	Psittacosis (Ornithosis)
87	Q fever
88	Q fever, acute
89	Q fever, chronic
90	Rabies, animal
91	Rabies, human
92	Rocky Mountain spotted fever
93	Rubella
94	Rubella, congenital syndrome
95	Salmonellosis
96	Severe Acute Respiratory Syndrome (SARS)-associated Coronavirus disease (SARS-CoV)
97	Shiga toxin-producing Escherichia coli (STEC)
98	Shigellosis
99	Smallpox
100	St. Louis encephalitis virus neuroinvasive disease
101	St. Louis encephalitis virus non-neuroinvasive disease
102	Streptococcal disease, invasive, Group A
103	Streptococcal disease, invasive, Group B
104	Streptococcal disease, other, invasive, beta-hemolytic (non-group A and non-group B)
105	Streptococcal toxic-shock syndrome
106	Streptococcus pneumoniae invasive, drug-resistant (DRSP)
107	Streptococcus pneumoniae, invasive disease
108	Syphilis, congenital
109	Syphilis, early latent
110	Syphilis, late latent
111	Syphilis, late with clinical manifestations other than neurosyphilis
112	Syphilis, primary
113	Syphilis, secondary
114	Syphilis, total primary and secondary
115	Syphilis, unknown latent
116	Tetanus
117	Toxic-shock syndrome (staphylococcal)
118	Trichinellosis
119	Tuberculosis
120	Tularemia
121	Typhoid fever (caused by Salmonella typhi)
122	Vancomycin-intermediate Staphylococcus aureus (VISA)
123	Vancomycin-resistant Staphylococcus aureus (VRSA)
124	Varicella (Chickenpox)
125	Venezuelan equine encephalitis virus neuroinvasive disease
126	Venezuelan equine encephalitis virus non-neuroinvasive disease
127	Vibriosis (non-cholera Vibrio species infections)
128	West Nile virus neuroinvasive disease
129	West Nile virus non-neuroinvasive disease
130	Western equine encephalitis virus neuroinvasive disease
131	Western equine encephalitis virus non-neuroinvasive disease
132	Yellow fever
133	Yersiniosis
\.


--
-- Data for Name: encounters; Type: TABLE DATA; Schema: public; Owner: -
--

COPY encounters (id, event_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: entities; Type: TABLE DATA; Schema: public; Owner: -
--

COPY entities (id, record_number, entity_url_number, created_at, updated_at, entity_type) FROM stdin;
1	\N	\N	2008-03-31 09:36:03.879215	2008-03-31 09:36:03.879215	place
2	\N	\N	2008-03-31 09:36:03.895437	2008-03-31 09:36:03.895437	place
3	\N	\N	2008-03-31 09:36:03.90386	2008-03-31 09:36:03.90386	place
4	\N	\N	2008-03-31 09:36:03.912046	2008-03-31 09:36:03.912046	place
5	\N	\N	2008-03-31 09:36:03.920263	2008-03-31 09:36:03.920263	place
6	\N	\N	2008-03-31 09:36:03.928473	2008-03-31 09:36:03.928473	place
7	\N	\N	2008-03-31 09:36:03.969737	2008-03-31 09:36:03.969737	place
8	\N	\N	2008-03-31 09:36:03.978513	2008-03-31 09:36:03.978513	place
9	\N	\N	2008-03-31 09:36:03.987543	2008-03-31 09:36:03.987543	place
10	\N	\N	2008-03-31 09:36:03.996432	2008-03-31 09:36:03.996432	place
11	\N	\N	2008-03-31 09:36:04.005289	2008-03-31 09:36:04.005289	place
12	\N	\N	2008-03-31 09:36:04.0222	2008-03-31 09:36:04.0222	place
13	\N	\N	2008-03-31 09:36:04.030892	2008-03-31 09:36:04.030892	place
14	\N	\N	2008-03-31 09:36:04.039839	2008-03-31 09:36:04.039839	place
15	\N	\N	2008-03-31 09:36:04.047999	2008-03-31 09:36:04.047999	place
16	\N	\N	2008-03-31 09:36:04.056537	2008-03-31 09:36:04.056537	place
17	\N	\N	2008-03-31 09:36:04.065056	2008-03-31 09:36:04.065056	place
18	\N	\N	2008-03-31 09:36:04.073219	2008-03-31 09:36:04.073219	place
19	\N	\N	2008-03-31 09:36:04.081704	2008-03-31 09:36:04.081704	place
20	\N	\N	2008-03-31 09:36:04.090036	2008-03-31 09:36:04.090036	place
21	\N	\N	2008-03-31 09:36:04.09793	2008-03-31 09:36:04.09793	place
22	\N	\N	2008-03-31 09:36:04.106213	2008-03-31 09:36:04.106213	place
23	\N	\N	2008-03-31 09:36:04.114791	2008-03-31 09:36:04.114791	place
24	\N	\N	2008-03-31 09:36:04.122921	2008-03-31 09:36:04.122921	place
25	\N	\N	2008-03-31 09:36:04.130755	2008-03-31 09:36:04.130755	place
26	\N	\N	2008-03-31 09:36:04.139077	2008-03-31 09:36:04.139077	place
27	\N	\N	2008-03-31 09:36:04.147203	2008-03-31 09:36:04.147203	place
28	\N	\N	2008-03-31 09:36:04.189534	2008-03-31 09:36:04.189534	place
29	\N	\N	2008-03-31 09:36:04.198366	2008-03-31 09:36:04.198366	place
30	\N	\N	2008-03-31 09:36:04.207075	2008-03-31 09:36:04.207075	place
31	\N	\N	2008-03-31 09:36:04.216088	2008-03-31 09:36:04.216088	place
32	\N	\N	2008-03-31 09:36:04.224993	2008-03-31 09:36:04.224993	place
33	\N	\N	2008-03-31 09:36:04.23372	2008-03-31 09:36:04.23372	place
34	\N	\N	2008-03-31 09:36:04.242473	2008-03-31 09:36:04.242473	place
35	\N	\N	2008-03-31 09:36:04.250976	2008-03-31 09:36:04.250976	place
36	\N	\N	2008-03-31 09:36:04.259433	2008-03-31 09:36:04.259433	place
37	\N	\N	2008-03-31 09:36:04.267925	2008-03-31 09:36:04.267925	place
38	\N	\N	2008-03-31 09:36:04.276465	2008-03-31 09:36:04.276465	place
39	\N	\N	2008-03-31 09:36:04.284996	2008-03-31 09:36:04.284996	place
40	\N	\N	2008-03-31 09:36:04.293433	2008-03-31 09:36:04.293433	place
41	\N	\N	2008-03-31 09:36:04.301949	2008-03-31 09:36:04.301949	place
42	\N	\N	2008-03-31 09:36:04.310218	2008-03-31 09:36:04.310218	place
43	\N	\N	2008-03-31 09:36:04.318744	2008-03-31 09:36:04.318744	place
44	\N	\N	2008-03-31 09:36:04.327134	2008-03-31 09:36:04.327134	place
45	\N	\N	2008-03-31 09:36:04.335591	2008-03-31 09:36:04.335591	place
46	\N	\N	2008-03-31 09:36:04.344059	2008-03-31 09:36:04.344059	place
47	\N	\N	2008-03-31 09:36:04.35253	2008-03-31 09:36:04.35253	place
48	\N	\N	2008-03-31 09:36:04.360977	2008-03-31 09:36:04.360977	place
49	\N	\N	2008-03-31 09:36:04.369431	2008-03-31 09:36:04.369431	place
50	\N	\N	2008-03-31 09:36:04.41249	2008-03-31 09:36:04.41249	place
51	\N	\N	2008-03-31 09:36:04.421382	2008-03-31 09:36:04.421382	place
52	\N	\N	2008-03-31 09:36:04.430314	2008-03-31 09:36:04.430314	place
53	\N	\N	2008-03-31 09:36:04.439172	2008-03-31 09:36:04.439172	place
54	\N	\N	2008-03-31 09:36:04.447841	2008-03-31 09:36:04.447841	place
55	\N	\N	2008-03-31 09:36:04.456487	2008-03-31 09:36:04.456487	place
56	\N	\N	2008-03-31 09:36:04.464869	2008-03-31 09:36:04.464869	place
57	\N	\N	2008-03-31 09:36:04.47354	2008-03-31 09:36:04.47354	place
58	\N	\N	2008-03-31 09:36:04.48191	2008-03-31 09:36:04.48191	place
59	\N	\N	2008-03-31 09:36:04.490787	2008-03-31 09:36:04.490787	place
60	\N	\N	2008-03-31 09:36:04.499536	2008-03-31 09:36:04.499536	place
61	\N	\N	2008-03-31 09:36:04.50802	2008-03-31 09:36:04.50802	place
62	\N	\N	2008-03-31 09:36:04.516275	2008-03-31 09:36:04.516275	place
63	\N	\N	2008-03-31 09:36:04.524665	2008-03-31 09:36:04.524665	place
64	\N	\N	2008-03-31 09:36:04.53332	2008-03-31 09:36:04.53332	place
65	\N	\N	2008-03-31 09:36:04.5418	2008-03-31 09:36:04.5418	place
66	\N	\N	2008-03-31 09:36:04.550114	2008-03-31 09:36:04.550114	place
67	\N	\N	2008-03-31 09:36:04.566447	2008-03-31 09:36:04.566447	place
68	\N	\N	2008-03-31 09:36:04.574716	2008-03-31 09:36:04.574716	place
69	\N	\N	2008-03-31 09:36:04.583174	2008-03-31 09:36:04.583174	place
70	\N	\N	2008-03-31 09:36:04.591509	2008-03-31 09:36:04.591509	place
71	\N	\N	2008-03-31 09:36:04.63452	2008-03-31 09:36:04.63452	place
72	\N	\N	2008-03-31 09:36:04.643498	2008-03-31 09:36:04.643498	place
73	\N	\N	2008-03-31 09:36:04.652401	2008-03-31 09:36:04.652401	place
74	\N	\N	2008-03-31 09:36:04.661145	2008-03-31 09:36:04.661145	place
75	\N	\N	2008-03-31 09:36:04.669743	2008-03-31 09:36:04.669743	place
76	\N	\N	2008-03-31 09:36:04.67835	2008-03-31 09:36:04.67835	place
77	\N	\N	2008-03-31 09:36:04.687062	2008-03-31 09:36:04.687062	place
78	\N	\N	2008-03-31 09:36:04.695468	2008-03-31 09:36:04.695468	place
79	\N	\N	2008-03-31 09:36:04.704029	2008-03-31 09:36:04.704029	place
80	\N	\N	2008-03-31 09:36:04.712431	2008-03-31 09:36:04.712431	place
\.


--
-- Data for Name: entities_locations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY entities_locations (id, location_id, entity_id, entity_location_type_id, primary_yn_id, "comment", created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: entitlements; Type: TABLE DATA; Schema: public; Owner: -
--

COPY entitlements (id, user_id, privilege_id, jurisdiction_id, created_at, updated_at) FROM stdin;
1	1	1	80	2008-03-31 09:36:04.880772	2008-03-31 09:36:04.880772
2	1	2	80	2008-03-31 09:36:04.887255	2008-03-31 09:36:04.887255
3	1	3	80	2008-03-31 09:36:04.889434	2008-03-31 09:36:04.889434
4	2	1	80	2008-03-31 09:36:04.898478	2008-03-31 09:36:04.898478
5	2	2	80	2008-03-31 09:36:04.900643	2008-03-31 09:36:04.900643
6	2	3	80	2008-03-31 09:36:04.902782	2008-03-31 09:36:04.902782
7	3	1	80	2008-03-31 09:36:04.911516	2008-03-31 09:36:04.911516
8	3	2	80	2008-03-31 09:36:04.91359	2008-03-31 09:36:04.91359
9	3	3	80	2008-03-31 09:36:04.915649	2008-03-31 09:36:04.915649
10	4	1	80	2008-03-31 09:36:04.924072	2008-03-31 09:36:04.924072
11	4	2	80	2008-03-31 09:36:04.926157	2008-03-31 09:36:04.926157
12	4	3	80	2008-03-31 09:36:04.928198	2008-03-31 09:36:04.928198
13	1	1	79	2008-03-31 09:36:04.958461	2008-03-31 09:36:04.958461
14	1	2	79	2008-03-31 09:36:04.960545	2008-03-31 09:36:04.960545
15	1	3	79	2008-03-31 09:36:04.962681	2008-03-31 09:36:04.962681
16	2	1	79	2008-03-31 09:36:04.971091	2008-03-31 09:36:04.971091
17	2	2	79	2008-03-31 09:36:04.973098	2008-03-31 09:36:04.973098
18	2	3	79	2008-03-31 09:36:04.975073	2008-03-31 09:36:04.975073
19	3	1	79	2008-03-31 09:36:04.983457	2008-03-31 09:36:04.983457
20	3	2	79	2008-03-31 09:36:04.985538	2008-03-31 09:36:04.985538
21	3	3	79	2008-03-31 09:36:04.98771	2008-03-31 09:36:04.98771
22	4	1	79	2008-03-31 09:36:04.9962	2008-03-31 09:36:04.9962
23	4	2	79	2008-03-31 09:36:04.998236	2008-03-31 09:36:04.998236
24	4	3	79	2008-03-31 09:36:05.000353	2008-03-31 09:36:05.000353
25	1	1	78	2008-03-31 09:36:05.031824	2008-03-31 09:36:05.031824
26	1	2	78	2008-03-31 09:36:05.033879	2008-03-31 09:36:05.033879
27	1	3	78	2008-03-31 09:36:05.035927	2008-03-31 09:36:05.035927
28	2	1	78	2008-03-31 09:36:05.044376	2008-03-31 09:36:05.044376
29	2	2	78	2008-03-31 09:36:05.046392	2008-03-31 09:36:05.046392
30	2	3	78	2008-03-31 09:36:05.048416	2008-03-31 09:36:05.048416
31	3	1	78	2008-03-31 09:36:05.056815	2008-03-31 09:36:05.056815
32	3	2	78	2008-03-31 09:36:05.058825	2008-03-31 09:36:05.058825
33	3	3	78	2008-03-31 09:36:05.060804	2008-03-31 09:36:05.060804
34	4	1	78	2008-03-31 09:36:05.069276	2008-03-31 09:36:05.069276
35	4	2	78	2008-03-31 09:36:05.071277	2008-03-31 09:36:05.071277
36	4	3	78	2008-03-31 09:36:05.073251	2008-03-31 09:36:05.073251
37	1	1	77	2008-03-31 09:36:05.10343	2008-03-31 09:36:05.10343
38	1	2	77	2008-03-31 09:36:05.105576	2008-03-31 09:36:05.105576
39	1	3	77	2008-03-31 09:36:05.107624	2008-03-31 09:36:05.107624
40	2	1	77	2008-03-31 09:36:05.116163	2008-03-31 09:36:05.116163
41	2	2	77	2008-03-31 09:36:05.118317	2008-03-31 09:36:05.118317
42	2	3	77	2008-03-31 09:36:05.120355	2008-03-31 09:36:05.120355
43	3	1	77	2008-03-31 09:36:05.128742	2008-03-31 09:36:05.128742
44	3	2	77	2008-03-31 09:36:05.130902	2008-03-31 09:36:05.130902
45	3	3	77	2008-03-31 09:36:05.132936	2008-03-31 09:36:05.132936
46	4	1	77	2008-03-31 09:36:05.141449	2008-03-31 09:36:05.141449
47	4	2	77	2008-03-31 09:36:05.143501	2008-03-31 09:36:05.143501
48	4	3	77	2008-03-31 09:36:05.145541	2008-03-31 09:36:05.145541
49	1	1	76	2008-03-31 09:36:05.175782	2008-03-31 09:36:05.175782
50	1	2	76	2008-03-31 09:36:05.177839	2008-03-31 09:36:05.177839
51	1	3	76	2008-03-31 09:36:05.179895	2008-03-31 09:36:05.179895
52	2	1	76	2008-03-31 09:36:05.188307	2008-03-31 09:36:05.188307
53	2	2	76	2008-03-31 09:36:05.190392	2008-03-31 09:36:05.190392
54	2	3	76	2008-03-31 09:36:05.192449	2008-03-31 09:36:05.192449
55	3	1	76	2008-03-31 09:36:05.200966	2008-03-31 09:36:05.200966
56	3	2	76	2008-03-31 09:36:05.20306	2008-03-31 09:36:05.20306
57	3	3	76	2008-03-31 09:36:05.205253	2008-03-31 09:36:05.205253
58	4	1	76	2008-03-31 09:36:05.215193	2008-03-31 09:36:05.215193
59	4	2	76	2008-03-31 09:36:05.217365	2008-03-31 09:36:05.217365
60	4	3	76	2008-03-31 09:36:05.219397	2008-03-31 09:36:05.219397
61	1	1	75	2008-03-31 09:36:05.28742	2008-03-31 09:36:05.28742
62	1	2	75	2008-03-31 09:36:05.289653	2008-03-31 09:36:05.289653
63	1	3	75	2008-03-31 09:36:05.291948	2008-03-31 09:36:05.291948
64	2	1	75	2008-03-31 09:36:05.300849	2008-03-31 09:36:05.300849
65	2	2	75	2008-03-31 09:36:05.302994	2008-03-31 09:36:05.302994
66	2	3	75	2008-03-31 09:36:05.30506	2008-03-31 09:36:05.30506
67	3	1	75	2008-03-31 09:36:05.31403	2008-03-31 09:36:05.31403
68	3	2	75	2008-03-31 09:36:05.316228	2008-03-31 09:36:05.316228
69	3	3	75	2008-03-31 09:36:05.318428	2008-03-31 09:36:05.318428
70	4	1	75	2008-03-31 09:36:05.327048	2008-03-31 09:36:05.327048
71	4	2	75	2008-03-31 09:36:05.329167	2008-03-31 09:36:05.329167
72	4	3	75	2008-03-31 09:36:05.331218	2008-03-31 09:36:05.331218
73	1	1	74	2008-03-31 09:36:05.361706	2008-03-31 09:36:05.361706
74	1	2	74	2008-03-31 09:36:05.363789	2008-03-31 09:36:05.363789
75	1	3	74	2008-03-31 09:36:05.3658	2008-03-31 09:36:05.3658
76	2	1	74	2008-03-31 09:36:05.374282	2008-03-31 09:36:05.374282
77	2	2	74	2008-03-31 09:36:05.3763	2008-03-31 09:36:05.3763
78	2	3	74	2008-03-31 09:36:05.378342	2008-03-31 09:36:05.378342
79	3	1	74	2008-03-31 09:36:05.386758	2008-03-31 09:36:05.386758
80	3	2	74	2008-03-31 09:36:05.388838	2008-03-31 09:36:05.388838
81	3	3	74	2008-03-31 09:36:05.390905	2008-03-31 09:36:05.390905
82	4	1	74	2008-03-31 09:36:05.399279	2008-03-31 09:36:05.399279
83	4	2	74	2008-03-31 09:36:05.40129	2008-03-31 09:36:05.40129
84	4	3	74	2008-03-31 09:36:05.403298	2008-03-31 09:36:05.403298
85	1	1	73	2008-03-31 09:36:05.43301	2008-03-31 09:36:05.43301
86	1	2	73	2008-03-31 09:36:05.435079	2008-03-31 09:36:05.435079
87	1	3	73	2008-03-31 09:36:05.437075	2008-03-31 09:36:05.437075
88	2	1	73	2008-03-31 09:36:05.445376	2008-03-31 09:36:05.445376
89	2	2	73	2008-03-31 09:36:05.447444	2008-03-31 09:36:05.447444
90	2	3	73	2008-03-31 09:36:05.449474	2008-03-31 09:36:05.449474
91	3	1	73	2008-03-31 09:36:05.457803	2008-03-31 09:36:05.457803
92	3	2	73	2008-03-31 09:36:05.459855	2008-03-31 09:36:05.459855
93	3	3	73	2008-03-31 09:36:05.461817	2008-03-31 09:36:05.461817
94	4	1	73	2008-03-31 09:36:05.470143	2008-03-31 09:36:05.470143
95	4	2	73	2008-03-31 09:36:05.472161	2008-03-31 09:36:05.472161
96	4	3	73	2008-03-31 09:36:05.474158	2008-03-31 09:36:05.474158
97	1	1	72	2008-03-31 09:36:05.50414	2008-03-31 09:36:05.50414
98	1	2	72	2008-03-31 09:36:05.50617	2008-03-31 09:36:05.50617
99	1	3	72	2008-03-31 09:36:05.508211	2008-03-31 09:36:05.508211
100	2	1	72	2008-03-31 09:36:05.516564	2008-03-31 09:36:05.516564
101	2	2	72	2008-03-31 09:36:05.51867	2008-03-31 09:36:05.51867
102	2	3	72	2008-03-31 09:36:05.520641	2008-03-31 09:36:05.520641
103	3	1	72	2008-03-31 09:36:05.528971	2008-03-31 09:36:05.528971
104	3	2	72	2008-03-31 09:36:05.531062	2008-03-31 09:36:05.531062
105	3	3	72	2008-03-31 09:36:05.533059	2008-03-31 09:36:05.533059
106	4	1	72	2008-03-31 09:36:05.541503	2008-03-31 09:36:05.541503
107	4	2	72	2008-03-31 09:36:05.543532	2008-03-31 09:36:05.543532
108	4	3	72	2008-03-31 09:36:05.545528	2008-03-31 09:36:05.545528
109	1	1	71	2008-03-31 09:36:05.575391	2008-03-31 09:36:05.575391
110	1	2	71	2008-03-31 09:36:05.577435	2008-03-31 09:36:05.577435
111	1	3	71	2008-03-31 09:36:05.579443	2008-03-31 09:36:05.579443
112	2	1	71	2008-03-31 09:36:05.587723	2008-03-31 09:36:05.587723
113	2	2	71	2008-03-31 09:36:05.589764	2008-03-31 09:36:05.589764
114	2	3	71	2008-03-31 09:36:05.591821	2008-03-31 09:36:05.591821
115	3	1	71	2008-03-31 09:36:05.600095	2008-03-31 09:36:05.600095
116	3	2	71	2008-03-31 09:36:05.602223	2008-03-31 09:36:05.602223
117	3	3	71	2008-03-31 09:36:05.60422	2008-03-31 09:36:05.60422
118	4	1	71	2008-03-31 09:36:05.612541	2008-03-31 09:36:05.612541
119	4	2	71	2008-03-31 09:36:05.614598	2008-03-31 09:36:05.614598
120	4	3	71	2008-03-31 09:36:05.616588	2008-03-31 09:36:05.616588
121	1	1	70	2008-03-31 09:36:05.647064	2008-03-31 09:36:05.647064
122	1	2	70	2008-03-31 09:36:05.649228	2008-03-31 09:36:05.649228
123	1	3	70	2008-03-31 09:36:05.651457	2008-03-31 09:36:05.651457
124	2	1	70	2008-03-31 09:36:05.699972	2008-03-31 09:36:05.699972
125	2	2	70	2008-03-31 09:36:05.702233	2008-03-31 09:36:05.702233
126	2	3	70	2008-03-31 09:36:05.704384	2008-03-31 09:36:05.704384
127	3	1	70	2008-03-31 09:36:05.713237	2008-03-31 09:36:05.713237
128	3	2	70	2008-03-31 09:36:05.715352	2008-03-31 09:36:05.715352
129	3	3	70	2008-03-31 09:36:05.71751	2008-03-31 09:36:05.71751
130	4	1	70	2008-03-31 09:36:05.726048	2008-03-31 09:36:05.726048
131	4	2	70	2008-03-31 09:36:05.728177	2008-03-31 09:36:05.728177
132	4	3	70	2008-03-31 09:36:05.73026	2008-03-31 09:36:05.73026
133	1	1	69	2008-03-31 09:36:05.761133	2008-03-31 09:36:05.761133
134	1	2	69	2008-03-31 09:36:05.763239	2008-03-31 09:36:05.763239
135	1	3	69	2008-03-31 09:36:05.765282	2008-03-31 09:36:05.765282
136	2	1	69	2008-03-31 09:36:05.773819	2008-03-31 09:36:05.773819
137	2	2	69	2008-03-31 09:36:05.775914	2008-03-31 09:36:05.775914
138	2	3	69	2008-03-31 09:36:05.777942	2008-03-31 09:36:05.777942
139	3	1	69	2008-03-31 09:36:05.786492	2008-03-31 09:36:05.786492
140	3	2	69	2008-03-31 09:36:05.78864	2008-03-31 09:36:05.78864
141	3	3	69	2008-03-31 09:36:05.790809	2008-03-31 09:36:05.790809
142	4	1	69	2008-03-31 09:36:05.799169	2008-03-31 09:36:05.799169
143	4	2	69	2008-03-31 09:36:05.801289	2008-03-31 09:36:05.801289
144	4	3	69	2008-03-31 09:36:05.80336	2008-03-31 09:36:05.80336
145	1	1	68	2008-03-31 09:36:05.834185	2008-03-31 09:36:05.834185
146	1	2	68	2008-03-31 09:36:05.836349	2008-03-31 09:36:05.836349
147	1	3	68	2008-03-31 09:36:05.838449	2008-03-31 09:36:05.838449
148	2	1	68	2008-03-31 09:36:05.846937	2008-03-31 09:36:05.846937
149	2	2	68	2008-03-31 09:36:05.849017	2008-03-31 09:36:05.849017
150	2	3	68	2008-03-31 09:36:05.851107	2008-03-31 09:36:05.851107
151	3	1	68	2008-03-31 09:36:05.859432	2008-03-31 09:36:05.859432
152	3	2	68	2008-03-31 09:36:05.861474	2008-03-31 09:36:05.861474
153	3	3	68	2008-03-31 09:36:05.863533	2008-03-31 09:36:05.863533
154	4	1	68	2008-03-31 09:36:05.871857	2008-03-31 09:36:05.871857
155	4	2	68	2008-03-31 09:36:05.873859	2008-03-31 09:36:05.873859
156	4	3	68	2008-03-31 09:36:05.875919	2008-03-31 09:36:05.875919
157	1	1	67	2008-03-31 09:36:05.905938	2008-03-31 09:36:05.905938
158	1	2	67	2008-03-31 09:36:05.908051	2008-03-31 09:36:05.908051
159	1	3	67	2008-03-31 09:36:05.910174	2008-03-31 09:36:05.910174
160	2	1	67	2008-03-31 09:36:05.918547	2008-03-31 09:36:05.918547
161	2	2	67	2008-03-31 09:36:05.920575	2008-03-31 09:36:05.920575
162	2	3	67	2008-03-31 09:36:05.922608	2008-03-31 09:36:05.922608
163	3	1	67	2008-03-31 09:36:05.93104	2008-03-31 09:36:05.93104
164	3	2	67	2008-03-31 09:36:05.933062	2008-03-31 09:36:05.933062
165	3	3	67	2008-03-31 09:36:05.935142	2008-03-31 09:36:05.935142
166	4	1	67	2008-03-31 09:36:05.94348	2008-03-31 09:36:05.94348
167	4	2	67	2008-03-31 09:36:05.945475	2008-03-31 09:36:05.945475
168	4	3	67	2008-03-31 09:36:05.947561	2008-03-31 09:36:05.947561
\.


--
-- Data for Name: entity_groups; Type: TABLE DATA; Schema: public; Owner: -
--

COPY entity_groups (id, entity_group_type_id, primary_entity_id, secondary_entity_id, entity_group_name, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: events; Type: TABLE DATA; Schema: public; Owner: -
--

COPY events (id, event_status_id, imported_from_id, event_case_status_id, event_name, event_onset_date, created_at, updated_at, outbreak_associated_id, outbreak_name, "investigation_LHD_status_id", investigation_started_date, "investigation_completed_LHD_date", "review_completed_UDOH_date", "first_reported_PH_date", results_reported_to_clinician_date, record_number, "MMWR_week", "MMWR_year") FROM stdin;
\.


--
-- Data for Name: hospitals_participations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY hospitals_participations (id, participation_id, hospital_record_number, admission_date, discharge_date, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: lab_results; Type: TABLE DATA; Schema: public; Owner: -
--

COPY lab_results (id, event_id, specimen_source_id, collection_date, lab_test_date, tested_at_uphl_yn_id, lab_result_text, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: laboratories; Type: TABLE DATA; Schema: public; Owner: -
--

COPY laboratories (id, entity_id, laboratory_name, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: locations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY locations (id, location_url_number) FROM stdin;
\.


--
-- Data for Name: materials; Type: TABLE DATA; Schema: public; Owner: -
--

COPY materials (id, entity_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: observations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY observations (id, event_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY organizations (id, entity_id, organization_type_id, organization_status_id, organization_name, duration_start_date, duration_end_date, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: participations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY participations (id, primary_entity_id, secondary_entity_id, role_id, participation_status_id, "comment", created_at, updated_at, event_id) FROM stdin;
\.


--
-- Data for Name: participations_risk_factors; Type: TABLE DATA; Schema: public; Owner: -
--

COPY participations_risk_factors (id, participation_id, food_handler_id, healthcare_worker_id, group_living_id, day_care_association_id, pregnant_id, pregnancy_due_date, risk_factors, risk_factors_notes, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: participations_treatments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY participations_treatments (id, participation_id, treatment_id, treatment_given_yn_id, treatment_date, created_at, updated_at, treatment) FROM stdin;
\.


--
-- Data for Name: people; Type: TABLE DATA; Schema: public; Owner: -
--

COPY people (id, entity_id, birth_gender_id, ethnicity_id, primary_language_id, first_name, middle_name, last_name, birth_date, date_of_death, created_at, updated_at, food_handler_id, age_type_id, approximate_age_no_birthday, first_name_soundex, last_name_soundex, vector) FROM stdin;
\.


--
-- Data for Name: people_races; Type: TABLE DATA; Schema: public; Owner: -
--

COPY people_races (race_id, entity_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: pg_ts_cfg; Type: TABLE DATA; Schema: public; Owner: -
--

COPY pg_ts_cfg (ts_name, prs_name, locale) FROM stdin;
default_russian	default	ru_RU.KOI8-R
utf8_russian	default	ru_RU.UTF-8
simple	default	\N
default	default	en_CA.UTF-8
\.


--
-- Data for Name: pg_ts_cfgmap; Type: TABLE DATA; Schema: public; Owner: -
--

COPY pg_ts_cfgmap (ts_name, tok_alias, dict_name) FROM stdin;
default	lword	{en_stem}
default	nlword	{simple}
default	word	{simple}
default	email	{simple}
default	url	{simple}
default	host	{simple}
default	sfloat	{simple}
default	version	{simple}
default	part_hword	{simple}
default	nlpart_hword	{simple}
default	lpart_hword	{en_stem}
default	hword	{simple}
default	lhword	{en_stem}
default	nlhword	{simple}
default	uri	{simple}
default	file	{simple}
default	float	{simple}
default	int	{simple}
default	uint	{simple}
default_russian	lword	{en_stem}
default_russian	nlword	{ru_stem_koi8}
default_russian	word	{ru_stem_koi8}
default_russian	email	{simple}
default_russian	url	{simple}
default_russian	host	{simple}
default_russian	sfloat	{simple}
default_russian	version	{simple}
default_russian	part_hword	{simple}
default_russian	nlpart_hword	{ru_stem_koi8}
default_russian	lpart_hword	{en_stem}
default_russian	hword	{ru_stem_koi8}
default_russian	lhword	{en_stem}
default_russian	nlhword	{ru_stem_koi8}
default_russian	uri	{simple}
default_russian	file	{simple}
default_russian	float	{simple}
default_russian	int	{simple}
default_russian	uint	{simple}
utf8_russian	lword	{en_stem}
utf8_russian	nlword	{ru_stem_utf8}
utf8_russian	word	{ru_stem_utf8}
utf8_russian	email	{simple}
utf8_russian	url	{simple}
utf8_russian	host	{simple}
utf8_russian	sfloat	{simple}
utf8_russian	version	{simple}
utf8_russian	part_hword	{simple}
utf8_russian	nlpart_hword	{ru_stem_utf8}
utf8_russian	lpart_hword	{en_stem}
utf8_russian	hword	{ru_stem_utf8}
utf8_russian	lhword	{en_stem}
utf8_russian	nlhword	{ru_stem_utf8}
utf8_russian	uri	{simple}
utf8_russian	file	{simple}
utf8_russian	float	{simple}
utf8_russian	int	{simple}
utf8_russian	uint	{simple}
simple	lword	{simple}
simple	nlword	{simple}
simple	word	{simple}
simple	email	{simple}
simple	url	{simple}
simple	host	{simple}
simple	sfloat	{simple}
simple	version	{simple}
simple	part_hword	{simple}
simple	nlpart_hword	{simple}
simple	lpart_hword	{simple}
simple	hword	{simple}
simple	lhword	{simple}
simple	nlhword	{simple}
simple	uri	{simple}
simple	file	{simple}
simple	float	{simple}
simple	int	{simple}
simple	uint	{simple}
\.


--
-- Data for Name: pg_ts_dict; Type: TABLE DATA; Schema: public; Owner: -
--

COPY pg_ts_dict (dict_name, dict_init, dict_initoption, dict_lexize, dict_comment) FROM stdin;
simple	dex_init(internal)	\N	dex_lexize(internal,internal,integer)	Simple example of dictionary.
en_stem	snb_en_init(internal)	contrib/english.stop	snb_lexize(internal,internal,integer)	English Stemmer. Snowball.
ru_stem_koi8	snb_ru_init_koi8(internal)	contrib/russian.stop	snb_lexize(internal,internal,integer)	Russian Stemmer. Snowball. KOI8 Encoding
ru_stem_utf8	snb_ru_init_utf8(internal)	contrib/russian.stop.utf8	snb_lexize(internal,internal,integer)	Russian Stemmer. Snowball. UTF8 Encoding
ispell_template	spell_init(internal)	\N	spell_lexize(internal,internal,integer)	ISpell interface. Must have .dict and .aff files
synonym	syn_init(internal)	\N	syn_lexize(internal,internal,integer)	Example of synonym dictionary
thesaurus_template	thesaurus_init(internal)	\N	thesaurus_lexize(internal,internal,integer,internal)	Thesaurus template, must be pointed Dictionary and DictFile
\.


--
-- Data for Name: pg_ts_parser; Type: TABLE DATA; Schema: public; Owner: -
--

COPY pg_ts_parser (prs_name, prs_start, prs_nexttoken, prs_end, prs_headline, prs_lextype, prs_comment) FROM stdin;
default	prsd_start(internal,integer)	prsd_getlexeme(internal,internal,internal)	prsd_end(internal)	prsd_headline(internal,internal,internal)	prsd_lextype(internal)	Parser from OpenFTS v0.34
\.


--
-- Data for Name: places; Type: TABLE DATA; Schema: public; Owner: -
--

COPY places (id, entity_id, created_at, updated_at, place_type_id, name, short_name) FROM stdin;
1	1	2008-03-31 09:36:03.885001	2008-03-31 09:36:03.885001	183	Allen Memorial Hospital	\N
2	2	2008-03-31 09:36:03.897353	2008-03-31 09:36:03.897353	183	Alta View Hospital	\N
3	3	2008-03-31 09:36:03.905678	2008-03-31 09:36:03.905678	183	American Fork Hospital	\N
4	4	2008-03-31 09:36:03.91385	2008-03-31 09:36:03.91385	183	Ashley Regional Medical Center	\N
5	5	2008-03-31 09:36:03.922094	2008-03-31 09:36:03.922094	183	Bear River Valley Hospital	\N
6	6	2008-03-31 09:36:03.930306	2008-03-31 09:36:03.930306	183	Beaver Valley Hospital	\N
7	7	2008-03-31 09:36:03.971954	2008-03-31 09:36:03.971954	183	Brigham City Community Hospital	\N
8	8	2008-03-31 09:36:03.980519	2008-03-31 09:36:03.980519	183	Cache Valley Specialty Hospital	\N
9	9	2008-03-31 09:36:03.989558	2008-03-31 09:36:03.989558	183	Castleview Hospital	\N
10	10	2008-03-31 09:36:03.998433	2008-03-31 09:36:03.998433	183	Center For Change, Inc	\N
11	11	2008-03-31 09:36:04.00728	2008-03-31 09:36:04.00728	183	Central Valley Medical Center	\N
12	12	2008-03-31 09:36:04.024018	2008-03-31 09:36:04.024018	183	CHRISTUS St Joseph Villa	\N
13	13	2008-03-31 09:36:04.032997	2008-03-31 09:36:04.032997	183	Davis Hospital and Medical Center	\N
14	14	2008-03-31 09:36:04.041797	2008-03-31 09:36:04.041797	183	Delta Community Medical Center	\N
15	15	2008-03-31 09:36:04.049871	2008-03-31 09:36:04.049871	183	Dixie Regional Medical Center	\N
16	16	2008-03-31 09:36:04.058505	2008-03-31 09:36:04.058505	183	Fillmore Community Medical Center	\N
17	17	2008-03-31 09:36:04.067075	2008-03-31 09:36:04.067075	183	Garfield Memorial Hospital	\N
18	18	2008-03-31 09:36:04.075078	2008-03-31 09:36:04.075078	183	Gunnison Valley Hospital	\N
19	19	2008-03-31 09:36:04.08375	2008-03-31 09:36:04.08375	183	Health South Rehab/Hospital of Utah	\N
20	20	2008-03-31 09:36:04.09183	2008-03-31 09:36:04.09183	183	HealthSouth Rehab/Specialty Hospital of Utah	\N
21	21	2008-03-31 09:36:04.099937	2008-03-31 09:36:04.099937	183	Heber Valley Medical Center	\N
22	22	2008-03-31 09:36:04.108136	2008-03-31 09:36:04.108136	183	Huntsman Cancer Hospital	\N
23	23	2008-03-31 09:36:04.116717	2008-03-31 09:36:04.116717	183	Intermountain Medical Center	\N
24	24	2008-03-31 09:36:04.12469	2008-03-31 09:36:04.12469	183	Jordan Valley Hospital	\N
25	25	2008-03-31 09:36:04.132533	2008-03-31 09:36:04.132533	183	Kane County Hospital	\N
26	26	2008-03-31 09:36:04.141018	2008-03-31 09:36:04.141018	183	Lakeview Hospital	\N
27	27	2008-03-31 09:36:04.148978	2008-03-31 09:36:04.148978	183	LDS Hospital	\N
28	28	2008-03-31 09:36:04.191661	2008-03-31 09:36:04.191661	183	Logan Regional Medical Center	\N
29	29	2008-03-31 09:36:04.200363	2008-03-31 09:36:04.200363	183	McKay-Dee Hospital Center	\N
30	30	2008-03-31 09:36:04.20926	2008-03-31 09:36:04.20926	183	Milford Valley Healthcare Services	\N
31	31	2008-03-31 09:36:04.218173	2008-03-31 09:36:04.218173	183	Mountain West Medical Center	\N
32	32	2008-03-31 09:36:04.226931	2008-03-31 09:36:04.226931	183	Mountain View Hospital	\N
33	33	2008-03-31 09:36:04.235735	2008-03-31 09:36:04.235735	183	Ogden Regional Medical Center	\N
34	34	2008-03-31 09:36:04.244449	2008-03-31 09:36:04.244449	183	Orem Community Hospital	\N
35	35	2008-03-31 09:36:04.252887	2008-03-31 09:36:04.252887	183	Pioneer Valley Hospital	\N
36	36	2008-03-31 09:36:04.261393	2008-03-31 09:36:04.261393	183	Primary Children's Medical Center	\N
37	37	2008-03-31 09:36:04.269783	2008-03-31 09:36:04.269783	183	Promise Hospital of Salt Lake	\N
38	38	2008-03-31 09:36:04.278435	2008-03-31 09:36:04.278435	183	Salt Lake Regional Medical Center	\N
39	39	2008-03-31 09:36:04.286992	2008-03-31 09:36:04.286992	183	San Juan Hospital	\N
40	40	2008-03-31 09:36:04.295351	2008-03-31 09:36:04.295351	183	Sanpete Valley Hospital	\N
41	41	2008-03-31 09:36:04.303869	2008-03-31 09:36:04.303869	183	Sevier Valley Medical Center	\N
42	42	2008-03-31 09:36:04.31217	2008-03-31 09:36:04.31217	183	Shriners Hospital for Children	\N
43	43	2008-03-31 09:36:04.320693	2008-03-31 09:36:04.320693	183	Surg-Alpine Surgical Center, LLC	\N
44	44	2008-03-31 09:36:04.32907	2008-03-31 09:36:04.32907	183	Surg-Central Utah Surgical Center	\N
45	45	2008-03-31 09:36:04.337549	2008-03-31 09:36:04.337549	183	Surg-Coral Desert Surgery Center	\N
46	46	2008-03-31 09:36:04.345987	2008-03-31 09:36:04.345987	183	Endo-Northern Utah Endoscopy Center, LLC	\N
47	47	2008-03-31 09:36:04.354513	2008-03-31 09:36:04.354513	183	Surg-Healthsouth Salt Lake Surgical Center	\N
48	48	2008-03-31 09:36:04.362853	2008-03-31 09:36:04.362853	183	Surg-Healthsouth Park City Surgical Center	\N
49	49	2008-03-31 09:36:04.398534	2008-03-31 09:36:04.398534	183	Surg-Intermountain Surgical Center	\N
50	50	2008-03-31 09:36:04.414537	2008-03-31 09:36:04.414537	183	Surg-Mt. Ogden Surgical Center	\N
51	51	2008-03-31 09:36:04.42342	2008-03-31 09:36:04.42342	183	Surg-St. George Surgical Center, LP	\N
52	52	2008-03-31 09:36:04.432346	2008-03-31 09:36:04.432346	183	Surg-St. Mark's Outpatient Surgery Center	\N
53	53	2008-03-31 09:36:04.441211	2008-03-31 09:36:04.441211	183	South Davis Community Hospital	\N
54	54	2008-03-31 09:36:04.449771	2008-03-31 09:36:04.449771	183	Silverado Senior Living Aspen Park	\N
55	55	2008-03-31 09:36:04.458487	2008-03-31 09:36:04.458487	183	St. Marks Hospital	\N
56	56	2008-03-31 09:36:04.466878	2008-03-31 09:36:04.466878	183	Summit Hospital	\N
57	57	2008-03-31 09:36:04.475548	2008-03-31 09:36:04.475548	183	The Orthopedic Speciality Hospital	\N
58	58	2008-03-31 09:36:04.483889	2008-03-31 09:36:04.483889	183	Timpanogos Regional Hospital	\N
59	59	2008-03-31 09:36:04.492781	2008-03-31 09:36:04.492781	183	Utah State Hospital	\N
60	60	2008-03-31 09:36:04.501498	2008-03-31 09:36:04.501498	183	University Neuropsychiatric Institute	\N
61	61	2008-03-31 09:36:04.509902	2008-03-31 09:36:04.509902	183	University Hospital	\N
62	62	2008-03-31 09:36:04.518185	2008-03-31 09:36:04.518185	183	Utah Valley Specialty Hospital	\N
63	63	2008-03-31 09:36:04.526655	2008-03-31 09:36:04.526655	183	Uintah Basin Medical Center	\N
64	64	2008-03-31 09:36:04.535212	2008-03-31 09:36:04.535212	183	Utah Valley Regional Medical Center	\N
65	65	2008-03-31 09:36:04.543705	2008-03-31 09:36:04.543705	183	Veteran's Medcial Center	\N
66	66	2008-03-31 09:36:04.552076	2008-03-31 09:36:04.552076	183	Valley View Medical Center	\N
67	67	2008-03-31 09:36:04.568364	2008-03-31 09:36:04.568364	184	Bear River Health Department	\N
68	68	2008-03-31 09:36:04.576542	2008-03-31 09:36:04.576542	184	Central Utah Public Health Department	\N
69	69	2008-03-31 09:36:04.585114	2008-03-31 09:36:04.585114	184	Davis County Health Department	\N
70	70	2008-03-31 09:36:04.593433	2008-03-31 09:36:04.593433	184	Salt Lake Valley Health Department	\N
71	71	2008-03-31 09:36:04.636697	2008-03-31 09:36:04.636697	184	Southeastern Utah District Health Department	\N
72	72	2008-03-31 09:36:04.645528	2008-03-31 09:36:04.645528	184	Southwest Utah Public Health Department	\N
73	73	2008-03-31 09:36:04.654435	2008-03-31 09:36:04.654435	184	Summit County Public Health Department	\N
74	74	2008-03-31 09:36:04.663175	2008-03-31 09:36:04.663175	184	Tooele County Health Department	\N
75	75	2008-03-31 09:36:04.671701	2008-03-31 09:36:04.671701	184	TriCounty Health Department	\N
76	76	2008-03-31 09:36:04.680372	2008-03-31 09:36:04.680372	184	Utah County Health Department	\N
77	77	2008-03-31 09:36:04.688968	2008-03-31 09:36:04.688968	184	Utah State	\N
78	78	2008-03-31 09:36:04.697419	2008-03-31 09:36:04.697419	184	Wasatch County Health Department	\N
79	79	2008-03-31 09:36:04.705926	2008-03-31 09:36:04.705926	184	Weber-Morgan Health Department	\N
80	80	2008-03-31 09:36:04.714375	2008-03-31 09:36:04.714375	184	Out of State	\N
\.


--
-- Data for Name: privileges; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "privileges" (id, priv_name, description) FROM stdin;
1	view	\N
2	update	\N
3	administer	\N
\.


--
-- Data for Name: privileges_roles; Type: TABLE DATA; Schema: public; Owner: -
--

COPY privileges_roles (id, role_id, privilege_id, jurisdiction_id, created_at, updated_at) FROM stdin;
1	1	1	80	2008-03-31 09:36:04.808841	2008-03-31 09:36:04.808841
2	1	2	80	2008-03-31 09:36:04.815887	2008-03-31 09:36:04.815887
3	1	3	80	2008-03-31 09:36:04.819018	2008-03-31 09:36:04.819018
4	2	1	80	2008-03-31 09:36:04.931329	2008-03-31 09:36:04.931329
5	2	2	80	2008-03-31 09:36:04.934557	2008-03-31 09:36:04.934557
6	1	1	79	2008-03-31 09:36:04.944089	2008-03-31 09:36:04.944089
7	1	2	79	2008-03-31 09:36:04.947127	2008-03-31 09:36:04.947127
8	1	3	79	2008-03-31 09:36:04.950201	2008-03-31 09:36:04.950201
9	2	1	79	2008-03-31 09:36:05.003566	2008-03-31 09:36:05.003566
10	2	2	79	2008-03-31 09:36:05.006929	2008-03-31 09:36:05.006929
11	1	1	78	2008-03-31 09:36:05.017453	2008-03-31 09:36:05.017453
12	1	2	78	2008-03-31 09:36:05.020524	2008-03-31 09:36:05.020524
13	1	3	78	2008-03-31 09:36:05.023553	2008-03-31 09:36:05.023553
14	2	1	78	2008-03-31 09:36:05.076333	2008-03-31 09:36:05.076333
15	2	2	78	2008-03-31 09:36:05.079378	2008-03-31 09:36:05.079378
16	1	1	77	2008-03-31 09:36:05.088979	2008-03-31 09:36:05.088979
17	1	2	77	2008-03-31 09:36:05.092102	2008-03-31 09:36:05.092102
18	1	3	77	2008-03-31 09:36:05.09508	2008-03-31 09:36:05.09508
19	2	1	77	2008-03-31 09:36:05.148673	2008-03-31 09:36:05.148673
20	2	2	77	2008-03-31 09:36:05.151883	2008-03-31 09:36:05.151883
21	1	1	76	2008-03-31 09:36:05.16131	2008-03-31 09:36:05.16131
22	1	2	76	2008-03-31 09:36:05.164342	2008-03-31 09:36:05.164342
23	1	3	76	2008-03-31 09:36:05.167345	2008-03-31 09:36:05.167345
24	2	1	76	2008-03-31 09:36:05.222498	2008-03-31 09:36:05.222498
25	2	2	76	2008-03-31 09:36:05.225605	2008-03-31 09:36:05.225605
26	1	1	75	2008-03-31 09:36:05.23614	2008-03-31 09:36:05.23614
27	1	2	75	2008-03-31 09:36:05.239351	2008-03-31 09:36:05.239351
28	1	3	75	2008-03-31 09:36:05.277389	2008-03-31 09:36:05.277389
29	2	1	75	2008-03-31 09:36:05.334452	2008-03-31 09:36:05.334452
30	2	2	75	2008-03-31 09:36:05.337505	2008-03-31 09:36:05.337505
31	1	1	74	2008-03-31 09:36:05.346986	2008-03-31 09:36:05.346986
32	1	2	74	2008-03-31 09:36:05.350311	2008-03-31 09:36:05.350311
33	1	3	74	2008-03-31 09:36:05.353416	2008-03-31 09:36:05.353416
34	2	1	74	2008-03-31 09:36:05.406379	2008-03-31 09:36:05.406379
35	2	2	74	2008-03-31 09:36:05.409359	2008-03-31 09:36:05.409359
36	1	1	73	2008-03-31 09:36:05.41883	2008-03-31 09:36:05.41883
37	1	2	73	2008-03-31 09:36:05.421811	2008-03-31 09:36:05.421811
38	1	3	73	2008-03-31 09:36:05.424782	2008-03-31 09:36:05.424782
39	2	1	73	2008-03-31 09:36:05.47721	2008-03-31 09:36:05.47721
40	2	2	73	2008-03-31 09:36:05.48023	2008-03-31 09:36:05.48023
41	1	1	72	2008-03-31 09:36:05.489781	2008-03-31 09:36:05.489781
42	1	2	72	2008-03-31 09:36:05.49284	2008-03-31 09:36:05.49284
43	1	3	72	2008-03-31 09:36:05.495815	2008-03-31 09:36:05.495815
44	2	1	72	2008-03-31 09:36:05.548661	2008-03-31 09:36:05.548661
45	2	2	72	2008-03-31 09:36:05.551847	2008-03-31 09:36:05.551847
46	1	1	71	2008-03-31 09:36:05.561206	2008-03-31 09:36:05.561206
47	1	2	71	2008-03-31 09:36:05.564214	2008-03-31 09:36:05.564214
48	1	3	71	2008-03-31 09:36:05.567199	2008-03-31 09:36:05.567199
49	2	1	71	2008-03-31 09:36:05.619701	2008-03-31 09:36:05.619701
50	2	2	71	2008-03-31 09:36:05.622715	2008-03-31 09:36:05.622715
51	1	1	70	2008-03-31 09:36:05.632218	2008-03-31 09:36:05.632218
52	1	2	70	2008-03-31 09:36:05.635286	2008-03-31 09:36:05.635286
53	1	3	70	2008-03-31 09:36:05.638396	2008-03-31 09:36:05.638396
54	2	1	70	2008-03-31 09:36:05.73339	2008-03-31 09:36:05.73339
55	2	2	70	2008-03-31 09:36:05.736611	2008-03-31 09:36:05.736611
56	1	1	69	2008-03-31 09:36:05.746402	2008-03-31 09:36:05.746402
57	1	2	69	2008-03-31 09:36:05.749517	2008-03-31 09:36:05.749517
58	1	3	69	2008-03-31 09:36:05.752709	2008-03-31 09:36:05.752709
59	2	1	69	2008-03-31 09:36:05.80655	2008-03-31 09:36:05.80655
60	2	2	69	2008-03-31 09:36:05.809545	2008-03-31 09:36:05.809545
61	1	1	68	2008-03-31 09:36:05.818967	2008-03-31 09:36:05.818967
62	1	2	68	2008-03-31 09:36:05.821961	2008-03-31 09:36:05.821961
63	1	3	68	2008-03-31 09:36:05.82499	2008-03-31 09:36:05.82499
64	2	1	68	2008-03-31 09:36:05.878994	2008-03-31 09:36:05.878994
65	2	2	68	2008-03-31 09:36:05.881985	2008-03-31 09:36:05.881985
66	1	1	67	2008-03-31 09:36:05.891531	2008-03-31 09:36:05.891531
67	1	2	67	2008-03-31 09:36:05.894615	2008-03-31 09:36:05.894615
68	1	3	67	2008-03-31 09:36:05.897571	2008-03-31 09:36:05.897571
69	2	1	67	2008-03-31 09:36:05.950812	2008-03-31 09:36:05.950812
70	2	2	67	2008-03-31 09:36:05.953831	2008-03-31 09:36:05.953831
\.


--
-- Data for Name: referrals; Type: TABLE DATA; Schema: public; Owner: -
--

COPY referrals (id, event_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: role_memberships; Type: TABLE DATA; Schema: public; Owner: -
--

COPY role_memberships (id, user_id, role_id, jurisdiction_id, created_at, updated_at) FROM stdin;
1	1	1	80	2008-03-31 09:36:04.825674	2008-03-31 09:36:04.825674
2	2	1	80	2008-03-31 09:36:04.893057	2008-03-31 09:36:04.893057
3	3	1	80	2008-03-31 09:36:04.906086	2008-03-31 09:36:04.906086
4	4	1	80	2008-03-31 09:36:04.91895	2008-03-31 09:36:04.91895
5	1	1	79	2008-03-31 09:36:04.953338	2008-03-31 09:36:04.953338
6	2	1	79	2008-03-31 09:36:04.965883	2008-03-31 09:36:04.965883
7	3	1	79	2008-03-31 09:36:04.97827	2008-03-31 09:36:04.97827
8	4	1	79	2008-03-31 09:36:04.990969	2008-03-31 09:36:04.990969
9	1	1	78	2008-03-31 09:36:05.026701	2008-03-31 09:36:05.026701
10	2	1	78	2008-03-31 09:36:05.039259	2008-03-31 09:36:05.039259
11	3	1	78	2008-03-31 09:36:05.051752	2008-03-31 09:36:05.051752
12	4	1	78	2008-03-31 09:36:05.064109	2008-03-31 09:36:05.064109
13	1	1	77	2008-03-31 09:36:05.098233	2008-03-31 09:36:05.098233
14	2	1	77	2008-03-31 09:36:05.110884	2008-03-31 09:36:05.110884
15	3	1	77	2008-03-31 09:36:05.123551	2008-03-31 09:36:05.123551
16	4	1	77	2008-03-31 09:36:05.136196	2008-03-31 09:36:05.136196
17	1	1	76	2008-03-31 09:36:05.170597	2008-03-31 09:36:05.170597
18	2	1	76	2008-03-31 09:36:05.183121	2008-03-31 09:36:05.183121
19	3	1	76	2008-03-31 09:36:05.195691	2008-03-31 09:36:05.195691
20	4	1	76	2008-03-31 09:36:05.209924	2008-03-31 09:36:05.209924
21	1	1	75	2008-03-31 09:36:05.281875	2008-03-31 09:36:05.281875
22	2	1	75	2008-03-31 09:36:05.29547	2008-03-31 09:36:05.29547
23	3	1	75	2008-03-31 09:36:05.308423	2008-03-31 09:36:05.308423
24	4	1	75	2008-03-31 09:36:05.321761	2008-03-31 09:36:05.321761
25	1	1	74	2008-03-31 09:36:05.356579	2008-03-31 09:36:05.356579
26	2	1	74	2008-03-31 09:36:05.36915	2008-03-31 09:36:05.36915
27	3	1	74	2008-03-31 09:36:05.381536	2008-03-31 09:36:05.381536
28	4	1	74	2008-03-31 09:36:05.394096	2008-03-31 09:36:05.394096
29	1	1	73	2008-03-31 09:36:05.427935	2008-03-31 09:36:05.427935
30	2	1	73	2008-03-31 09:36:05.440353	2008-03-31 09:36:05.440353
31	3	1	73	2008-03-31 09:36:05.452786	2008-03-31 09:36:05.452786
32	4	1	73	2008-03-31 09:36:05.46501	2008-03-31 09:36:05.46501
33	1	1	72	2008-03-31 09:36:05.498926	2008-03-31 09:36:05.498926
34	2	1	72	2008-03-31 09:36:05.5115	2008-03-31 09:36:05.5115
35	3	1	72	2008-03-31 09:36:05.523871	2008-03-31 09:36:05.523871
36	4	1	72	2008-03-31 09:36:05.536325	2008-03-31 09:36:05.536325
37	1	1	71	2008-03-31 09:36:05.570311	2008-03-31 09:36:05.570311
38	2	1	71	2008-03-31 09:36:05.582637	2008-03-31 09:36:05.582637
39	3	1	71	2008-03-31 09:36:05.595026	2008-03-31 09:36:05.595026
40	4	1	71	2008-03-31 09:36:05.607424	2008-03-31 09:36:05.607424
41	1	1	70	2008-03-31 09:36:05.641557	2008-03-31 09:36:05.641557
42	2	1	70	2008-03-31 09:36:05.694355	2008-03-31 09:36:05.694355
43	3	1	70	2008-03-31 09:36:05.707849	2008-03-31 09:36:05.707849
44	4	1	70	2008-03-31 09:36:05.72079	2008-03-31 09:36:05.72079
45	1	1	69	2008-03-31 09:36:05.755896	2008-03-31 09:36:05.755896
46	2	1	69	2008-03-31 09:36:05.768632	2008-03-31 09:36:05.768632
47	3	1	69	2008-03-31 09:36:05.78117	2008-03-31 09:36:05.78117
48	4	1	69	2008-03-31 09:36:05.794011	2008-03-31 09:36:05.794011
49	1	1	68	2008-03-31 09:36:05.82814	2008-03-31 09:36:05.82814
50	2	1	68	2008-03-31 09:36:05.841665	2008-03-31 09:36:05.841665
51	3	1	68	2008-03-31 09:36:05.854353	2008-03-31 09:36:05.854353
52	4	1	68	2008-03-31 09:36:05.866783	2008-03-31 09:36:05.866783
53	1	1	67	2008-03-31 09:36:05.90077	2008-03-31 09:36:05.90077
54	2	1	67	2008-03-31 09:36:05.913382	2008-03-31 09:36:05.913382
55	3	1	67	2008-03-31 09:36:05.925923	2008-03-31 09:36:05.925923
56	4	1	67	2008-03-31 09:36:05.938402	2008-03-31 09:36:05.938402
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: -
--

COPY roles (id, role_name, description) FROM stdin;
1	administrator	\N
2	investigator	\N
\.


--
-- Data for Name: schema_info; Type: TABLE DATA; Schema: public; Owner: -
--

COPY schema_info (version) FROM stdin;
22
\.


--
-- Data for Name: telephones; Type: TABLE DATA; Schema: public; Owner: -
--

COPY telephones (id, location_id, country_code, area_code, phone_number, extension, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: treatments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY treatments (id, treatment_type_id, treatment_name) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY users (id, uid, given_name, first_name, last_name, initials, generational_qualifer, user_name, created_at, updated_at) FROM stdin;
1	utah	\N	\N	\N	\N	\N	default_user	2008-03-31 09:36:04.764734	2008-03-31 09:36:04.764734
2	100045044	\N	\N	\N	\N	\N	mike	2008-03-31 09:36:04.772249	2008-03-31 09:36:04.772249
3	100045099	\N	\N	\N	\N	\N	chuck	2008-03-31 09:36:04.776169	2008-03-31 09:36:04.776169
4	100045088	\N	\N	\N	\N	\N	davidjackson	2008-03-31 09:36:04.779939	2008-03-31 09:36:04.779939
\.


--
-- Name: addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY addresses
    ADD CONSTRAINT addresses_pkey PRIMARY KEY (id);


--
-- Name: animals_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY animals
    ADD CONSTRAINT animals_pkey PRIMARY KEY (id);


--
-- Name: clinicals_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY clinicals
    ADD CONSTRAINT clinicals_pkey PRIMARY KEY (id);


--
-- Name: clusters_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY clusters
    ADD CONSTRAINT clusters_pkey PRIMARY KEY (id);


--
-- Name: codes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY codes
    ADD CONSTRAINT codes_pkey PRIMARY KEY (id);


--
-- Name: disease_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY disease_events
    ADD CONSTRAINT disease_events_pkey PRIMARY KEY (id);


--
-- Name: diseases_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY diseases
    ADD CONSTRAINT diseases_pkey PRIMARY KEY (id);


--
-- Name: encounters_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY encounters
    ADD CONSTRAINT encounters_pkey PRIMARY KEY (id);


--
-- Name: entities_locations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY entities_locations
    ADD CONSTRAINT entities_locations_pkey PRIMARY KEY (id);


--
-- Name: entities_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY entities
    ADD CONSTRAINT entities_pkey PRIMARY KEY (id);


--
-- Name: entitlements_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY entitlements
    ADD CONSTRAINT entitlements_pkey PRIMARY KEY (id);


--
-- Name: entity_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY entity_groups
    ADD CONSTRAINT entity_groups_pkey PRIMARY KEY (id);


--
-- Name: event_cases_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cases_events
    ADD CONSTRAINT event_cases_pkey PRIMARY KEY (id);


--
-- Name: events_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- Name: lab_results_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY lab_results
    ADD CONSTRAINT lab_results_pkey PRIMARY KEY (id);


--
-- Name: laboratories_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY laboratories
    ADD CONSTRAINT laboratories_pkey PRIMARY KEY (id);


--
-- Name: locations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY locations
    ADD CONSTRAINT locations_pkey PRIMARY KEY (id);


--
-- Name: materials_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY materials
    ADD CONSTRAINT materials_pkey PRIMARY KEY (id);


--
-- Name: observations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY observations
    ADD CONSTRAINT observations_pkey PRIMARY KEY (id);


--
-- Name: organizations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY organizations
    ADD CONSTRAINT organizations_pkey PRIMARY KEY (id);


--
-- Name: participation_hospitals_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY hospitals_participations
    ADD CONSTRAINT participation_hospitals_pkey PRIMARY KEY (id);


--
-- Name: participations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY participations
    ADD CONSTRAINT participations_pkey PRIMARY KEY (id);


--
-- Name: participations_risk_factors_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY participations_risk_factors
    ADD CONSTRAINT participations_risk_factors_pkey PRIMARY KEY (id);


--
-- Name: participations_treatments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY participations_treatments
    ADD CONSTRAINT participations_treatments_pkey PRIMARY KEY (id);


--
-- Name: people_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY people
    ADD CONSTRAINT people_pkey PRIMARY KEY (id);


--
-- Name: pg_ts_cfg_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY pg_ts_cfg
    ADD CONSTRAINT pg_ts_cfg_pkey PRIMARY KEY (ts_name);


--
-- Name: pg_ts_cfgmap_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY pg_ts_cfgmap
    ADD CONSTRAINT pg_ts_cfgmap_pkey PRIMARY KEY (ts_name, tok_alias);


--
-- Name: pg_ts_dict_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY pg_ts_dict
    ADD CONSTRAINT pg_ts_dict_pkey PRIMARY KEY (dict_name);


--
-- Name: pg_ts_parser_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY pg_ts_parser
    ADD CONSTRAINT pg_ts_parser_pkey PRIMARY KEY (prs_name);


--
-- Name: places_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY places
    ADD CONSTRAINT places_pkey PRIMARY KEY (id);


--
-- Name: privileges_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY "privileges"
    ADD CONSTRAINT privileges_pkey PRIMARY KEY (id);


--
-- Name: privileges_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY privileges_roles
    ADD CONSTRAINT privileges_roles_pkey PRIMARY KEY (id);


--
-- Name: referrals_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY referrals
    ADD CONSTRAINT referrals_pkey PRIMARY KEY (id);


--
-- Name: role_memberships_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY role_memberships
    ADD CONSTRAINT role_memberships_pkey PRIMARY KEY (id);


--
-- Name: roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: telephones_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY telephones
    ADD CONSTRAINT telephones_pkey PRIMARY KEY (id);


--
-- Name: treatments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY treatments
    ADD CONSTRAINT treatments_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_addresses_on_county_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_addresses_on_county_id ON addresses USING btree (county_id);


--
-- Name: index_addresses_on_location_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_addresses_on_location_id ON addresses USING btree (location_id);


--
-- Name: index_addresses_on_state_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_addresses_on_state_id ON addresses USING btree (state_id);


--
-- Name: index_animals_on_entity_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_animals_on_entity_id ON animals USING btree (entity_id);


--
-- Name: index_cases_events_on_event_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_cases_events_on_event_id ON cases_events USING btree (event_id);


--
-- Name: index_clusters_on_cluster_status_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_clusters_on_cluster_status_id ON clusters USING btree (cluster_status_id);


--
-- Name: index_clusters_on_primary_event_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_clusters_on_primary_event_id ON clusters USING btree (primary_event_id);


--
-- Name: index_clusters_on_secondary_event_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_clusters_on_secondary_event_id ON clusters USING btree (secondary_event_id);


--
-- Name: index_disease_events_on_died_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_disease_events_on_died_id ON disease_events USING btree (died_id);


--
-- Name: index_disease_events_on_disease_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_disease_events_on_disease_id ON disease_events USING btree (disease_id);


--
-- Name: index_disease_events_on_event_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_disease_events_on_event_id ON disease_events USING btree (event_id);


--
-- Name: index_disease_events_on_hospitalized_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_disease_events_on_hospitalized_id ON disease_events USING btree (hospitalized_id);


--
-- Name: index_encounters_on_event_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_encounters_on_event_id ON encounters USING btree (event_id);


--
-- Name: index_entity_groups_on_entity_group_type_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_entity_groups_on_entity_group_type_id ON entity_groups USING btree (entity_group_type_id);


--
-- Name: index_entity_groups_on_primary_entity_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_entity_groups_on_primary_entity_id ON entity_groups USING btree (primary_entity_id);


--
-- Name: index_entity_groups_on_secondary_entity_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_entity_groups_on_secondary_entity_id ON entity_groups USING btree (secondary_entity_id);


--
-- Name: index_events_on_event_case_status_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_events_on_event_case_status_id ON events USING btree (event_case_status_id);


--
-- Name: index_events_on_event_status_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_events_on_event_status_id ON events USING btree (event_status_id);


--
-- Name: index_events_on_imported_from_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_events_on_imported_from_id ON events USING btree (imported_from_id);


--
-- Name: index_events_on_investigation_LHD_status_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX "index_events_on_investigation_LHD_status_id" ON events USING btree ("investigation_LHD_status_id");


--
-- Name: index_events_on_outbreak_associated_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_events_on_outbreak_associated_id ON events USING btree (outbreak_associated_id);


--
-- Name: index_hospitals_participations_on_participation_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_hospitals_participations_on_participation_id ON hospitals_participations USING btree (participation_id);


--
-- Name: index_lab_results_on_specimen_source_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_lab_results_on_specimen_source_id ON lab_results USING btree (specimen_source_id);


--
-- Name: index_lab_results_on_tested_at_uphl_yn_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_lab_results_on_tested_at_uphl_yn_id ON lab_results USING btree (tested_at_uphl_yn_id);


--
-- Name: index_materials_on_entity_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_materials_on_entity_id ON materials USING btree (entity_id);


--
-- Name: index_observations_on_event_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_observations_on_event_id ON observations USING btree (event_id);


--
-- Name: index_participations_on_event_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_participations_on_event_id ON participations USING btree (event_id);


--
-- Name: index_participations_on_participation_status_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_participations_on_participation_status_id ON participations USING btree (participation_status_id);


--
-- Name: index_participations_on_primary_entity_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_participations_on_primary_entity_id ON participations USING btree (primary_entity_id);


--
-- Name: index_participations_on_role_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_participations_on_role_id ON participations USING btree (role_id);


--
-- Name: index_participations_on_secondary_entity_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_participations_on_secondary_entity_id ON participations USING btree (secondary_entity_id);


--
-- Name: index_participations_risk_factors_on_day_care_association_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_participations_risk_factors_on_day_care_association_id ON participations_risk_factors USING btree (day_care_association_id);


--
-- Name: index_participations_risk_factors_on_food_handler_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_participations_risk_factors_on_food_handler_id ON participations_risk_factors USING btree (food_handler_id);


--
-- Name: index_participations_risk_factors_on_group_living_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_participations_risk_factors_on_group_living_id ON participations_risk_factors USING btree (group_living_id);


--
-- Name: index_participations_risk_factors_on_healthcare_worker_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_participations_risk_factors_on_healthcare_worker_id ON participations_risk_factors USING btree (healthcare_worker_id);


--
-- Name: index_participations_risk_factors_on_participation_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_participations_risk_factors_on_participation_id ON participations_risk_factors USING btree (participation_id);


--
-- Name: index_participations_risk_factors_on_pregnant_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_participations_risk_factors_on_pregnant_id ON participations_risk_factors USING btree (pregnant_id);


--
-- Name: index_participations_treatments_on_participation_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_participations_treatments_on_participation_id ON participations_treatments USING btree (participation_id);


--
-- Name: index_participations_treatments_on_treatment_given_yn_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_participations_treatments_on_treatment_given_yn_id ON participations_treatments USING btree (treatment_given_yn_id);


--
-- Name: index_participations_treatments_on_treatment_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_participations_treatments_on_treatment_id ON participations_treatments USING btree (treatment_id);


--
-- Name: index_people_on_age_type_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_people_on_age_type_id ON people USING btree (age_type_id);


--
-- Name: index_people_on_birth_gender_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_people_on_birth_gender_id ON people USING btree (birth_gender_id);


--
-- Name: index_people_on_entity_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_people_on_entity_id ON people USING btree (entity_id);


--
-- Name: index_people_on_ethnicity_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_people_on_ethnicity_id ON people USING btree (ethnicity_id);


--
-- Name: index_people_on_first_name_soundex; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_people_on_first_name_soundex ON people USING btree (first_name_soundex);


--
-- Name: index_people_on_last_name_soundex; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_people_on_last_name_soundex ON people USING btree (last_name_soundex);


--
-- Name: index_people_on_primary_language_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_people_on_primary_language_id ON people USING btree (primary_language_id);


--
-- Name: index_people_races_on_entity_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_people_races_on_entity_id ON people_races USING btree (entity_id);


--
-- Name: index_people_races_on_race_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_people_races_on_race_id ON people_races USING btree (race_id);


--
-- Name: index_places_on_entity_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_places_on_entity_id ON places USING btree (entity_id);


--
-- Name: index_places_on_place_type_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_places_on_place_type_id ON places USING btree (place_type_id);


--
-- Name: index_referrals_on_event_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_referrals_on_event_id ON referrals USING btree (event_id);


--
-- Name: index_telephones_on_location_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_telephones_on_location_id ON telephones USING btree (location_id);


--
-- Name: index_treatments_on_treatment_type_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_treatments_on_treatment_type_id ON treatments USING btree (treatment_type_id);


--
-- Name: people_fts_vector_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX people_fts_vector_index ON people USING gist (vector);


--
-- Name: tsvectorupdate; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER tsvectorupdate
    BEFORE INSERT OR UPDATE ON people
    FOR EACH ROW
    EXECUTE PROCEDURE tsearch2('vector', 'first_name', 'last_name', 'first_name_soundex', 'last_name_soundex');


--
-- Name: fk_cluster_status; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY clusters
    ADD CONSTRAINT fk_cluster_status FOREIGN KEY (cluster_status_id) REFERENCES codes(id);


--
-- Name: fk_code_birthgender; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY people
    ADD CONSTRAINT fk_code_birthgender FOREIGN KEY (birth_gender_id) REFERENCES codes(id);


--
-- Name: fk_county; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY addresses
    ADD CONSTRAINT fk_county FOREIGN KEY (county_id) REFERENCES codes(id);


--
-- Name: fk_daycareassoc; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY participations_risk_factors
    ADD CONSTRAINT fk_daycareassoc FOREIGN KEY (day_care_association_id) REFERENCES codes(id);


--
-- Name: fk_died; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY disease_events
    ADD CONSTRAINT fk_died FOREIGN KEY (died_id) REFERENCES codes(id);


--
-- Name: fk_disease; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY disease_events
    ADD CONSTRAINT fk_disease FOREIGN KEY (disease_id) REFERENCES diseases(id);


--
-- Name: fk_entity; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY entities_locations
    ADD CONSTRAINT fk_entity FOREIGN KEY (entity_id) REFERENCES entities(id);


--
-- Name: fk_entitygrouptypecode; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY entity_groups
    ADD CONSTRAINT fk_entitygrouptypecode FOREIGN KEY (entity_group_type_id) REFERENCES codes(id);


--
-- Name: fk_entityid; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY laboratories
    ADD CONSTRAINT fk_entityid FOREIGN KEY (entity_id) REFERENCES entities(id);


--
-- Name: fk_ethnicity; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY people
    ADD CONSTRAINT fk_ethnicity FOREIGN KEY (ethnicity_id) REFERENCES codes(id);


--
-- Name: fk_event; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY disease_events
    ADD CONSTRAINT fk_event FOREIGN KEY (event_id) REFERENCES events(id);


--
-- Name: fk_event_case; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY cases_events
    ADD CONSTRAINT fk_event_case FOREIGN KEY (event_id) REFERENCES events(id);


--
-- Name: fk_event_case_status; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY events
    ADD CONSTRAINT fk_event_case_status FOREIGN KEY (event_case_status_id) REFERENCES codes(id);


--
-- Name: fk_event_clinical; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY clinicals
    ADD CONSTRAINT fk_event_clinical FOREIGN KEY (event_id) REFERENCES events(id);


--
-- Name: fk_event_encounter; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY encounters
    ADD CONSTRAINT fk_event_encounter FOREIGN KEY (event_id) REFERENCES events(id);


--
-- Name: fk_event_observation; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY observations
    ADD CONSTRAINT fk_event_observation FOREIGN KEY (event_id) REFERENCES events(id);


--
-- Name: fk_event_referral; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY referrals
    ADD CONSTRAINT fk_event_referral FOREIGN KEY (event_id) REFERENCES events(id);


--
-- Name: fk_event_status; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY events
    ADD CONSTRAINT fk_event_status FOREIGN KEY (event_status_id) REFERENCES codes(id);


--
-- Name: fk_eventid; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY lab_results
    ADD CONSTRAINT fk_eventid FOREIGN KEY (event_id) REFERENCES events(id);


--
-- Name: fk_foodhandler; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY participations_risk_factors
    ADD CONSTRAINT fk_foodhandler FOREIGN KEY (food_handler_id) REFERENCES codes(id);


--
-- Name: fk_groupliving; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY participations_risk_factors
    ADD CONSTRAINT fk_groupliving FOREIGN KEY (group_living_id) REFERENCES codes(id);


--
-- Name: fk_healthcareworker; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY participations_risk_factors
    ADD CONSTRAINT fk_healthcareworker FOREIGN KEY (healthcare_worker_id) REFERENCES codes(id);


--
-- Name: fk_hospitalized; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY disease_events
    ADD CONSTRAINT fk_hospitalized FOREIGN KEY (hospitalized_id) REFERENCES codes(id);


--
-- Name: fk_imported_from; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY events
    ADD CONSTRAINT fk_imported_from FOREIGN KEY (imported_from_id) REFERENCES codes(id);


--
-- Name: fk_jurisdictionid; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY entitlements
    ADD CONSTRAINT fk_jurisdictionid FOREIGN KEY (jurisdiction_id) REFERENCES entities(id);


--
-- Name: fk_jurisdictionid; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY role_memberships
    ADD CONSTRAINT fk_jurisdictionid FOREIGN KEY (jurisdiction_id) REFERENCES entities(id);


--
-- Name: fk_jurisdictionid; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY privileges_roles
    ADD CONSTRAINT fk_jurisdictionid FOREIGN KEY (jurisdiction_id) REFERENCES entities(id);


--
-- Name: fk_lab_yn; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY clinicals
    ADD CONSTRAINT fk_lab_yn FOREIGN KEY (test_public_health_lab_id) REFERENCES codes(id);


--
-- Name: fk_location; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY entities_locations
    ADD CONSTRAINT fk_location FOREIGN KEY (location_id) REFERENCES locations(id);


--
-- Name: fk_location_type; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY entities_locations
    ADD CONSTRAINT fk_location_type FOREIGN KEY (entity_location_type_id) REFERENCES codes(id);


--
-- Name: fk_participation; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY hospitals_participations
    ADD CONSTRAINT fk_participation FOREIGN KEY (participation_id) REFERENCES participations(id);


--
-- Name: fk_participation; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY participations_risk_factors
    ADD CONSTRAINT fk_participation FOREIGN KEY (participation_id) REFERENCES participations(id);


--
-- Name: fk_participation_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY participations_treatments
    ADD CONSTRAINT fk_participation_id FOREIGN KEY (participation_id) REFERENCES participations(id);


--
-- Name: fk_participation_status; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY participations
    ADD CONSTRAINT fk_participation_status FOREIGN KEY (participation_status_id) REFERENCES codes(id);


--
-- Name: fk_pregnant; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY participations_risk_factors
    ADD CONSTRAINT fk_pregnant FOREIGN KEY (pregnant_id) REFERENCES codes(id);


--
-- Name: fk_primary_event_cluster; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY clusters
    ADD CONSTRAINT fk_primary_event_cluster FOREIGN KEY (primary_event_id) REFERENCES events(id);


--
-- Name: fk_primary_language; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY people
    ADD CONSTRAINT fk_primary_language FOREIGN KEY (primary_language_id) REFERENCES codes(id);


--
-- Name: fk_primary_yn; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY entities_locations
    ADD CONSTRAINT fk_primary_yn FOREIGN KEY (primary_yn_id) REFERENCES codes(id);


--
-- Name: fk_primaryentityid; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY entity_groups
    ADD CONSTRAINT fk_primaryentityid FOREIGN KEY (primary_entity_id) REFERENCES entities(id);


--
-- Name: fk_privilegeid; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY entitlements
    ADD CONSTRAINT fk_privilegeid FOREIGN KEY (privilege_id) REFERENCES "privileges"(id);


--
-- Name: fk_privilegeid; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY privileges_roles
    ADD CONSTRAINT fk_privilegeid FOREIGN KEY (privilege_id) REFERENCES "privileges"(id);


--
-- Name: fk_role; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY participations
    ADD CONSTRAINT fk_role FOREIGN KEY (role_id) REFERENCES codes(id);


--
-- Name: fk_roleid; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY role_memberships
    ADD CONSTRAINT fk_roleid FOREIGN KEY (role_id) REFERENCES roles(id);


--
-- Name: fk_roleid; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY privileges_roles
    ADD CONSTRAINT fk_roleid FOREIGN KEY (role_id) REFERENCES roles(id);


--
-- Name: fk_secondary_event_cluster; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY clusters
    ADD CONSTRAINT fk_secondary_event_cluster FOREIGN KEY (secondary_event_id) REFERENCES events(id);


--
-- Name: fk_secondaryentityid; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY entity_groups
    ADD CONSTRAINT fk_secondaryentityid FOREIGN KEY (secondary_entity_id) REFERENCES entities(id);


--
-- Name: fk_specimensourceid; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY lab_results
    ADD CONSTRAINT fk_specimensourceid FOREIGN KEY (specimen_source_id) REFERENCES codes(id);


--
-- Name: fk_state; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY addresses
    ADD CONSTRAINT fk_state FOREIGN KEY (state_id) REFERENCES codes(id);


--
-- Name: fk_testedatuphlynid; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY lab_results
    ADD CONSTRAINT fk_testedatuphlynid FOREIGN KEY (tested_at_uphl_yn_id) REFERENCES codes(id);


--
-- Name: fk_treatment_given_yn; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY participations_treatments
    ADD CONSTRAINT fk_treatment_given_yn FOREIGN KEY (treatment_given_yn_id) REFERENCES codes(id);


--
-- Name: fk_treatment_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY participations_treatments
    ADD CONSTRAINT fk_treatment_id FOREIGN KEY (treatment_id) REFERENCES treatments(id);


--
-- Name: fk_treatment_type; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY treatments
    ADD CONSTRAINT fk_treatment_type FOREIGN KEY (treatment_type_id) REFERENCES codes(id);


--
-- Name: fk_userid; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY entitlements
    ADD CONSTRAINT fk_userid FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: fk_userid; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY role_memberships
    ADD CONSTRAINT fk_userid FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: is_animal_entity; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY animals
    ADD CONSTRAINT is_animal_entity FOREIGN KEY (entity_id) REFERENCES entities(id);


--
-- Name: is_material_entity; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY materials
    ADD CONSTRAINT is_material_entity FOREIGN KEY (entity_id) REFERENCES entities(id);


--
-- Name: is_person_entity; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY people
    ADD CONSTRAINT is_person_entity FOREIGN KEY (entity_id) REFERENCES entities(id);


--
-- Name: is_place_entity; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY places
    ADD CONSTRAINT is_place_entity FOREIGN KEY (entity_id) REFERENCES entities(id);


--
-- Name: r_1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY addresses
    ADD CONSTRAINT r_1 FOREIGN KEY (location_id) REFERENCES locations(id);


--
-- Name: r_2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY telephones
    ADD CONSTRAINT r_2 FOREIGN KEY (location_id) REFERENCES locations(id);


--
-- Name: r_3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY participations
    ADD CONSTRAINT r_3 FOREIGN KEY (primary_entity_id) REFERENCES entities(id);


--
-- Name: r_4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY participations
    ADD CONSTRAINT r_4 FOREIGN KEY (secondary_entity_id) REFERENCES entities(id);


--
-- Name: r_5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY participations
    ADD CONSTRAINT r_5 FOREIGN KEY (event_id) REFERENCES events(id);


--
-- Name: public; Type: ACL; Schema: -; Owner: -
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

