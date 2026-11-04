# Human Resource Management System (HRMS)

A Java-based enterprise HRMS built with Spring Boot, Spring Security, JPA/Hibernate, MySQL, JSP, Bootstrap, and Maven.

## Features

- Authentication and role-based access
- Employee registration and profile management
- Department and designation management
- Attendance tracking and reports
- Leave request and approval workflow
- Payroll and payslip support
- Recruitment and candidate tracking
- Performance and dashboard reporting
- Notification support and secure API design

## Tech Stack

- Backend: Java 25, Spring Boot 3, Spring MVC, Spring Security
- Database: MySQL
- ORM: JPA / Hibernate
- Frontend: JSP / Bootstrap / JavaScript
- Build tool: Maven
- Deployment: Apache Tomcat

## Run Locally

1. Start MySQL and create a database named `hrms_db`.
2. Update database credentials in `src/main/resources/application.properties` if needed.
3. Run:

```bash
mvn spring-boot:run
```

4. Open the app in the browser:

- http://localhost:8080/login

## Default Login

- Username: `admin`
- Password: `admin123`

## API Notes

- Auth endpoints: `/api/auth/login`, `/api/auth/register`
- Employee endpoints: `/api/employees`
- Organization endpoints: `/api/departments`, `/api/designations`
- Attendance endpoints: `/api/attendance/**`

## Architecture

The application uses a layered enterprise structure:

- Controller
- Service
- Repository / DAO
- Entity / Model
- DTO
- Security
- JSP-based views
