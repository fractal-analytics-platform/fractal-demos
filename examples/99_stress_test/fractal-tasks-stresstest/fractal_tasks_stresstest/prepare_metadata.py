import logging
from typing import Any
from typing import Dict
from typing import Optional
from typing import Sequence


logger = logging.getLogger(__name__)


def prepare_metadata(
    *,
    input_paths: Sequence[str],
    output_path: str,
    metadata: Dict[str, Any],
    # Task-specific arguments
    num_components: int = 10,
) -> Dict[str, Any]:
    """
    Prepare metadata

    :param num_components: Number of components
    """

    list_components = [f"{ind:04d}" for ind in range(num_components)]
    metadata_update = {"component": list_components}
    logger.info(f"This is a log from prepare_metadata, with {num_components=}")
    return metadata_update


if __name__ == "__main__":
    from fractal_tasks_core.tasks._utils import run_fractal_task

    run_fractal_task(task_function=prepare_metadata)
