from celery import shared_task
from celery.utils.log import get_task_logger
import time 
logger = get_task_logger(__name__)

@shared_task
def sample_task():
    logger.info('Sample task work')
    time.sleep(20)
    print("here")