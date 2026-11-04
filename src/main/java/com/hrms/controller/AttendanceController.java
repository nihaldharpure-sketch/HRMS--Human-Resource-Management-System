package com.hrms.controller;

import com.hrms.entity.Attendance;
import com.hrms.entity.Employee;
import com.hrms.repository.EmployeeRepository;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api")
public class AttendanceController {

    private final EmployeeRepository employeeRepository;

    public AttendanceController(EmployeeRepository employeeRepository) {
        this.employeeRepository = employeeRepository;
    }

    @GetMapping("/attendance")
    public List<Attendance> getAttendance() {
        return List.of();
    }

    @PostMapping("/attendance/check-in")
    public Map<String, Object> checkIn(@RequestParam Long employeeId) {
        Employee employee = employeeRepository.findById(employeeId)
                .orElseThrow(() -> new IllegalArgumentException("Employee not found"));

        Attendance attendance = new Attendance();
        attendance.setEmployee(employee);
        attendance.setAttendanceDate(LocalDate.now());
        attendance.setCheckIn(LocalDateTime.now());
        attendance.setStatus("PRESENT");

        return Map.of("message", "Check-in successful", "employee", employee.getFirstName() + " " + employee.getLastName());
    }
}
