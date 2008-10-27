truncate table export_conversion_values cascade;
truncate table export_columns cascade;
truncate table export_names cascade;

select setval('export_names_id_seq',1);
select setval('export_columns_id_seq',1);
select setval('export_conversion_values_id_seq',1);
select setval('export_predicates_id_seq',1);


insert into export_names (export_name) 
	values ('CDC');

update export_names set id=1 where export_name='CDC';

insert into export_columns ( export_name_id
, type_data
, export_column_name
, table_name
, column_name
, is_required
, start_position
, length_to_output
)
values
( 1
, 'FIXED'
, 'RECTYPE'
, NULL
, NULL
, 'Y'
, 1
, 1
);

insert into export_columns ( export_name_id
, type_data
, export_column_name
, table_name
, column_name
, is_required
, start_position
, length_to_output
)
values
( 1
, 'FIXED'
, 'UPDATE'
, NULL
, NULL
, 'N'
, 2
, 1
);

insert into export_columns ( export_name_id
, type_data
, export_column_name
, table_name
, column_name
, is_required
, start_position
, length_to_output
)
values
( 1
, 'FIXED'
, 'STATE'
, NULL
, NULL
, 'Y'
, 3
, 2
);

insert into export_columns ( export_name_id
, type_data
, export_column_name
, table_name
, column_name
, is_required
, start_position
, length_to_output
)
values
( 1
, 'FIXED'
, 'YEAR'
, NULL
, NULL
, 'Y'
, 5
, 2
);

insert into export_columns ( export_name_id
, type_data
, export_column_name
, table_name
, column_name
, is_required
, start_position
, length_to_output
)
values
( 1
, 'CORE'
, 'CASEID'
, 'events'
, 'id'
, 'Y'
, 7
, 6
);

insert into export_columns ( export_name_id
, type_data
, export_column_name
, table_name
, column_name
, is_required
, start_position
, length_to_output
)
values
( 1
, 'FIXED'
, 'SITE'
, NULL
, NULL
, 'Y'
, 13
, 3
);

insert into export_columns ( export_name_id
, type_data
, export_column_name
, table_name
, column_name
, is_required
, start_position
, length_to_output
)
values
( 1
, 'CORE'
, 'WEEK'
, 'events'
, '"MMWR_week"'
, 'Y'
, 16
, 2
);

insert into export_columns ( export_name_id
, type_data
, export_column_name
, table_name
, column_name
, is_required
, start_position
, length_to_output
)
values
( 1
, 'FIXED'
, 'EVENT'
, 'diseases'
, 'id'
, 'Y'
, 18
, 5
);

insert into export_columns ( export_name_id
, type_data
, export_column_name
, table_name
, column_name
, is_required
, start_position
, length_to_output
)
values
( 1
, 'FIXED'
, 'COUNT'
, NULL
, NULL
, 'Y'
, 23
, 5
);

insert into export_columns ( export_name_id
, type_data
, export_column_name
, table_name
, column_name
, is_required
, start_position
, length_to_output
)
values
( 1
, 'CORE'
, 'COUNTY'
, 'addresses'
, 'county_id'
, 'N'
, 28
, 3
);

insert into export_columns ( export_name_id
, type_data
, export_column_name
, table_name
, column_name
, is_required
, start_position
, length_to_output
)
values
( 1
, 'CORE'
, 'BIRTHDATE'
, 'people'
, 'birth_date'
, 'N'
, 31
, 8
);

insert into export_columns ( export_name_id
, type_data
, export_column_name
, table_name
, column_name
, is_required
, start_position
, length_to_output
)
values
( 1
, 'CORE'
, 'AGE'
, 'events'    
, 'age_at_onset'
, 'N'
, 39
, 3
);

insert into export_columns ( export_name_id
, type_data
, export_column_name
, table_name
, column_name
, is_required
, start_position
, length_to_output
)
values
( 1
, 'CORE'
, 'AGETYPE'
, 'events' 
, 'age_type_id'
, 'N'
, 42
, 1
);

insert into export_columns ( export_name_id
, type_data
, export_column_name
, table_name
, column_name
, is_required
, start_position
, length_to_output
)
values
( 1
, 'CORE'
, 'SEX'
, 'people'
, 'birth_gender_id'
, 'N'
, 43
, 1
);

insert into export_columns ( export_name_id
, type_data
, export_column_name
, table_name
, column_name
, is_required
, start_position
, length_to_output
)
values
( 1
, 'CORE'
, 'RACE'
, 'people_races'
, 'race_id'
, 'N'
, 44
, 1
);

insert into export_columns ( export_name_id
, type_data
, export_column_name
, table_name
, column_name
, is_required
, start_position
, length_to_output
)
values
( 1
, 'CORE'
, 'ETHNICITY'
, 'people'
, 'ethnicity_id'
, 'N'
, 45
, 1
);

