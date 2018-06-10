select 
    _kf_hh_data_id, _kp_hh_member_data_id
    ,Program
    ,name_last, name_first, name_nickname, name_last_preferred
    ,gender, race, ethnicity, disabled, veteran, education, insur_health
from
    "Household Member Data"
where
    name_last like 'Conway' or name_last like 'Inabnitt' or name_last like 'Anderson' or name_last like 'Sequoia' or name_last like 'Fyrrce' or name_last like 'Working' or name_last like 'Gallagher (Darr' or name_last like 'Pierre' or name_last like 'Lawrence' or name_last like 'Thomas' or name_last like 'Deshong' or name_last like 'Ragsdale' or name_last like 'Sorensen' or name_last like 'Calvin'