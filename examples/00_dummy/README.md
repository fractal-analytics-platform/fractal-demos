This example runs a workflow made of a single dummy task.
After successfully running, there will be a file `tmp_dummy/output/*.json` (NAME HAS TO BE MODIFIED), with content similar to
```
[
  {
    "task": "DUMMY TASK",
    "timestamp": "2022-10-14T10:28:33.452313+00:00",
    "input_paths": [
      "/tmp/*.png"
    ],
    "output_path": "/home/tommaso/Fractal/fractal-demos/examples/00_dummy/tmp_dummy/output/*.json",
    "metadata": {},
    "message": "bottle"
  }
]
```

Successfully ran with:
* fractal-server==0.3.3, fractal-client==0.2.9, fracal-tasks-core==0.2.3
* fractal-server==0.3.4, fractal-client==0.2.9, fracal-tasks-core==0.2.5
* fractal-server==70fe645ea200e502d9d1758ba298b240e0abd4ee (to become 0.3.5), fractal-client==0.2.9, fracal-tasks-core==0.2.4
