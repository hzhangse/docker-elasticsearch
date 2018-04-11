select 
    *
from 
   contacts
where 
    creation_time >= :sql_last_value
