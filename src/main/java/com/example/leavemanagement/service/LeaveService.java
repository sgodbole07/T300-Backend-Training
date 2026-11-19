package com.example.leavemanagement.service;

import com.example.leavemanagement.dto.LeaveRequestDto;
import com.example.leavemanagement.dto.LeaveResponseDto;
import com.example.leavemanagement.exception.InvalidLeaveDateException;
import com.example.leavemanagement.exception.LeaveNotFoundException;
import com.example.leavemanagement.model.Leave;
import com.example.leavemanagement.model.LeaveStatus;
import com.example.leavemanagement.repository.LeaveRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class LeaveService {

    private final LeaveRepository leaveRepository;

    public LeaveService(LeaveRepository leaveRepository) {
        this.leaveRepository = leaveRepository;
    }

    public List<LeaveResponseDto> getAllLeaves() {
        return leaveRepository.getAllLeaves().stream()
                .map(this::toResponse)
                .toList();
    }

    public LeaveResponseDto getLeaveById(Long id) {
        return toResponse(findOrThrow(id));
    }

    public LeaveResponseDto createLeave(LeaveRequestDto request) {
        validateDates(request);
        Leave leave = new Leave(
                request.employeeId(),
                request.leaveType(),
                request.reason(),
                LeaveStatus.PENDING,
                request.startDate(),
                request.endDate());
        return toResponse(leaveRepository.save(leave));
    }



    public LeaveResponseDto updateLeave(Long id, LeaveRequestDto request) {
        Leave leave = findOrThrow(id);
        validateDates(request);
        leave.setLeaveType(request.leaveType());
        leave.setReason(request.reason());
        leave.setStartDate(request.startDate());
        leave.setEndDate(request.endDate());
        return toResponse(leaveRepository.save(leave));
    }

    public void deleteLeave(Long id) {
        if (!leaveRepository.deleteById(id)) {
            throw new LeaveNotFoundException(id);
        }
    }

    private Leave findOrThrow(Long id) {
        return leaveRepository.getLeaveById(id)
                .orElseThrow(() -> new LeaveNotFoundException(id));
    }

    private void validateDates(LeaveRequestDto request) {
        if (request.endDate().isBefore(request.startDate())) {
            throw new InvalidLeaveDateException("endDate cannot be before startDate");
        }
    }

    private LeaveResponseDto toResponse(Leave leave) {
        return new LeaveResponseDto(
                leave.getId(),
                leave.getEmployeeId(),
                leave.getLeaveType(),
                leave.getReason(),
                leave.getStatus(),
                leave.getStartDate(),
                leave.getEndDate());
    }
}