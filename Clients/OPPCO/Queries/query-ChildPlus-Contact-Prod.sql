SELECT
    Person.ChildPlusID
    , Person.PersonID
	, FamilyMembership.FamilyID
	, CONVERT(varchar(128), Person.FirstName)
		COLLATE Cyrillic_General_CI_AI as FirstName
	, CONVERT(varchar(128), Person.MiddleName)
		COLLATE Cyrillic_General_CI_AI as MiddleName
	, CONVERT(varchar(128), Person.LastName)
		COLLATE Cyrillic_General_CI_AI as LastName
	, CONVERT(varchar(128), Person.NameSuffix)
		COLLATE Cyrillic_General_CI_AI as NameSuffix
	, CONVERT(varchar(128), Person.PreferredName)
		COLLATE Cyrillic_General_CI_AI as PreferredName
	, CONVERT(varchar(128), Person.PreviousName)
		COLLATE Cyrillic_General_CI_AI as PreviousName
    , Person.Birthday
	, vPerson.Age
	, vPerson.GenderDescription
	, vPerson.RaceDescription
	, vPerson.PrimaryLanguageDescription
	, vPerson.SecondaryLanguageDescription
	, vPerson.ThirdLanguageDescription
    ,CASE
		WHEN vPerson.IsHispanic = 1 THEN 'Yes'
		WHEN vPerson.IsHispanic = 0 THEN 'No'
		WHEN vPerson.IsHispanic >= 2 THEN 'Unknown/Not reported'
 	END AS EthnicityHispanicLatino    
	, CONVERT(varchar(128), Person.Email1)
		COLLATE Cyrillic_General_CI_AI as Email1
    , Person.MailAddress1, Person.MailAddress2, Person.MailCity, Person.MailState, Person.MailZip
    , Person.PhysicalAddress1, Person.PhysicalAddress2, Person.PhysicalCity, Person.PhysicalState, Person.PhysicalZip
    , PrimaryPhone.PhoneType, PrimaryPhone.PhoneNumber, PrimaryPhone.Extension, PrimaryPhone.FullDescription
    , SecondaryPhone.PhoneType, SecondaryPhone.PhoneNumber, SecondaryPhone.Extension, SecondaryPhone.FullDescription
	,(SELECT
		COUNT(*)
		FROM DisabilityConcern DC
		JOIN DisabilityConcernActivity DCA
			ON DCA.DisabilityConcernID = DC.DisabilityConcernID
		WHERE Vperson.PersonID = DC.PersonID
			AND DCA.DisabilityConcernActivityTypeID = 'CDCD74A7-A992-446C-81BD-149382E92BD4'
			AND (DC.ClosedDate IS NULL
			OR DC.ClosedDate > GETDATE())) as Disabled
	, CodeEducation.Description as Education
	, CodeEmployment.Description as Employment
	, vFamily.PrimaryAdult
	,vIEP.PrimaryDisability
	,CASE
		WHEN vIEP.PrimaryDisability = 'Non-categorical/developmental delay' THEN 'Yes'
		ELSE 'No'
	 END AS DevelopmentalDelay
	,(SELECT CONVERT(varchar(128), PersonName)
		COLLATE Cyrillic_General_CI_AI from vPerson Temp where Temp.PersonID = Vperson.PersonCaseworker) as PersonCaseWorker
FROM Vperson
INNER JOIN Person
	   ON Person.PersonID = vPerson.PersonID
INNER JOIN FamilyMembership
       ON FamilyMembership.PersonID = vPerson.PersonID
INNER JOIN vFamily
       ON FamilyMembership.FamilyID = vFamily.FamilyID
INNER JOIN FamilyMember
	ON FamilyMember.PersonID = Vperson.PersonID
LEFT JOIN vIEP
	ON vIEP.PersonID = vPerson.PersonID
LEFT JOIN Code CodeEducation
	ON CodeEducation.CodeID = FamilyMember.EducationLevelCodeID
LEFT JOIN Code CodeEmployment
	ON CodeEmployment.CodeID = FamilyMember.EmploymentStatusCodeID
LEFT JOIN vPersonPhone as PrimaryPhone
	ON PrimaryPhone.PersonID = vPerson.PersonID AND
		PrimaryPhone.PhoneRank <= 1
LEFT JOIN vPersonPhone as SecondaryPhone
	ON SecondaryPhone.PersonID = vPerson.PersonID AND
		SecondaryPhone.PhoneRank = 2
--		Uncomment Unit Test to verify joins should return 4 family members
--		WHERE vFamily.FamilyID = '73A0AC56-6A33-480A-AE93-5BF444D18EF2'
ORDER BY Person.ChildPlusID DESC