insert into export_columns ( export_name_id
, type_data
, export_column_name
, table_name
, column_name
, is_required
, start_position
, length_to_output
)
values
( 1
, 'CORE'
, 'EVENTDATE'
, 'events'
, 'event_onset_date'
, 'Y'
, 46
, 6
);

insert into export_columns ( export_name_id
, type_data
, export_column_name
, table_name
, column_name
, is_required
, start_position
, length_to_output
)
values
( 1
, 'FIXED'
, 'DATETYPE'
, NULL
, NULL
, 'Y'
, 46
, 6
);


insert into export_columns ( export_name_id
, type_data
, export_column_name
, table_name
, column_name
, is_required
, start_position
, length_to_output
)
values
( 1
, 'CORE'
, 'CASESTATUS'
, 'events'
, 'event_status'
, 'N'
, 53
, 1
);

insert into export_columns ( export_name_id
, type_data
, export_column_name
, table_name
, column_name
, is_required
, start_position
, length_to_output
)
values
( 1
, 'CORE'
, 'IMPORTED'
, 'events'
, 'imported_from_id'
, 'N'
, 54
, 1
);

insert into export_columns ( export_name_id
, type_data
, export_column_name
, table_name
, column_name
, is_required
, start_position
, length_to_output
)
values
( 1
, 'CORE'
, 'OUTBREAK'
, 'events'
, 'outbreak_associated_id'
, 'N'
, 55
, 1
);

insert into export_columns ( export_name_id
, type_data
, export_column_name
, table_name
, column_name
, is_required
, start_position
, length_to_output
)
values
( 1
, 'FIXED'
, 'FUTURE'
, NULL
, NULL
, 'N'
, 56
, 5
);

--     This is for loading the conversion codes
-- birthdate  if NULL then 99999999  else output as YYYYMMDD
insert into export_conversion_values (export_column_id
, value_from
, value_to
)
values
(12
, NULL
,'99999999'
);
--	Age
insert into export_conversion_values (export_column_id
, value_from
, value_to
)
values
(13
,NULL
,'999'
);
-- Age Type  HAS NOT BEEN DEFINED YET
--insert into export_conversion_values (export_column_id
--, value_from
--, value_to
--)
--values
--(
--,
--,
--)


--  Ethnicity  ----------------------------------------------------
insert into export_conversion_values (export_column_id
, value_from
, value_to
)
values
(17
,'H'
,'H'
);

insert into export_conversion_values (export_column_id
, value_from
, value_to
)
values
(17
,'U'
,'U'
);

insert into export_conversion_values (export_column_id
, value_from
, value_to
)
values
(17
,'NH'
,'N'
);

insert into export_conversion_values (export_column_id
, value_from
, value_to
)
values
(17
,'O'
,'U'
);

insert into export_conversion_values (export_column_id
, value_from
, value_to
)
values
(17
,'UNK'
,'U'
);
--   end of Ethnicity  ----------------------------------------------
--  Race  16   ----------------------------------------------------------
insert into export_conversion_values (export_column_id
, value_from
, value_to
)
values
(16
,'W'
,'W'
);

insert into export_conversion_values (export_column_id
, value_from
, value_to
)
values
(16
,'B'
,'B'
);

insert into export_conversion_values (export_column_id
, value_from
, value_to
)
values
(16
,'AA'
,'N'
);

insert into export_conversion_values (export_column_id
, value_from
, value_to
)
values
(16
,'A'
,'A'
);

insert into export_conversion_values (export_column_id
, value_from
, value_to
)
values
(16
,'AK'
,'N'
);

insert into export_conversion_values (export_column_id
, value_from
, value_to
)
values
(16
,'H'
,'A'
);

insert into export_conversion_values (export_column_id
, value_from
, value_to
)
values
(16
,'UNK'
,'U'
);
--  end of Ethnicity  --------------------------------------------------
---  Case Status  ------------------------------------------------------
insert into export_conversion_values (export_column_id
, value_from
, value_to
)
values
(20
,'U'
,'9'
);

insert into export_conversion_values (export_column_id
, value_from
, value_to
)
values
(20
,'UNK'
,'9'
);
insert into export_conversion_values (export_column_id
, value_from
, value_to
)
values
(20
,'C'
,'1'
);
insert into export_conversion_values (export_column_id
, value_from
, value_to
)
values
(20
,'P'
,'2'
);
insert into export_conversion_values (export_column_id
, value_from
, value_to
)
values
(20
,'S'
,'3'
);
insert into export_conversion_values (export_column_id
, value_from
, value_to
)
values
(20
,'NC'
,'U'
);
insert into export_conversion_values (export_column_id
, value_from
, value_to
)
values
(20
,'CC'
,'N'
);
insert into export_conversion_values (export_column_id
, value_from
, value_to
)
values
(20
,'D'
,'U'
);

