import logging
import time
from typing import Any
from typing import Dict
from typing import Optional
from typing import Sequence


logger = logging.getLogger(__name__)


def sleep_task(
    *,
    input_paths: Sequence[str],
    output_path: str,
    metadata: Dict[str, Any],
    component: str,
    # Task-specific arguments
    sleep_time: float = 1.0,
    memory_MB: Optional
) -> Dict[str, Any]:
    """
    :param sleep_time: Number of components to be added to metadata
    """

    logger.info("ENTERING sleep_task")
    time.sleep(sleep_time)
    logger.info("EXITING sleep_task")

    return {}


if __name__ == "__main__":
    from pydantic import BaseModel
    from fractal_tasks_stresstest._utils import run_fractal_task

    class TaskArguments(BaseModel):
        input_paths: Sequence[str]
        output_path: str
        metadata: Dict[str, Any]
        component: str
        sleep_time: Optional[float]

    run_fractal_task(task_function=sleep_task, TaskArgsModel=TaskArguments)
