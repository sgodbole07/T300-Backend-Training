package com.example.leavemanagement.dto;

import com.example.leavemanagement.model.LeaveStatus;
import com.example.leavemanagement.model.LeaveType;

import java.time.LocalDate;

public record LeaveResponseDto(
        Long id,
        Long employeeId,
        LeaveType leaveType,
        String reason,
        LeaveStatus status,
        LocalDate startDate,
        LocalDate endDate
) { }
