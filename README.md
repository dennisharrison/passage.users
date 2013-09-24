
passage.user
============

1. Each organization on create gets a DB created for them.
1. Users are added to each org by having an identifier on the user.  There is a view for users-by-org.
2. Field added to each Org with the name of the DB
3. If the user doesn't have an org they are assumed to be app staff
4. Each user should be in a channel for the Passages

## Database Organization
 - Assessments_OrgName
 	 - Assessment
 	 	- QuestionsArray
	 - Question
	 	
	 - Answers
	 
	 
/dbname/_view/questions-by-assessment?key="questionId"

questionId:
	assessmentsArray: []