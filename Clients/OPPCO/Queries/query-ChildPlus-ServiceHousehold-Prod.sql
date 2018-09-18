SELECT TOP 100
	   ProgramParticipation.ProgramParticipationID
	   , ProgramTerm.ProgramTermName
	   , ProgramTerm.BeginDate
	   , ProgramTerm.EndDate
	   , vCurrentStatusLoc.StatusDescription
	   , vCurrentStatusLoc.TerminationReason
	   , vCurrentStatusLoc.StartDate
	   , vCurrentStatusLoc.EndDate
	   , vCurrentStatusLoc.EntryDate
	   , Family.FamilyID
	   , vFamily.FamilyName
	   , vFamily.NumberInFamily
	   , vFamily.NumberInHousehold
	   , Family.MailAddress1, Family.MailCity, Family.MailState, Family.MailZip, Family.MailingAddressStartDate
	   , Family.PhysicalAddress1, Family.PhysicalCity, Family.PhysicalState, Family.PhysicalZip, Family.PhysicalAddressStartDate
	   , PrimaryPhone.PhoneType, PrimaryPhone.PhoneNumber, PrimaryPhone.Extension, PrimaryPhone.FullDescription
	   , SecondaryPhone.PhoneType, SecondaryPhone.PhoneNumber, SecondaryPhone.Extension, SecondaryPhone.FullDescription
	   , vFamily.TANFStatusDescription
	   , vFamily.SSIStatus
	   ,CASE
			WHEN ProgramParticipation.WICServicesReceived = 1 THEN 'Yes'
			WHEN ProgramParticipation.WICServicesReceived = 0 THEN 'No'
			WHEN ProgramParticipation.WICServicesReceived >= 2 THEN 'Unknown/Not reported'
   	   END AS WIC    
	   ,CASE
			WHEN ProgramParticipation.SNAP = 1 THEN 'Yes'
			WHEN ProgramParticipation.SNAP = 0 THEN 'No'
			WHEN ProgramParticipation.SNAP >= 2 THEN 'Unknown/Not reported'
   	   END AS SNAP    
	   , ProgramParticipation.MedicaidNumber
	   , ProgramParticipation.MedicaidEligibilityCodeID
	   , vFamily.ParentTypeDescription
	   ,CASE
			WHEN ParentTypeCodeID = 'A49CC970-9B38-4DA5-A4F3-2E000C9CD8D8' AND
				GenderCode = 'F' THEN 'Single Parent Female'
			WHEN ParentTypeCodeID = 'A49CC970-9B38-4DA5-A4F3-2E000C9CD8D8' AND
				GenderCode = 'M' THEN 'Single Parent Male'
			WHEN ParentTypeCodeID = '5E3550B1-2452-4E6D-91CE-BDB30B9A5C86' THEN 'Two Parent Household'
			WHEN Family.FamilyID IN (SELECT DISTINCT
						FamilyID
					FROM (SELECT DISTINCT
							FamilyID
						   ,COUNT(*) OVER (PARTITION BY familyID) AS NIF
						FROM Family) S
					WHERE NIF = 1) THEN 'Single Person'
			WHEN 1 = 0 THEN 'Two Adults NO Children'
			ELSE 'f. Other'
		END AS FamilyType
	   , vPerson.GenderDescription
	   , vPerson.PersonName
	   , vPerson.PersonID
	   , vFamily.NumberInHousehold
	   , Family.SocialSecurityIncome
	   ,CASE
			WHEN '88888888-0000-0000-0000-000000000002' IN (Family.Income1Descriptioncodeid, Family.Income2DescriptionCodeID, Family.Income3DescriptionCodeID, Family.Income4DescriptionCodeID, Family.Income5DescriptionCodeID) THEN 'Yes'
			ELSE 'No'
		END AS SocialSecurityIncomeCalculated
	   ,CASE
			WHEN '88888888-0000-0000-0000-000000000003' IN (Income1Descriptioncodeid, Income2DescriptionCodeID, Income3DescriptionCodeID, Income4DescriptionCodeID, Income5DescriptionCodeID) THEN 'Yes'
			ELSE 'No'
		END AS PensionCalculated
	   ,CASE
			WHEN '77777777-0000-0000-0000-000000000006' IN (Income1VerificationTypeCodeID, Income2VerificationTypeCodeID, Income3VerificationTypeCodeID, Income4VerificationTypeCodeID, Income5VerificationTypeCodeID) THEN 'Yes'
			ELSE 'No'
		END AS UnemploymentCalculated
	   ,CASE
			WHEN 'C29391B5-AF69-4668-9488-273B0A732E72' IN (Income1Descriptioncodeid, Income2DescriptionCodeID, Income3DescriptionCodeID, Income4DescriptionCodeID, Income5DescriptionCodeID) THEN 'Yes'
			ELSE 'No'
		END AS GeneralAssistanceCalculated
	   ,CASE
			WHEN
				((Income1DescriptionCodeID = '96143509-3ED4-47D4-BE99-32D94478832D' OR
				Income2DescriptionCodeID = '96143509-3ED4-47D4-BE99-32D94478832D' OR
				Income3DescriptionCodeID = '96143509-3ED4-47D4-BE99-32D94478832D' OR
				Income4DescriptionCodeID = '96143509-3ED4-47D4-BE99-32D94478832D' OR
				Income5DescriptionCodeID = '96143509-3ED4-47D4-BE99-32D94478832D') AND
				(Income1DescriptionCodeID NOT IN ('00000000-0000-0000-0000-000000000000', '96143509-3ED4-47D4-BE99-32D94478832D') OR
				Income2DescriptionCodeID NOT IN ('00000000-0000-0000-0000-000000000000', '96143509-3ED4-47D4-BE99-32D94478832D') OR
				Income3DescriptionCodeID NOT IN ('00000000-0000-0000-0000-000000000000', '96143509-3ED4-47D4-BE99-32D94478832D') OR
				Income4DescriptionCodeID NOT IN ('00000000-0000-0000-0000-000000000000', '96143509-3ED4-47D4-BE99-32D94478832D') OR
				Income5DescriptionCodeID NOT IN ('00000000-0000-0000-0000-000000000000', '96143509-3ED4-47D4-BE99-32D94478832D')
				)) THEN 'Yes'
			ELSE 'No'
		END AS EmploymentAndOtherCalculated
	   ,CASE
			WHEN ((Income1DescriptionCodeID = '96143509-3ED4-47D4-BE99-32D94478832D' OR
				Income2DescriptionCodeID = '96143509-3ED4-47D4-BE99-32D94478832D' OR
				Income3DescriptionCodeID = '96143509-3ED4-47D4-BE99-32D94478832D' OR
				Income4DescriptionCodeID = '96143509-3ED4-47D4-BE99-32D94478832D' OR
				Income5DescriptionCodeID = '96143509-3ED4-47D4-BE99-32D94478832D')) THEN 'Yes'
			ELSE 'No'
		END AS EmploymentOnlyCalculated
	    ,ProgramParticipation.EligibilityIncome
		,Family.MonthlyFamilyIncome
	   
