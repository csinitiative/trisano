DROP TABLE columns;
CREATE TABLE columns (
  table_id text,
  column_id text,
  column_display_name text,
  aggregation_type_desc text,
  -- aggregation_type text,
  -- length text,
  -- precision text,
  formula text,
  model_element_description text,
  relative_size text,
  is_attribute_field text,
  is_dimension_field text,
  is_dimension_table text,
  is_exact text,
  is_fact_field text,
  is_fact_table text,
  is_hidden text,
  primary key (table_id, column_id)
);

DROP TABLE column_aggregation_types;
CREATE TABLE column_aggregation_types (
  table_id text,
  column_id text,
  code text,
  description text,
  agg_type text
);

DROP TABLE tables;
CREATE TABLE tables (
  table_id text,
  table_name text,
  aggregation_type_desc text,
  aggregation_type text,
  length text,
  precision text,
  data_type_description text,
  description text,
  display_name text,
  field_type text,
  field_type_desc text,
  formula text,
  model_element_description text,
  relative_size text,
  is_attribute_field text,
  is_dimension_field text,
  is_dimension_table text,
  is_exact text,
  is_fact_field text,
  is_fact_table text,
  is_hidden text
);

DROP TABLE table_aggregation_types;
CREATE TABLE table_aggregation_types (
  table_id text,
  aggregation_code text,
  aggregation_description text,
  aggregation_type text
);

DROP TABLE table_concepts;
CREATE TABLE table_concepts (
  table_id text,
  concept_name text,
  concept_description text
);

DROP TABLE table_concept_child_properties;
CREATE TABLE table_concept_child_properties (
  table_id text,
  concept_name text,
  child_concept_name text,
  child_concept_value text,
  child_concept_type text
);

DROP TABLE business_tables;
CREATE TABLE business_tables (
  table_id text,
  physical_table_id text,
  display_name text
);

DROP TABLE relationships;
CREATE TABLE relationships (
    table_from text,
    field_from text,
    table_to text,
    field_to text,
    type_desc text
);

DROP TABLE categories;
CREATE TABLE categories (
    category_name text,
    display_name text
);

DROP TABLE category_columns;
DROP SEQUENCE category_columns_col_order_seq;
CREATE  SEQUENCE category_columns_col_order_seq;
CREATE TABLE category_columns (
    category_name text,
    business_table text,
    business_column text,
    col_order integer default nextval('category_columns_col_order_seq')
);

DROP TABLE business_columns;
CREATE TABLE business_columns (
    business_column_id text,
    physical_table_id text,
    physical_column_id text
);
