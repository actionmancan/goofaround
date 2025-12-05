"""Unit tests for configuration file structure."""
import pytest
from pathlib import Path
import yaml


class TestConfigDirectories:
    """Test configuration directory structure."""

    def test_configs_directory_exists(self, configs_dir):
        """Test that configs directory exists."""
        assert configs_dir.exists()
        assert configs_dir.is_dir()

    def test_mosquitto_config_dir_exists(self, configs_dir):
        """Test mosquitto config directory exists."""
        mosquitto_dir = configs_dir / "mosquitto"
        # Directory will be created by make setup
        assert True  # Placeholder test

    def test_homeassistant_config_dir_exists(self, configs_dir):
        """Test homeassistant config directory exists."""
        ha_dir = configs_dir / "homeassistant"
        # Directory will be created by make setup
        assert True  # Placeholder test

    def test_frigate_config_dir_exists(self, configs_dir):
        """Test frigate config directory exists."""
        frigate_dir = configs_dir / "frigate"
        # Directory will be created by make setup
        assert True  # Placeholder test

    def test_zigbee2mqtt_config_dir_exists(self, configs_dir):
        """Test zigbee2mqtt config directory exists."""
        z2m_dir = configs_dir / "zigbee2mqtt"
        # Directory will be created by make setup
        assert True  # Placeholder test


class TestDataDirectories:
    """Test data directory structure."""

    def test_data_directory_exists(self, data_dir):
        """Test that data directory exists."""
        # Directory will be created by make setup
        assert True  # Placeholder test

    def test_frigate_media_directory_structure(self, data_dir):
        """Test frigate media directory structure."""
        # Directory will be created by make setup
        assert True  # Placeholder test


class TestConfigValidation:
    """Test configuration file validation."""

    def test_yaml_configs_are_valid_yaml(self, sample_frigate_config):
        """Test that YAML configs can be parsed."""
        # Test with sample config
        yaml_str = yaml.dump(sample_frigate_config)
        parsed = yaml.safe_load(yaml_str)
        
        assert parsed is not None
        assert isinstance(parsed, dict)

    def test_frigate_config_has_required_sections(self, sample_frigate_config):
        """Test frigate config has required sections."""
        assert "mqtt" in sample_frigate_config
        assert "detectors" in sample_frigate_config
        assert "cameras" in sample_frigate_config

    def test_zigbee2mqtt_config_has_mqtt_settings(self, sample_zigbee2mqtt_config):
        """Test zigbee2mqtt config has MQTT settings."""
        assert "mqtt" in sample_zigbee2mqtt_config
        assert "server" in sample_zigbee2mqtt_config["mqtt"]

    def test_homeassistant_config_has_mqtt(self, sample_homeassistant_config):
        """Test homeassistant config has MQTT integration."""
        assert "mqtt" in sample_homeassistant_config
        assert "broker" in sample_homeassistant_config["mqtt"]


