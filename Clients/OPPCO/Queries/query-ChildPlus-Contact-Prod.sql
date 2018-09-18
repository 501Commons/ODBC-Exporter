SELECT TOP 100
    Person.ChildPlusID
    , Person.PersonID
	, FamilyMembership.FamilyID
	, Person.FirstName
	, Person.MiddleName
	, Person.LastName
	, Person.NameSuffix
	, Person.PreferredName
	, Person.PreviousName
    , Person.Birthday
	, vFamily.PrimaryAdult
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
	, Person.Email1
	, RIGHT(vPerson.SSN, 4) as SSNShort
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
FROM Vperson
INNER JOIN Person
	   ON Person.PersonID = vPerson.PersonID
INNER JOIN FamilyMembership
       ON FamilyMembership.PersonID = vPerson.PersonID
INNER JOIN vFamily
       ON FamilyMembership.FamilyID = vFamily.FamilyID
INNER JOIN FamilyMember
	ON FamilyMember.PersonID = Vperson.PersonID
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
WHERE FamilyMembership.FamilyID = '73a0ac56-6a33-480a-ae93-5bf444d18ef2'