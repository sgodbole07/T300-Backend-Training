package com.example.leavemanagement.dto;

import com.example.leavemanagement.model.LeaveType;
import jakarta.validation.constraints.*;

import java.time.LocalDate;

public record LeaveRequestDto(
        @NotNull(message = "employeeId is required")
        @Positive(message = "employeeId must be a positive number")
        Long employeeId,

        @NotNull(message = "leaveType is required")
        LeaveType leaveType,

        @NotBlank(message = "reason is required")
        @Size(max = 200, message = "reason must not exceed 200 characters")
        String reason,

        @NotNull(message = "startDate is required")
        @FutureOrPresent(message = "startDate cannot be in the past")
        LocalDate startDate,

        @NotNull(message = "endDate is required")
        @FutureOrPresent(message = "endDate cannot be in the past")
        LocalDate endDate
) { }
