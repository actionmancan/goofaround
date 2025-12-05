"""Pytest configuration and shared fixtures."""
import os
import pytest
import yaml
from pathlib import Path


@pytest.fixture
def project_root():
    """Return the project root directory."""
    return Path(__file__).parent.parent


@pytest.fixture
def quadlets_dir(project_root):
    """Return the quadlets directory."""
    return project_root / "quadlets"


@pytest.fixture
def configs_dir(project_root):
    """Return the configs directory."""
    return project_root / "configs"


@pytest.fixture
def data_dir(project_root):
    """Return the data directory."""
    return project_root / "data"


@pytest.fixture
def mock_home_dir(tmp_path):
    """Create a mock home directory for testing."""
    return tmp_path / "home" / "testuser"


@pytest.fixture
def sample_quadlet_content():
    """Return sample quadlet file content."""
    return """[Unit]
Description=Test Container

[Container]
Image=docker.io/test:latest
ContainerName=test-container

[Service]
Restart=always

[Install]
WantedBy=default.target
"""


@pytest.fixture
def sample_mosquitto_config():
    """Return sample mosquitto config."""
    return """listener 1883
allow_anonymous false
password_file /mosquitto/config/password.txt
"""


@pytest.fixture
def sample_zigbee2mqtt_config():
    """Return sample zigbee2mqtt config."""
    return {
        "homeassistant": True,
        "permit_join": False,
        "mqtt": {
            "base_topic": "zigbee2mqtt",
            "server": "mqtt://homeserver-mosquitto:1883"
        },
        "serial": {
            "port": "/dev/ttyACM0"
        },
        "advanced": {
            "log_level": "info",
            "pan_id": 6754,
            "channel": 11
        },
        "frontend": {
            "port": 8080
        }
    }


@pytest.fixture
def sample_frigate_config():
    """Return sample frigate config."""
    return {
        "mqtt": {
            "host": "homeserver-mosquitto",
            "port": 1883
        },
        "detectors": {
            "cpu1": {
                "type": "cpu"
            }
        },
        "cameras": {
            "test_camera": {
                "ffmpeg": {
                    "inputs": [
                        {
                            "path": "rtsp://admin:password@192.168.1.100:554/stream",
                            "roles": ["detect", "record"]
                        }
                    ]
                },
                "detect": {
                    "width": 1920,
                    "height": 1080,
                    "fps": 5
                }
            }
        }
    }


@pytest.fixture
def sample_homeassistant_config():
    """Return sample Home Assistant config."""
    return {
        "default_config": {},
        "http": {
            "server_port": 8123
        },
        "mqtt": {
            "broker": "homeserver-mosquitto",
            "port": 1883
        }
    }


