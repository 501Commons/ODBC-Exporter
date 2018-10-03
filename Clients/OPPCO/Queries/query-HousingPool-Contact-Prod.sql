select
    Household.timestamp_created
    ,"key_foreign_waitlist_id"
    ,"Client_Name_First"
    ,"Client_Name_Last"
    ,"Client_DOB"
    ,"Client_Relationship_to_Household"
    ,"Client_Gender"
    ,"Client_Ethnicity"
    ,"Client_Race"
    ,"Client_Language"
    ,"Client_Pregnancy_Due_Date"
    ,"Client_Custody_Status"
    ,"Client_Intimate_Partner_Violence"
    ,"Client_Medically_Fragile"
    ,"Client_Veteran"
    ,"Client_Disabled"
    ,"Client_Age"
    ,"Client_MH_Disability"
    ,"Client_MH_Services"
from
    Household
INNER JOIN Waitlist
       ON Household.key_foreign_waitlist_id = Waitlist.key_primary_waitlist_id
where
    intake_date > '12/01/2017'