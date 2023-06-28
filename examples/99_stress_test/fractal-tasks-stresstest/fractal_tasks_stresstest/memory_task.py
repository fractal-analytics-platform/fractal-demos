import logging
import time
import sys
from typing import Any
from typing import Dict
from typing import Optional
from typing import Sequence


logger = logging.getLogger(__name__)


def memory_task(
    *,
    input_paths: Sequence[str],
    output_path: str,
    metadata: Dict[str, Any],
    component: str,
    # Task-specific arguments
    total_time: float = 2.0,
    memory_MB: int = 100,
) -> Dict[str, Any]:
    """
    Memory-consuming task

    :param total_time: How long the task should run
    :param memory_task: How much memory the task should use
    """
    logger.info(
        f"This is a log from memory_task, with {total_time=} and {memory_MB=}"
    )
    time_start = time.perf_counter()
    first_iteration = True
    while time.perf_counter() - time_start < total_time:
        obj = '1' * (memory_MB * 10**6)
        if first_iteration:
            size = sys.getsizeof(obj)
            size_MB = size / 1e6
            logger.warning(f"{size=}, {size_MB=}")
            first_iteration = False
        del obj
    logger.warning("EXITING memory_task")

    return {}


if __name__ == "__main__":
    from fractal_tasks_core.tasks._utils import run_fractal_task

    run_fractal_task(task_function=memory_task)
