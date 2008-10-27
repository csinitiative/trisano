truncate table export_predicates;


insert into export_predicates (table_name
, column_name
, comparison_operator
, comparison_value
, comparison_logical
, export_name_id
)
values
('diseases'
, 'disease_name'
, '='
, 'Anthrax'
, 'AND'
, 1
)
;


insert into export_predicates (table_name
, column_name
, comparison_operator
, comparison_value
, comparison_logical
, export_name_id
)
values
('events'
, 'event_onset_date'
, '<'
, '10/25/2008'
, 'AND'
, 1
)
;

insert into export_predicates (table_name
, column_name
, comparison_operator
, comparison_value
, comparison_logical
, export_name_id
)
values
('events'
, 'MMWR_week'
, '<='
, '41'
, NULL
, 1
)
;


/*
insert into export_predicates (table_name
, column_name
, comparison_operator
, comparison_value
, comparison_logical
, export_name_id
)
values
(''
, ''
, ''
, ''
, NULL
, 1
)
;
*/

