--create a join table
select * from Absenteeism_at_work a
left join compensation b
on a.ID = b.ID
left join Reasons r
on a.Reason_for_absence = r.Number;

--find the healthiest employees for the bonus
select * from Absenteeism_at_work
where Social_drinker = 0 and Social_smoker = 0
and Body_mass_index <25 and
Absenteeism_time_in_hours <(select AVG(Absenteeism_time_in_hours) from Absenteeism_at_work)

--compensation rate increase for non-smokers/budget $983,221 so $0.68 per hour/$1,414.40 per year
select count(*) as nonsmokers from Absenteeism_at_work
where Social_smoker = 0

--optimize this query
select a.ID, r.Reason, Month_of_absence, Body_mass_index,
Case When Body_mass_index < 18.5 Then 'Underweight'
     When Body_mass_index between 18.5 and 25 Then 'Healthy Weight'
	 When Body_mass_index between 25.1 and 30 Then 'Overweight'
	 When Body_mass_index > 30.1 Then 'Obese'
	 Else 'Unknown' End as BMI_Category,
Case When Month_of_absence in (12,1,2) Then 'Winter'
	 When Month_of_absence in (3,4,5) Then 'Spring'
	 When Month_of_absence in (6,7,8) Then 'Summer'
	 When Month_of_absence in (9.10,11) Then 'Fall'
	 Else 'Unknown' End as Season_Names,
Month_of_absence,
Day_of_the_week,
Transportation_expense,
Education,
Son,
Social_drinker,
Social_smoker,
Pet,
Disciplinary_failure,
Age,
Work_load_Average_day,
Absenteeism_time_in_hours
from Absenteeism_at_work a
left join compensation b
on a.ID = b.ID
left join Reasons r
on a.Reason_for_absence = r.Number;