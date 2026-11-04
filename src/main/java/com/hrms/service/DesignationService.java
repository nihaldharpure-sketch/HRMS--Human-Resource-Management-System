package com.hrms.service;

import com.hrms.entity.Designation;
import com.hrms.repository.DesignationRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class DesignationService {

    private final DesignationRepository designationRepository;

    public DesignationService(DesignationRepository designationRepository) {
        this.designationRepository = designationRepository;
    }

    public List<Designation> getAllDesignations() {
        return designationRepository.findAll();
    }

    public Designation saveDesignation(Designation designation) {
        return designationRepository.save(designation);
    }

    public Designation getDesignationById(Long id) {
        return designationRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Designation not found with id: " + id));
    }
}
