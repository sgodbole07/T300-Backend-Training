package com.example.leavemanagement.service;


import com.example.leavemanagement.dto.LeaveRequestDto;
import com.example.leavemanagement.dto.LeaveResponseDto;
import com.example.leavemanagement.exception.InvalidLeaveDateException;
import com.example.leavemanagement.exception.LeaveNotFoundException;
import com.example.leavemanagement.model.Leave;
import com.example.leavemanagement.model.LeaveStatus;
import com.example.leavemanagement.model.LeaveType;
import com.example.leavemanagement.repository.LeaveRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDate;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class LeaveServiceTest {

    @Mock
    private LeaveRepository leaveRepository;

    @InjectMocks
    private LeaveService leaveService;

    @Test
    void createLeave_shouldSetPendingStatus() {
        LeaveRequestDto request = new LeaveRequestDto(
                1L, LeaveType.CASUAL, "Family function",
                LocalDate.of(2026, 12, 1), LocalDate.of(2026, 12, 3));
        when(leaveRepository.save(any(Leave.class))).thenAnswer(invocation -> {
            Leave saved = invocation.getArgument(0);
            saved.setId(1L);
            return saved;
        });

        LeaveResponseDto response = leaveService.createLeave(request);

        assertThat(response.id()).isEqualTo(1L);
        assertThat(response.status()).isEqualTo(LeaveStatus.PENDING);
        assertThat(response.reason()).isEqualTo("Family function");
    }

    @Test
    void createLeave_shouldThrowWhenEndDateBeforeStartDate() {
        LeaveRequestDto request = new LeaveRequestDto(
                1L, LeaveType.CASUAL, "Test",
                LocalDate.of(2026, 12, 10), LocalDate.of(2026, 12, 5));

        assertThatThrownBy(() -> leaveService.createLeave(request))
                .isInstanceOf(InvalidLeaveDateException.class);

        verify(leaveRepository, never()).save(any());
    }

    @Test
    void getLeaveById_shouldThrowWhenNotFound() {
        when(leaveRepository.getLeaveById(99L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> leaveService.getLeaveById(99L))
                .isInstanceOf(LeaveNotFoundException.class)
                .hasMessage("Leave not found with id 99");
    }

    @Test
    void updateLeave_shouldChangeAllowedFieldsOnly() {
        Leave existing = new Leave(
                1L, LeaveType.CASUAL, "Old reason", LeaveStatus.PENDING,
                LocalDate.of(2026, 12, 1), LocalDate.of(2026, 12, 3));
        existing.setId(10L);
        LeaveRequestDto update = new LeaveRequestDto(
                99L, LeaveType.PAID, "New reason",
                LocalDate.of(2026, 12, 20), LocalDate.of(2026, 12, 25));
        when(leaveRepository.getLeaveById(10L)).thenReturn(Optional.of(existing));
        when(leaveRepository.save(any(Leave.class))).thenAnswer(i -> i.getArgument(0));

        LeaveResponseDto response = leaveService.updateLeave(10L, update);

        assertThat(response.leaveType()).isEqualTo(LeaveType.PAID);
        assertThat(response.reason()).isEqualTo("New reason");
        assertThat(response.startDate()).isEqualTo(LocalDate.of(2026, 12, 20));
        assertThat(response.employeeId()).isEqualTo(1L);
        assertThat(response.status()).isEqualTo(LeaveStatus.PENDING);
    }
}