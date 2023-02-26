package com.example.systemapi.InstanceControl;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping(path = "/")
public class StreamController {
    @PostMapping("/streams/{streamId}/started")
    public static Map<String, Boolean> started(@PathVariable("streamId") String streamId) {
        HashMap<String, Boolean> map = new HashMap<>();
        map.put(streamId, true);
        return map;
    }

    @PostMapping("/streams/{streamId}/finished")
    public static Map<String, Boolean> finished(@PathVariable("streamId") String streamId) {
        HashMap<String, Boolean> map = new HashMap<>();
        map.put(streamId, true);
        return map;
    }
}
