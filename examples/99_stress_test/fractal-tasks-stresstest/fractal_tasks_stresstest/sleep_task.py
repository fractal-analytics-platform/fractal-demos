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
) -> Dict[str, Any]:
    """
    :param sleep_time: Number of components to be added to metadata
    """

    logger.info(f"This is a log from sleep_task, with {sleep_task=}")
    time.sleep(sleep_time)

    return {}


if __name__ == "__main__":
    from fractal_tasks_core.tasks._utils import run_fractal_task

    run_fractal_task(task_function=sleep_task)
