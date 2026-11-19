package com.example.leavemanagement.exception;

import com.example.leavemanagement.dto.ErrorResponse;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.time.LocalDateTime;
import java.util.List;

@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(LeaveNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleNotFound(LeaveNotFoundException ex) {
        return build(HttpStatus.NOT_FOUND, List.of(ex.getMessage()));
    }

    @ExceptionHandler(InvalidLeaveDateException.class)
    public ResponseEntity<ErrorResponse> handleInvalidDate(InvalidLeaveDateException ex) {
        return build(HttpStatus.BAD_REQUEST, List.of(ex.getMessage()));
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ErrorResponse> handleValidation(MethodArgumentNotValidException ex) {
        List<String> messages = ex.getBindingResult().getFieldErrors().stream()
                .map(error -> error.getDefaultMessage())
                .toList();
        return build(HttpStatus.BAD_REQUEST, messages);
    }

    @ExceptionHandler(HttpMessageNotReadableException.class)
    public ResponseEntity<ErrorResponse> handleUnreadable(HttpMessageNotReadableException ex) {
        return build(HttpStatus.BAD_REQUEST,
                List.of("Malformed request: check JSON format, enum values and date format (yyyy-MM-dd)"));
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse> handleGeneric(Exception ex) {
        return build(HttpStatus.INTERNAL_SERVER_ERROR, List.of("Something went wrong"));
    }

    private ResponseEntity<ErrorResponse> build(HttpStatus status, List<String> messages) {
        ErrorResponse body = new ErrorResponse(
                status.value(), status.getReasonPhrase(), messages, LocalDateTime.now());
        return ResponseEntity.status(status).body(body);
    }
}