FROM vFamily
INNER JOIN Family
	ON Family.FamilyID = vFamily.FamilyID
INNER JOIN FamilyMembership
	ON FamilyMembership.FamilyID = Family.familyID
LEFT JOIN vPerson
	ON vPerson.PersonID = FamilyMembership.PersonID
LEFT JOIN ProgramParticipation
	ON vPerson.PersonID = ProgramParticipation.PersonID
LEFT JOIN ProgramTerm
	ON ProgramTerm.ProgramTermID = ProgramParticipation.ProgramTermID
LEFT JOIN vCurrentStatusLoc
	on vCurrentStatusLoc.PersonID = ProgramParticipation.PersonID AND vCurrentStatusLoc.ProgramTermID = ProgramParticipation.ProgramTermID AND vCurrentStatusLoc.ProgramID = ProgramTerm.ProgramID
LEFT JOIN vFamilyPhone as PrimaryPhone
	ON PrimaryPhone.FamilyID = vFamily.FamilyID AND
		PrimaryPhone.PhoneRank <= 1
LEFT JOIN vFamilyPhone as SecondaryPhone
	ON SecondaryPhone.FamilyID = vFamily.FamilyID AND
		SecondaryPhone.PhoneRank = 2
WHERE YEAR(ProgramTerm.BeginDate) = 2017 
	AND FamilyMembership.FamilyID = '73a0ac56-6a33-480a-ae93-5bf444d18ef2'