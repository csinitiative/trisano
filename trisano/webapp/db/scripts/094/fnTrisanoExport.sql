CREATE OR REPLACE FUNCTION  fnTrisanoExport (integer) RETURNS varchar 
AS $$
declare 
	iexport_id  ALIAS  FOR $1;
	vexport_name varchar(50);
	return_status varchar(50);
BEGIN
-- If the passed in value is NULL, then error!
	IF iexport_id IS NULL  
	THEN RETURN 'NULL VALUE PASSED';
	END IF;
-- If the passed in value is NOT NULL, but is not found in the export_names table, then error!
	SELECT export_name INTO vexport_name FROM export_names WHERE id = iexport_id;
	if vexport_name is NULL
	THEN RETURN 'Invalid export_name.id';
	END IF;

-- Get all the columns for the export_name that will need to be retrieved from the database.
	IF (vexport_name = 'CDC')
	THEN

	   return_status = fnTrisanoExportNonGenericCdc(iexport_id, vexport_name);
--	   return_status = fnTrisanoExportCdc(iexport_id, vexport_name);
	   return return_status;
--	   IF substring(return_status,1,7) = 'SUCCESS'
--	   THEN
--		return 'SUCCESS';
--	   ELSE
--		return 'FAILURE';
--	   END IF;
	ELSE
		return vexport_name;
	END IF;

END;
$$ 
LANGUAGE plpgsql;

