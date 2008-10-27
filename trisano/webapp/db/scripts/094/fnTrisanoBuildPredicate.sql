CREATE OR REPLACE FUNCTION  fnTrisanoExportBuildPredicate (iexport_id integer) RETURNS varchar(4000) 
AS $$

DECLARE
  return_status 	varchar(50);
  thePredicate	varchar(4000);
  theRow		integer;
-- to build the predicate
DECLARE preds export_predicates%ROWTYPE;
DECLARE pred 	CURSOR  FOR SELECT * 
    FROM export_predicates 
    WHERE export_name_id = 1 --iexport_id
    ORDER BY id;

BEGIN

  thePredicate	:= ' WHERE ';
  theRow	:= 0;
  return_status	:= 'FAILURE';

  OPEN pred
  ;

  LOOP
    FETCH pred
    INTO 
    preds
    ;
    EXIT WHEN NOT FOUND;

    theRow	  := theRow + 1;
    thePredicate  := thePredicate || '( '|| preds.column_name
	  || ' ' || preds.comparison_operator || ' ''' || preds.comparison_value 
	  ||''' ' || ' ) '
	  || COALESCE(preds.comparison_logical,' ', preds.comparison_logical) 
	  || ' ' ;

/*
    thePredicate  := thePredicate || '( '|| preds.table_name || '.' || preds.column_name
	  || ' ' || preds.comparison_operator || ' ''' || preds.comparison_value 
	  ||''' ' || ' ) '
	  || COALESCE(preds.comparison_logical,' ', preds.comparison_logical) 
	  || ' ' ;
*/	  

  END LOOP;
 
  -- where there any rows in the predicates
  IF theRow = 0
  THEN
    thePredicate	:= ' ';
  ELSE
    thePredicate	:= thePredicate || ' ; ';
  END IF;

  RETURN thePredicate;

END;
$$ 
LANGUAGE plpgsql;