--  End of Case Status ---------------------------------------------------

-- Imported from    ------------------------------------------------------

insert into export_conversion_values (export_column_id
, value_from
, value_to
)
values
(21
,'U'
,'9'
);


insert into export_conversion_values (export_column_id
, value_from
, value_to
)
values
(21
,'UNK'
,'9'
);


insert into export_conversion_values (export_column_id
, value_from
, value_to
)
values
(21
,'US'
,'3'
);

insert into export_conversion_values (export_column_id
, value_from
, value_to
)
values
(21
,'UT'
,'1'
);

insert into export_conversion_values (export_column_id
, value_from
, value_to
)
values
(21
,'F'
,'2'
);

--  end of Imported By   ----------------------------------------------
--  county code  ------------------------------------------------------
 insert into export_conversion_values (export_column_id
 , value_from
 , value_to
 )
 VALUES
 (11
 , 'BV'
 , '001' )
;
 insert into export_conversion_values (export_column_id
 , value_from
 , value_to
 )
 VALUES
 (11
 , 'BE'
 , '003' )
;
 insert into export_conversion_values (export_column_id
 , value_from
 , value_to
 )
 VALUES
 (11
 , 'CA'
 , '005' )
;
 insert into export_conversion_values (export_column_id
 , value_from
 , value_to
 )
 VALUES
 (11
 , 'CR'
 , '007' )
;
 insert into export_conversion_values (export_column_id
 , value_from
 , value_to
 )
 VALUES
 (11
 , 'DG'
 , '009' )
;
 insert into export_conversion_values (export_column_id
 , value_from
 , value_to
 )
 VALUES
 (11
 , 'DV'
 , '011' );
 insert into export_conversion_values (export_column_id
 , value_from
 , value_to
 )
 VALUES
 (11
 , 'DU'
 , '013' );
 insert into export_conversion_values (export_column_id
 , value_from
 , value_to
 )
 VALUES
 (11
 , 'EM'
 , '015' );
 insert into export_conversion_values (export_column_id
 , value_from
 , value_to
 )
 VALUES
 (11
 , 'GA'
 , '017' );
 insert into export_conversion_values (export_column_id
 , value_from
 , value_to
 )
 VALUES
 (11
 , 'GR'
 , '019' );
 insert into export_conversion_values (export_column_id
 , value_from
 , value_to
 )
 VALUES
 (11
 , 'IR'
 , '021' );
 insert into export_conversion_values (export_column_id
 , value_from
 , value_to
 )
 VALUES
 (11
 , 'JU'
 , '023' );
 insert into export_conversion_values (export_column_id
 , value_from
 , value_to
 )
 VALUES
 (11
 , 'KA'
 , '025' );
 insert into export_conversion_values (export_column_id
 , value_from
 , value_to
 )
 VALUES
 (11
 , 'MI'
 , '027' );
 insert into export_conversion_values (export_column_id
 , value_from
 , value_to
 )
 VALUES
 (11
 , 'MO'
 , '029' );
 insert into export_conversion_values (export_column_id
 , value_from
 , value_to
 )
 VALUES
 (11
 , 'RI'
 , '033' );
 insert into export_conversion_values (export_column_id
 , value_from
 , value_to
 )
 VALUES
 (11
 , 'SL'
 , '035' );
 insert into export_conversion_values (export_column_id
 , value_from
 , value_to
 )
 VALUES
 (11
 , 'SJ'
 , '037' );
 insert into export_conversion_values (export_column_id
 , value_from
 , value_to
 )
 VALUES
 (11
 , 'SP'
 , '039' );
 insert into export_conversion_values (export_column_id
 , value_from
 , value_to
 )
 VALUES
 (11
 , 'SV'
 , '041' );
 insert into export_conversion_values (export_column_id
 , value_from
 , value_to
 )
 VALUES
 (11
 , 'SM'
 , '043' );
 insert into export_conversion_values (export_column_id
 , value_from
 , value_to
 )
 VALUES
 (11
 , 'TL'
 , '045' );
 insert into export_conversion_values (export_column_id
 , value_from
 , value_to
 )
 VALUES
 (11
 , 'UI'
 , '047' );
 insert into export_conversion_values (export_column_id
 , value_from
 , value_to
 )
 VALUES
 (11
 , 'UT'
 , '049' );
 insert into export_conversion_values (export_column_id
 , value_from
 , value_to
 )
 VALUES
 (11
 , 'WS'
 , '051' );
 insert into export_conversion_values (export_column_id
 , value_from
 , value_to
 )
 VALUES
 (11
 , 'WA'
 , '053' );
 insert into export_conversion_values (export_column_id
 , value_from
 , value_to
 )
 VALUES
 (11
 , 'WN'
 , '055' );
 insert into export_conversion_values (export_column_id
 , value_from
 , value_to
 )
 VALUES
 (11
 , 'WB'
 , '057' );
