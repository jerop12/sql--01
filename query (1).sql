--Select all the employees who were born between January 1, 1952 and December 31, 1955 and their titles and title date ranges
-- Order the results by emp_no

SELECT 
    employees.emp_no, 
    employees.first_name,
    employees.last_name,
    titles.title,
    titles.from_date,
    titles.to_date
    FROM employees 
    JOIN titles ON employees.emp_no = titles.emp_no
    WHERE birth_date BETWEEN '1952/01/01' AND '1955/12/31'
    ORDER BY emp_no
-- Select only the current title for each employee
SELECT DISTINCT emp_no, first_name, last_name, last_value(title) OVER (PARTITION BY emp_no ORDER BY from_date
    RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
FROM (
SELECT 
    employees.emp_no, 
    employees.first_name,
    employees.last_name,
    titles.title,
    titles.from_date,
    titles.to_date
    FROM employees 
    JOIN titles ON employees.emp_no = titles.emp_no
    WHERE birth_date BETWEEN '1952/01/01' AND '1955/12/31'
    ORDER BY emp_no
    ) emp_titles
-- Count the total number of employees about to retire by their current job title
SELECT DISTINCT 
    title, COUNT(*)
    FROM employees 
    JOIN titles ON employees.emp_no = titles.emp_no
    WHERE birth_date BETWEEN '1952/01/01' AND '1955/12/31'
    GROUP BY title
--Write a query to count the total number of employees per department.*/
With latest_dept AS  (SELECT DISTINCT emp_no, last_value(dept_no) OVER (PARTITION BY emp_no ORDER BY from_date
            RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as dept_no
FROM dept_emp)
Select dept_name, count(distinct emp_no) as emp_count from latest_dept LEFT JOIN departments on latest_dept.dept_no = departments.dept_no
GROUP BY dept_name
-- Bonus: Find the highest salary per department and department manager

--Highest salary per department manager
with latest_manager_salaries as (
with latest_salaries as (
with latest_emp as( 
select emp_no,
       max(from_date) as latest_appt 
       from salaries group by emp_no)
select latest_emp.*, 
       salaries.salary 
       from salaries join latest_emp 
       on salaries.emp_no=latest_emp.emp_no 
       and salaries.from_date=latest_emp.latest_appt
       order by emp_no),

current_managers as(
select dept_no, emp_no, from_date from dept_manager where to_date= '9999-01-01')
select current_managers.dept_no, 
       latest_salaries.emp_no, 
       latest_salaries.salary 
       from current_managers join
       latest_salaries on current_managers.emp_no=latest_salaries.emp_no)
select max(salary) from latest_manager_salaries


--Highest salary per department
with latest_emp_salaries as (
with latest_emp_date as(
with latest_emp as (select emp_no, max(from_date) as from_date from dept_emp group by emp_no)
select latest_emp.emp_no, 
       latest_emp.from_date, 
       dept_emp.dept_no
       from latest_emp join dept_emp 
       on latest_emp.emp_no=dept_emp.emp_no
        and dept_emp.from_date=latest_emp.from_date)
select latest_emp_date.emp_no,
					latest_emp_date.dept_no,
					salaries.salary
					from latest_emp_date join salaries
					on latest_emp_date.emp_no=salaries.emp_no
					and latest_emp_date.from_date=salaries.from_date
					order by emp_no)
		select dept_no, 
				max(salary) as highest_salary from
				latest_emp_salaries
				group by dept_no
				order by dept_no 