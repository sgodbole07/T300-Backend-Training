# Leave Management API

A small Spring Boot REST API for handling employee leave requests. You can create, view, update and delete leaves. Everything is stored in memory (a `ConcurrentHashMap`), so there's no database and the data is gone when you restart the app.

Built with Java 17, Spring Boot 4.1.2 and Maven.

## How it's organised

Code lives under `com.example.leavemanagement`, split into controller, service, repository, model, dto, exception and configuration packages. The controller only deals with DTOs, the service holds the rules, and the repository just stores and fetches `Leave` objects.

A few rules worth knowing:
- New leaves always start as `PENDING`
- Start and end dates can't be in the past
- End date can't be before start date
- `PUT` only changes the leave type, reason and dates. The employee and status stay as they were.

## Running it

You need JDK 17 or newer. Maven isn't needed since the wrapper is included.

```bash
./mvnw spring-boot:run
```

(On Windows use `mvnw.cmd`.) The `dev` profile is active by default and the app runs on http://localhost:8081. Change the port or logging in `application-dev.properties` if you want.

To build a jar instead: `./mvnw clean package`

## Endpoints

| Method | Path | What it does |
|---|---|---|
| GET | /leaves | list all leaves |
| GET | /leaves/{id} | get one leave |
| POST | /leaves | create a leave (returns 201) |
| PUT | /leaves/{id} | update a leave |
| DELETE | /leaves/{id} | delete a leave (returns 204) |

Example body for POST and PUT:

```json
{
  "employeeId": 1,
  "leaveType": "CASUAL",
  "reason": "Family function",
  "startDate": "2026-12-01",
  "endDate": "2026-12-03"
}
```

Leave types are `CASUAL`, `PAID`, `ELECTION` and `MATERNITY`. Statuses are `PENDING`, `APPROVED` and `REJECTED`. Dates use the `yyyy-MM-dd` format.

Errors come back in one format:

```json
{
  "status": 404,
  "error": "Not Found",
  "messages": ["Leave not found with id 99"],
  "timestamp": "2026-11-19T17:50:00"
}
```

You'll get a 400 for validation problems, a bad date range, or a malformed body (wrong enum value, bad date format), and a 404 when the id doesn't exist.

## Tests

```bash
./mvnw test
```

There are service tests using Mockito (`LeaveServiceTest`) and controller tests using MockMvc (`LeaveControllerTest`). Mockito prints a warning about loading an agent dynamically when the tests run. It's harmless.

For manual testing, Postman works fine, or curl:

```bash
curl -X POST http://localhost:8081/leaves \
  -H "Content-Type: application/json" \
  -d '{"employeeId":1,"leaveType":"CASUAL","reason":"Family function","startDate":"2026-12-01","endDate":"2026-12-03"}'
```
