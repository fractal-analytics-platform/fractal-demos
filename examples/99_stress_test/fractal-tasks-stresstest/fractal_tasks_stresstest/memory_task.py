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
    """
    logger.warning("ENTERING memory_task")
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
    from pydantic import BaseModel
    from fractal_tasks_stresstest._utils import run_fractal_task

    class TaskArguments(BaseModel):
        input_paths: Sequence[str]
        output_path: str
        metadata: Dict[str, Any]
        component: str
        total_time: Optional[float]
        memory_MB: Optional[int]

    run_fractal_task(
            task_function=memory_task, TaskArgsModel=TaskArguments
            )
