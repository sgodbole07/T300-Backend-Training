package com.example.leavemanagement.repository;

import com.example.leavemanagement.model.Leave;
import org.springframework.stereotype.Repository;


import java.util.Comparator;
import java.util.List;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicLong;

@Repository
public class LeaveRepository {


    private final ConcurrentHashMap<Long, Leave> storage = new ConcurrentHashMap<>();
    private final AtomicLong idGenerator = new AtomicLong(0);

    public Optional<Leave> getLeaveById(Long id) {

        Leave leave = storage.get(id);
        return Optional.ofNullable(leave);
    }

    public List<Leave> getAllLeaves() {
        return storage.values().stream()
                .sorted(Comparator.comparing(Leave::getId))
                .toList();
    }


    public Leave save(Leave leave) {
        if (leave.getId() == null) {
            leave.setId(idGenerator.incrementAndGet());
        }
        storage.put(leave.getId(), leave);
        return leave;
    }

    public boolean deleteById(Long id) {
        return storage.remove(id) != null;
    }


    public boolean existsById(Long id) {
        return storage.containsKey(id);
    }


}
