import sys
sys.path.append("../fractal_tasks_stresstest")

from memory_task import memory_task  # noqa

memory_task(
        input_paths=["/tmp"],
        output_path="/tmp",
        metadata={},
        component="asd",
        total_time=4.0,
        memory_MB=1000,
        )
