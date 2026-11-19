package com.example.leavemanagement.controller;

import com.example.leavemanagement.dto.LeaveResponseDto;
import com.example.leavemanagement.exception.LeaveNotFoundException;
import com.example.leavemanagement.model.LeaveStatus;
import com.example.leavemanagement.model.LeaveType;
import com.example.leavemanagement.service.LeaveService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.WebMvcTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import java.time.LocalDate;
import java.util.List;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(LeaveController.class)
class LeaveControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    private LeaveService leaveService;

    private LeaveResponseDto sampleResponse() {
        return new LeaveResponseDto(
                1L, 1L, LeaveType.CASUAL, "Family function", LeaveStatus.PENDING,
                LocalDate.of(2026, 12, 1), LocalDate.of(2026, 12, 3));
    }

    @Test
    void getAllLeaves_shouldReturn200WithList() throws Exception {
        when(leaveService.getAllLeaves()).thenReturn(List.of(sampleResponse()));

        mockMvc.perform(get("/leaves"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(1))
                .andExpect(jsonPath("$[0].id").value(1))
                .andExpect(jsonPath("$[0].status").value("PENDING"));
    }

    @Test
    void createLeave_shouldReturn201WhenRequestIsValid() throws Exception {
        when(leaveService.createLeave(any())).thenReturn(sampleResponse());

        String body = """
                {
                  "employeeId": 1,
                  "leaveType": "CASUAL",
                  "reason": "Family function",
                  "startDate": "2026-12-01",
                  "endDate": "2026-12-03"
                }
                """;

        mockMvc.perform(post("/leaves")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.id").value(1))
                .andExpect(jsonPath("$.status").value("PENDING"));
    }

    @Test
    void createLeave_shouldReturn400WhenReasonIsBlank() throws Exception {
        String body = """
                {
                  "employeeId": 1,
                  "leaveType": "CASUAL",
                  "reason": "",
                  "startDate": "2026-12-01",
                  "endDate": "2026-12-03"
                }
                """;

        mockMvc.perform(post("/leaves")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.messages[0]").value("reason is required"));
    }

    @Test
    void getLeaveById_shouldReturn404WhenNotFound() throws Exception {
        when(leaveService.getLeaveById(99L)).thenThrow(new LeaveNotFoundException(99L));

        mockMvc.perform(get("/leaves/99"))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.messages[0]").value("Leave not found with id 99"));
    }
}