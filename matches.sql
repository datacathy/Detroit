CREATE OR REPLACE FUNCTION matches(s1 text, s2 text) RETURNS BOOLEAN AS $$
       BEGIN
	IF (trim(TRAILING ' ST' FROM $1) = $2) OR (trim(TRAILING ' ST' FROM $2) = $1) OR
	   (trim(TRAILING ' BLVD' FROM $1) = $2) OR (trim(TRAILING ' BLVD' FROM $2) = $1) OR
	   (trim(TRAILING ' RD' FROM $1) = $2) OR (trim(TRAILING ' RD' FROM $2) = $1) OR
	   (trim(TRAILING ' AVE' FROM $1) = $2) OR (trim(TRAILING ' AVE' FROM $2) = $1) OR
	   (trim(TRAILING ' DR' FROM $1) = $2) OR (trim(TRAILING ' DR' FROM $2) = $1) OR
	   (trim(TRAILING ' STREET' FROM $1) = $2) OR (trim(TRAILING ' STREET' FROM $2) = $1) OR
	   (trim(TRAILING ' ROAD' FROM $1) = $2) OR (trim(TRAILING ' ROAD' FROM $2) = $1) OR
	   (trim(TRAILING ' DRIVE' FROM $1) = $2) OR (trim(TRAILING ' DRIVE' FROM $2) = $1) OR
	   (trim(TRAILING ' BOULEVARD' FROM $1) = $2) OR (trim(TRAILING ' BOULEVARD' FROM $2) = $1) OR
	   (trim(TRAILING ' AVENUE' FROM $1) = $2) OR (trim(TRAILING ' AVENUE' FROM $2) = $1) OR
	   ($1 = $2)
	THEN RETURN TRUE;
	ELSE RETURN FALSE;
	END IF;
       END;
$$ LANGUAGE plpgsql;
