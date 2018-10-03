select 
    "timestamp_created"
    ,"key_primary_waitlist_id"
    ,"intake_date"
    ,"intake_case_manager"
    ,"outcome_status"
    ,"outcome_outcome"
    ,"outcome_date_inactive"
    ,"outcome_case_manager"
from
    Waitlist
where
    Waitlist.intake_date >= '10/01/2018' and Waitlist.intake_date <= '10/30/2018'