--  end of county   ----------------------------------------------
--  start of diseases/event  -------------------------------------
 insert into export_conversion_values (export_column_id
 , value_from
 , value_to
 )
 VALUES
 (9
 , 'AIDS'
 , '10560' );

insert into export_conversion_values (export_column_id
 , value_from
 , value_to
 )
 VALUES
 (9
 , 'Amebiasis'
 , '11040' );

insert into export_conversion_values (export_column_id
 , value_from
 , value_to
 )
 VALUES
 (9
 , 'Anthrax'
 , '10350' );

insert into export_conversion_values (export_column_id
 , value_from
 , value_to
 )
 VALUES
 (9
 , 'Aseptic meningitis'
 , '10010' );

insert into export_conversion_values (export_column_id
 , value_from
 , value_to
 )
 VALUES
 (9
 , 'Bacterial meningitis, other'
 , '10650' );

insert into export_conversion_values (export_column_id
 , value_from
 , value_to
 )
 VALUES
 (9
 , 'Brucellosis'
 , '10020' );

insert into export_conversion_values (export_column_id
 , value_from
 , value_to
 )
 VALUES
 (9
 , 'Campylobacteriosis'
 , '11020' );

insert into export_conversion_values (export_column_id
 , value_from
 , value_to
 )
 VALUES
 (9
 , 'Chancroid'
 , '10273' );

insert into export_conversion_values (export_column_id
 , value_from
 , value_to
 )
 VALUES
 (9
 , 'Cryptosporidiosis'
 , '11580' );

insert into export_conversion_values (export_column_id
 , value_from
 , value_to
 )
 VALUES
 (9
 , 'Cyclosporiasis'
 , '11575' );
      

insert into export_conversion_values (export_column_id
 , value_from
 , value_to
 )
 VALUES
 (9
 , 'Dengue hemorrhagic fever'
 , '10685' );

insert into export_conversion_values (export_column_id
 , value_from
 , value_to
 )
 VALUES
 (9
 , 'Diphtheria'
 , '10040' );

insert into export_conversion_values (export_column_id
 , value_from
 , value_to
 )
 VALUES
 (9
 , 'Encephalitis, post-mumps'
 , '10080' );

insert into export_conversion_values (export_column_id
 , value_from
 , value_to
 )
 VALUES
 (9
 , '10090'
 , 'Encephalitis, post-other' );

insert into export_conversion_values (export_column_id
 , value_from
 , value_to
 )
 VALUES
 (9
 , 'Encephalitis, primary'
 , '10050' );

insert into export_conversion_values (export_column_id
 , value_from
 , value_to
 )
 VALUES
 (9
 , 'Lead poisoning'
 , '32010' );

insert into export_conversion_values (export_column_id
 , value_from
 , value_to
 )
 VALUES
 (9
 , '10490'
 , 'Legionellosis' );

insert into export_conversion_values (export_column_id
 , value_from
 , value_to
 )
 VALUES
 (9
 , 'Malaria'
 , '10130' );

insert into export_conversion_values (export_column_id
 , value_from
 , value_to
 )
 VALUES
 (9
 , 'Mumps'
 , '10180' );

insert into export_conversion_values (export_column_id
 , value_from
 , value_to
 )
 VALUES
 (9
 , 'Neurosyphilis'
 , '10317' );

insert into export_conversion_values (export_column_id
 , value_from
 , value_to
 )
 VALUES
 (9
 , 'Plague'
 , '10440' );

insert into export_conversion_values (export_column_id
 , value_from
 , value_to
 )
 VALUES
 (9
 , 'Q fever'
 , '10255' );


insert into export_conversion_values (export_column_id
 , value_from
 , value_to
 )
 VALUES
 (9
 , 'Rubella'
 , '10200' );

insert into export_conversion_values (export_column_id
 , value_from
 , value_to
 )
 VALUES
 (9
 , 'Smallpox'
 , '11800' );

insert into export_conversion_values (export_column_id
 , value_from
 , value_to
 )
 VALUES
 (9
 , 'Tetanus'
 , '10210' );

insert into export_conversion_values (export_column_id
 , value_from
 , value_to
 )
 VALUES
 (9
 , 'Tularemia'
 , '10230' );

/*
insert into export_conversion_values (export_column_id
 , value_from
 , value_to
 )
 VALUES
 (9
 , ''
 , '' );
*/





