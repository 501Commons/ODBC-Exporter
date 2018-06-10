select
    FILE_NUMBER, _kp_hh_data_id
    ,CLIENT_LAST_NAME, CLIENT_FIRST_NAME, CLIENT_MIDDLE_NAME
    ,RESIDENCE_STREET_ADDRESS, RESIDENCE_CITY, RESIDENCE_STATE, RESIDENCE_ZIP_CODE
    ,MAILING_STREET_ADDRES, MAILING_CITY, MAILING_STATE, MAILING_ZIP_CODE
    ,PHONE, AreaCode, AreaCodeMessage, MessagePhone
    ,DATE_CREATED, CertificationDate, PROGRAM, HEAT_SYS_REPAIR_REPLACE, ApplicationType
    ,ReceivedFoodStamps, RoundedMonthlyNetIncome, HHM_TotalNumberInHousehold
    ,CSBGOther, MILITARY_INCOMDE, VETERANS_BENEFITS, CSBGGeneralAssistance, SELF_EMPLOYED
    ,EARNED_INCOME, CHILD_SUPPORT_INCOME, HousingStatusSelection, CSBGFamilyType
    ,CSBGTANF, CSBGSSI, CSBGSocialSecurity, CSBGPension, CSBGIncomeSourceTypes, CSBGUnemploymentIns
from LIHEAP
where
    HEAT_SYS_REPAIR_REPLACE IS NOT NULL or CLIENT_LAST_NAME = 'Deshong' or CLIENT_LAST_NAME = 'Calvin' or CLIENT_LAST_NAME = 'Ragsdale' or CLIENT_LAST_NAME = 'Sorensen'