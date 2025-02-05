""" Example Airflow Hook"""
from airflow.hooks.base import BaseHook
from airflow.plugins_manager import AirflowPlugin
from airflow.utils.decorators import apply_defaults


class ExampleHook(BaseHook):
    """
    ExampleHook is an example hook for an Airflow plugin
    """

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

    def get_conn(self):
        print("I got your connection")


class ExamplePlugin(AirflowPlugin):
    """Example Plugin"""

    name = "example_plugin"
    hooks = [ExampleHook]
