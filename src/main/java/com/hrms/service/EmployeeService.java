package com.hrms.service;

import com.hrms.dto.EmployeeRequest;
import com.hrms.entity.*;
import com.hrms.repository.*;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.Set;

@Service
public class EmployeeService {

    private final EmployeeRepository employeeRepository;
    private final DepartmentRepository departmentRepository;
    private final DesignationRepository designationRepository;
    private final LeaveBalanceRepository leaveBalanceRepository;
    private final SalaryStructureRepository salaryStructureRepository;
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public EmployeeService(EmployeeRepository employeeRepository,
                          DepartmentRepository departmentRepository,
                          DesignationRepository designationRepository,
                          LeaveBalanceRepository leaveBalanceRepository,
                          SalaryStructureRepository salaryStructureRepository,
                          UserRepository userRepository,
                          PasswordEncoder passwordEncoder) {
        this.employeeRepository = employeeRepository;
        this.departmentRepository = departmentRepository;
        this.designationRepository = designationRepository;
        this.leaveBalanceRepository = leaveBalanceRepository;
        this.salaryStructureRepository = salaryStructureRepository;
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    public List<Employee> getAllEmployees() {
        return employeeRepository.findAll();
    }

    public Employee getEmployeeById(Long id) {
        return employeeRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Employee not found with id: " + id));
    }

    public Optional<Employee> findByEmail(String email) {
        return employeeRepository.findByEmail(email);
    }

    public List<Employee> searchEmployees(String query, Long departmentId, String status) {
        return employeeRepository.searchEmployees(query, departmentId, status);
    }

    @Transactional
    public Employee createEmployee(EmployeeRequest request) {
        if (request.getEmail() != null && !request.getEmail().isBlank()) {
            if (employeeRepository.findByEmail(request.getEmail()).isPresent()) {
                throw new IllegalArgumentException("An employee with email " + request.getEmail() + " already exists.");
            }
        }

        Department department = departmentRepository.findById(request.getDepartmentId())
                .orElseThrow(() -> new IllegalArgumentException("Department not found"));
        Designation designation = designationRepository.findById(request.getDesignationId())
                .orElseThrow(() -> new IllegalArgumentException("Designation not found"));

        Employee employee = new Employee();
        employee.setFirstName(request.getFirstName().trim());
        employee.setLastName(request.getLastName().trim());
        employee.setEmail(request.getEmail() != null ? request.getEmail().trim().toLowerCase() : null);
        employee.setPhone(request.getPhone());

        // Auto-generate employee code if missing
        if (request.getEmployeeCode() == null || request.getEmployeeCode().isBlank()) {
            long count = employeeRepository.count() + 1001;
            employee.setEmployeeCode("EMP-" + count);
        } else {
            employee.setEmployeeCode(request.getEmployeeCode().trim().toUpperCase());
        }

        employee.setDateOfJoining(request.getDateOfJoining() != null ? request.getDateOfJoining() : LocalDate.now());
        employee.setStatus(request.getStatus() != null ? request.getStatus() : "ACTIVE");
        employee.setEmploymentType(request.getEmploymentType() != null ? request.getEmploymentType() : "FULL_TIME");
        employee.setProbationPeriodMonths(request.getProbationPeriodMonths() != null ? request.getProbationPeriodMonths() : 3);
        employee.setDepartment(department);
        employee.setDesignation(designation);

        // Personal, address, bank
        employee.setDateOfBirth(request.getDateOfBirth());
        employee.setGender(request.getGender());
        employee.setMaritalStatus(request.getMaritalStatus());
        employee.setAddressStreet(request.getAddressStreet());
        employee.setAddressCity(request.getAddressCity());
        employee.setAddressState(request.getAddressState());
        employee.setAddressZip(request.getAddressZip());
        employee.setEmergencyContactName(request.getEmergencyContactName());
        employee.setEmergencyContactPhone(request.getEmergencyContactPhone());
        employee.setEmergencyContactRelation(request.getEmergencyContactRelation());
        employee.setQualification(request.getQualification());
        employee.setExperienceYears(request.getExperienceYears() != null ? request.getExperienceYears() : 0.0);
        employee.setBankName(request.getBankName());
        employee.setBankAccountNumber(request.getBankAccountNumber());
        employee.setBankIfsc(request.getBankIfsc());

        if (request.getManagerId() != null) {
            employee.setManager(employeeRepository.findById(request.getManagerId())
                    .orElseThrow(() -> new IllegalArgumentException("Manager not found")));
        }

        Employee saved = employeeRepository.save(employee);

        // Initialize Leave Balance for current year
        int currentYear = LocalDate.now().getYear();
        if (leaveBalanceRepository.findByEmployeeIdAndYear(saved.getId(), currentYear).isEmpty()) {
            LeaveBalance balance = new LeaveBalance(saved, currentYear);
            leaveBalanceRepository.save(balance);
        }

        // Initialize Salary Structure
        if (salaryStructureRepository.findByEmployeeId(saved.getId()).isEmpty()) {
            SalaryStructure salary = new SalaryStructure();
            salary.setEmployee(saved);
            BigDecimal base = request.getBasicSalary() != null ? request.getBasicSalary() : BigDecimal.valueOf(50000);
            salary.setBasicSalary(base);
            salary.setHra(base.multiply(BigDecimal.valueOf(0.40))); // 40% HRA
            salary.setConveyance(BigDecimal.valueOf(2500));
            salary.setMedicalAllowance(BigDecimal.valueOf(1500));
            salary.setSpecialAllowance(BigDecimal.valueOf(3000));
            salary.setProvidentFund(base.multiply(BigDecimal.valueOf(0.12))); // 12% PF
            salary.setProfessionalTax(BigDecimal.valueOf(200));
            salaryStructureRepository.save(salary);
        }

        // Provision user account for self-service if not exists
        String username = saved.getFirstName().toLowerCase().replaceAll("[^a-z0-9]", "");
        if (userRepository.findByUsername(username).isPresent()) {
            username = saved.getEmployeeCode().toLowerCase();
        }
        if (userRepository.findByEmployeeId(saved.getId()).isEmpty() && userRepository.findByUsername(username).isEmpty()) {
            UserAccount account = new UserAccount();
            account.setUsername(username);
            account.setPassword(passwordEncoder.encode("user123"));
            account.setFullName(saved.getFullName());
            account.setRoles(Set.of(Role.EMPLOYEE));
            account.setEmployee(saved);
            userRepository.save(account);
        }

        return saved;
    }

    @Transactional
    public Employee updateEmployee(Long id, EmployeeRequest request) {
        Employee employee = getEmployeeById(id);

        if (request.getEmail() != null && !request.getEmail().equalsIgnoreCase(employee.getEmail())) {
            Optional<Employee> existing = employeeRepository.findByEmail(request.getEmail());
            if (existing.isPresent() && !existing.get().getId().equals(id)) {
                throw new IllegalArgumentException("Email " + request.getEmail() + " is already in use.");
            }
            employee.setEmail(request.getEmail().trim().toLowerCase());
        }

        employee.setFirstName(request.getFirstName().trim());
        employee.setLastName(request.getLastName().trim());
        employee.setPhone(request.getPhone());
        employee.setEmploymentType(request.getEmploymentType());
        employee.setStatus(request.getStatus());

        if (request.getDepartmentId() != null) {
            employee.setDepartment(departmentRepository.findById(request.getDepartmentId())
                    .orElseThrow(() -> new IllegalArgumentException("Department not found")));
        }
        if (request.getDesignationId() != null) {
            employee.setDesignation(designationRepository.findById(request.getDesignationId())
                    .orElseThrow(() -> new IllegalArgumentException("Designation not found")));
        }
        if (request.getManagerId() != null) {
            employee.setManager(employeeRepository.findById(request.getManagerId()).orElse(null));
        }

        employee.setDateOfBirth(request.getDateOfBirth());
        employee.setGender(request.getGender());
        employee.setMaritalStatus(request.getMaritalStatus());
        employee.setAddressStreet(request.getAddressStreet());
        employee.setAddressCity(request.getAddressCity());
        employee.setAddressState(request.getAddressState());
        employee.setAddressZip(request.getAddressZip());
        employee.setEmergencyContactName(request.getEmergencyContactName());
        employee.setEmergencyContactPhone(request.getEmergencyContactPhone());
        employee.setEmergencyContactRelation(request.getEmergencyContactRelation());
        employee.setQualification(request.getQualification());
        employee.setExperienceYears(request.getExperienceYears());
        employee.setBankName(request.getBankName());
        employee.setBankAccountNumber(request.getBankAccountNumber());
        employee.setBankIfsc(request.getBankIfsc());

        return employeeRepository.save(employee);
    }

    @Transactional
    public void recordExit(Long id, LocalDate exitDate, String reason, String exitStatus) {
        Employee employee = getEmployeeById(id);
        employee.setExitDate(exitDate != null ? exitDate : LocalDate.now());
        employee.setExitReason(reason);
        employee.setExitStatus(exitStatus != null ? exitStatus : "RESIGNED");
        employee.setStatus("INACTIVE");
        employeeRepository.save(employee);
    }

    public long countTotal() {
        return employeeRepository.count();
    }

    public long countActive() {
        return employeeRepository.countByStatus("ACTIVE");
    }

    public long countInactive() {
        return employeeRepository.countByStatus("INACTIVE") + employeeRepository.countByStatus("TERMINATED");
    }

    public long countOnLeave() {
        return employeeRepository.countByStatus("ON_LEAVE");
    }
}
